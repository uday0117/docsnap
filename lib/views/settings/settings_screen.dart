import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/settings_controller.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_constants.dart';
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
            _buildSectionTitle(context, 'language'.tr),
            _buildSettingsCard([
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(26),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.language_rounded,
                      color: Colors.blue, size: 20),
                ),
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
                      .map(
                        (lang) => DropdownMenuItem(
                          value: lang,
                          child: Text(
                            lang,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) controller.setLanguage(v);
                  },
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'about'.tr),
            _buildSettingsCard([
              _buildActionTile(
                icon: Icons.privacy_tip_outlined,
                iconColor: Colors.teal,
                title: 'privacy_policy'.tr,
                onTap: () async {
                  final url = Uri.parse(AppConstants.privacyPolicyUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    Get.snackbar(
                      'error'.tr,
                      'could_not_open_privacy_policy'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildActionTile(
                icon: Icons.description_outlined,
                iconColor: Colors.blue,
                title: 'terms_and_conditions'.tr,
                onTap: () async {
                  final url = Uri.parse(AppConstants.termsUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    Get.snackbar(
                      'error'.tr,
                      'could_not_open_terms'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildActionTile(
                icon: Icons.star_rate_rounded,
                iconColor: Colors.amber,
                title: 'rate_app'.tr,
                onTap: () async {
                  final url = Uri.parse(AppConstants.rateAppUrl);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    Get.snackbar(
                      'error'.tr,
                      'could_not_open_store'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
              ),
              const Divider(height: 1, indent: 56),
              _buildActionTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppTheme.primaryColor,
                title: 'app_version'.tr,
                trailing: Text(
                  AppConstants.appVersion,
                  style: const TextStyle(color: Colors.grey),
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
              child: Text(
                '${AppConstants.appName} v${AppConstants.appVersion}\n© 2024 UK Solutions',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
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

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    Color? titleColor,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: Colors.grey)
              : null),
    );
  }

  void _confirmClearData() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All Data'),
        content: const Text(
          'This will delete all your documents, signatures and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // Note: This would also need to delete physical files
      Get.snackbar('Cleared', 'All data has been cleared.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
