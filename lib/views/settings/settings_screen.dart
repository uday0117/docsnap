import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/settings_controller.dart';
import '../../services/ad_service.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_helpers.dart';
import '../../utils/app_theme_mode.dart';
import '../../widgets/common_widgets.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: 'settings'.tr),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle(context, 'support_docsnap'.tr),
            _buildSettingsCard([
              _buildActionTile(
                icon: Icons.play_circle_outline_rounded,
                iconColor: Colors.deepOrange,
                title: 'watch_ad_support'.tr,
                subtitle: 'watch_ad_subtitle'.tr,
                onTap: () async {
                  AppHelpers.showLoading('loading_ad'.tr);
                  try {
                    await Get.find<AdService>().showRewardedAdIfReady();
                  } finally {
                    AppHelpers.hideLoading();
                  }
                },
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'language'.tr),
            _buildSettingsCard([
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: _iconBox(Icons.language_rounded, Colors.blue),
                title: Text('app_language'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(
                  'choose_language'.tr,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: DropdownButton<String>(
                  value: controller.settings.value.language,
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(12),
                  items: AppConstants.languages
                      .map((lang) => DropdownMenuItem(
                            value: lang,
                            child: Text(lang,
                                style: const TextStyle(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) controller.setLanguage(v);
                  },
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'appearance'.tr),
            _buildSettingsCard([
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: _iconBox(
                  switch (controller.themeMode) {
                    AppThemeMode.dark => Icons.dark_mode_rounded,
                    AppThemeMode.system => Icons.brightness_auto_rounded,
                    AppThemeMode.light => Icons.light_mode_rounded,
                  },
                  Colors.indigo,
                ),
                title: Text('theme_mode'.tr,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text('theme_mode_subtitle'.tr,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: DropdownButton<AppThemeMode>(
                  value: controller.themeMode,
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(12),
                  items: AppThemeMode.values
                      .map(
                        (mode) => DropdownMenuItem(
                          value: mode,
                          child: Text(
                            _themeModeLabel(mode),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (mode) {
                    if (mode != null) controller.setThemeMode(mode);
                  },
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'cloud_backup'.tr),
            _buildSettingsCard([
              _buildActionTile(
                icon: Icons.cloud_upload_rounded,
                iconColor: Colors.lightBlue,
                title: 'cloud_backup'.tr,
                subtitle: 'cloud_backup_subtitle'.tr,
                onTap: () => Get.toNamed(AppConstants.cloudBackupRoute),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'scanning_defaults'.tr),
            _buildSettingsCard([
              _buildActionTile(
                icon: Icons.filter_rounded,
                iconColor: Colors.purple,
                title: 'default_filter'.tr,
                trailing: DropdownButton<String>(
                  value: controller.defaultFilter,
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(12),
                  items: AppConstants.filters
                      .map((f) => DropdownMenuItem(
                            value: f,
                            child:
                                Text(f, style: const TextStyle(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) controller.setDefaultFilter(v);
                  },
                ),
              ),
              const Divider(height: 1, indent: 56),
              _buildActionTile(
                icon: Icons.high_quality_rounded,
                iconColor: Colors.teal,
                title: 'default_pdf_quality'.tr,
                trailing: DropdownButton<String>(
                  value: controller.defaultQuality,
                  underline: const SizedBox.shrink(),
                  borderRadius: BorderRadius.circular(12),
                  items: AppConstants.pdfQualities
                      .map((q) => DropdownMenuItem(
                            value: q,
                            child:
                                Text(q, style: const TextStyle(fontSize: 13)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) controller.setDefaultQuality(v);
                  },
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'share_support'.tr),
            _buildSettingsCard([
              _buildActionTile(
                icon: Icons.star_rate_rounded,
                iconColor: Colors.amber,
                title: 'rate_app'.tr,
                onTap: () async {
                  final url = Uri.parse(AppConstants.rateAppUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildActionTile(
                icon: Icons.share_rounded,
                iconColor: Colors.green,
                title: 'share_app'.tr,
                onTap: () {
                  Share.share(
                    'share_app_message'
                        .trParams({'url': AppConstants.rateAppUrl}),
                    subject: 'share_app_subject'.tr,
                  );
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildActionTile(
                icon: Icons.mail_outline_rounded,
                iconColor: Colors.blue,
                title: 'contact_support'.tr,
                onTap: _contactSupport,
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'about'.tr),
            _buildSettingsCard([
              _buildActionTile(
                icon: Icons.privacy_tip_outlined,
                iconColor: Colors.teal,
                title: 'privacy_policy'.tr,
                onTap: () => _launchUrl(AppConstants.privacyPolicyUrl),
              ),
              const Divider(height: 1, indent: 56),
              _buildActionTile(
                icon: Icons.description_outlined,
                iconColor: Colors.blue,
                title: 'terms_and_conditions'.tr,
                onTap: () => _launchUrl(AppConstants.termsUrl),
              ),
              const Divider(height: 1, indent: 56),
              _buildActionTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppTheme.primaryColor,
                title: 'app_version'.tr,
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'v${AppConstants.appVersion}',
                    style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'danger_zone'.tr),
            _buildSettingsCard([
              _buildActionTile(
                icon: Icons.delete_forever_rounded,
                iconColor: Colors.red,
                title: 'clear_all_data'.tr,
                titleColor: Colors.red,
                onTap: _confirmClearData,
              ),
            ]),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.document_scanner_rounded,
                        color: AppTheme.primaryColor, size: 30),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${AppConstants.appName} v${AppConstants.appVersion}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'copyright_notice'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? titleColor,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
      leading: _iconBox(icon, iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey))
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: Colors.grey)
              : null),
    );
  }

  String _themeModeLabel(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'theme_light'.tr;
      case AppThemeMode.dark:
        return 'theme_dark'.tr;
      case AppThemeMode.system:
        return 'theme_system'.tr;
    }
  }

  Future<void> _contactSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'apps.uksolutions@gmail.com',
      queryParameters: {
        'subject': 'DocSnap Support',
        'body': 'App Version: ${AppConstants.appVersion}',
      },
    );
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        AppHelpers.showSnackbar('could_not_open_email'.tr, isError: true);
      }
    } catch (_) {
      AppHelpers.showSnackbar('could_not_open_email'.tr, isError: true);
    }
  }

  Future<void> _launchUrl(String urlStr) async {
    final url = Uri.parse(urlStr);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      AppHelpers.showSnackbar('could_not_open_link'.tr, isError: true);
    }
  }

  void _confirmClearData() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('clear_all_data_title'.tr),
        content: Text('clear_all_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('clear_all_button'.tr,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      AppHelpers.showLoading('clearing_data'.tr);
      try {
        await controller.clearAllData();
        AppHelpers.hideLoading();
        Get.offAllNamed(AppConstants.splashRoute);
        AppHelpers.showSnackbar('all_data_cleared'.tr, title: 'cleared'.tr);
      } catch (e) {
        AppHelpers.hideLoading();
        AppHelpers.showSnackbar(
          'failed_clear_data'.trParams({'error': '$e'}),
          isError: true,
        );
      }
    }
  }
}
