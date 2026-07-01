import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import '../models/document_model.dart';
import '../repositories/document_repository.dart';
import '../services/ad_service.dart';
import '../services/analytics_service.dart';
import '../utils/app_helpers.dart';

class OcrController extends GetxController {
  final DocumentRepository _repository;
  final _picker = ImagePicker();
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  OcrController(this._repository);

  final RxList<DocumentModel> documents = <DocumentModel>[].obs;
  final RxString imagePath = ''.obs;
  final RxString extractedText = ''.obs;
  final RxBool isProcessing = false.obs;
  final RxBool fromDocument = false.obs;

  @override
  void onInit() {
    super.onInit();
    documents.value = _repository.getAllDocuments();
  }

  @override
  void onClose() {
    _recognizer.close();
    super.onClose();
  }

  Future<void> pickFromGallery() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      fromDocument.value = false;
      imagePath.value = image.path;
      await _runOcr(image.path);
    } catch (e) {
      AppHelpers.showSnackbar('could_not_open_gallery'.tr, isError: true);
    }
  }

  Future<void> pickFromCamera() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return;
      fromDocument.value = false;
      imagePath.value = image.path;
      await _runOcr(image.path);
    } catch (e) {
      AppHelpers.showSnackbar('could_not_open_camera'.tr, isError: true);
    }
  }

  Future<void> extractFromDocumentPage(DocumentModel doc, int pageIndex) async {
    if (pageIndex < 0 || pageIndex >= doc.pageImagePaths.length) {
      AppHelpers.showSnackbar('invalid_page'.tr, isError: true);
      return;
    }
    fromDocument.value = true;
    imagePath.value = doc.pageImagePaths[pageIndex];
    await _runOcr(doc.pageImagePaths[pageIndex]);
  }

  Future<void> _runOcr(String path) async {
    if (!File(path).existsSync()) {
      AppHelpers.showSnackbar('image_not_found'.tr, isError: true);
      return;
    }

    isProcessing.value = true;
    extractedText.value = '';

    try {
      final input = InputImage.fromFilePath(path);
      final result = await _recognizer.processImage(input);
      extractedText.value = result.text.trim();

      if (extractedText.value.isEmpty) {
        AppHelpers.showSnackbar(
          'no_text_detected'.tr,
          title: 'no_text_found'.tr,
        );
      } else {
        if (Get.isRegistered<AnalyticsService>()) {
          await Get.find<AnalyticsService>().logOcrUsed(
            source: fromDocument.value ? 'document' : 'image',
          );
        }
        try {
          await Get.find<AdService>().showInterstitialIfReady();
        } catch (_) {}
      }
    } catch (e) {
      AppHelpers.showSnackbar(
        'ocr_failed'.trParams({'error': '$e'}),
        isError: true,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  void copyText() {
    if (extractedText.value.isEmpty) return;
    Clipboard.setData(ClipboardData(text: extractedText.value));
    AppHelpers.showSnackbar('text_copied'.tr, title: 'copied'.tr);
  }

  void clearResult() {
    imagePath.value = '';
    extractedText.value = '';
    fromDocument.value = false;
  }
}
