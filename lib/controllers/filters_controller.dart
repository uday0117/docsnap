import 'package:get/get.dart';
import '../models/scanned_page.dart';
import '../services/image_processing_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_helpers.dart';

class FiltersController extends GetxController {
  final _imageService = Get.find<ImageProcessingService>();

  final RxString selectedFilter = AppConstants.filterOriginal.obs;
  final RxString previewImagePath = ''.obs;
  final RxBool isProcessing = false.obs;
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
      selectedFilter.value = args.filter;
    }
  }

  Future<void> applyPreview(String filterName) async {
    if (selectedFilter.value == filterName) return;
    selectedFilter.value = filterName;
    isProcessing.value = true;
    try {
      final processed = await _imageService.applyFilter(
        _originalPath,
        filterName,
      );
      previewImagePath.value = processed;
    } finally {
      isProcessing.value = false;
    }
  }

  void applyFilter() {
    final updatedPage = page.copyWith(
      imagePath: previewImagePath.value,
      filter: selectedFilter.value,
    );
    AppHelpers.showSnackbar('Filter applied: ${selectedFilter.value}');
    Get.back(result: updatedPage);
  }

  void cancel() {
    Get.back();
  }
}
