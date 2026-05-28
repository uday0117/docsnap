import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';

import '../models/scanned_page.dart';
import '../services/image_processing_service.dart';
import '../utils/app_helpers.dart';
import 'scanner_controller.dart';

class CropEditorController extends GetxController {
  final _imageService = Get.find<ImageProcessingService>();

  final RxString imagePath = ''.obs;
  final RxDouble rotation = 0.0.obs;
  final RxBool isProcessing = false.obs;
  dynamic scannerController;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      imagePath.value = args['imagePath'] as String? ?? '';
      scannerController = args['scannerController'];
    }
  }

  Future<void> openSystemCropper() async {
    if (imagePath.value.isEmpty) return;
    isProcessing.value = true;
    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: imagePath.value,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Document',
            toolbarColor: const Color(0xFF1565C0),
            toolbarWidgetColor: Colors.white,
            statusBarColor: const Color(0xFF0D47A1),
            backgroundColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
            showCropGrid: true,
            cropFrameColor: Colors.white,
            cropGridColor: Colors.white54,
          ),
          IOSUiSettings(
            title: 'Crop Document',
            cancelButtonTitle: 'Cancel',
            doneButtonTitle: 'Done',
            hidesNavigationBar: false,
            minimumAspectRatio: 0.5,
          ),
        ],
      );
      if (cropped != null) {
        imagePath.value = cropped.path;
      }
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> rotateLeft() async {
    rotation.value = (rotation.value - 90) % 360;
    await _applyRotation();
  }

  Future<void> rotateRight() async {
    rotation.value = (rotation.value + 90) % 360;
    await _applyRotation();
  }

  Future<void> _applyRotation() async {
    if (imagePath.value.isEmpty) return;
    isProcessing.value = true;
    try {
      final rotated = await _imageService.rotateImage(
        imagePath.value,
        rotation.value == 0 ? 90 : rotation.value,
      );
      imagePath.value = rotated;
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> applyAndAddPage() async {
    if (imagePath.value.isEmpty) {
      AppHelpers.showSnackbar('No image to process', isError: true);
      return;
    }

    isProcessing.value = true;

    try {
      final page = ScannedPage(imagePath: imagePath.value);

      // Try to find scanner controller
      dynamic scanner = scannerController;
      if (scanner == null) {
        try {
          scanner = Get.find<ScannerController>();
        } catch (_) {
          Get.back(result: page);
          return;
        }
      }

      scanner.addScannedPage(page);
      Get.back();
      await Future.delayed(const Duration(milliseconds: 100));
      AppHelpers.showSnackbar('Page added!');
    } catch (e) {
      Get.back();
      AppHelpers.showSnackbar('Error: $e', isError: true);
    } finally {
      isProcessing.value = false;
    }
  }

  void cancel() {
    Get.back(result: 'cancelled');
  }

  // Quick add without any adjustments
  Future<void> skipAndAddPage() async {
    if (imagePath.value.isEmpty) return;

    try {
      isProcessing.value = true;

      final page = ScannedPage(imagePath: imagePath.value);

      if (scannerController != null) {
        await Future.delayed(const Duration(milliseconds: 50));
        scannerController.addScannedPage(page);
        AppHelpers.showSnackbar('Page added!');
        Get.back(result: 'added');
      } else {
        Get.back(result: page);
      }
    } catch (e) {
      AppHelpers.showSnackbar('Error: $e', isError: true);
      isProcessing.value = false;
    }
  }
}
