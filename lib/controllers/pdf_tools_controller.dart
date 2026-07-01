import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/document_model.dart';
import '../repositories/document_repository.dart';
import '../services/ad_service.dart';
import '../services/analytics_service.dart';
import '../services/image_processing_service.dart';
import '../services/pdf_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_helpers.dart';

enum PdfToolMode { merge, split, compress, watermark, sign }

class PdfToolsController extends GetxController {
  final DocumentRepository _repository;
  final PdfService _pdfService;
  final _imageService = Get.find<ImageProcessingService>();

  PdfToolsController(this._repository, this._pdfService);

  late PdfToolMode mode;
  final RxList<DocumentModel> allDocuments = <DocumentModel>[].obs;
  final RxList<String> selectedDocIds = <String>[].obs;
  final RxSet<int> selectedPageIndices = <int>{}.obs;
  final RxString outputName = ''.obs;
  final RxString watermarkText = 'CONFIDENTIAL'.obs;
  final RxString quality = AppConstants.qualityHigh.obs;
  final RxBool isProcessing = false.obs;
  final Rxn<DocumentModel> splitSource = Rxn<DocumentModel>();
  late final TextEditingController nameController;
  late final TextEditingController watermarkController;

  String get modeTitle {
    switch (mode) {
      case PdfToolMode.merge:
        return 'merge_pdfs_title'.tr;
      case PdfToolMode.split:
        return 'split_pdf_title'.tr;
      case PdfToolMode.compress:
        return 'compress_pdf_title'.tr;
      case PdfToolMode.watermark:
        return 'add_watermark'.tr;
      case PdfToolMode.sign:
        return 'sign_pdf_title'.tr;
    }
  }

  String get modeSubtitle {
    switch (mode) {
      case PdfToolMode.merge:
        return 'merge_subtitle'.tr;
      case PdfToolMode.split:
        return 'split_subtitle'.tr;
      case PdfToolMode.compress:
        return 'compress_subtitle'.tr;
      case PdfToolMode.watermark:
        return 'watermark_subtitle'.tr;
      case PdfToolMode.sign:
        return 'sign_subtitle'.tr;
    }
  }

  bool get canProcess {
    switch (mode) {
      case PdfToolMode.merge:
        return selectedDocIds.length >= 2 && outputName.value.trim().isNotEmpty;
      case PdfToolMode.split:
        return splitSource.value != null &&
            selectedPageIndices.isNotEmpty &&
            outputName.value.trim().isNotEmpty;
      case PdfToolMode.compress:
        return selectedDocIds.length == 1 && outputName.value.trim().isNotEmpty;
      case PdfToolMode.watermark:
        return selectedDocIds.length == 1 &&
            watermarkText.value.trim().isNotEmpty &&
            outputName.value.trim().isNotEmpty;
      case PdfToolMode.sign:
        return selectedDocIds.length == 1;
    }
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final modeStr = args?['mode'] as String? ?? 'merge';
    mode = PdfToolMode.values.firstWhere(
      (m) => m.name == modeStr,
      orElse: () => PdfToolMode.merge,
    );
    outputName.value = _defaultOutputName();
    nameController = TextEditingController(text: outputName.value);
    watermarkController = TextEditingController(text: watermarkText.value);
    nameController.addListener(() => outputName.value = nameController.text);
    watermarkController
        .addListener(() => watermarkText.value = watermarkController.text);
    _loadDocuments();
  }

  @override
  void onClose() {
    nameController.dispose();
    watermarkController.dispose();
    super.onClose();
  }

  String _defaultOutputName() {
    final now = DateTime.now();
    final stamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    switch (mode) {
      case PdfToolMode.merge:
        return 'Merged_$stamp';
      case PdfToolMode.split:
        return 'Split_$stamp';
      case PdfToolMode.compress:
        return 'Compressed_$stamp';
      case PdfToolMode.watermark:
        return 'Watermarked_$stamp';
      case PdfToolMode.sign:
        return 'Signed_$stamp';
    }
  }

  void _loadDocuments() {
    allDocuments.value = _repository.getAllDocuments();
  }

  void toggleDocument(String id) {
    if (mode == PdfToolMode.merge) {
      if (selectedDocIds.contains(id)) {
        selectedDocIds.remove(id);
      } else {
        selectedDocIds.add(id);
      }
      return;
    }

    selectedDocIds.value = [id];
    if (mode == PdfToolMode.split) {
      final doc = allDocuments.firstWhereOrNull((d) => d.id == id);
      splitSource.value = doc;
      selectedPageIndices.clear();
    }
  }

  void togglePage(int index) {
    if (selectedPageIndices.contains(index)) {
      selectedPageIndices.remove(index);
    } else {
      selectedPageIndices.add(index);
    }
    selectedPageIndices.refresh();
  }

  void selectAllPages() {
    final doc = splitSource.value;
    if (doc == null) return;
    selectedPageIndices
      ..clear()
      ..addAll(List.generate(doc.pageCount, (i) => i));
    selectedPageIndices.refresh();
  }

