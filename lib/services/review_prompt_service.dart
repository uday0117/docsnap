import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/analytics_service.dart';
import '../services/storage_service.dart';
import '../themes/app_theme.dart';
import '../utils/app_constants.dart';

/// Prompts users to rate or share the app after meaningful usage milestones.
class ReviewPromptService extends GetxService {
  static const _pdfCountKey = 'pdf_generated_count';
  static const _lastPromptKey = 'last_review_prompt_ms';
  static const _hasRatedKey = 'has_rated_app';

  static const _promptMilestones = [3, 8, 20];
  static const _promptCooldownDays = 14;

  StorageService get _storage => Get.find<StorageService>();

  void recordPdfGenerated() {
    final count = _storage.readInt(_pdfCountKey) + 1;
    _storage.writeInt(_pdfCountKey, count);
    _maybeShowPrompt(count);
  }

  void _maybeShowPrompt(int count) {
    if (!_promptMilestones.contains(count)) return;
    if (_storage.readBool(_hasRatedKey)) return;

    final lastMs = _storage.readInt(_lastPromptKey);
    if (lastMs > 0) {
      final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
      if (DateTime.now().difference(last).inDays < _promptCooldownDays) {
        return;
      }
    }

    _storage.writeInt(_lastPromptKey, DateTime.now().millisecondsSinceEpoch);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (Get.isDialogOpen == true) return;
      _showPromptDialog();
    });
  }

  void _showPromptDialog() {
    Get.dialog(
      _ReviewPromptDialog(
        onRate: _openStore,
        onShare: _shareApp,
        onLater: () {
          if (Get.isRegistered<AnalyticsService>()) {
            Get.find<AnalyticsService>().logEvent('review_prompt_dismissed');
          }
          Get.back();
        },
      ),
      barrierDismissible: true,
    );

    if (Get.isRegistered<AnalyticsService>()) {
      Get.find<AnalyticsService>().logEvent('review_prompt_shown');
    }
  }

  Future<void> _openStore() async {
    _storage.writeBool(_hasRatedKey, true);
    Get.back();

    final url = Uri.parse(AppConstants.rateAppUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }

    if (Get.isRegistered<AnalyticsService>()) {
      Get.find<AnalyticsService>().logEvent('review_prompt_rate_tapped');
    }
  }

  Future<void> _shareApp() async {
    Get.back();
    await Share.share(
      'share_app_message'.trParams({'url': AppConstants.rateAppUrl}),
      subject: 'share_app_subject'.tr,
    );

    if (Get.isRegistered<AnalyticsService>()) {
      Get.find<AnalyticsService>().logEvent('review_prompt_share_tapped');
    }
  }
}

class _ReviewPromptDialog extends StatelessWidget {
  final VoidCallback onRate;
  final VoidCallback onShare;
  final VoidCallback onLater;

  const _ReviewPromptDialog({
    required this.onRate,
    required this.onShare,
    required this.onLater,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.star_rounded,
                color: AppTheme.primaryColor,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'rate_prompt_title'.tr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'rate_prompt_message'.tr,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onRate,
                icon: const Icon(Icons.star_rate_rounded, size: 20),
                label: Text('rate_now'.tr),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_rounded, size: 18),
                label: Text('share_with_friends'.tr),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: onLater,
              child: Text('maybe_later'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
