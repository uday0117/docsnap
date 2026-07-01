import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/cloud_backup_model.dart';
import '../models/document_model.dart';
import '../utils/app_constants.dart';
import 'storage_service.dart';

/// Cloud backup with Google Drive (OAuth), Dropbox, and OneDrive providers.
class CloudBackupService extends GetxService {
  static const _secure = FlutterSecureStorage();
  static const _docsnapFolder = 'DocSnap Backups';
  static const _backupVersion = 1;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
      'email',
    ],
  );

  final RxList<CloudAccount> connectedAccounts = <CloudAccount>[].obs;
  final RxBool isBusy = false.obs;

  Future<CloudBackupService> init() async {
    await _loadConnectedAccounts();
    return this;
  }

  Future<void> _loadConnectedAccounts() async {
    if (!Get.isRegistered<StorageService>()) return;
    final raw = Get.find<StorageService>().readString(
      AppConstants.cloudBackupProvidersKey,
    );
    if (raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List;
      connectedAccounts.value = list
          .map((e) => CloudAccount.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {}
  }

  Future<void> _persistAccounts() async {
    if (!Get.isRegistered<StorageService>()) return;
    Get.find<StorageService>().writeString(
      AppConstants.cloudBackupProvidersKey,
      jsonEncode(connectedAccounts.map((a) => a.toJson()).toList()),
    );
  }

  bool isConnected(CloudProvider provider) =>
      connectedAccounts.any((a) => a.provider == provider);

  Future<void> connectGoogleDrive() async {
    isBusy.value = true;
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) throw Exception('Sign-in cancelled.');

      final authClient = await _googleSignIn.authenticatedClient();
      if (authClient == null) {
        throw Exception('Could not authenticate with Google.');
      }

      connectedAccounts.removeWhere((a) => a.provider == CloudProvider.googleDrive);
      connectedAccounts.add(CloudAccount(
        provider: CloudProvider.googleDrive,
        email: account.email,
        connectedAt: DateTime.now(),
      ));
      await _persistAccounts();
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> connectDropbox() async {
    isBusy.value = true;
    try {
      var token = await _readToken('dropbox');
      if (token == null || token.isEmpty) {
        token = await _promptAccessToken('Dropbox');
        if (token == null || token.isEmpty) {
          throw Exception('Sign-in cancelled.');
        }
        await storeOAuthToken(CloudProvider.dropbox, token);
      }
      final email = await _dropboxAccountEmail(token);
      connectedAccounts.removeWhere((a) => a.provider == CloudProvider.dropbox);
      connectedAccounts.add(CloudAccount(
        provider: CloudProvider.dropbox,
        email: email,
        connectedAt: DateTime.now(),
      ));
      await _persistAccounts();
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> connectOneDrive() async {
    isBusy.value = true;
    try {
      var token = await _readToken('onedrive');
      if (token == null || token.isEmpty) {
        token = await _promptAccessToken('OneDrive');
        if (token == null || token.isEmpty) {
          throw Exception('Sign-in cancelled.');
        }
        await storeOAuthToken(CloudProvider.oneDrive, token);
      }
      final email = await _oneDriveAccountEmail(token);
      connectedAccounts.removeWhere((a) => a.provider == CloudProvider.oneDrive);
      connectedAccounts.add(CloudAccount(
        provider: CloudProvider.oneDrive,
        email: email,
        connectedAt: DateTime.now(),
      ));
      await _persistAccounts();
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> disconnect(CloudProvider provider) async {
    connectedAccounts.removeWhere((a) => a.provider == provider);
    await _persistAccounts();
    if (provider == CloudProvider.googleDrive) {
      await _googleSignIn.signOut();
    } else {
      await _secure.delete(key: '${provider.name}_token');
    }
  }

  Future<void> disconnectAll() async {
    for (final provider in CloudProvider.values) {
      if (isConnected(provider)) {
        await disconnect(provider);
      }
    }
  }

  Future<void> backupDocuments(List<DocumentModel> documents) async {
    if (connectedAccounts.isEmpty) {
      throw Exception('Connect a cloud account first.');
    }

    isBusy.value = true;
    try {
      final archiveBytes = await _buildBackupArchive(documents);
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'docsnap_backup_$timestamp.zip';

      for (final account in connectedAccounts) {
        switch (account.provider) {
          case CloudProvider.googleDrive:
            await _uploadToGoogleDrive(fileName, archiveBytes);
          case CloudProvider.dropbox:
            await _uploadToDropbox(fileName, archiveBytes);
          case CloudProvider.oneDrive:
            await _uploadToOneDrive(fileName, archiveBytes);
        }
      }
    } finally {
      isBusy.value = false;
    }
  }

  Future<List<DocumentModel>> restoreLatest(CloudProvider provider) async {
    isBusy.value = true;
    try {
      final payload = switch (provider) {
        CloudProvider.googleDrive => await _downloadLatestFromGoogleDrive(),
        CloudProvider.dropbox => await _downloadLatestFromDropbox(),
        CloudProvider.oneDrive => await _downloadLatestFromOneDrive(),
      };

      if (payload == null || payload.isEmpty) {
        throw Exception('No backup found in cloud.');
      }

      return _parseBackupPayload(payload);
    } finally {
      isBusy.value = false;
    }
  }

  Future<Uint8List> _buildBackupArchive(List<DocumentModel> documents) async {
    final archive = Archive();
    final manifestDocs = <Map<String, dynamic>>[];

    for (final doc in documents) {
      final docEntry = doc.toJson();
      final filesPrefix = 'files/${doc.id}';

      final pdfFile = File(doc.pdfPath);
      if (pdfFile.existsSync()) {
        const relPath = 'document.pdf';
        final fullRelPath = '$filesPrefix/$relPath';
        archive.addFile(
          ArchiveFile(
            fullRelPath,
            pdfFile.lengthSync(),
            pdfFile.readAsBytesSync(),
          ),
        );
        docEntry['pdfPath'] = fullRelPath;
      }

      final relPages = <String>[];
      for (var i = 0; i < doc.pageImagePaths.length; i++) {
        final imgFile = File(doc.pageImagePaths[i]);
        if (imgFile.existsSync()) {
          final relPath = '$filesPrefix/page_$i.jpg';
          archive.addFile(
            ArchiveFile(
              relPath,
              imgFile.lengthSync(),
              imgFile.readAsBytesSync(),
            ),
          );
          relPages.add(relPath);
        }
      }
      docEntry['pageImagePaths'] = relPages;

      if (doc.thumbnailPath != null) {
        final thumbFile = File(doc.thumbnailPath!);
        if (thumbFile.existsSync()) {
          final relPath = '$filesPrefix/thumb.jpg';
          archive.addFile(
            ArchiveFile(
              relPath,
              thumbFile.lengthSync(),
              thumbFile.readAsBytesSync(),
            ),
          );
          docEntry['thumbnailPath'] = relPath;
        }
      }

      manifestDocs.add(docEntry);
    }

    final manifest = jsonEncode({
      'version': _backupVersion,
      'documents': manifestDocs,
    });
    final manifestBytes = utf8.encode(manifest);
    archive.addFile(
      ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
    );

    final encoded = ZipEncoder().encode(archive);
    return Uint8List.fromList(encoded);
  }

  Future<List<DocumentModel>> _parseBackupPayload(Uint8List payload) async {
    if (_isZipArchive(payload)) {
      return _parseZipBackup(payload);
    }

    final text = utf8.decode(payload);
    final list = jsonDecode(text) as List;
    return list
        .map((e) => DocumentModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  bool _isZipArchive(Uint8List bytes) =>
      bytes.length >= 2 && bytes[0] == 0x50 && bytes[1] == 0x4B;

  Future<List<DocumentModel>> _parseZipBackup(Uint8List bytes) async {
    final archive = ZipDecoder().decodeBytes(bytes);
    ArchiveFile? manifestFile;
    for (final file in archive.files) {
      if (file.name == 'manifest.json') {
        manifestFile = file;
        break;
      }
    }
    if (manifestFile == null) {
      throw Exception('Invalid backup: missing manifest.');
    }

    final manifest =
        jsonDecode(utf8.decode(manifestFile.content as List<int>))
            as Map<String, dynamic>;
    final docsRaw = manifest['documents'] as List? ?? [];

    final appDir = await getApplicationDocumentsDirectory();
    final restoreDir = Directory(
      p.join(
        appDir.path,
        'docsnap',
        'restored_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
    await restoreDir.create(recursive: true);

    for (final file in archive.files) {
      if (!file.isFile || !file.name.startsWith('files/')) continue;
      final outFile = File(p.join(restoreDir.path, file.name));
      await outFile.parent.create(recursive: true);
      await outFile.writeAsBytes(file.content as List<int>);
    }

    final documents = <DocumentModel>[];
    for (final raw in docsRaw) {
      final map = Map<String, dynamic>.from(raw as Map);
      if (map['pdfPath'] is String) {
        map['pdfPath'] = p.join(restoreDir.path, map['pdfPath'] as String);
      }
      if (map['pageImagePaths'] is List) {
        map['pageImagePaths'] = (map['pageImagePaths'] as List)
            .map((path) => p.join(restoreDir.path, path as String))
            .toList();
      }
      if (map['thumbnailPath'] is String) {
        map['thumbnailPath'] =
            p.join(restoreDir.path, map['thumbnailPath'] as String);
      }
      documents.add(DocumentModel.fromJson(map));
    }
    return documents;
  }

  Future<void> _uploadToGoogleDrive(String fileName, Uint8List content) async {
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) throw Exception('Google Drive not connected.');

    final api = drive.DriveApi(client);
    final folderId = await _ensureGoogleDriveFolder(api);

    final media = drive.Media(
      Stream.value(content),
      content.length,
      contentType: 'application/zip',
    );
    await api.files.create(
      drive.File()
        ..name = fileName
        ..parents = [folderId],
      uploadMedia: media,
    );
  }

  Future<String> _ensureGoogleDriveFolder(drive.DriveApi api) async {
    final query =
        "mimeType='application/vnd.google-apps.folder' and name='$_docsnapFolder' and trashed=false";
    final existing = await api.files.list(q: query, spaces: 'drive');
    if (existing.files != null && existing.files!.isNotEmpty) {
      return existing.files!.first.id!;
    }

    final folder = await api.files.create(
      drive.File()
        ..name = _docsnapFolder
        ..mimeType = 'application/vnd.google-apps.folder',
    );
    return folder.id!;
  }

  Future<Uint8List?> _downloadLatestFromGoogleDrive() async {
    final client = await _googleSignIn.authenticatedClient();
    if (client == null) return null;

    final api = drive.DriveApi(client);
    final folderId = await _ensureGoogleDriveFolder(api);
    final list = await api.files.list(
      q: "'$folderId' in parents and trashed=false",
      orderBy: 'createdTime desc',
      pageSize: 1,
    );
    if (list.files == null || list.files!.isEmpty) return null;

    final fileId = list.files!.first.id!;
    final media = await api.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;
    final chunks = await media.stream.toList();
    return Uint8List.fromList(chunks.expand((b) => b).toList());
  }

  Future<void> _uploadToDropbox(String fileName, Uint8List content) async {
    final token = await _readToken('dropbox');
    if (token == null) throw Exception('Dropbox not connected.');

    final path = '/$_docsnapFolder/$fileName';
    final response = await http.post(
      Uri.parse('https://content.dropboxapi.com/2/files/upload'),
      headers: {
        'Authorization': 'Bearer $token',
        'Dropbox-API-Arg': jsonEncode({
          'path': path,
          'mode': 'add',
          'autorename': true,
        }),
        'Content-Type': 'application/octet-stream',
      },
      body: content,
    );
    if (response.statusCode >= 400) {
      throw Exception('Dropbox upload failed: ${response.body}');
    }
  }

  Future<Uint8List?> _downloadLatestFromDropbox() async {
    final token = await _readToken('dropbox');
    if (token == null) return null;

    final listResponse = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/files/list_folder'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'path': '/$_docsnapFolder', 'recursive': false}),
    );
    if (listResponse.statusCode >= 400) return null;

    final entries = (jsonDecode(listResponse.body)['entries'] as List?) ?? [];
    if (entries.isEmpty) return null;

    entries.sort((a, b) =>
        (b['client_modified'] as String).compareTo(a['client_modified'] as String));
    final path = entries.first['path_display'] as String;

    final download = await http.post(
      Uri.parse('https://content.dropboxapi.com/2/files/download'),
      headers: {
        'Authorization': 'Bearer $token',
        'Dropbox-API-Arg': jsonEncode({'path': path}),
      },
    );
    if (download.statusCode >= 400) return null;
    return Uint8List.fromList(download.bodyBytes);
  }

  Future<void> _uploadToOneDrive(String fileName, Uint8List content) async {
    final token = await _readToken('onedrive');
    if (token == null) throw Exception('OneDrive not connected.');

    final path = p.posix.join(_docsnapFolder, fileName);
    final response = await http.put(
      Uri.parse(
        'https://graph.microsoft.com/v1.0/me/drive/root:/$path:/content',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/zip',
      },
      body: content,
    );
    if (response.statusCode >= 400) {
      throw Exception('OneDrive upload failed: ${response.body}');
    }
  }

  Future<Uint8List?> _downloadLatestFromOneDrive() async {
    final token = await _readToken('onedrive');
    if (token == null) return null;

    final listResponse = await http.get(
      Uri.parse(
        'https://graph.microsoft.com/v1.0/me/drive/root:/$_docsnapFolder:/children',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (listResponse.statusCode >= 400) return null;

    final items = (jsonDecode(listResponse.body)['value'] as List?) ?? [];
    if (items.isEmpty) return null;

    items.sort((a, b) =>
        (b['lastModifiedDateTime'] as String).compareTo(a['lastModifiedDateTime'] as String));
    final downloadUrl = items.first['@microsoft.graph.downloadUrl'] as String?;

    if (downloadUrl == null) return null;
    final download = await http.get(Uri.parse(downloadUrl));
    if (download.statusCode >= 400) return null;
    return Uint8List.fromList(download.bodyBytes);
  }

  Future<String> _dropboxAccountEmail(String token) async {
    final response = await http.post(
      Uri.parse('https://api.dropboxapi.com/2/users/get_current_account'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode >= 400) {
      return 'Dropbox account';
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['email'] as String? ?? 'Dropbox account';
  }

  Future<String> _oneDriveAccountEmail(String token) async {
    final response = await http.get(
      Uri.parse('https://graph.microsoft.com/v1.0/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode >= 400) return 'OneDrive account';
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['userPrincipalName'] as String? ?? 'OneDrive account';
  }

  Future<String?> _readToken(String provider) =>
      _secure.read(key: '${provider}_token');

  Future<String?> _promptAccessToken(String providerName) async {
    final controller = TextEditingController();
    final token = await Get.dialog<String>(
      AlertDialog(
        title: Text('Connect $providerName'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Access token',
            hintText: 'Paste OAuth access token',
          ),
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Get.back(result: controller.text.trim()),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
    controller.dispose();
    return token;
  }

  /// Stores OAuth token after external auth flow completes.
  Future<void> storeOAuthToken(CloudProvider provider, String token) async {
    await _secure.write(key: '${provider.name}_token', value: token);
  }

  /// Helper for manual token setup during development / enterprise deployment.
  Future<void> configureProviderToken(
    CloudProvider provider,
    String token,
    String email,
  ) async {
    await storeOAuthToken(provider, token);
    connectedAccounts.removeWhere((a) => a.provider == provider);
    connectedAccounts.add(CloudAccount(
      provider: provider,
      email: email,
      connectedAt: DateTime.now(),
    ));
    await _persistAccounts();
  }
}