  void clearPageSelection() {
    selectedPageIndices.clear();
    selectedPageIndices.refresh();
  }

  Future<void> process() async {
    if (!canProcess || isProcessing.value) return;

    if (mode == PdfToolMode.sign) {
      final doc = _selectedSingleDoc();
      final result =
          await Get.toNamed(AppConstants.signatureRoute, arguments: doc);
      if (result is DocumentModel) {
        Get.offNamed(AppConstants.pdfViewerRoute, arguments: result);
      }
      return;
    }

    isProcessing.value = true;
    AppHelpers.showLoading('processing'.tr);

    try {
      switch (mode) {
        case PdfToolMode.merge:
          await _processMerge();
          break;
        case PdfToolMode.split:
          await _processSplit();
          break;
        case PdfToolMode.compress:
          await _processCompress();
          break;
        case PdfToolMode.watermark:
          await _processWatermark();
          break;
        case PdfToolMode.sign:
          break;
      }
      if (Get.isRegistered<AnalyticsService>()) {
        await Get.find<AnalyticsService>().logPdfToolUsed(mode.name);
      }
      AppHelpers.hideLoading();
      try {
        await Get.find<AdService>().showInterstitialIfReady();
      } catch (_) {}
      await AppHelpers.finishWithSnackbar(
        'pdf_saved_documents'.tr,
        goToDocuments: true,
      );
    } catch (e) {
      AppHelpers.hideLoading();
      AppHelpers.showSnackbar('failed_generic'.trParams({'error': '$e'}), isError: true);
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _processMerge() async {
    final selected = allDocuments
        .where((d) => selectedDocIds.contains(d.id))
        .toList();
    final images = selected.expand((d) => d.pageImagePaths).toList();
    if (images.isEmpty) {
      throw Exception('Selected documents have no page images.');
    }

    for (final path in images) {
      if (!File(path).existsSync()) {
        throw Exception(
          'Some page images are missing. Re-scan those documents and try again.',
        );
      }
    }

    await _saveDocument(
      name: outputName.value.trim(),
      images: images,
      quality: quality.value,
      folder: selected.first.folder,
    );
  }

  Future<void> _processSplit() async {
    final doc = splitSource.value;
    if (doc == null) throw Exception('No document selected.');

    final indices = selectedPageIndices.toList()..sort();
    final images = indices
        .where((i) => i >= 0 && i < doc.pageImagePaths.length)
        .map((i) => doc.pageImagePaths[i])
        .toList();

    if (images.isEmpty) {
      throw Exception('No pages selected.');
    }

    await _saveDocument(
      name: outputName.value.trim(),
      images: images,
      quality: quality.value,
      folder: doc.folder,
    );
  }

  Future<void> _processCompress() async {
    final doc = _selectedSingleDoc();
    final pdfPath = await _pdfService.compressPdf(
      name: outputName.value.trim(),
      imagesPaths: doc.pageImagePaths,
      quality: quality.value,
    );
    await _persistDocument(doc, pdfPath, outputName.value.trim());
  }

  Future<void> _processWatermark() async {
    final doc = _selectedSingleDoc();
    final pdfPath = await _pdfService.addWatermark(
      name: outputName.value.trim(),
      imagesPaths: doc.pageImagePaths,
      watermarkText: watermarkText.value.trim(),
      quality: quality.value,
    );
    await _persistDocument(doc, pdfPath, outputName.value.trim());
  }

  DocumentModel _selectedSingleDoc() {
    final doc =
        allDocuments.firstWhereOrNull((d) => selectedDocIds.contains(d.id));
    if (doc == null || doc.pageImagePaths.isEmpty) {
      throw Exception('Select a document with page images.');
    }
    return doc;
  }

  Future<void> _saveDocument({
    required String name,
    required List<String> images,
    required String quality,
    required String folder,
  }) async {
    final pdfPath = await _pdfService.mergeImagesToPdf(
      name: name,
      imagesPaths: images,
      quality: quality,
    );
    final fileSize = await _pdfService.getPdfFileSize(pdfPath);
    final thumbnail =
        images.isNotEmpty ? await _imageService.generateThumbnail(images.first) : null;

    _repository.saveDocument(
      DocumentModel(
        name: name,
        pdfPath: pdfPath,
        pageImagePaths: images,
        pageCount: images.length,
        folder: folder,
        sizeBytes: fileSize,
        thumbnailPath: thumbnail,
      ),
    );
  }

  Future<void> _persistDocument(
    DocumentModel source,
    String pdfPath,
    String name,
  ) async {
    final fileSize = await _pdfService.getPdfFileSize(pdfPath);
    final thumbnail = source.thumbnailPath ??
        (source.pageImagePaths.isNotEmpty
            ? await _imageService.generateThumbnail(source.pageImagePaths.first)
            : null);

    _repository.saveDocument(
      DocumentModel(
        name: name,
        pdfPath: pdfPath,
        pageImagePaths: List<String>.from(source.pageImagePaths),
        pageCount: source.pageCount,
        folder: source.folder,
        sizeBytes: fileSize,
        thumbnailPath: thumbnail,
      ),
    );
  }
}
