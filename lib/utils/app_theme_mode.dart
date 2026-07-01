enum AppThemeMode {
  light,
  dark,
  system;

  static AppThemeMode fromString(String? value) {
    switch (value) {
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
        return AppThemeMode.system;
      case 'light':
      default:
        return AppThemeMode.light;
    }
  }

  String get storageValue => name;
}
