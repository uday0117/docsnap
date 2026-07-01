import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/image_tools_controller.dart';
import '../../themes/app_theme.dart';
import '../../widgets/ad_banner_widget.dart';
import '../../widgets/common_widgets.dart';

class ImageToolsScreen extends GetView<ImageToolsController> {
  const ImageToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: GradientAppBar(
          title: 'image_tools'.tr,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            onTap: (i) => controller.setTab(
              i == 0 ? ImageToolTab.resize : ImageToolTab.convert,
            ),
            tabs: [
              Tab(text: 'resize_image'.tr),
              Tab(text: 'convert_format'.tr),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _ResizeTab(controller: controller),
                  _ConvertTab(controller: controller),
                ],
              ),
            ),
            const AdBannerWidget(),
          ],
        ),
      ),
    );
  }
}

class _ResizeTab extends StatelessWidget {
  final ImageToolsController controller;

  const _ResizeTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ImagePickerCard(controller: controller),
          if (controller.sourcePath.value != null) ...[
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'original_size'.trParams({
                        'w': '${controller.originalWidth.value}',
                        'h': '${controller.originalHeight.value}',
                      }),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Text('target_width'.tr),
                    Slider(
                      value: controller.targetWidth.value.toDouble(),
                      min: 320,
                      max: controller.originalWidth.value.toDouble().clamp(320, 4096),
                      divisions: 20,
                      activeColor: AppTheme.primaryColor,
                      label: '${controller.targetWidth.value}px',
                      onChanged: (v) => controller.targetWidth.value = v.round(),
                    ),
                    Text('jpeg_quality'.tr),
                    Slider(
                      value: controller.jpegQuality.value.toDouble(),
                      min: 40,
                      max: 100,
                      divisions: 12,
                      activeColor: AppTheme.primaryColor,
                      label: '${controller.jpegQuality.value}%',
                      onChanged: (v) => controller.jpegQuality.value = v.round(),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.isProcessing.value
                            ? null
                            : controller.processResize,
                        icon: const Icon(Icons.photo_size_select_large_rounded),
                        label: Text('resize_save'.tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (controller.resultPath.value != null) ...[
            const SizedBox(height: 16),
            _ResultPreview(
              path: controller.resultPath.value!,
              onShare: controller.shareResult,
            ),
          ],
        ],
      );
    });
  }
}

class _ConvertTab extends StatelessWidget {
  final ImageToolsController controller;

  const _ConvertTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ImagePickerCard(controller: controller),
          if (controller.sourcePath.value != null) ...[
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('output_format'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['jpg', 'png', 'webp'].map((fmt) {
                        final selected = controller.targetFormat.value == fmt;
                        return ChoiceChip(
                          label: Text(fmt.toUpperCase()),
                          selected: selected,
                          onSelected: (_) => controller.targetFormat.value = fmt,
                          selectedColor: AppTheme.primaryColor.withAlpha(40),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: controller.isProcessing.value
                            ? null
                            : controller.processConvert,
                        icon: const Icon(Icons.transform_rounded),
                        label: Text('convert_save'.tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (controller.resultPath.value != null) ...[
            const SizedBox(height: 16),
            _ResultPreview(
              path: controller.resultPath.value!,
              onShare: controller.shareResult,
            ),
          ],
        ],
      );
    });
  }
}

class _ImagePickerCard extends StatelessWidget {
  final ImageToolsController controller;

  const _ImagePickerCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final path = controller.sourcePath.value;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: controller.pickImage,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (path != null && File(path).existsSync())
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(path),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: AppTheme.primaryColor.withAlpha(120),
                  ),
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: controller.pickImage,
                icon: const Icon(Icons.photo_library_rounded),
                label: Text(path == null ? 'pick_image'.tr : 'change_image'.tr),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultPreview extends StatelessWidget {
  final String path;
  final VoidCallback onShare;

  const _ResultPreview({required this.path, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('result'.tr,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(path), fit: BoxFit.contain),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share_rounded),
                label: Text('share'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
