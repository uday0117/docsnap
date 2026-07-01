import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_service.dart';

/// Adaptive banner ad shown at the bottom of key screens (Android only).
/// Uses a single shared [BannerAd] via [AdService]; only the topmost host
/// on the navigation stack mounts [AdWidget] to avoid duplicate-ad crashes.
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  final _hostToken = Object();
  late final AdService _adService;

  bool get _isAndroid => Platform.isAndroid;

  @override
  void initState() {
    super.initState();
    _adService = Get.find<AdService>();
    _adService.registerBannerHost(_hostToken);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isAndroid) {
      _adService.loadBannerAd(MediaQuery.sizeOf(context).width);
    }
  }

  @override
  void dispose() {
    _adService.unregisterBannerHost(_hostToken);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAndroid) return const SizedBox.shrink();

    return Obx(() {
      // Observe host changes and load state.
      _adService.bannerHostChanged.value;

      if (!_adService.shouldShowBanner(_hostToken)) {
        return const SizedBox.shrink();
      }

      final banner = _adService.bannerAd;
      if (banner == null) return const SizedBox.shrink();

      return ColoredBox(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1C1C1E)
            : Colors.white,
        child: SizedBox(
          width: double.infinity,
          height: banner.size.height.toDouble(),
          child: Center(
            child: SizedBox(
              width: banner.size.width.toDouble(),
              height: banner.size.height.toDouble(),
              child: AdWidget(
                key: ValueKey(banner.hashCode),
                ad: banner,
              ),
            ),
          ),
        ),
      );
    });
  }
}
