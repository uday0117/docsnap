import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../controllers/settings_controller.dart';
import '../models/scanned_page.dart';
import '../services/edge_detection_service.dart';
import '../services/permission_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_helpers.dart';
import '../utils/scan_mode.dart';

class ScannerController extends GetxController {
  final _permissionService = Get.find<PermissionService>();
  final _picker = ImagePicker();

  CameraController? cameraController;
  final RxList<CameraDescription> cameras = <CameraDescription>[].obs;
  final RxBool isCameraReady = false.obs;
  final RxBool isFlashOn = false.obs;
  final RxBool isFrontCamera = false.obs;
  final RxBool isCapturing = false.obs;
  final RxList<ScannedPage> scannedPages = <ScannedPage>[].obs;
  final RxString documentName = 'Document_${_formattedDate()}'.obs;
  final Rx<ScanMode> scanMode = ScanMode.document.obs;
  final Rx<IdCardSide> idCardSide = IdCardSide.front.obs;
  final ScrollController modeScrollController = ScrollController();

  bool _galleryOnlyMode = false;
  bool get galleryOnlyMode => _galleryOnlyMode;

  bool get isIdCardMode => scanMode.value.isIdCard;
  bool get awaitingIdBack =>
      isIdCardMode && scannedPages.length == 1 && idCardSide.value == IdCardSide.back;
  bool get idCardComplete => isIdCardMode && scannedPages.length >= 2;

  static String _formattedDate() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    _galleryOnlyMode = args?['openGallery'] == true;
    if (args?['scanMode'] == 'idCard') {
      scanMode.value = ScanMode.idCard;
      documentName.value = 'ID_${_formattedDate()}';
    } else if (args?['scanMode'] != null) {
      scanMode.value = ScanMode.fromString(args!['scanMode'] as String?);
      _updateDocumentNameForMode();
    }

