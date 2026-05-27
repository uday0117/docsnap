class AppConstants {
  AppConstants._();

  static const String appName = 'DocSnap';
  static const String appSubtitle = 'PDF Scanner';
  static const String packageName = 'com.uksolutions.docsnap';

  // Storage keys
  static const String darkModeKey = 'dark_mode';
  static const String autoCropKey = 'auto_crop';
  static const String autoSaveKey = 'auto_save';
  static const String defaultFilterKey = 'default_filter';
  static const String pdfQualityKey = 'pdf_quality';
  static const String savedSignaturesKey = 'saved_signatures';
  static const String documentsKey = 'documents';
  static const String onboardingKey = 'onboarding_done';

  // Documents folder names
  static const List<String> defaultFolders = [
    'All Documents',
    'Invoices',
    'Receipts',
    'Personal',
    'Others',
  ];

  // Filter names
  static const String filterOriginal = 'Original';
  static const String filterBW = 'Black & White';
  static const String filterMagicColor = 'Magic Color';
  static const String filterGrayscale = 'Grayscale';
  static const String filterHighContrast = 'High Contrast';

  static const List<String> filters = [
    filterOriginal,
    filterBW,
    filterMagicColor,
    filterGrayscale,
    filterHighContrast,
  ];

  // PDF Quality
  static const String qualityLow = 'Low';
  static const String qualityMedium = 'Medium';
  static const String qualityHigh = 'High';

  static const List<String> pdfQualities = [
    qualityLow,
    qualityMedium,
    qualityHigh,
  ];

  // Routes
  static const String splashRoute = '/';
  static const String homeRoute = '/home';
  static const String scannerRoute = '/scanner';
  static const String cropEditorRoute = '/crop-editor';
  static const String filtersRoute = '/filters';
  static const String documentsRoute = '/documents';
  static const String pdfViewerRoute = '/pdf-viewer';
  static const String signatureRoute = '/signature';
  static const String settingsRoute = '/settings';
  static const String pdfGeneratorRoute = '/pdf-generator';

  // App version
  static const String appVersion = '1.0.0';
  static const String privacyPolicyUrl =
      'https://uksolutions.com/docsnap/privacy';
  static const String rateAppUrl =
      'https://play.google.com/store/apps/details?id=com.uksolutions.docsnap';
}
