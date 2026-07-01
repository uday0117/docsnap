import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/scanner_controller.dart';
import '../../themes/app_theme.dart';
import '../../utils/scan_mode.dart';

class ScannerScreen extends GetView<ScannerController> {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: controller.galleryOnlyMode
            ? _buildGalleryOnlyBody()
            : _buildCameraBody(),
      ),
    );
  }

  Widget _buildGalleryOnlyBody() {
    return Obx(() {
      if (controller.scannedPages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'opening_gallery'.tr,
                style: TextStyle(color: Colors.white.withAlpha(220)),
              ),
            ],
          ),
        );
      }

      return Stack(
        children: [
          _buildImportReviewBody(),
          _buildImportTopControls(),
          _buildThumbnailStrip(),
          _buildImportBottomControls(),
          _buildPageCountBadge(),
        ],
      );
    });
  }

  Widget _buildCameraBody() {
    return Stack(
      children: [
        _buildCameraPreview(),
        _buildIdCardOverlay(),
        _buildTopControls(),
        _buildThumbnailStrip(),
        _buildBottomControls(),
        _buildPageCountBadge(),
        _buildInstructionBadge(),
      ],
    );
  }

  Widget _buildImportReviewBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_rounded,
            size: 72,
            color: Colors.white.withAlpha(180),
          ),
          const SizedBox(height: 20),
          Obx(
            () {
              final count = controller.scannedPages.length;
              return Text(
                count == 1
                    ? 'images_imported_one'.trParams({'count': '$count'})
                    : 'images_imported_other'.trParams({'count': '$count'}),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'add_more_gallery'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildImportTopControls() {
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
            Text(
              'import_image'.tr,
              style: TextStyle(
                color: Colors.white.withAlpha(230),
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildImportBottomControls() {
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildGalleryButton(),
            _buildDoneButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Obx(() {
      if (!controller.isCameraReady.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'loading'.tr,
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
        child: Column(
          children: [
            _buildModeSelector(),
            Row(
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
                      color: controller.isFlashOn.value
                          ? Colors.yellow
                          : Colors.white,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThumbnailStripContent(),
            const SizedBox(height: 12),
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
              controller.scannedPages.length == 1
                  ? 'pages_added_one'.trParams({
                      'count': '${controller.scannedPages.length}',
                    })
                  : 'pages_added_other'.trParams({
                      'count': '${controller.scannedPages.length}',
                    }),
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
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  'start_scanning'.tr,
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

  Widget _buildModeSelector() {
    return Obx(() {
      if (controller.scannedPages.isNotEmpty) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        height: 40,
        child: ListView.separated(
          controller: controller.modeScrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: ScanMode.values.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, index) {
            final mode = ScanMode.values[index];
            final selected = controller.scanMode.value == mode;
            return GestureDetector(
              onTap: () => controller.setScanMode(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primaryColor
                      : Colors.black.withAlpha(90),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? Colors.white.withAlpha(180)
                        : Colors.white.withAlpha(45),
                    width: selected ? 1.5 : 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withAlpha(120),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      mode.icon,
                      color: selected
                          ? Colors.white
                          : Colors.white.withAlpha(170),
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      mode.labelKey.tr,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : Colors.white.withAlpha(170),
                        fontSize: 12,
                        fontWeight:
                            selected ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildIdCardOverlay() {
    return Obx(() {
      final aspect = controller.scanMode.value.overlayAspectRatio;
      if (aspect == null) return const SizedBox.shrink();

      return IgnorePointer(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxW = constraints.maxWidth * 0.85;
              final maxH = constraints.maxHeight * 0.55;
              double width = maxW;
              double height = width / aspect;
              if (height > maxH) {
                height = maxH;
                width = height * aspect;
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: width,
                    height: height,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.primaryLight,
                        width: 2.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        ..._cornerBrackets(),
                        if (controller.isIdCardMode)
                          Center(
                            child: Text(
                              controller.idCardSide.value == IdCardSide.front
                                  ? 'id_front'.tr
                                  : 'id_back'.tr,
                              style: TextStyle(
                                color: Colors.white.withAlpha(180),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (controller.isIdCardMode) ...[
                    const SizedBox(height: 12),
                    Text(
                      controller.awaitingIdBack
                          ? 'scan_id_back'.tr
                          : 'scan_id_front'.tr,
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      );
    });
  }

  List<Widget> _cornerBrackets() {
    const len = 24.0;
    const stroke = 3.0;
    const color = AppTheme.primaryLight;
    Widget corner(Alignment align) {
      return Align(
        alignment: align,
        child: Container(
          width: len,
          height: len,
          decoration: BoxDecoration(
            border: Border(
              top: align.y < 0
                  ? const BorderSide(color: color, width: stroke)
                  : BorderSide.none,
              bottom: align.y > 0
                  ? const BorderSide(color: color, width: stroke)
                  : BorderSide.none,
              left: align.x < 0
                  ? const BorderSide(color: color, width: stroke)
                  : BorderSide.none,
              right: align.x > 0
                  ? const BorderSide(color: color, width: stroke)
                  : BorderSide.none,
            ),
          ),
        ),
      );
    }

    return [
      corner(Alignment.topLeft),
      corner(Alignment.topRight),
      corner(Alignment.bottomLeft),
      corner(Alignment.bottomRight),
    ];
  }

  Widget _buildThumbnailStrip() {
    return Obx(() {
      if (controller.scannedPages.isEmpty) return const SizedBox.shrink();
      return Positioned(
        bottom: controller.galleryOnlyMode ? 110 : 130,
        left: 0,
        right: 0,
        child: _buildThumbnailStripContent(),
      );
    });
  }

  Widget _buildThumbnailStripContent() {
    return Obx(() {
      if (controller.scannedPages.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 72,
        child: ReorderableListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.scannedPages.length,
          onReorder: controller.reorderPage,
          proxyDecorator: (child, _, __) => Material(
            color: Colors.transparent,
            elevation: 4,
            borderRadius: BorderRadius.circular(10),
            child: child,
          ),
          itemBuilder: (_, index) {
            final page = controller.scannedPages[index];
            return Container(
              key: ValueKey(page.id),
              width: 56,
              margin: const EdgeInsets.only(right: 8),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(page.imagePath),
                      width: 56,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade800,
                        child: const Icon(Icons.image, color: Colors.white54),
                      ),
                    ),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: GestureDetector(
                      onTap: () => controller.removePageAt(index),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
