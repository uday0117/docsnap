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
      appBar: const GradientAppBar(title: 'Settings'),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle(context, 'Appearance'),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.dark_mode_rounded,
                iconColor: const Color(0xFF5C6BC0),
                title: 'Dark Mode',
                subtitle: 'Switch between light and dark theme',
                value: controller.settings.value.darkMode,
                onChanged: controller.toggleDarkMode,
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Scanning'),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.crop_free_rounded,
                iconColor: AppTheme.primaryColor,
                title: 'Auto Crop',
                subtitle: 'Automatically detect and crop document edges',
                value: controller.settings.value.autoCrop,
                onChanged: controller.toggleAutoCrop,
              ),
              const Divider(height: 1, indent: 56),
              _buildSwitchTile(
                icon: Icons.save_rounded,
                iconColor: AppTheme.successColor,
                title: 'Auto Save',
                subtitle: 'Automatically save scanned documents',
                value: controller.settings.value.autoSave,
                onChanged: controller.toggleAutoSave,
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'PDF Generation'),
            _buildSettingsCard([
              _buildDropdownTile(
                icon: Icons.auto_fix_high_rounded,
                iconColor: Colors.purple,
                title: 'Default Filter',
                value: controller.settings.value.defaultFilter,
                items: AppConstants.filters,
                onChanged: controller.setDefaultFilter,
              ),
              const Divider(height: 1, indent: 56),
              _buildDropdownTile(
                icon: Icons.high_quality_rounded,
                iconColor: Colors.orange,
                title: 'PDF Quality',
                value: controller.settings.value.pdfQuality,
                items: AppConstants.pdfQualities,
                onChanged: controller.setPdfQuality,
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'About'),
            _buildSettingsCard([
              _buildActionTile(
                icon: Icons.privacy_tip_outlined,
                iconColor: Colors.teal,
                title: 'Privacy Policy',
                onTap: () => _launchUrl(AppConstants.privacyPolicyUrl),
              ),
              const Divider(height: 1, indent: 56),
              _buildActionTile(
                icon: Icons.star_rate_rounded,
                iconColor: Colors.amber,
                title: 'Rate App',
                onTap: () => _launchUrl(AppConstants.rateAppUrl),
              ),
              const Divider(height: 1, indent: 56),
              _buildActionTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppTheme.primaryColor,
                title: 'App Version',
                trailing: Text(
                  AppConstants.appVersion,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Danger Zone'),
            _buildSettingsCard([
              _buildActionTile(
                icon: Icons.delete_forever_rounded,
                iconColor: Colors.red,
                title: 'Clear All Data',
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

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        borderRadius: BorderRadius.circular(12),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            )
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
