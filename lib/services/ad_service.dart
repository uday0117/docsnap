import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../utils/ad_constants.dart';

class AdService extends GetxService {
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;

  int _interstitialLoadAttempts = 0;
  static const int _maxLoadAttempts = 3;
  RewardedAd? _rewardedAd;

  Future<AdService> init() async {
    if (!_isMobilePlatform) return this;

    await MobileAds.instance.initialize();
    _loadInterstitialAd();
    _loadRewardedAd();

    return this;
  }

  bool get _isMobilePlatform =>
      !GetPlatform.isWeb && (Platform.isAndroid || Platform.isIOS);

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

  void _loadRewardedAd() {
    if (!_isMobilePlatform || _isRewardedLoading) return;

    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: AdConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;

          debugPrint('✅ Rewarded Ad Loaded');
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedLoading = false;

          debugPrint('❌ Rewarded Ad Failed');
          debugPrint(error.message);
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

  Future<void> showRewardedAdIfReady() async {
    if (!_isMobilePlatform) return;

    final ad = _rewardedAd;

    if (ad == null) {
      _loadRewardedAd();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();

        debugPrint('✅ Rewarded Ad Closed');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();

        debugPrint('❌ Rewarded Ad Show Failed');
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint(
          '🎁 Reward Earned: ${reward.amount} ${reward.type}',
        );
      },
    );

    _rewardedAd = null;
  }

  @override
  void onClose() {
    _interstitialAd?.dispose();
    super.onClose();
  }
}
