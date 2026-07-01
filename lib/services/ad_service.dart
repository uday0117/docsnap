import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/config/app_config.dart';
import '../services/analytics_service.dart';
import '../services/storage_service.dart';
import '../utils/ad_constants.dart';
import '../utils/app_constants.dart';
import '../utils/app_helpers.dart';

class AdService extends GetxService {
  InterstitialAd? _interstitialAd;
  AppOpenAd? _appOpenAd;
  BannerAd? _bannerAd;
  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;
  bool _isAppOpenLoading = false;
  bool _isBannerLoading = false;
  bool _isShowingFullScreenAd = false;
  bool _sessionColdStartAdAttempted = false;

  final bannerLoaded = false.obs;
  final _bannerHosts = <Object>[];
  final bannerHostChanged = 0.obs;
  bool _bannerHostNotifyPending = false;

  int _interstitialLoadAttempts = 0;
  static const int _maxLoadAttempts = 3;
  int _actionCount = 0;
  RewardedAd? _rewardedAd;

  Future<AdService> init() async {
    if (!_isAndroid) return this;

    await MobileAds.instance.initialize();
    _loadInterstitialAd();
    _loadRewardedAd();
    _loadAppOpenAd();

    return this;
  }

  bool get _isAndroid => !GetPlatform.isWeb && Platform.isAndroid;

  BannerAd? get bannerAd => bannerLoaded.value ? _bannerAd : null;

  void registerBannerHost(Object token) {
    _bannerHosts.remove(token);
    _bannerHosts.add(token);
    _notifyBannerHostsChanged();
  }

  void unregisterBannerHost(Object token) {
    if (_bannerHosts.remove(token)) {
      _notifyBannerHostsChanged();
    }
  }

