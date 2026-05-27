class AppSettings {
  final bool darkMode;
  final bool autoCrop;
  final bool autoSave;
  final String defaultFilter;
  final String pdfQuality;

  const AppSettings({
    this.darkMode = false,
    this.autoCrop = true,
    this.autoSave = true,
    this.defaultFilter = 'Original',
    this.pdfQuality = 'High',
  });

  AppSettings copyWith({
    bool? darkMode,
    bool? autoCrop,
    bool? autoSave,
    String? defaultFilter,
    String? pdfQuality,
  }) {
    return AppSettings(
      darkMode: darkMode ?? this.darkMode,
      autoCrop: autoCrop ?? this.autoCrop,
      autoSave: autoSave ?? this.autoSave,
      defaultFilter: defaultFilter ?? this.defaultFilter,
      pdfQuality: pdfQuality ?? this.pdfQuality,
    );
  }

  Map<String, dynamic> toJson() => {
        'darkMode': darkMode,
        'autoCrop': autoCrop,
        'autoSave': autoSave,
        'defaultFilter': defaultFilter,
        'pdfQuality': pdfQuality,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        darkMode: (json['darkMode'] as bool?) ?? false,
        autoCrop: (json['autoCrop'] as bool?) ?? true,
        autoSave: (json['autoSave'] as bool?) ?? true,
        defaultFilter: (json['defaultFilter'] as String?) ?? 'Original',
        pdfQuality: (json['pdfQuality'] as String?) ?? 'High',
      );
}
