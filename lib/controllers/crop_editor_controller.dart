import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';

import '../models/scanned_page.dart';
import '../services/image_processing_service.dart';
import '../themes/app_theme.dart';
import '../utils/app_constants.dart';
import '../utils/app_helpers.dart';
import '../utils/scan_mode.dart';
import 'scanner_controller.dart';

class CropEditorController extends GetxController {
  final _imageService = Get.find<ImageProcessingService>();

  final RxString imagePath = ''.obs;
  final RxBool isProcessing = false.obs;
  dynamic scannerController;
  ScanMode scanMode = ScanMode.document;
  IdCardSide idCardSide = IdCardSide.front;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      imagePath.value = args['imagePath'] as String? ?? '';
      scannerController = args['scannerController'];
      final mode = args['scanMode'] as String?;
      if (mode == 'idCard') scanMode = ScanMode.idCard;
      final side = args['idCardSide'] as String?;
      if (side == 'back') idCardSide = IdCardSide.back;
    }
  }

  Future<void> openSystemCropper() async {
    if (imagePath.value.isEmpty) return;
    isProcessing.value = true;
    try {
      final lockRatio = scanMode.isIdCard;
      final cropped = await ImageCropper().cropImage(
        sourcePath: imagePath.value,
        aspectRatio: lockRatio
            ? CropAspectRatio(
                ratioX: AppConstants.idCardAspectRatio * 100,
                ratioY: 100,
              )
            : null,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'crop_document'.tr,
            toolbarColor: AppTheme.primaryColor,
            toolbarWidgetColor: Colors.white,
            statusBarLight: false,
            backgroundColor: Colors.black,
            initAspectRatio: lockRatio
                ? CropAspectRatioPreset.ratio16x9
                : CropAspectRatioPreset.original,
            lockAspectRatio: lockRatio,
            hideBottomControls: false,
            showCropGrid: true,
            cropFrameColor: Colors.white,
            cropGridColor: Colors.white54,
          ),
          IOSUiSettings(
            title: 'crop_document'.tr,
            cancelButtonTitle: 'cancel'.tr,
            doneButtonTitle: 'done'.tr,
            hidesNavigationBar: false,
            minimumAspectRatio: lockRatio ? 1.0 : 0.5,
            aspectRatioLockEnabled: lockRatio,
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

  Future<void> rotateLeft() async => _rotateBy(-90);

  Future<void> rotateRight() async => _rotateBy(90);

  Future<void> _rotateBy(double degrees) async {
    if (imagePath.value.isEmpty) return;
    isProcessing.value = true;
    try {
      imagePath.value =
          await _imageService.rotateImage(imagePath.value, degrees);
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> openFilters() async {
    if (imagePath.value.isEmpty) return;

    final page = ScannedPage(imagePath: imagePath.value);
    final result = await Get.toNamed(
      AppConstants.filtersRoute,
      arguments: page,
    );

    if (result is ScannedPage) {
      imagePath.value = result.imagePath;
    }
  }

  Future<void> applyAndAddPage() async {
    if (imagePath.value.isEmpty) {
      AppHelpers.showSnackbar('no_image_process'.tr, isError: true);
      return;
    }

    isProcessing.value = true;

    try {
      final page = ScannedPage(imagePath: imagePath.value);

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
      Get.back(result: 'added');
      await Future.delayed(const Duration(milliseconds: 100));
      AppHelpers.showSnackbar('page_added'.tr);
    } catch (e) {
      Get.back();
      AppHelpers.showSnackbar(
        'failed_generic'.trParams({'error': '$e'}),
        isError: true,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  void cancel() {
    Get.back(result: 'cancelled');
  }

  Future<void> skipAndAddPage() async {
    if (imagePath.value.isEmpty) return;

    try {
      isProcessing.value = true;

      final page = ScannedPage(imagePath: imagePath.value);

      if (scannerController != null) {
        await Future.delayed(const Duration(milliseconds: 50));
        scannerController.addScannedPage(page);
        AppHelpers.showSnackbar('page_added'.tr);
        Get.back(result: 'added');
      } else {
        Get.back(result: page);
      }
    } catch (e) {
      AppHelpers.showSnackbar(
        'failed_generic'.trParams({'error': '$e'}),
        isError: true,
      );
      isProcessing.value = false;
    }
  }
}
