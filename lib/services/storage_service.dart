import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../models/app_settings.dart';
import '../models/document_model.dart';
import '../models/signature_model.dart';
import '../utils/app_constants.dart';

class StorageService extends GetxService {
  late final GetStorage _box;

  Future<StorageService> init() async {
    await GetStorage.init();
    _box = GetStorage();
    return this;
  }

  // Settings
  AppSettings readSettings() {
    final raw = _box.read<Map<String, dynamic>>(AppConstants.darkModeKey);
    if (raw == null) return const AppSettings();
    return AppSettings.fromJson(raw);
  }

  void writeSettings(AppSettings settings) {
    _box.write(AppConstants.darkModeKey, settings.toJson());
  }

  bool readBool(String key, {bool defaultValue = false}) {
    return _box.read<bool>(key) ?? defaultValue;
  }

  void writeBool(String key, bool value) {
    _box.write(key, value);
  }

  String readString(String key, {String defaultValue = ''}) {
    return _box.read<String>(key) ?? defaultValue;
  }

  void writeString(String key, String value) {
    _box.write(key, value);
  }

  // Documents
  List<DocumentModel> readDocuments() {
    final raw = _box.read<List>(AppConstants.documentsKey);
    if (raw == null) return [];
    return raw
        .map((e) => DocumentModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  void writeDocuments(List<DocumentModel> docs) {
    _box.write(
      AppConstants.documentsKey,
      docs.map((d) => d.toJson()).toList(),
    );
  }

  // Signatures
  List<SignatureModel> readSignatures() {
    final raw = _box.read<List>(AppConstants.savedSignaturesKey);
    if (raw == null) return [];
    return raw
        .map(
            (e) => SignatureModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  void writeSignatures(List<SignatureModel> sigs) {
    _box.write(
      AppConstants.savedSignaturesKey,
      sigs.map((s) => s.toJson()).toList(),
    );
  }

  void remove(String key) => _box.remove(key);
  void clearAll() => _box.erase();
}
