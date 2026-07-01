import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/document_model.dart';
import '../controllers/settings_controller.dart';
import '../models/scanned_page.dart';
import '../repositories/document_repository.dart';
import '../services/ad_service.dart';
import '../services/analytics_service.dart';
import '../services/review_prompt_service.dart';
import '../services/image_processing_service.dart';
import '../services/pdf_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_helpers.dart';
import '../utils/scan_mode.dart';

class PdfGeneratorController extends GetxController {
  final DocumentRepository _repository;
  final PdfService _pdfService;
  final _imageService = Get.find<ImageProcessingService>();

  PdfGeneratorController(this._repository, this._pdfService);

  final RxList<ScannedPage> pages = <ScannedPage>[].obs;
  final RxString documentName = ''.obs;
  final RxString selectedFolder = 'Others'.obs;
  final RxBool isGenerating = false.obs;
  final RxString pdfQuality = 'High'.obs;
  final RxBool enablePassword = false.obs;
  final RxString pdfPassword = ''.obs;
  ScanMode scanMode = ScanMode.document;
  late final TextEditingController passwordController;

  @override
  void onInit() {
    super.onInit();
    passwordController = TextEditingController();
    passwordController.addListener(() => pdfPassword.value = passwordController.text);

    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      final rawPages = args['pages'];
      if (rawPages is List<ScannedPage>) {
        pages.value = rawPages;
      }
      documentName.value = (args['name'] as String?) ?? 'Document';
      if (args['scanMode'] == 'idCard') {
        scanMode = ScanMode.idCard;
      } else if (args['scanMode'] != null) {
        scanMode = ScanMode.fromString(args['scanMode'] as String?);
      }
    }
    pdfQuality.value = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>().defaultQuality
        : AppConstants.qualityHigh;
  }

  @override
  void onClose() {
    passwordController.dispose();
    super.onClose();
  }

  bool get isIdCardMode => scanMode.isIdCard;

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
      AppHelpers.showSnackbar('no_pages_generate'.tr, isError: true);
      return;
    }
    if (documentName.value.trim().isEmpty) {
      AppHelpers.showSnackbar('enter_document_name'.tr, isError: true);
      return;
    }
    if (enablePassword.value && pdfPassword.value.trim().length < 4) {
      AppHelpers.showSnackbar('password_min_length'.tr, isError: true);
      return;
    }
    if (isIdCardMode && pages.length < 2) {
      AppHelpers.showSnackbar('id_card_need_both'.tr, isError: true);
      return;
    }

    AppHelpers.showLoading('generating_pdf'.tr);
    isGenerating.value = true;

    try {
      final rawPaths = pages.map((p) => p.imagePath).toList();
      final imagePaths = <String>[];
      for (final path in rawPaths) {
        imagePaths.add(await _imageService.saveImageToDocsnap(path));
      }

      final password =
          enablePassword.value ? pdfPassword.value.trim() : null;

      final String pdfPath;
      if (isIdCardMode) {
        pdfPath = await _pdfService.generateIdCardPdf(
          name: documentName.value.trim(),
          frontPath: imagePaths[0],
          backPath: imagePaths[1],
          quality: pdfQuality.value,
          userPassword: password,
        );
      } else {
        pdfPath = await _pdfService.generatePdf(
          name: documentName.value.trim(),
          imagesPaths: imagePaths,
          quality: pdfQuality.value,
          userPassword: password,
        );
      }

      final fileSize = await _pdfService.getPdfFileSize(pdfPath);
      final thumbnail = imagePaths.isNotEmpty
          ? await _imageService.generateThumbnail(imagePaths.first)
          : null;

      final doc = DocumentModel(
        name: documentName.value.trim(),
        pdfPath: pdfPath,
        pageImagePaths: imagePaths,
        pageCount: isIdCardMode ? 1 : pages.length,
        folder: selectedFolder.value,
        sizeBytes: fileSize,
        thumbnailPath: thumbnail,
        isPasswordProtected: password != null && password.isNotEmpty,
      );

      _repository.saveDocument(doc);
      AppHelpers.hideLoading();

      if (Get.isRegistered<AnalyticsService>()) {
        await Get.find<AnalyticsService>().logPdfGenerated(
          pageCount: isIdCardMode ? 1 : pages.length,
          quality: pdfQuality.value,
        );
      }

      try {
        await Get.find<AdService>().showInterstitialIfReady();
      } catch (_) {}

      if (Get.isRegistered<ReviewPromptService>()) {
        Get.find<ReviewPromptService>().recordPdfGenerated();
      }

      await AppHelpers.finishWithSnackbar('pdf_saved_success'.tr);
    } catch (e) {
      AppHelpers.hideLoading();
      AppHelpers.showSnackbar(
        'failed_generate_pdf'.trParams({'error': '$e'}),
        isError: true,
      );
    } finally {
      isGenerating.value = false;
    }
  }
}
