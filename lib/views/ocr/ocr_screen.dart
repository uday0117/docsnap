import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/ocr_controller.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../widgets/ad_banner_widget.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/empty_state.dart';

class OcrScreen extends GetView<OcrController> {
  const OcrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'ocr_title'.tr,
        actions: [
          Obx(
            () => controller.extractedText.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.copy_rounded),
                    onPressed: controller.copyText,
                    tooltip: 'copy_text_tooltip'.tr,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isProcessing.value) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text('extracting_text'.tr),
                    ],
                  ),
                );
              }

              if (controller.extractedText.value.isNotEmpty) {
                return _buildResultView(context);
              }

              return _buildSourcePicker(context);
            }),
          ),
          const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildSourcePicker(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SourceCard(
          icon: Icons.camera_alt_rounded,
          label: 'take_photo'.tr,
          subtitle: 'capture_text_camera'.tr,
          color: AppTheme.primaryColor,
          onTap: controller.pickFromCamera,
        ),
        const SizedBox(height: 12),
        _SourceCard(
          icon: Icons.photo_library_rounded,
          label: 'choose_from_gallery'.tr,
          subtitle: 'pick_image_text'.tr,
          color: const Color(0xFF6A1B9A),
          onTap: controller.pickFromGallery,
        ),
        const SizedBox(height: 24),
        SectionHeader(title: 'or_extract_document'.tr),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.documents.isEmpty) {
            return EmptyState(
              icon: Icons.description_outlined,
              title: 'no_documents'.tr,
              subtitle: 'scan_first_ocr'.tr,
              actionLabel: 'scan_document'.tr,
              onAction: () => Get.toNamed(AppConstants.scannerRoute),
            );
          }

          return Column(
            children: controller.documents.map((doc) {
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ExpansionTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 40,
                      height: 48,
                      child: doc.thumbnailPath != null &&
                              File(doc.thumbnailPath!).existsSync()
                          ? Image.file(
                              File(doc.thumbnailPath!),
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.red.shade50,
                              child: Icon(Icons.picture_as_pdf,
                                  color: Colors.red.shade400, size: 20),
                            ),
                    ),
                  ),
                  title: Text(
                    doc.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('pages_count'.trParams(
                      {'count': '${doc.pageCount}'})),
                  children: List.generate(doc.pageCount, (index) {
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            AppTheme.primaryColor.withAlpha(30),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      title: Text('page_n'.trParams({'n': '${index + 1}'})),
                      trailing: const Icon(Icons.text_snippet_outlined),
                      onTap: () =>
                          controller.extractFromDocumentPage(doc, index),
                    );
                  }),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildResultView(BuildContext context) {
    return Column(
      children: [
        if (controller.imagePath.value.isNotEmpty)
          Container(
            height: 160,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.withAlpha(50)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(
                File(controller.imagePath.value),
                fit: BoxFit.contain,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'extracted_text'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: controller.clearResult,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('new_scan'.tr),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.withAlpha(60)),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                controller.extractedText.value,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.copyText,
                  icon: const Icon(Icons.copy_rounded),
                  label: Text('copy'.tr),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Share.share(controller.extractedText.value),
                  icon: const Icon(Icons.share_rounded),
                  label: Text('share'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SourceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _SourceCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: color.withAlpha(18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(45)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
