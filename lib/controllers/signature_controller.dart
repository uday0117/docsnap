import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/document_model.dart';
import '../models/signature_model.dart';
import '../repositories/document_repository.dart';
import '../repositories/signature_repository.dart';
import '../services/ad_service.dart';
import '../services/pdf_service.dart';
import '../services/share_service.dart';
import '../utils/app_helpers.dart';

class SignatureController extends GetxController {
  final SignatureRepository _repository;
  final _shareService = Get.find<ShareService>();
  final _documentRepository = Get.find<DocumentRepository>();
  final _pdfService = Get.find<PdfService>();
  final _adService = Get.find<AdService>();

  SignatureController(this._repository);

  final RxList<SignatureModel> signatures = <SignatureModel>[].obs;
  final RxBool isDrawing = false.obs;
  final RxBool hasSignature = false.obs;
  final RxDouble strokeWidth = 3.0.obs;
  final Rx<Color> strokeColor = Colors.black.obs;
  final Rxn<DocumentModel> targetDocument = Rxn<DocumentModel>();

  @override
  void onInit() {
    super.onInit();
    loadSignatures();
    final args = Get.arguments;
    if (args is DocumentModel) {
      targetDocument.value = args;
    }
  }

  void loadSignatures() {
    signatures.value = _repository.getAllSignatures();
  }

  void onSignatureChanged(bool hasSig) {
    hasSignature.value = hasSig;
  }

  Future<void> saveSignature(Uint8List signatureBytes) async {
    AppHelpers.showLoading('processing'.tr);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final sigDir = Directory(p.join(dir.path, 'docsnap', 'signatures'));
      await sigDir.create(recursive: true);
      final fileName = '${const Uuid().v4()}.png';
      final filePath = p.join(sigDir.path, fileName);
      await File(filePath).writeAsBytes(signatureBytes);

      final signature = SignatureModel(
        name: 'Signature ${signatures.length + 1}',
        imagePath: filePath,
      );
      _repository.saveSignature(signature);
      loadSignatures();
      AppHelpers.hideLoading();

      Get.dialog(
        AlertDialog(
          title: Text('signature_saved'.tr),
          content: Text('watch_ad_subtitle'.tr),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                if (targetDocument.value != null) {
                  _applySignatureToDocument(filePath);
                }
              },
              child: Text('no_thanks'.tr),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                await _adService.showRewardedAdIfReady();
                if (targetDocument.value != null) {
                  await _applySignatureToDocument(filePath);
                }
              },
              child: Text('watch_ad'.tr),
            ),
          ],
        ),
      );
    } catch (e) {
      AppHelpers.hideLoading();
      AppHelpers.showSnackbar(
        'failed_save'.trParams({'error': '$e'}),
        isError: true,
      );
    }
  }

  Future<void> applySavedSignatureToDocument(SignatureModel sig) async {
    final doc = targetDocument.value;
    if (doc == null) {
      Get.back(result: sig);
      return;
    }

    await _applySignatureToDocument(sig.imagePath);
  }

  Future<void> _applySignatureToDocument(String signaturePath) async {
    final doc = targetDocument.value;
    if (doc == null) return;

    AppHelpers.showLoading('processing'.tr);
    try {
      final result = await _pdfService.applySignatureToPdf(
        pdfPath: doc.pdfPath,
        pageImagePaths: doc.pageImagePaths,
        signatureImagePath: signaturePath,
      );

      final newSize = await _pdfService.getPdfFileSize(result.pdfPath);
      final updated = doc.copyWith(
        pageImagePaths: result.pageImagePaths,
        sizeBytes: newSize,
        updatedAt: DateTime.now(),
      );
      _documentRepository.saveDocument(updated);
      targetDocument.value = updated;

      AppHelpers.hideLoading();
      AppHelpers.showSnackbar('signature_applied'.tr);
      Get.back(result: updated);
    } catch (e) {
      AppHelpers.hideLoading();
      AppHelpers.showSnackbar(
        'failed_apply_signature'.trParams({'error': '$e'}),
        isError: true,
      );
    }
  }

  Future<void> deleteSignature(SignatureModel sig) async {
    final confirmed = await AppHelpers.showConfirmDialog(
      title: 'delete_signature'.tr,
      message: 'delete_signature_confirm'.tr,
      confirmText: 'delete'.tr,
      isDestructive: true,
    );
    if (confirmed == true) {
      _repository.deleteSignature(sig.id);
      loadSignatures();
    }
  }

  void setStrokeWidth(double width) {
    strokeWidth.value = width;
  }

  void setStrokeColor(Color color) {
    strokeColor.value = color;
  }

  void selectSavedSignature(SignatureModel sig) {
    if (targetDocument.value != null) {
      applySavedSignatureToDocument(sig);
    } else {
      Get.back(result: sig);
    }
  }

  Future<void> shareSignature(SignatureModel sig) async {
    try {
      if (!File(sig.imagePath).existsSync()) {
        AppHelpers.showSnackbar('signature_not_found'.tr, isError: true);
        return;
      }
      await _shareService.shareFile(
        sig.imagePath,
        subject: 'My Signature - ${sig.name}',
      );
    } catch (e) {
      AppHelpers.showSnackbar(
        'failed_to_share'.trParams({'error': '$e'}),
        isError: true,
      );
    }
  }
}
