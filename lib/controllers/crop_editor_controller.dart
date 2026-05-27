import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import '../models/scanned_page.dart';
import '../services/image_processing_service.dart';
import '../utils/app_helpers.dart';

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
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Crop Document',
            cancelButtonTitle: 'Cancel',
            doneButtonTitle: 'Done',
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
    if (imagePath.value.isEmpty) return;

    final savedPath = await _imageService.saveImageToDocsnap(imagePath.value);
    final page = ScannedPage(imagePath: savedPath);

    if (scannerController != null) {
      scannerController.addScannedPage(page);
      AppHelpers.showSnackbar('Page added successfully!');
      Get.back();
    } else {
      Get.back(result: page);
    }
  }

  void cancel() {
    Get.back();
  }
}
