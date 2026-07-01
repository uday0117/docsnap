import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/cloud_backup_model.dart';
import '../repositories/document_repository.dart';
import '../services/cloud_backup_service.dart';
import '../utils/app_helpers.dart';

class CloudBackupController extends GetxController {
  final CloudBackupService _cloudService;
  final DocumentRepository _repository;

  CloudBackupController(this._cloudService, this._repository);

  List<CloudAccount> get accounts => _cloudService.connectedAccounts;
  bool get isBusy => _cloudService.isBusy.value;

  Future<void> connect(CloudProvider provider) async {
    try {
      switch (provider) {
        case CloudProvider.googleDrive:
          await _cloudService.connectGoogleDrive();
        case CloudProvider.dropbox:
          await _cloudService.connectDropbox();
        case CloudProvider.oneDrive:
          await _cloudService.connectOneDrive();
      }
      AppHelpers.showSnackbar('cloud_connected'.tr);
    } catch (e) {
      AppHelpers.showSnackbar(
        'failed_generic'.trParams({'error': '$e'}),
        isError: true,
      );
    }
  }

  Future<void> disconnect(CloudProvider provider) async {
    await _cloudService.disconnect(provider);
    AppHelpers.showSnackbar('cloud_disconnected'.tr);
  }

  Future<void> backupNow() async {
    AppHelpers.showLoading('cloud_backup_in_progress'.tr);
    try {
      final docs = _repository.getAllDocuments();
      await _cloudService.backupDocuments(docs);
      AppHelpers.hideLoading();
      AppHelpers.showSnackbar('cloud_backup_complete'.tr);
    } catch (e) {
      AppHelpers.hideLoading();
      AppHelpers.showSnackbar(
        'failed_generic'.trParams({'error': '$e'}),
        isError: true,
      );
    }
  }

  Future<void> restoreFrom(CloudProvider provider) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('cloud_restore_title'.tr),
        content: Text('cloud_restore_confirm'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text('restore'.tr),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    AppHelpers.showLoading('cloud_restore_in_progress'.tr);
    try {
      final docs = await _cloudService.restoreLatest(provider);
      _repository.replaceAllDocuments(docs);
      AppHelpers.hideLoading();
      AppHelpers.showSnackbar('cloud_restore_complete'.tr);
      AppHelpers.refreshDocumentLists();
    } catch (e) {
      AppHelpers.hideLoading();
      AppHelpers.showSnackbar(
        'failed_generic'.trParams({'error': '$e'}),
        isError: true,
      );
    }
  }
}
