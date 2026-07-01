import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../models/annotation_model.dart';
import '../models/document_model.dart';
import '../repositories/document_repository.dart';
import '../services/annotation_service.dart';
import '../services/image_processing_service.dart';
import '../services/pdf_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_helpers.dart';

class AnnotationController extends GetxController {
  final DocumentRepository _repository;
  final AnnotationService _annotationService;
  final _imageService = Get.find<ImageProcessingService>();
  final _pdfService = Get.find<PdfService>();
  final _picker = ImagePicker();

  AnnotationController(this._repository, this._annotationService);

  final RxnString imagePath = RxnString();
  final Rx<AnnotationType> activeTool = AnnotationType.draw.obs;
  final Rx<Color> strokeColor = Colors.red.obs;
  final RxDouble strokeWidth = 3.0.obs;
  final RxList<AnnotationStroke> strokes = <AnnotationStroke>[].obs;
  final RxList<AnnotationShape> shapes = <AnnotationShape>[].obs;
  final RxList<AnnotationTextStamp> textStamps = <AnnotationTextStamp>[].obs;
  final RxBool isSaving = false.obs;
  final Rxn<DocumentModel> targetDocument = Rxn<DocumentModel>();
  final RxInt targetPageIndex = 0.obs;
  final RxnString resultPath = RxnString();

  List<Offset> _currentPoints = [];
  Offset? _shapeStart;
  Size _canvasSize = Size.zero;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is DocumentModel) {
      targetDocument.value = args;
      if (args.pageImagePaths.isNotEmpty) {
        imagePath.value = args.pageImagePaths.first;
      }
    } else if (args is Map<String, dynamic>) {
      final doc = args['document'] as DocumentModel?;
      final page = args['pageIndex'] as int? ?? 0;
      targetDocument.value = doc;
      targetPageIndex.value = page;
      if (doc != null && doc.pageImagePaths.length > page) {
        imagePath.value = doc.pageImagePaths[page];
      } else if (args['imagePath'] is String) {
        imagePath.value = args['imagePath'] as String;
      }
    }
  }

  void setCanvasSize(Size size) => _canvasSize = size;

  void setTool(AnnotationType tool) => activeTool.value = tool;

  void setStrokeColor(Color color) => strokeColor.value = color;

  void onPanStart(Offset local) {
    if (activeTool.value == AnnotationType.draw) {
      _currentPoints = [local];
    } else if (activeTool.value == AnnotationType.text) {
      _promptTextStamp(local);
    } else {
      _shapeStart = local;
    }
  }

  void onPanUpdate(Offset local) {
    if (activeTool.value == AnnotationType.draw) {
      _currentPoints = [..._currentPoints, local];
      update(['canvas']);
      return;
    }
  }

  void onPanEnd(Offset local) {
    if (activeTool.value == AnnotationType.draw) {
      if (_currentPoints.length >= 2) {
        strokes.add(AnnotationStroke(
          points: List.from(_currentPoints),
          color: strokeColor.value,
          strokeWidth: strokeWidth.value,
        ));
      }
      _currentPoints = [];
      strokes.refresh();
      return;
    }

    final start = _shapeStart;
    if (start == null) return;
    final rect = Rect.fromPoints(start, local);
    if (rect.width.abs() < 4 && rect.height.abs() < 4) {
      _shapeStart = null;
      return;
    }

    shapes.add(AnnotationShape(
      type: activeTool.value,
      rect: rect,
      color: strokeColor.value,
      strokeWidth: strokeWidth.value,
    ));
    _shapeStart = null;
    shapes.refresh();
  }

  List<Offset> get previewPoints => List.unmodifiable(_currentPoints);

  Future<void> _promptTextStamp(Offset position) async {
    final controller = TextEditingController();
    final text = await Get.dialog<String>(
      AlertDialog(
        title: Text('add_text_stamp'.tr),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: 'text_hint'.tr),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () => Get.back(result: controller.text),
            child: Text('add'.tr),
          ),
        ],
      ),
    );
    controller.dispose();
    if (text == null || text.trim().isEmpty) return;

    textStamps.add(AnnotationTextStamp(
      text: text.trim(),
      position: position,
      color: strokeColor.value,
    ));
    textStamps.refresh();
  }

  void undo() {
    if (textStamps.isNotEmpty) {
      textStamps.removeLast();
    } else if (shapes.isNotEmpty) {
      shapes.removeLast();
    } else if (strokes.isNotEmpty) {
      strokes.removeLast();
    }
  }

  void clearAll() {
    strokes.clear();
    shapes.clear();
    textStamps.clear();
  }

  Future<void> pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      imagePath.value = file.path;
      clearAll();
    }
  }

  Future<void> saveAnnotatedImage() async {
    final path = imagePath.value;
    if (path == null || _canvasSize == Size.zero) {
      AppHelpers.showSnackbar('pick_image_first'.tr, isError: true);
      return;
    }

    isSaving.value = true;
    AppHelpers.showLoading('processing'.tr);
    try {
      final outPath = await _annotationService.renderAnnotations(
        imagePath: path,
        strokes: strokes.toList(),
        shapes: shapes.toList(),
        textStamps: textStamps.toList(),
        canvasSize: _canvasSize,
      );
      resultPath.value = outPath;

      final doc = targetDocument.value;
      if (doc != null) {
        await _updateDocumentPage(doc, outPath);
      }

      AppHelpers.hideLoading();
      AppHelpers.showSnackbar('annotation_saved'.tr);
    } catch (e) {
      AppHelpers.hideLoading();
      AppHelpers.showSnackbar(
        'failed_generic'.trParams({'error': '$e'}),
        isError: true,
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _updateDocumentPage(DocumentModel doc, String newPagePath) async {
    final pageIndex = targetPageIndex.value;
    final pages = List<String>.from(doc.pageImagePaths);
    if (pageIndex >= 0 && pageIndex < pages.length) {
      pages[pageIndex] = newPagePath;
    }

    final pdfPath = await _pdfService.generatePdf(
      name: doc.name,
      imagesPaths: pages,
      quality: AppConstants.qualityHigh,
    );
    final fileSize = await _pdfService.getPdfFileSize(pdfPath);
    final thumbnail = pages.isNotEmpty
        ? await _imageService.generateThumbnail(pages.first)
        : doc.thumbnailPath;

    _repository.saveDocument(
      doc.copyWith(
        pdfPath: pdfPath,
        pageImagePaths: pages,
        sizeBytes: fileSize,
        thumbnailPath: thumbnail,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> shareResult() async {
    final path = resultPath.value ?? imagePath.value;
    if (path == null || !File(path).existsSync()) return;
    await Share.shareXFiles([XFile(path)]);
  }
}
