import '../utils/app_constants.dart';
import '../utils/app_theme_mode.dart';

class AppSettings {
  final String language;
  final AppThemeMode themeMode;
  final bool autoCrop;
  final String defaultFilter;
  final String defaultQuality;

  const AppSettings({
    this.language = 'English',
    this.themeMode = AppThemeMode.light,
    this.autoCrop = true,
    this.defaultFilter = AppConstants.filterOriginal,
    this.defaultQuality = AppConstants.qualityMedium,
  });

  /// Legacy compatibility for code that still reads a boolean dark flag.
  bool get darkMode => themeMode == AppThemeMode.dark;

  AppSettings copyWith({
    String? language,
    AppThemeMode? themeMode,
    bool? autoCrop,
    String? defaultFilter,
    String? defaultQuality,
  }) {
    return AppSettings(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      autoCrop: autoCrop ?? this.autoCrop,
      defaultFilter: defaultFilter ?? this.defaultFilter,
      defaultQuality: defaultQuality ?? this.defaultQuality,
    );
  }

  Map<String, dynamic> toJson() => {
        'language': language,
        'themeMode': themeMode.storageValue,
        'autoCrop': autoCrop,
        'defaultFilter': defaultFilter,
        'defaultQuality': defaultQuality,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    AppThemeMode themeMode;
    final themeModeRaw = json['themeMode'] as String?;
    if (themeModeRaw != null) {
      themeMode = AppThemeMode.fromString(themeModeRaw);
    } else {
      final legacyDark = (json['darkMode'] as bool?) ?? false;
      themeMode = legacyDark ? AppThemeMode.dark : AppThemeMode.light;
    }

    return AppSettings(
      language: (json['language'] as String?) ?? 'English',
      themeMode: themeMode,
      autoCrop: (json['autoCrop'] as bool?) ?? true,
      defaultFilter:
          (json['defaultFilter'] as String?) ?? AppConstants.filterOriginal,
      defaultQuality:
          (json['defaultQuality'] as String?) ?? AppConstants.qualityMedium,
    );
  }
}
