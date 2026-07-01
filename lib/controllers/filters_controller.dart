import 'package:get/get.dart';

import '../models/scanned_page.dart';
import '../controllers/settings_controller.dart';
import '../services/image_processing_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_helpers.dart';

class FiltersController extends GetxController {
  final _imageService = Get.find<ImageProcessingService>();

  final RxString selectedFilter = AppConstants.filterOriginal.obs;
  final RxString previewImagePath = ''.obs;
  final RxBool isProcessing = false.obs;
  final RxBool showAdjustments = false.obs;
  final Rx<ImageAdjustments> adjustments = const ImageAdjustments().obs;
  late ScannedPage page;
  String _originalPath = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ScannedPage) {
      page = args;
      _originalPath = args.imagePath;
      previewImagePath.value = args.imagePath;
      final initialFilter = args.filter == AppConstants.filterOriginal &&
              Get.isRegistered<SettingsController>()
          ? Get.find<SettingsController>().defaultFilter
          : args.filter;
      selectedFilter.value = initialFilter;
      if (initialFilter != AppConstants.filterOriginal) {
        _refreshPreview();
      }
    }
  }

  Future<void> applyPreview(String filterName) async {
    if (selectedFilter.value == filterName && !adjustments.value.hasChanges) {
      return;
    }
    selectedFilter.value = filterName;
    await _refreshPreview();
  }

  Future<void> updateAdjustment({
    double? brightness,
    double? contrast,
    double? saturation,
    double? sharpness,
    double? exposure,
    double? temperature,
    double? tint,
  }) async {
    adjustments.value = adjustments.value.copyWith(
      brightness: brightness,
      contrast: contrast,
      saturation: saturation,
      sharpness: sharpness,
      exposure: exposure,
      temperature: temperature,
      tint: tint,
    );
    await _refreshPreview();
  }

  Future<void> resetAdjustments() async {
    adjustments.value = const ImageAdjustments();
    await _refreshPreview();
  }

  Future<void> _refreshPreview() async {
    isProcessing.value = true;
    try {
      final filtered = await _imageService.applyFilter(
        _originalPath,
        selectedFilter.value,
      );
      final adjusted = await _imageService.applyAdjustments(
        filtered,
        adjustments.value,
      );
      previewImagePath.value = adjusted;
    } finally {
      isProcessing.value = false;
    }
  }

  void applyFilter() {
    final updatedPage = page.copyWith(
      imagePath: previewImagePath.value,
      filter: selectedFilter.value,
    );
    AppHelpers.showSnackbar('filter_applied'.trParams({
      'filter': AppHelpers.translateFilterName(selectedFilter.value),
    }));
    Get.back(result: updatedPage);
  }

  void cancel() {
    Get.back();
  }
}
