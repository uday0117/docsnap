import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';
import '../utils/app_constants.dart';

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

  bool get isDarkMode => settings.value.darkMode;
  bool get autoCrop => settings.value.autoCrop;
  bool get autoSave => settings.value.autoSave;
  String get defaultFilter => settings.value.defaultFilter;
  String get pdfQuality => settings.value.pdfQuality;

  void toggleDarkMode(bool value) {
    settings.value = settings.value.copyWith(darkMode: value);
    _saveSettings();
    _applyTheme(value);
  }

  void toggleAutoCrop(bool value) {
    settings.value = settings.value.copyWith(autoCrop: value);
    _saveSettings();
  }

  void toggleAutoSave(bool value) {
    settings.value = settings.value.copyWith(autoSave: value);
    _saveSettings();
  }

  void setDefaultFilter(String filter) {
    settings.value = settings.value.copyWith(defaultFilter: filter);
    _saveSettings();
  }

  void setPdfQuality(String quality) {
    settings.value = settings.value.copyWith(pdfQuality: quality);
    _saveSettings();
  }

  void _saveSettings() {
    _storage.writeSettings(settings.value);
  }
}
