class AppSettings {
  final String language;
  final bool darkMode;

  const AppSettings({
    this.language = 'English',
    this.darkMode = false,
  });

  AppSettings copyWith({
    String? language,
    bool? darkMode,
  }) {
    return AppSettings(
      language: language ?? this.language,
      darkMode: darkMode ?? this.darkMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'language': language,
        'darkMode': darkMode,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        language: (json['language'] as String?) ?? 'English',
        darkMode: (json['darkMode'] as bool?) ?? false,
      );
}
