import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../services/ad_service.dart';
import '../services/image_processing_service.dart';
import '../utils/app_helpers.dart';

enum ImageToolTab { resize, convert }

class ImageToolsController extends GetxController {
  final _imageService = Get.find<ImageProcessingService>();
  final _picker = ImagePicker();

  final Rx<ImageToolTab> activeTab = ImageToolTab.resize.obs;
  final RxnString sourcePath = RxnString();
  final RxnString resultPath = RxnString();
  final RxInt originalWidth = 0.obs;
  final RxInt originalHeight = 0.obs;
  final RxInt targetWidth = 1920.obs;
  final RxInt jpegQuality = 85.obs;
  final RxString targetFormat = 'png'.obs;
  final RxBool isProcessing = false.obs;

  void setTab(ImageToolTab tab) => activeTab.value = tab;

  Future<void> pickImage() async {
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      sourcePath.value = file.path;
      resultPath.value = null;
      await _loadDimensions(file.path);
    } catch (e) {
      AppHelpers.showSnackbar('failed_import_images'.tr, isError: true);
    }
  }

  Future<void> _loadDimensions(String path) async {
    final dims = await _imageService.readImageDimensions(path);
    if (dims == null) return;
    originalWidth.value = dims.width;
    originalHeight.value = dims.height;
    targetWidth.value = dims.width.clamp(320, 4096);
  }

  Future<void> processResize() async {
    final path = sourcePath.value;
    if (path == null) {
      AppHelpers.showSnackbar('pick_image_first'.tr, isError: true);
      return;
    }

    isProcessing.value = true;
    AppHelpers.showLoading('processing'.tr);
    try {
      resultPath.value = await _imageService.compressImage(
        path,
        quality: jpegQuality.value,
        maxWidth: targetWidth.value,
      );
      AppHelpers.hideLoading();
      AppHelpers.showSnackbar('image_resized'.tr);
      try {
        await Get.find<AdService>().showInterstitialIfReady();
      } catch (_) {}
    } catch (e) {
      AppHelpers.hideLoading();
      AppHelpers.showSnackbar(
        'failed_generic'.trParams({'error': '$e'}),
        isError: true,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> processConvert() async {
    final path = sourcePath.value;
    if (path == null) {
      AppHelpers.showSnackbar('pick_image_first'.tr, isError: true);
      return;
    }

    isProcessing.value = true;
    AppHelpers.showLoading('processing'.tr);
    try {
      resultPath.value = await _imageService.convertFormat(
        path,
        format: targetFormat.value,
      );
      AppHelpers.hideLoading();
      AppHelpers.showSnackbar('image_converted'.tr);
      try {
        await Get.find<AdService>().showInterstitialIfReady();
      } catch (_) {}
    } catch (e) {
      AppHelpers.hideLoading();
      AppHelpers.showSnackbar(
        'failed_generic'.trParams({'error': '$e'}),
        isError: true,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> shareResult() async {
    final path = resultPath.value;
    if (path == null || !File(path).existsSync()) return;
    await Share.shareXFiles([XFile(path)]);
  }
}
