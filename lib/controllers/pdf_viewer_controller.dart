import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/document_model.dart';
import '../repositories/document_repository.dart';
import '../services/ad_service.dart';
import '../services/print_service.dart';
import '../services/share_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_helpers.dart';

class PdfViewerController extends GetxController {
  final _shareService = Get.find<ShareService>();
  final _repository = Get.find<DocumentRepository>();

  final RxString pdfPath = ''.obs;
  final RxString documentName = ''.obs;
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxBool showControls = true.obs;
  final RxInt pdfReloadKey = 0.obs;
  final RxString pdfPassword = ''.obs;
  final RxBool needsPassword = false.obs;
  late DocumentModel document;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is DocumentModel) {
      document = args;
      pdfPath.value = args.pdfPath;
      documentName.value = args.name;
      totalPages.value = args.pageCount;
      needsPassword.value = args.isPasswordProtected;
      if (needsPassword.value) {
        Future.microtask(promptForPassword);
      }
    }
  }

  Future<void> promptForPassword() async {
    final controller = TextEditingController();
    final password = await Get.dialog<String>(
      AlertDialog(
        title: Text('enter_pdf_password'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('pdf_password_hint'.tr),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'password'.tr,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () => Get.back(result: controller.text),
            child: Text('open'.tr),
          ),
        ],
      ),
    );
    controller.dispose();
    if (password != null && password.isNotEmpty) {
      await setPassword(password);
    }
  }

  void updateCurrentPage(int page) {
    currentPage.value = page;
  }

  void toggleControls() {
    showControls.value = !showControls.value;
  }

  Future<void> setPassword(String password) async {
    pdfPassword.value = password;
    pdfReloadKey.value++;
  }

  Future<void> shareDocument() async {
    await _shareService.shareFile(pdfPath.value, subject: documentName.value);
    await Get.find<AdService>().maybeShowInterstitialOnAction();
  }

  Future<void> printDocument() async {
    try {
      if (!Get.isRegistered<PrintService>()) {
        Get.put(PrintService(), permanent: true);
      }
      await Get.find<PrintService>().printPdf(
        pdfPath.value,
        name: documentName.value,
      );
      await Get.find<AdService>().maybeShowInterstitialOnAction();
    } catch (e) {
      AppHelpers.showSnackbar(
        'print_failed'.trParams({'error': '$e'}),
        isError: true,
      );
    }
  }

  Future<void> openSignature() async {
    final result = await Get.toNamed(AppConstants.signatureRoute, arguments: document);
    if (result is DocumentModel) {
      document = result;
      documentName.value = result.name;
      pdfPath.value = result.pdfPath;
      totalPages.value = result.pageCount;
      pdfReloadKey.value++;
    }
  }

  Future<void> renameDocument() async {
    final newName = await AppHelpers.showRenameDialog(documentName.value);
    if (newName != null && newName.isNotEmpty && newName != documentName.value) {
      _repository.renameDocument(document.id, newName);
      document = document.copyWith(name: newName);
      documentName.value = newName;
      AppHelpers.showSnackbar('renamed_success'.tr);
    }
  }
}
