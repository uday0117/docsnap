import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/app_settings.dart';
import '../services/analytics_service.dart';
import '../services/cloud_backup_service.dart';
import '../services/storage_service.dart';
import '../utils/app_theme_mode.dart';

class SettingsController extends GetxController {
  final StorageService _storage;

  SettingsController(this._storage);

  final Rx<AppSettings> settings = const AppSettings().obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    final saved = _storage.readSettings();
    settings.value = saved;
    _applyTheme(saved.themeMode);
  }

  void _applyTheme(AppThemeMode mode) {
    Get.changeThemeMode(_toFlutterThemeMode(mode));
  }

  ThemeMode _toFlutterThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
    }
  }

  String get language => settings.value.language;
  AppThemeMode get themeMode => settings.value.themeMode;
  bool get isDarkMode => settings.value.darkMode;
  bool get autoCrop => settings.value.autoCrop;
  String get defaultFilter => settings.value.defaultFilter;
  String get defaultQuality => settings.value.defaultQuality;

  Locale getLocale() {
    return _languageToLocale(settings.value.language);
  }

  Locale _languageToLocale(String language) {
    switch (language) {
      case 'Spanish':
        return const Locale('es', 'ES');
      case 'French':
        return const Locale('fr', 'FR');
      case 'German':
        return const Locale('de', 'DE');
      case 'Italian':
        return const Locale('it', 'IT');
      case 'Portuguese':
        return const Locale('pt', 'PT');
      case 'Arabic':
        return const Locale('ar', 'SA');
      case 'Chinese':
        return const Locale('zh', 'CN');
      case 'Japanese':
        return const Locale('ja', 'JP');
      case 'Hindi':
        return const Locale('hi', 'IN');
      case 'English':
      default:
        return const Locale('en', 'US');
    }
  }

  void setLanguage(String lang) {
    settings.value = settings.value.copyWith(language: lang);
    _saveSettings();
    Get.updateLocale(_languageToLocale(lang));
    if (Get.isRegistered<AnalyticsService>()) {
      Get.find<AnalyticsService>().logLanguageChanged(lang);
    }
  }

  void setDefaultFilter(String filter) {
    settings.value = settings.value.copyWith(defaultFilter: filter);
    _saveSettings();
  }

  void setDefaultQuality(String quality) {
    settings.value = settings.value.copyWith(defaultQuality: quality);
    _saveSettings();
  }

  void setThemeMode(AppThemeMode mode) {
    settings.value = settings.value.copyWith(themeMode: mode);
    _saveSettings();
    _applyTheme(mode);
  }

  void toggleAutoCrop(bool value) {
    settings.value = settings.value.copyWith(autoCrop: value);
    _saveSettings();
  }

  Future<void> clearAllData() async {
    if (Get.isRegistered<CloudBackupService>()) {
      await Get.find<CloudBackupService>().disconnectAll();
    }
    await _storage.clearAllData();
    settings.value = const AppSettings();
    _applyTheme(AppThemeMode.light);
    Get.updateLocale(const Locale('en', 'US'));
  }

  void _saveSettings() {
    _storage.writeSettings(settings.value);
  }
}
