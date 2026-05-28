import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/signature_model.dart';
import '../repositories/signature_repository.dart';
import '../services/share_service.dart';
import '../utils/app_helpers.dart';

class SignatureController extends GetxController {
  final SignatureRepository _repository;
  final _shareService = Get.find<ShareService>();

  SignatureController(this._repository);

  final RxList<SignatureModel> signatures = <SignatureModel>[].obs;
  final RxBool isDrawing = false.obs;
  final RxBool hasSignature = false.obs;
  final RxDouble strokeWidth = 3.0.obs;
  final Rx<Color> strokeColor = Colors.black.obs;

  @override
  void onInit() {
    super.onInit();
    loadSignatures();
  }

  void loadSignatures() {
    signatures.value = _repository.getAllSignatures();
  }

  void onSignatureChanged(bool hasSig) {
    hasSignature.value = hasSig;
  }

  Future<void> saveSignature(Uint8List signatureBytes) async {
    AppHelpers.showLoading('Saving signature...');
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
      AppHelpers.showSnackbar('Signature saved!');
    } catch (e) {
      AppHelpers.hideLoading();
      AppHelpers.showSnackbar('Failed to save: $e', isError: true);
    }
  }

  Future<void> deleteSignature(SignatureModel sig) async {
    final confirmed = await AppHelpers.showConfirmDialog(
      title: 'Delete Signature',
      message: 'Are you sure you want to delete this signature?',
      confirmText: 'Delete',
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
    Get.back(result: sig);
  }

  Future<void> shareSignature(SignatureModel sig) async {
    try {
      if (!File(sig.imagePath).existsSync()) {
        AppHelpers.showSnackbar('Signature file not found', isError: true);
        return;
      }
      await _shareService.shareFile(
        sig.imagePath,
        subject: 'My Signature - ${sig.name}',
      );
    } catch (e) {
      AppHelpers.showSnackbar('Failed to share: $e', isError: true);
    }
  }
}
