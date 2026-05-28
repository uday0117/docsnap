import 'dart:io';

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/scanned_page.dart';
import '../services/permission_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_helpers.dart';

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

  static String _formattedDate() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void onInit() {
    super.onInit();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final hasPermission = await _permissionService.requestCameraPermission();
    if (!hasPermission) return;

    final cams = await availableCameras();
    cameras.value = cams;

    if (cams.isEmpty) {
      AppHelpers.showSnackbar('No camera found on device.', isError: true);
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
      AppHelpers.showSnackbar('Camera error: ${e.description}', isError: true);
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
    isCapturing.value = true;
    try {
      final xFile = await cameraController!.takePicture();
      final savedPath = await _saveImageToTemp(xFile.path);
      _openCropEditor(savedPath);
    } on CameraException catch (e) {
      AppHelpers.showSnackbar('Capture failed: ${e.description}',
          isError: true);
    } finally {
      isCapturing.value = false;
    }
  }

  Future<void> importFromGallery() async {
    final hasPermission = await _permissionService.requestStoragePermission();
    if (!hasPermission) return;

    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 95);
    if (images.isEmpty) return;

    // Process images sequentially to avoid navigation stack corruption
    for (final image in images) {
      final savedPath = await _saveImageToTemp(image.path);
      final result = await _openCropEditor(savedPath);

      // If user cancels, stop importing remaining images
      if (result == null) break;
    }
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
      arguments: {'imagePath': imagePath, 'scannerController': this},
    );
  }

  void addScannedPage(ScannedPage page) {
    scannedPages.add(page);
  }

  void removePageAt(int index) {
    scannedPages.removeAt(index);
  }

  void reorderPage(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final page = scannedPages.removeAt(oldIndex);
    scannedPages.insert(newIndex, page);
  }

  void proceedToGenerate() {
    if (scannedPages.isEmpty) {
      AppHelpers.showSnackbar('Add at least one page to continue.',
          isError: true);
      return;
    }
    Get.toNamed(
      AppConstants.pdfGeneratorRoute,
      arguments: {
        'pages': scannedPages.toList(),
        'name': documentName.value,
      },
    );
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}
