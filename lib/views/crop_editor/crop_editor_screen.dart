import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/crop_editor_controller.dart';
import '../../services/image_processing_service.dart';
import '../../themes/app_theme.dart';
import '../../widgets/app_button.dart';

class CropEditorScreen extends StatelessWidget {
  const CropEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ImageProcessingService());
    final ctrl = Get.put(CropEditorController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Crop & Adjust'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: ctrl.applyAndAddPage,
            child: const Text(
              'Add Page',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
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
        return const Center(
          child:
              Text('No image selected', style: TextStyle(color: Colors.white)),
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
                label: 'Rotate Left',
                onTap: ctrl.rotateLeft,
              ),
              _ToolButton(
                icon: Icons.rotate_right_rounded,
                label: 'Rotate Right',
                onTap: ctrl.rotateRight,
              ),
              _ToolButton(
                icon: Icons.crop_rounded,
                label: 'Crop',
                onTap: ctrl.openSystemCropper,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Cancel',
                  onPressed: ctrl.cancel,
                  isOutlined: true,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Add Page',
                  icon: Icons.add_circle_outline_rounded,
                  onPressed: ctrl.applyAndAddPage,
                ),
              ),
            ],
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
