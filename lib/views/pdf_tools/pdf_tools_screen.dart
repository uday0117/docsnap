import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/pdf_tools_controller.dart';
import '../../models/document_model.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_helpers.dart';
import '../../widgets/ad_banner_widget.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/empty_state.dart';

class PdfToolsScreen extends GetView<PdfToolsController> {
  const PdfToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: controller.modeTitle,
        subtitle: controller.modeSubtitle,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.allDocuments.isEmpty) {
                return EmptyState(
                  icon: Icons.folder_open_rounded,
                  title: 'no_documents_tool'.tr,
                  subtitle: 'scan_first_tool'.tr,
                  actionLabel: 'scan_document'.tr,
                  onAction: () => Get.toNamed(AppConstants.scannerRoute),
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withAlpha(40),
                      ),
                    ),
                    child: Text(
                      controller.modeSubtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.35,
                      ),
                    ),
                  ),
                  if (controller.mode != PdfToolMode.sign) ...[
                    _buildOutputSection(context),
                    const SizedBox(height: 16),
                  ],
                  if (controller.mode == PdfToolMode.watermark)
                    _buildWatermarkField(context),
                  if (controller.mode == PdfToolMode.compress ||
                      controller.mode == PdfToolMode.merge)
                    _buildQualitySelector(context),
                  if (controller.mode == PdfToolMode.split &&
                      controller.splitSource.value != null)
                    _buildPageSelector(context),
                  const SizedBox(height: 8),
                  Text(
                    controller.mode == PdfToolMode.merge
                        ? 'select_documents'.trParams({
                            'count': '${controller.selectedDocIds.length}',
                          })
                        : 'select_document'.tr,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ...controller.allDocuments.map(_buildDocumentTile),
                ],
              );
            }),
          ),
          _buildBottomBar(context),
          const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildOutputSection(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: TextField(
          controller: controller.nameController,
          decoration: InputDecoration(
            labelText: 'output_file_name'.tr,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ),
    );
  }

  Widget _buildWatermarkField(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: TextField(
          controller: controller.watermarkController,
          decoration: InputDecoration(
            labelText: 'watermark_text'.tr,
            hintText: 'watermark_hint'.tr,
            border: const OutlineInputBorder(),
            isDense: true,
          ),
        ),
      ),
    );
  }

  Widget _buildQualitySelector(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.high_quality_rounded, color: AppTheme.primaryColor),
            const SizedBox(width: 12),
            Text('quality'.tr),
            const Spacer(),
            Obx(
              () => DropdownButton<String>(
                value: controller.quality.value,
                underline: const SizedBox.shrink(),
                items: AppConstants.pdfQualities
                    .map(
                      (q) => DropdownMenuItem(value: q, child: Text(q)),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) controller.quality.value = v;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageSelector(BuildContext context) {
    final doc = controller.splitSource.value!;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'select_pages'.tr,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TextButton(
                  onPressed: controller.selectAllPages,
                  child: Text('all'.tr),
                ),
                TextButton(
                  onPressed: controller.clearPageSelection,
                  child: Text('clear'.tr),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(doc.pageCount, (index) {
                final selected = controller.selectedPageIndices.contains(index);
                return FilterChip(
                  label: Text('page_n'.trParams({'n': '${index + 1}'})),
                  selected: selected,
                  onSelected: (_) => controller.togglePage(index),
                  selectedColor: AppTheme.primaryColor.withAlpha(40),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTile(DocumentModel doc) {
    return Obx(() {
      final isSelected = controller.selectedDocIds.contains(doc.id);
      final isSingleSelect = controller.mode != PdfToolMode.merge;

      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: ListTile(
          onTap: () => controller.toggleDocument(doc.id),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 54,
              child: doc.thumbnailPath != null &&
                      File(doc.thumbnailPath!).existsSync()
                  ? Image.file(File(doc.thumbnailPath!), fit: BoxFit.cover)
                  : Container(
                      color: Colors.red.shade50,
                      child: Icon(Icons.picture_as_pdf,
                          color: Colors.red.shade400),
                    ),
            ),
          ),
          title: Text(
            doc.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${'pages_count'.trParams({'count': '${doc.pageCount}'})} • ${AppHelpers.formatFileSize(doc.sizeBytes)}',
          ),
          trailing: isSingleSelect
              ? Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey,
                )
              : Checkbox(
                  value: isSelected,
                  onChanged: (_) => controller.toggleDocument(doc.id),
                  activeColor: AppTheme.primaryColor,
                ),
        ),
      );
    });
  }

  Widget _buildBottomBar(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.canProcess && !controller.isProcessing.value
                  ? controller.process
                  : null,
              icon: controller.isProcessing.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      controller.mode == PdfToolMode.sign
                          ? Icons.draw_rounded
                          : Icons.check_rounded,
                    ),
              label: Text(
                controller.mode == PdfToolMode.sign
                    ? 'continue_to_sign'.tr
                    : controller.mode == PdfToolMode.compress
                        ? 'compress_save'.tr
                        : controller.mode == PdfToolMode.watermark
                            ? 'apply_watermark'.tr
                            : 'create_pdf'.tr,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
