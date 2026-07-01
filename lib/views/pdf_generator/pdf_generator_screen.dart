import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/pdf_generator_controller.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_helpers.dart';
import '../../widgets/ad_banner_widget.dart';
import '../../widgets/app_button.dart';
import '../../widgets/common_widgets.dart';

class PdfGeneratorScreen extends GetView<PdfGeneratorController> {
  const PdfGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'generate_pdf'.tr,
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.isGenerating.value
                  ? null
                  : controller.generateAndSave,
              child: Text(
                'save'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDocumentNameField(context),
                  const SizedBox(height: 20),
                  _buildFolderSelector(context),
                  const SizedBox(height: 20),
                  _buildQualitySelector(context),
                  const SizedBox(height: 24),
                  _buildPagesList(context),
                  const SizedBox(height: 24),
                  _buildGenerateButton(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildDocumentNameField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'document_name'.tr,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextFormField(
            initialValue: controller.documentName.value,
            onChanged: (v) => controller.documentName.value = v,
            decoration: InputDecoration(
              hintText: 'hint_document_name'.tr,
              prefixIcon: const Icon(Icons.description_rounded),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFolderSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('folder'.tr, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.defaultFolders
                .where((f) => f != 'All Documents')
                .map(
                  (folder) {
                    final isSelected =
                        controller.selectedFolder.value == folder;
                    return ChoiceChip(
                      label: Text(folder),
                      selected: isSelected,
                      onSelected: (_) => controller.setFolder(folder),
                      selectedColor: AppTheme.primaryColor,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : colorScheme.outline.withAlpha(80),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQualitySelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('pdf_quality'.tr, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            children: [
              for (var i = 0; i < AppConstants.pdfQualities.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        controller.setQuality(AppConstants.pdfQualities[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: controller.pdfQuality.value ==
                                AppConstants.pdfQualities[i]
                            ? AppTheme.primaryColor
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: controller.pdfQuality.value ==
                                  AppConstants.pdfQualities[i]
                              ? AppTheme.primaryColor
                              : colorScheme.outline.withAlpha(80),
                        ),
                      ),
                      child: Text(
                        AppHelpers.translateQuality(
                          AppConstants.pdfQualities[i],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: controller.pdfQuality.value ==
                                  AppConstants.pdfQualities[i]
                              ? Colors.white
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPagesList(BuildContext context) {
    return Obx(() {
      if (controller.pages.isEmpty) {
        return Center(
          child: Text(
            'no_pages_added'.tr,
            style: const TextStyle(color: Colors.grey),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'pages_count'.trParams({'count': '${controller.pages.length}'}),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'long_press_reorder'.tr,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.pages.length,
            onReorder: controller.reorderPages,
            itemBuilder: (_, index) {
              final page = controller.pages[index];
              return Card(
                key: ValueKey(page.id),
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 50,
                      height: 62,
                      child: File(page.imagePath).existsSync()
                          ? Image.file(
                              File(page.imagePath),
                              fit: BoxFit.cover,
                            )
                          : Container(color: Colors.grey.shade200),
                    ),
                  ),
                  title: Text(
                    'page_n'.trParams({'n': '${index + 1}'}),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'filter_label'.trParams({
                      'filter': AppHelpers.translateFilterName(page.filter),
                    }),
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.drag_handle_rounded,
                        color: Colors.grey,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: Theme.of(context).colorScheme.error,
                          size: 20,
                        ),
                        onPressed: () => controller.deletePage(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildGenerateButton() {
    return Obx(
      () => AppButton(
        label: 'generate_save_pdf'.tr,
        icon: Icons.picture_as_pdf_rounded,
        isLoading: controller.isGenerating.value,
        onPressed: controller.generateAndSave,
        width: double.infinity,
        height: 56,
      ),
    );
  }
}
