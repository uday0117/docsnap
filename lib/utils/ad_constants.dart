import 'dart:io';

class AdConstants {
  AdConstants._();

  static const String androidAppId = 'ca-app-pub-1451522103593938~2607261274';

  /// Banner Ad Unit ID

  static const String bannerAdUnitId = 'ca-app-pub-1451522103593938/6849758619';

  /// Interstitial Ad Unit ID
  static const String interstitialAdUnitId =
      'ca-app-pub-1451522103593938/2910513600';

  static void validatePlatform() {
    if (!Platform.isAndroid) {
      throw UnsupportedError('DocSnap currently supports Android ads only.');
    }
  }
}
