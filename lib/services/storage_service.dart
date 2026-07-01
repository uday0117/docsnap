import 'dart:io';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../models/app_settings.dart';
import '../models/document_model.dart';
import '../models/signature_model.dart';
import '../utils/app_theme_mode.dart';
import '../utils/app_constants.dart';

/// Persistent storage backed by Hive with one-time migration from GetStorage.
class StorageService extends GetxService {
  static const _settingsBoxName = 'settings_box';
  static const _documentsBoxName = 'documents_box';
  static const _signaturesBoxName = 'signatures_box';
  static const _metaBoxName = 'meta_box';

  late Box _settingsBox;
  late Box _documentsBox;
  late Box _signaturesBox;
  late Box _metaBox;
  GetStorage? _legacyBox;

  Future<StorageService> init() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox(_settingsBoxName);
    _documentsBox = await Hive.openBox(_documentsBoxName);
    _signaturesBox = await Hive.openBox(_signaturesBoxName);
    _metaBox = await Hive.openBox(_metaBoxName);
    await _migrateFromGetStorageIfNeeded();
    return this;
  }

  Future<void> _migrateFromGetStorageIfNeeded() async {
    if (_metaBox.get(AppConstants.hiveMigrationDoneKey) == true) return;

    _legacyBox = GetStorage();
    await GetStorage.init();

    final legacySettingsRaw = _legacyBox!.read(AppConstants.darkModeKey);
    AppSettings settings;
    if (legacySettingsRaw is Map) {
      settings = AppSettings.fromJson(
        Map<String, dynamic>.from(legacySettingsRaw),
      );
    } else {
      final legacyLanguage = _legacyBox!.read('language') as String?;
      final legacyAutoCrop = _legacyBox!.read(AppConstants.autoCropKey);
      final legacyFilter = _legacyBox!.read(AppConstants.defaultFilterKey);
      final legacyQuality = _legacyBox!.read(AppConstants.pdfQualityKey);
      settings = AppSettings(
        language: legacyLanguage ?? 'English',
        themeMode: legacySettingsRaw == true
            ? AppThemeMode.dark
            : AppThemeMode.light,
        autoCrop: legacyAutoCrop is bool ? legacyAutoCrop : true,
        defaultFilter: legacyFilter is String
            ? legacyFilter
            : AppConstants.filterOriginal,
        defaultQuality: legacyQuality is String
            ? legacyQuality
            : AppConstants.qualityMedium,
      );
    }
    _settingsBox.put(AppConstants.darkModeKey, settings.toJson());

    final legacyDocs = _legacyBox!.read<List>(AppConstants.documentsKey);
    if (legacyDocs != null) {
      _documentsBox.put(AppConstants.documentsKey, legacyDocs);
    }

    final legacySigs = _legacyBox!.read<List>(AppConstants.savedSignaturesKey);
    if (legacySigs != null) {
      _signaturesBox.put(AppConstants.savedSignaturesKey, legacySigs);
    }

    for (final key in [
      AppConstants.cloudBackupProvidersKey,
      AppConstants.onboardingKey,
      AppConstants.qrHistoryKey,
      AppConstants.trashDocumentsKey,
      AppConstants.draftsKey,
    ]) {
      final value = _legacyBox!.read(key);
      if (value != null) {
        _metaBox.put(key, value);
      }
    }

    _metaBox.put(AppConstants.hiveMigrationDoneKey, true);
  }

  // Settings
  AppSettings readSettings() {
    final raw = _settingsBox.get(AppConstants.darkModeKey);
    if (raw == null) return const AppSettings();
    return AppSettings.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  void writeSettings(AppSettings settings) {
    _settingsBox.put(AppConstants.darkModeKey, settings.toJson());
  }

  bool readBool(String key, {bool defaultValue = false}) {
    return _metaBox.get(key, defaultValue: defaultValue) as bool;
  }

  void writeBool(String key, bool value) {
    _metaBox.put(key, value);
  }

  String readString(String key, {String defaultValue = ''}) {
    return _metaBox.get(key, defaultValue: defaultValue) as String;
  }

  void writeString(String key, String value) {
    _metaBox.put(key, value);
  }

  int readInt(String key, {int defaultValue = 0}) {
    final value = _metaBox.get(key, defaultValue: defaultValue);
    if (value is int) return value;
    if (value is num) return value.toInt();
    return defaultValue;
  }

  void writeInt(String key, int value) {
    _metaBox.put(key, value);
  }

  bool isOnboardingComplete() =>
      readBool(AppConstants.onboardingKey, defaultValue: false);

  void setOnboardingComplete(bool value) =>
      writeBool(AppConstants.onboardingKey, value);

  List<Map<String, dynamic>> readQrHistory() {
    final raw = _metaBox.get(AppConstants.qrHistoryKey);
    if (raw == null) return [];
    return (raw as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  void writeQrHistory(List<Map<String, dynamic>> history) {
    _metaBox.put(AppConstants.qrHistoryKey, history);
  }

  // Documents
  List<DocumentModel> readDocuments() {
    final raw = _documentsBox.get(AppConstants.documentsKey);
    if (raw == null) return [];
    return (raw as List)
        .map((e) => DocumentModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  void writeDocuments(List<DocumentModel> docs) {
    _documentsBox.put(
      AppConstants.documentsKey,
      docs.map((d) => d.toJson()).toList(),
    );
  }

  // Signatures
  List<SignatureModel> readSignatures() {
    final raw = _signaturesBox.get(AppConstants.savedSignaturesKey);
    if (raw == null) return [];
    return (raw as List)
        .map(
            (e) => SignatureModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  void writeSignatures(List<SignatureModel> sigs) {
    _signaturesBox.put(
      AppConstants.savedSignaturesKey,
      sigs.map((s) => s.toJson()).toList(),
    );
  }

  void remove(String key) {
    _metaBox.delete(key);
    _settingsBox.delete(key);
    _documentsBox.delete(key);
    _signaturesBox.delete(key);
  }

  Future<void> clearAll() async {
    await _settingsBox.clear();
    await _documentsBox.clear();
    await _signaturesBox.clear();
    await _metaBox.clear();
    await _clearLegacyGetStorage();
  }

  Future<void> _clearLegacyGetStorage() async {
    await GetStorage.init();
    await GetStorage().erase();
  }

  /// Deletes all app files and clears persisted storage.
  Future<void> clearAllData() async {
    final dir = await getApplicationDocumentsDirectory();
    final docsnapDir = Directory('${dir.path}/docsnap');
    if (await docsnapDir.exists()) {
      await docsnapDir.delete(recursive: true);
    }
    await clearAll();
  }
}
