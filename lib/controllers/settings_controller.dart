import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/app_settings.dart';
import '../services/storage_service.dart';

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
    _applyTheme(saved.darkMode);
  }

  void _applyTheme(bool isDark) {
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  String get language => settings.value.language;
  bool get isDarkMode => settings.value.darkMode;

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
  }

  void toggleDarkMode(bool value) {
    settings.value = settings.value.copyWith(darkMode: value);
    _saveSettings();
    _applyTheme(value);
  }

  void _saveSettings() {
    _storage.writeSettings(settings.value);
  }
}
