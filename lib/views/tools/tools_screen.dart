import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../controllers/main_shell_controller.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      _ToolItem(
        icon: Icons.document_scanner_rounded,
        label: 'scan_document'.tr,
        subtitle: 'camera_or_gallery'.tr,
        color: AppTheme.primaryColor,
        onTap: () => Get.toNamed(AppConstants.scannerRoute),
      ),
      _ToolItem(
        icon: Icons.photo_library_rounded,
        label: 'import_image'.tr,
        subtitle: 'from_gallery'.tr,
        color: const Color(0xFF6A1B9A),
        onTap: () => Get.toNamed(AppConstants.scannerRoute,
            arguments: {'openGallery': true}),
      ),
      _ToolItem(
        icon: Icons.qr_code_scanner_rounded,
        label: 'qr_scanner'.tr,
        subtitle: 'qr_scan_generate'.tr,
        color: const Color(0xFF00695C),
        onTap: () => Get.toNamed(AppConstants.qrScannerRoute),
      ),
      _ToolItem(
        icon: Icons.text_snippet_rounded,
        label: 'ocr_extract'.tr,
        subtitle: 'text_from_image'.tr,
        color: const Color(0xFFE65100),
        onTap: () => Get.toNamed(AppConstants.ocrRoute),
      ),
      _ToolItem(
        icon: Icons.merge_rounded,
        label: 'merge_pdfs'.tr,
        subtitle: 'combine_documents'.tr,
        color: const Color(0xFF880E4F),
        onTap: () => Get.toNamed(
          AppConstants.pdfToolsRoute,
          arguments: {'mode': 'merge'},
        ),
      ),
      _ToolItem(
        icon: Icons.call_split_rounded,
        label: 'split_pdf'.tr,
        subtitle: 'extract_pages'.tr,
        color: const Color(0xFF4A148C),
        onTap: () => Get.toNamed(
          AppConstants.pdfToolsRoute,
          arguments: {'mode': 'split'},
        ),
      ),
      _ToolItem(
        icon: Icons.draw_rounded,
        label: 'sign_pdf'.tr,
        subtitle: 'digital_signature'.tr,
        color: AppTheme.successColor,
        onTap: () => Get.toNamed(
          AppConstants.pdfToolsRoute,
          arguments: {'mode': 'sign'},
        ),
      ),
      _ToolItem(
        icon: Icons.water_rounded,
        label: 'watermark'.tr,
        subtitle: 'add_to_pdf'.tr,
        color: const Color(0xFF01579B),
        onTap: () => Get.toNamed(
          AppConstants.pdfToolsRoute,
          arguments: {'mode': 'watermark'},
        ),
      ),
      _ToolItem(
        icon: Icons.compress_rounded,
        label: 'compress_pdf'.tr,
        subtitle: 'reduce_file_size'.tr,
        color: const Color(0xFF33691E),
        onTap: () => Get.toNamed(
          AppConstants.pdfToolsRoute,
          arguments: {'mode': 'compress'},
        ),
      ),
      _ToolItem(
        icon: Icons.brush_rounded,
        label: 'annotate'.tr,
        subtitle: 'draw_shapes_text'.tr,
        color: const Color(0xFFC62828),
        onTap: () => Get.toNamed(AppConstants.annotationRoute),
      ),
      _ToolItem(
        icon: Icons.photo_size_select_large_rounded,
        label: 'image_tools'.tr,
        subtitle: 'resize_convert'.tr,
        color: const Color(0xFF4527A0),
        onTap: () => Get.toNamed(AppConstants.imageToolsRoute),
      ),
      _ToolItem(
        icon: Icons.cloud_upload_rounded,
        label: 'cloud_backup'.tr,
        subtitle: 'backup_restore'.tr,
        color: const Color(0xFF0277BD),
        onTap: () => Get.toNamed(AppConstants.cloudBackupRoute),
      ),
      _ToolItem(
        icon: Icons.share_rounded,
        label: 'my_documents'.tr,
        subtitle: 'browse_manage'.tr,
        color: AppTheme.warningColor,
        onTap: () => _switchShellTab(1),
      ),
      _ToolItem(
        icon: Icons.settings_rounded,
        label: 'settings'.tr,
        subtitle: 'app_preferences'.tr,
        color: const Color(0xFF455A64),
        onTap: () => _switchShellTab(3),
      ),
    ];

    return Scaffold(
      appBar: GradientAppBar(
        title: 'tools'.tr,
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final crossAxisCount = width < 380 ? 2 : 3;
                final childAspectRatio = crossAxisCount == 2 ? 1.0 : 0.82;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: childAspectRatio,
                  ),
                  itemCount: tools.length,
                  itemBuilder: (context, index) {
                    final tool = tools[index];
                    return _ToolCard(tool: tool, compact: crossAxisCount == 3)
                        .animate(delay: Duration(milliseconds: 40 * index))
                        .fadeIn(duration: 300.ms)
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          duration: 300.ms,
                          curve: Curves.easeOut,
                        );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _switchShellTab(int index) {
    if (Get.isRegistered<MainShellController>()) {
      Get.find<MainShellController>().switchToTab(index);
      return;
    }
    switch (index) {
      case 1:
        Get.toNamed(AppConstants.documentsRoute);
        break;
      case 3:
        Get.toNamed(AppConstants.settingsRoute);
        break;
      default:
        break;
    }
  }
}

class _ToolItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ToolItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _ToolCard extends StatelessWidget {
  final _ToolItem tool;
  final bool compact;

  const _ToolCard({required this.tool, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 40.0 : 44.0;
    final iconInnerSize = compact ? 22.0 : 24.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tool.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: tool.color.withAlpha(18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tool.color.withAlpha(40), width: 1),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 6 : 10,
              vertical: compact ? 8 : 12,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    color: tool.color,
                    borderRadius: BorderRadius.circular(compact ? 12 : 14),
                  ),
                  child: Icon(tool.icon, color: Colors.white, size: iconInnerSize),
                ),
                SizedBox(height: compact ? 6 : 8),
                Flexible(
                  child: Text(
                    tool.label,
                    style: TextStyle(
                      fontSize: compact ? 11 : 12,
                      fontWeight: FontWeight.w700,
                      color: tool.color,
                      height: 1.15,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    tool.subtitle,
                    style: TextStyle(
                      fontSize: compact ? 8 : 9,
                      color: Colors.grey.shade600,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