    if (_galleryOnlyMode) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        importFromGallery(openedFromTools: true);
      });
    } else {
      _initCamera();
    }
  }

  void setScanMode(ScanMode mode) {
    if (scannedPages.isNotEmpty) return;
    scanMode.value = mode;
    _updateDocumentNameForMode();
    if (mode.isIdCard) {
      idCardSide.value = IdCardSide.front;
    }
    _scrollModeIntoView(mode);
  }

  void _scrollModeIntoView(ScanMode mode) {
    final index = ScanMode.values.indexOf(mode);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!modeScrollController.hasClients) return;
      const itemExtent = 108.0;
      final target = (index * itemExtent).clamp(
        0.0,
        modeScrollController.position.maxScrollExtent,
      );
      modeScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _updateDocumentNameForMode() {
    final prefix = switch (scanMode.value) {
      ScanMode.idCard => 'ID',
      ScanMode.receipt => 'Receipt',
      ScanMode.passport => 'Passport',
      ScanMode.businessCard => 'Card',
      ScanMode.book => 'Book',
      ScanMode.whiteboard => 'Board',
      ScanMode.document => 'Document',
    };
    documentName.value = '${prefix}_${_formattedDate()}';
  }

  Future<void> _initCamera() async {
    final hasPermission = await _permissionService.requestCameraPermission();
    if (!hasPermission) return;

    final cams = await availableCameras();
    cameras.value = cams;

    if (cams.isEmpty) {
      AppHelpers.showSnackbar('no_camera'.tr, isError: true);
      return;
    }

    await _setupCamera(cams.first);
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    isCameraReady.value = false;

    await cameraController?.dispose();
    cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await cameraController!.initialize();
      isCameraReady.value = true;
    } on CameraException catch (e) {
      AppHelpers.showSnackbar(
        'camera_error'.trParams({'error': e.description ?? ''}),
        isError: true,
      );
    }
  }

  Future<void> toggleFlash() async {
    if (cameraController == null || !isCameraReady.value) return;
    isFlashOn.value = !isFlashOn.value;
    await cameraController!.setFlashMode(
      isFlashOn.value ? FlashMode.torch : FlashMode.off,
    );
  }

  Future<void> toggleCamera() async {
    if (cameras.length < 2) return;
    isFrontCamera.value = !isFrontCamera.value;
    final camera = isFrontCamera.value
        ? cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
          )
        : cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
            orElse: () => cameras.first,
          );
    await _setupCamera(camera);
  }

  Future<void> captureImage() async {
    if (cameraController == null || !isCameraReady.value || isCapturing.value) {
      return;
    }
    if (isIdCardMode && scannedPages.length >= 2) {
      AppHelpers.showSnackbar('id_card_complete_hint'.tr);
      return;
    }

    isCapturing.value = true;
    try {
      final xFile = await cameraController!.takePicture();
      final savedPath = await _saveImageToTemp(xFile.path);
      final processed = await _maybeAutoCrop(savedPath);
      await _openCropEditor(processed);
    } on CameraException catch (e) {
      AppHelpers.showSnackbar(
        'capture_failed'.trParams({'error': e.description ?? ''}),
        isError: true,
      );
    } finally {
      isCapturing.value = false;
    }
  }

  Future<void> importFromGallery({bool openedFromTools = false}) async {
    try {
      final hasPermission = await _permissionService.requestPhotosPermission();
      if (!hasPermission) {
        if (openedFromTools && scannedPages.isEmpty) {
          Get.back();
        }
        return;
      }

      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 95);

      if (images.isEmpty) {
        if (openedFromTools && scannedPages.isEmpty) {
          Get.back();
        }
        return;
      }

      for (final image in images) {
        final savedPath = await _saveImageToTemp(image.path);
        final processed = await _maybeAutoCrop(savedPath);
        final result = await _openCropEditor(processed);
        if (result == 'cancelled') {
          continue;
        }
      }

      if (openedFromTools && scannedPages.isEmpty) {
        Get.back();
      }
    } catch (e) {
      AppHelpers.showSnackbar(
        'failed_import_images'.tr,
        isError: true,
      );
      if (openedFromTools && scannedPages.isEmpty) {
        Get.back();
      }
    }
  }

  Future<String> _maybeAutoCrop(String path) async {
    if (!Get.isRegistered<SettingsController>()) return path;
    if (!Get.find<SettingsController>().autoCrop) return path;
    if (!Get.isRegistered<EdgeDetectionService>()) return path;

    final cropped =
        await Get.find<EdgeDetectionService>().autoCropDocument(path);
    return cropped ?? path;
  }

  Future<String> _saveImageToTemp(String sourcePath) async {
    final dir = await getTemporaryDirectory();
    final destPath = p.join(dir.path, '${const Uuid().v4()}.jpg');
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  Future<dynamic> _openCropEditor(String imagePath) async {
    return await Get.toNamed(
      AppConstants.cropEditorRoute,
      arguments: {
        'imagePath': imagePath,
        'scannerController': this,
        'scanMode': scanMode.value.name,
        'idCardSide': idCardSide.value.name,
      },
    );
  }

  void addScannedPage(ScannedPage page) {
    scannedPages.add(page);
    if (isIdCardMode && scannedPages.length == 1) {
      idCardSide.value = IdCardSide.back;
    }
  }

  void removePageAt(int index) {
    scannedPages.removeAt(index);
    if (isIdCardMode) {
      idCardSide.value =
          scannedPages.isEmpty ? IdCardSide.front : IdCardSide.back;
    }
  }

  void reorderPage(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final page = scannedPages.removeAt(oldIndex);
    scannedPages.insert(newIndex, page);
  }

  void proceedToGenerate() {
    if (scannedPages.isEmpty) {
      AppHelpers.showSnackbar('add_one_page'.tr, isError: true);
      return;
    }
    if (isIdCardMode && scannedPages.length < 2) {
      AppHelpers.showSnackbar('id_card_need_both'.tr, isError: true);
      return;
    }

    Get.toNamed(
      AppConstants.pdfGeneratorRoute,
      arguments: {
        'pages': scannedPages.toList(),
        'name': documentName.value,
        'scanMode': scanMode.value.name,
      },
    );
  }

  @override
  void onClose() {
    modeScrollController.dispose();
    cameraController?.dispose();
    super.onClose();
  }
}
