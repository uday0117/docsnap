import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/crop_editor_controller.dart';
import '../../widgets/app_button.dart';

class CropEditorScreen extends StatelessWidget {
  const CropEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<CropEditorController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('crop_adjust'.tr),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: _buildImagePreview(ctrl)),
          _buildToolbar(ctrl),
        ],
      ),
    );
  }

  Widget _buildImagePreview(CropEditorController ctrl) {
    return Obx(() {
      if (ctrl.imagePath.value.isEmpty) {
        return Center(
          child:
              Text('no_image'.tr, style: const TextStyle(color: Colors.white)),
        );
      }
      if (ctrl.isProcessing.value) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: Hero(
            tag: 'crop_image',
            child: Image.file(
              File(ctrl.imagePath.value),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 64,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildToolbar(CropEditorController ctrl) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      color: const Color(0xFF1A1A2E),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ToolButton(
                icon: Icons.rotate_left_rounded,
                label: 'rotate_left'.tr,
                onTap: ctrl.rotateLeft,
              ),
              _ToolButton(
                icon: Icons.rotate_right_rounded,
                label: 'rotate_right'.tr,
                onTap: ctrl.rotateRight,
              ),
              _ToolButton(
                icon: Icons.crop_rounded,
                label: 'crop'.tr,
                onTap: ctrl.openSystemCropper,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AppButton(
                  label: 'cancel'.tr,
                  onPressed: ctrl.cancel,
                  isOutlined: true,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 3,
                child: Obx(
                  () => AppButton(
                    label: 'skip'.tr,
                    icon: Icons.skip_next_rounded,
                    onPressed:
                        ctrl.isProcessing.value ? null : ctrl.skipAndAddPage,
                    color: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 3,
                child: Obx(
                  () => AppButton(
                    label: 'done'.tr,
                    icon: Icons.check_circle_outline_rounded,
                    onPressed:
                        ctrl.isProcessing.value ? null : ctrl.applyAndAddPage,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'crop_hint'.tr,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
