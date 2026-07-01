import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/cloud_backup_controller.dart';
import '../../models/cloud_backup_model.dart';
import '../../themes/app_theme.dart';
import '../../widgets/ad_banner_widget.dart';
import '../../widgets/common_widgets.dart';

class CloudBackupScreen extends GetView<CloudBackupController> {
  const CloudBackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: 'cloud_backup'.tr),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              final busy = controller.isBusy;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'cloud_backup_subtitle'.tr,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  _ProviderCard(
                    provider: CloudProvider.googleDrive,
                    icon: Icons.cloud_rounded,
                    color: Colors.blue,
                    title: 'Google Drive',
                    connected: controller.accounts
                        .any((a) => a.provider == CloudProvider.googleDrive),
                    email: controller.accounts
                        .firstWhereOrNull((a) => a.provider == CloudProvider.googleDrive)
                        ?.email,
                    busy: busy,
                    onConnect: () => controller.connect(CloudProvider.googleDrive),
                    onDisconnect: () => controller.disconnect(CloudProvider.googleDrive),
                  ),
                  const SizedBox(height: 12),
                  _ProviderCard(
                    provider: CloudProvider.dropbox,
                    icon: Icons.folder_zip_rounded,
                    color: const Color(0xFF0061FF),
                    title: 'Dropbox',
                    connected: controller.accounts
                        .any((a) => a.provider == CloudProvider.dropbox),
                    email: controller.accounts
                        .firstWhereOrNull((a) => a.provider == CloudProvider.dropbox)
                        ?.email,
                    busy: busy,
                    onConnect: () => controller.connect(CloudProvider.dropbox),
                    onDisconnect: () => controller.disconnect(CloudProvider.dropbox),
                  ),
                  const SizedBox(height: 12),
                  _ProviderCard(
                    provider: CloudProvider.oneDrive,
                    icon: Icons.cloud_queue_rounded,
                    color: const Color(0xFF0078D4),
                    title: 'OneDrive',
                    connected: controller.accounts
                        .any((a) => a.provider == CloudProvider.oneDrive),
                    email: controller.accounts
                        .firstWhereOrNull((a) => a.provider == CloudProvider.oneDrive)
                        ?.email,
                    busy: busy,
                    onConnect: () => controller.connect(CloudProvider.oneDrive),
                    onDisconnect: () => controller.disconnect(CloudProvider.oneDrive),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: busy ? null : controller.backupNow,
                      icon: const Icon(Icons.cloud_upload_rounded),
                      label: Text('backup_now'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('cloud_restore_hint'.tr,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: CloudProvider.values.map((provider) {
                      final connected =
                          controller.accounts.any((a) => a.provider == provider);
                      return OutlinedButton(
                        onPressed: !connected || busy
                            ? null
                            : () => controller.restoreFrom(provider),
                        child: Text('${'restore'.tr} ${_providerLabel(provider)}'),
                      );
                    }).toList(),
                  ),
                ],
              );
            }),
          ),
          const AdBannerWidget(),
        ],
      ),
    );
  }

  String _providerLabel(CloudProvider provider) {
    switch (provider) {
      case CloudProvider.googleDrive:
        return 'Drive';
      case CloudProvider.dropbox:
        return 'Dropbox';
      case CloudProvider.oneDrive:
        return 'OneDrive';
    }
  }
}

class _ProviderCard extends StatelessWidget {
  final CloudProvider provider;
  final IconData icon;
  final Color color;
  final String title;
  final bool connected;
  final String? email;
  final bool busy;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const _ProviderCard({
    required this.provider,
    required this.icon,
    required this.color,
    required this.title,
    required this.connected,
    required this.email,
    required this.busy,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          connected ? (email ?? 'connected'.tr) : 'not_connected'.tr,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: connected
            ? TextButton(onPressed: busy ? null : onDisconnect, child: Text('disconnect'.tr))
            : ElevatedButton(
                onPressed: busy ? null : onConnect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text('connect'.tr),
              ),
      ),
    );
  }
}