  void _notifyBannerHostsChanged() {
    if (_bannerHostNotifyPending) return;
    _bannerHostNotifyPending = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _bannerHostNotifyPending = false;
      bannerHostChanged.value++;
    });
  }

  bool shouldShowBanner(Object token) =>
      _bannerHosts.isNotEmpty && _bannerHosts.last == token;

  Future<void> loadBannerAd(double width) async {
    if (!_isAndroid || _isBannerLoading || _bannerAd != null) return;

    _isBannerLoading = true;
    final size =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width.truncate());
    if (size == null) {
      _isBannerLoading = false;
      return;
    }

    final banner = BannerAd(
      adUnitId: AdConstants.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          bannerLoaded.value = true;
          _isBannerLoading = false;
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: ${error.message}');
          ad.dispose();
          _bannerAd = null;
          bannerLoaded.value = false;
          _isBannerLoading = false;
          Future.delayed(const Duration(seconds: 10), () {
            if (_bannerAd == null && !_isBannerLoading) {
              loadBannerAd(width);
            }
          });
        },
      ),
    );

    _bannerAd = banner;
    await banner.load();
    if (!bannerLoaded.value) {
      _bannerAd = null;
      _isBannerLoading = false;
    }
  }

  void _loadAppOpenAd() {
    if (!_isAndroid || _isAppOpenLoading || _appOpenAd != null) return;

    _isAppOpenLoading = true;
    AppOpenAd.load(
      adUnitId: AdConstants.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAppOpenLoading = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (_) {
              _isShowingFullScreenAd = true;
            },
            onAdDismissedFullScreenContent: (ad) {
              _isShowingFullScreenAd = false;
              ad.dispose();
              _appOpenAd = null;
              _loadAppOpenAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('App open ad failed to show: ${error.message}');
              _isShowingFullScreenAd = false;
              ad.dispose();
              _appOpenAd = null;
              _loadAppOpenAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('App open ad failed to load: ${error.message}');
          _isAppOpenLoading = false;
          _appOpenAd = null;
          Future.delayed(const Duration(seconds: 30), _loadAppOpenAd);
        },
      ),
    );
  }

  Future<void> showAppOpenAdOnColdStart() async {
    if (!_isAndroid || _sessionColdStartAdAttempted) return;
    _sessionColdStartAdAttempted = true;

    await Future.delayed(AppConfig.appOpenAdStartupDelay);
    await _showAppOpenAdIfAllowed();
  }

  Future<void> showAppOpenAdOnResume() async {
    if (!_isAndroid) return;
    if (!_isCooldownElapsed()) return;
    await _showAppOpenAdIfAllowed();
  }

  bool _isCooldownElapsed() {
    if (!Get.isRegistered<StorageService>()) return true;

    final lastMs =
        Get.find<StorageService>().readInt(AppConstants.lastAppOpenAdKey);
    if (lastMs <= 0) return true;

    final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
    return DateTime.now().difference(last) >= AppConfig.appOpenAdCooldown;
  }

  Future<void> _showAppOpenAdIfAllowed() async {
    if (!_isAndroid) return;
    if (_isShowingFullScreenAd) return;
    if (!AppConfig.appOpenAdRoutes.contains(Get.currentRoute)) return;

    final ad = _appOpenAd;
    if (ad == null) {
      _loadAppOpenAd();
      return;
    }

    _recordAppOpenShown();
    await ad.show();
    if (Get.isRegistered<AnalyticsService>()) {
      await Get.find<AnalyticsService>().logAdWatched('app_open');
    }
    _appOpenAd = null;
  }

  void _recordAppOpenShown() {
    if (Get.isRegistered<StorageService>()) {
      Get.find<StorageService>().writeInt(
        AppConstants.lastAppOpenAdKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  void _loadInterstitialAd() {
    if (!_isAndroid || _isInterstitialLoading) return;

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
            onAdShowedFullScreenContent: (_) {
              _isShowingFullScreenAd = true;
            },
            onAdDismissedFullScreenContent: (ad) {
              _isShowingFullScreenAd = false;
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              _isShowingFullScreenAd = false;
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
    if (!_isAndroid || _isRewardedLoading) return;

    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: AdConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          debugPrint('Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedLoading = false;
          debugPrint('Rewarded ad failed: ${error.message}');
          Future.delayed(const Duration(seconds: 5), _loadRewardedAd);
        },
      ),
    );
  }

  Future<void> showInterstitialIfReady() async {
    if (!_isAndroid || _isShowingFullScreenAd) return;

    final ad = _interstitialAd;
    if (ad == null) {
      _loadInterstitialAd();
      return;
    }

    await ad.show();
    if (Get.isRegistered<AnalyticsService>()) {
      await Get.find<AnalyticsService>().logAdWatched('interstitial');
    }
    _interstitialAd = null;
  }

  /// Shows an interstitial every [AppConfig.interstitialMinActionInterval] calls.
  Future<void> maybeShowInterstitialOnAction() async {
    if (!_isAndroid) return;
    if (AppConfig.adFreeRoutes.contains(Get.currentRoute)) return;

    _actionCount++;
    if (_actionCount >= AppConfig.interstitialMinActionInterval) {
      _actionCount = 0;
      await showInterstitialIfReady();
    }
  }

  Future<void> showRewardedAdIfReady() async {
    if (!_isAndroid) return;

    final ad = _rewardedAd;
    if (ad == null) {
      _loadRewardedAd();
      AppHelpers.showSnackbar('ad_not_ready'.tr, isError: true);
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        _isShowingFullScreenAd = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingFullScreenAd = false;
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingFullScreenAd = false;
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
      },
    );

    ad.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('Reward earned: ${reward.amount} ${reward.type}');
        if (Get.isRegistered<AnalyticsService>()) {
          Get.find<AnalyticsService>().logAdWatched('rewarded');
        }
      },
    );

    _rewardedAd = null;
  }

  @override
  void onClose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _appOpenAd?.dispose();
    _bannerAd?.dispose();
    _bannerAd = null;
    super.onClose();
  }
}
