import 'dart:io';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../utils/ad_constants.dart';

class AdService extends GetxService {
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;
  int _interstitialLoadAttempts = 0;
  static const int _maxLoadAttempts = 3;

  Future<AdService> init() async {
    if (!_isMobilePlatform) return this;

    await MobileAds.instance.initialize();
    _loadInterstitialAd();
    return this;
  }

  bool get _isMobilePlatform =>
      !GetPlatform.isWeb &&
      (Platform.isAndroid || Platform.isIOS);

  void _loadInterstitialAd() {
    if (!_isMobilePlatform || _isInterstitialLoading) return;

    _isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: AdConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
          _isInterstitialLoading = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoading = false;
          _interstitialLoadAttempts++;
          _interstitialAd = null;
          if (_interstitialLoadAttempts < _maxLoadAttempts) {
            Future.delayed(const Duration(seconds: 5), _loadInterstitialAd);
          }
        },
      ),
    );
  }

  /// Shows an interstitial after key actions (e.g. PDF saved).
  Future<void> showInterstitialIfReady() async {
    if (!_isMobilePlatform) return;

    final ad = _interstitialAd;
    if (ad == null) {
      _loadInterstitialAd();
      return;
    }

    await ad.show();
    _interstitialAd = null;
  }

  @override
  void onClose() {
    _interstitialAd?.dispose();
    super.onClose();
  }
}
