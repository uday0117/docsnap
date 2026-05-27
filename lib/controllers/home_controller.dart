import 'package:get/get.dart';

import '../models/document_model.dart';
import '../repositories/document_repository.dart';
import '../utils/app_constants.dart';

class HomeController extends GetxController {
  final DocumentRepository _repository;

  HomeController(this._repository);

  final RxList<DocumentModel> recentDocuments = <DocumentModel>[].obs;
  final RxInt totalDocuments = 0.obs;
  final RxInt totalPages = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecentDocuments();
  }

  void loadRecentDocuments() {
    final docs = _repository.getAllDocuments();
    totalDocuments.value = docs.length;
    totalPages.value = docs.fold(0, (sum, d) => sum + d.pageCount);
    recentDocuments.value = docs.take(5).toList();
  }

  void navigateToScanner() {
    Get.toNamed(AppConstants.scannerRoute);
  }

  void navigateToDocuments() {
    Get.toNamed(AppConstants.documentsRoute);
  }

  void navigateToSettings() {
    Get.toNamed(AppConstants.settingsRoute);
  }

  void navigateToSignature() {
    Get.toNamed(AppConstants.signatureRoute);
  }

  void openDocument(DocumentModel doc) {
    Get.toNamed(AppConstants.pdfViewerRoute, arguments: doc);
  }

  void onResumed() {
    loadRecentDocuments();
  }
}
