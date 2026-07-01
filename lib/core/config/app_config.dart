/// Application-wide configuration constants.
class AppConfig {
  AppConfig._();

  static const String appName = 'DocSnap';
  static const String storageNamespace = 'docsnap';
  static const int maxRecentDocuments = 6;
  static const int maxThumbnailWidth = 300;
  static const int interstitialMinActionInterval = 3;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);

  /// Minimum time between app-open ads on resume (Android).
  static const Duration appOpenAdCooldown = Duration(minutes: 20);

  /// Delay before showing app-open ad after reaching home (Android).
  static const Duration appOpenAdStartupDelay = Duration(milliseconds: 600);

  /// Never show interstitial ads during active scanning flows.
  static const Set<String> adFreeRoutes = {
    '/scanner',
    '/crop-editor',
    '/filters',
    '/qr-scanner',
  };

  /// Only show app-open ads when on these routes (Android).
  static const Set<String> appOpenAdRoutes = {
    '/home',
    '/pdf-viewer',
    '/ocr',
    '/pdf-tools',
    '/image-tools',
    '/annotation',
    '/cloud-backup',
  };
}
