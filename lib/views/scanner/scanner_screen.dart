import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/scanner_controller.dart';
import '../../themes/app_theme.dart';

class ScannerScreen extends GetView<ScannerController> {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            _buildCameraPreview(),
            _buildTopControls(),
            _buildBottomControls(),
            _buildPageCountBadge(),
            _buildInstructionBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Obx(() {
      if (!controller.isCameraReady.value) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Initializing camera...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      }
      return SizedBox.expand(
        child: CameraPreview(controller.cameraController!),
      );
    });
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withAlpha(180), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            const Spacer(),
            Obx(
              () => IconButton(
                icon: Icon(
                  controller.isFlashOn.value
                      ? Icons.flash_on_rounded
                      : Icons.flash_off_rounded,
                  color:
                      controller.isFlashOn.value ? Colors.yellow : Colors.white,
                  size: 28,
                ),
                onPressed: controller.toggleFlash,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.flip_camera_ios_rounded,
                  color: Colors.white, size: 28),
              onPressed: controller.toggleCamera,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withAlpha(200), Colors.transparent],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildGalleryButton(),
                _buildCaptureButton(),
                _buildDoneButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return GestureDetector(
      onTap: controller.importFromGallery,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(100), width: 1.5),
        ),
        child: const Icon(
          Icons.photo_library_rounded,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return Obx(
      () => GestureDetector(
        onTap: controller.isCapturing.value ? null : controller.captureImage,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: controller.isCapturing.value ? 72 : 80,
          height: controller.isCapturing.value ? 72 : 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: AppTheme.primaryColor,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withAlpha(80),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: controller.isCapturing.value
              ? const Padding(
                  padding: EdgeInsets.all(18),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryColor,
                  ),
                )
              : const Icon(
                  Icons.camera_rounded,
                  color: AppTheme.primaryColor,
                  size: 36,
                ),
        ),
      ),
    );
  }

  Widget _buildDoneButton() {
    return Obx(
      () => GestureDetector(
        onTap: controller.scannedPages.isNotEmpty
            ? controller.proceedToGenerate
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: controller.scannedPages.isNotEmpty
                ? AppTheme.primaryColor
                : Colors.white.withAlpha(30),
            border: Border.all(
              color: controller.scannedPages.isNotEmpty
                  ? AppTheme.primaryColor
                  : Colors.white.withAlpha(100),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: controller.scannedPages.isNotEmpty
                    ? Colors.white
                    : Colors.white60,
                size: 22,
              ),
              if (controller.scannedPages.isNotEmpty)
                Text(
                  '${controller.scannedPages.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageCountBadge() {
    return Obx(() {
      if (controller.scannedPages.isEmpty) return const SizedBox.shrink();
      return Positioned(
        top: 80,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(50),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              '${controller.scannedPages.length} page${controller.scannedPages.length == 1 ? '' : 's'} added',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildInstructionBadge() {
    return Obx(() {
      if (controller.scannedPages.isNotEmpty) return const SizedBox.shrink();
      return Positioned(
        top: 80,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(150),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(50)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.info_outline, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'Capture pages to create PDF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
