import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/pdf_generator_controller.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../widgets/app_button.dart';
import '../../widgets/common_widgets.dart';

class PdfGeneratorScreen extends GetView<PdfGeneratorController> {
  const PdfGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: 'Generate PDF',
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.isGenerating.value
                  ? null
                  : controller.generateAndSave,
              child: const Text(
                'Save PDF',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentNameField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Document Name',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Obx(
          () => TextFormField(
            initialValue: controller.documentName.value,
            onChanged: (v) => controller.documentName.value = v,
            decoration: const InputDecoration(
              hintText: 'Enter document name',
              prefixIcon: Icon(Icons.description_rounded),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFolderSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Save to Folder', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.defaultFolders
                .where((f) => f != 'All Documents')
                .map(
                  (folder) => ChoiceChip(
                    label: Text(folder),
                    selected: controller.selectedFolder.value == folder,
                    onSelected: (_) => controller.setFolder(folder),
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: controller.selectedFolder.value == folder
                          ? Colors.white
                          : null,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQualitySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PDF Quality', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            children: AppConstants.pdfQualities.map(
              (quality) {
                final isSelected = controller.pdfQuality.value == quality;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.setQuality(quality),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        quality,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : null,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPagesList(BuildContext context) {
    return Obx(() {
      if (controller.pages.isEmpty) {
        return const Center(
          child: Text('No pages added.', style: TextStyle(color: Colors.grey)),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Pages (${controller.pages.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              const Text(
                'Long press to reorder',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
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
                    'Page ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Filter: ${page.filter}',
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
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red,
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
        label: 'Generate & Save PDF',
        icon: Icons.picture_as_pdf_rounded,
        isLoading: controller.isGenerating.value,
        onPressed: controller.generateAndSave,
        width: double.infinity,
        height: 56,
      ),
    );
  }
}
