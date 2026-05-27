import 'package:get/get.dart';

import '../controllers/settings_controller.dart';
import '../models/document_model.dart';
import '../models/scanned_page.dart';
import '../repositories/document_repository.dart';
import '../services/pdf_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_helpers.dart';

class PdfGeneratorController extends GetxController {
  final DocumentRepository _repository;
  final PdfService _pdfService;

  PdfGeneratorController(this._repository, this._pdfService);

  final RxList<ScannedPage> pages = <ScannedPage>[].obs;
  final RxString documentName = ''.obs;
  final RxString selectedFolder = 'Others'.obs;
  final RxBool isGenerating = false.obs;
  final RxString pdfQuality = 'High'.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      final rawPages = args['pages'];
      if (rawPages is List<ScannedPage>) {
        pages.value = rawPages;
      }
      documentName.value = (args['name'] as String?) ?? 'Document';
    }
    // Get default PDF quality from settings if available
    try {
      final settingsController = Get.find<SettingsController>();
      pdfQuality.value = settingsController.pdfQuality;
    } catch (_) {
      // If settings controller not found, use default
      pdfQuality.value = 'High';
    }
  }

  void reorderPages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final page = pages.removeAt(oldIndex);
    pages.insert(newIndex, page);
  }

  void deletePage(int index) {
    pages.removeAt(index);
  }

  void setFolder(String folder) {
    selectedFolder.value = folder;
  }

  void setQuality(String quality) {
    pdfQuality.value = quality;
  }

  Future<void> generateAndSave() async {
    if (pages.isEmpty) {
      AppHelpers.showSnackbar('No pages to generate PDF.', isError: true);
      return;
    }
    if (documentName.value.trim().isEmpty) {
      AppHelpers.showSnackbar('Please enter a document name.', isError: true);
      return;
    }

    AppHelpers.showLoading('Generating PDF...');
    isGenerating.value = true;

    try {
      final imagePaths = pages.map((p) => p.imagePath).toList();
      final pdfPath = await _pdfService.generatePdf(
        name: documentName.value.trim(),
        imagesPaths: imagePaths,
        quality: pdfQuality.value,
      );

      final fileSize = await _pdfService.getPdfFileSize(pdfPath);
      final thumbnail = imagePaths.isNotEmpty ? imagePaths.first : null;

      final doc = DocumentModel(
        name: documentName.value.trim(),
        pdfPath: pdfPath,
        pageImagePaths: imagePaths,
        pageCount: pages.length,
        folder: selectedFolder.value,
        sizeBytes: fileSize,
        thumbnailPath: thumbnail,
      );

      _repository.saveDocument(doc);
      AppHelpers.hideLoading();
      AppHelpers.showSnackbar('PDF saved successfully!');
      Get.offAllNamed(AppConstants.homeRoute);
    } catch (e) {
      AppHelpers.hideLoading();
      AppHelpers.showSnackbar('Failed to generate PDF: $e', isError: true);
    } finally {
      isGenerating.value = false;
    }
  }
}
