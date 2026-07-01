class AppConstants {
  AppConstants._();

  static const String appName = 'DocSnap';
  static const String appSubtitle = 'PDF Scanner & Document Manager';
  static const String packageName = 'com.uksolutions.docsnap';

  // Storage keys
  static const String darkModeKey = 'dark_mode';
  static const String autoCropKey = 'auto_crop';
  static const double idCardAspectRatio = 1.586;
  static const String autoSaveKey = 'auto_save';
  static const String defaultFilterKey = 'default_filter';
  static const String pdfQualityKey = 'pdf_quality';
  static const String savedSignaturesKey = 'saved_signatures';
  static const String documentsKey = 'documents';
  static const String onboardingKey = 'onboarding_done';
  static const String qrHistoryKey = 'qr_history';
  static const String lastAppOpenAdKey = 'last_app_open_ad_ms';

  // Documents folder names
  static const List<String> defaultFolders = [
    'All Documents',
    'Invoices',
    'Receipts',
    'Personal',
    'Work',
    'Medical',
    'Education',
    'Others',
  ];

  // Filter names
  static const String filterOriginal = 'Original';
  static const String filterAutoEnhance = 'Auto Enhance';
  static const String filterMagicColor = 'Magic Color';
  static const String filterBW = 'Black & White';
  static const String filterGrayscale = 'Grayscale';
  static const String filterColor = 'Color';
  static const String filterDocument = 'Document';
  static const String filterReceipt = 'Receipt';
  static const String filterHighContrast = 'High Contrast';

  static const List<String> filters = [
    filterOriginal,
    filterAutoEnhance,
    filterMagicColor,
    filterBW,
    filterGrayscale,
    filterColor,
    filterDocument,
    filterReceipt,
    filterHighContrast,
  ];

  // PDF page sizes
  static const String pageSizeA4 = 'A4';
  static const String pageSizeLetter = 'Letter';
  static const String pageSizeLegal = 'Legal';
  static const String pageSizeCustom = 'Custom';

  static const List<String> pageSizes = [
    pageSizeA4,
    pageSizeLetter,
    pageSizeLegal,
    pageSizeCustom,
  ];

  // Storage keys (extended)
  static const String cloudBackupProvidersKey = 'cloud_backup_providers';
  static const String hiveMigrationDoneKey = 'hive_migration_done';
  static const String defaultFilenameKey = 'default_filename';
  static const String trashDocumentsKey = 'trash_documents';
  static const String draftsKey = 'scan_drafts';

  // PDF Quality
  static const String qualityLow = 'Low';
  static const String qualityMedium = 'Medium';
  static const String qualityHigh = 'High';

  static const List<String> pdfQualities = [
    qualityLow,
    qualityMedium,
    qualityHigh,
  ];

  // Languages
  static const List<String> languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Arabic',
    'Chinese',
    'Japanese',
    'Hindi',
  ];

  // Routes
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String homeRoute = '/home';
  static const String scannerRoute = '/scanner';
  static const String cropEditorRoute = '/crop-editor';
  static const String filtersRoute = '/filters';
  static const String documentsRoute = '/documents';
  static const String pdfViewerRoute = '/pdf-viewer';
  static const String signatureRoute = '/signature';
  static const String settingsRoute = '/settings';
  static const String pdfGeneratorRoute = '/pdf-generator';
  static const String toolsRoute = '/tools';
  static const String qrScannerRoute = '/qr-scanner';
  static const String ocrRoute = '/ocr';
  static const String pdfToolsRoute = '/pdf-tools';
  static const String imageToolsRoute = '/image-tools';
  static const String annotationRoute = '/annotation';
  static const String cloudBackupRoute = '/cloud-backup';

  // App version (keep in sync with pubspec.yaml)
  static const String appVersion = '1.0.4';

  // URLs
  static const String privacyPolicyUrl =
      'https://uday0117.github.io/docsnap/privacy_policy.html';
  static const String termsUrl =
      'https://uday0117.github.io/docsnap/terms_and_conditions.html';
  static const String rateAppUrl =
      'https://play.google.com/store/apps/details?id=com.uksolutions.docsnap';

}
