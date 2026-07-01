import 'package:get/get.dart';

import '../models/document_model.dart';
import '../controllers/main_shell_controller.dart';
import '../repositories/document_repository.dart';
import '../services/ad_service.dart';
import '../services/analytics_service.dart';
import '../services/share_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_helpers.dart';

class HomeController extends GetxController {
  final DocumentRepository _repository;
  final _shareService = Get.find<ShareService>();

  HomeController(this._repository);

  final RxList<DocumentModel> recentDocuments = <DocumentModel>[].obs;
  final RxList<DocumentModel> pinnedDocuments = <DocumentModel>[].obs;
  final RxInt totalDocuments = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxInt totalStorageBytes = 0.obs;
  final RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecentDocuments();
  }

  void loadRecentDocuments() {
    final docs = _repository.getAllDocuments()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    totalDocuments.value = docs.length;
    totalPages.value = docs.fold(0, (sum, d) => sum + d.pageCount);
    totalStorageBytes.value = docs.fold(0, (sum, d) => sum + d.sizeBytes);
    pinnedDocuments.value = docs.where((d) => d.isPinned).take(4).toList();
    recentDocuments.value = docs.take(6).toList();
  }

  Future<void> refreshData() async {
    isRefreshing.value = true;
    await Future.delayed(const Duration(milliseconds: 400));
    loadRecentDocuments();
    isRefreshing.value = false;
  }

  void _switchTab(int index, {Map<String, dynamic>? arguments}) {
    if (Get.isRegistered<MainShellController>()) {
      Get.find<MainShellController>().switchToTab(index, arguments: arguments);
    }
  }

  void navigateToScanner({bool openGallery = false, bool idCard = false}) {
    if (Get.isRegistered<AnalyticsService>()) {
      Get.find<AnalyticsService>().logScanStarted(
        source: openGallery ? 'gallery' : (idCard ? 'id_card' : 'camera'),
      );
    }
    final args = <String, dynamic>{};
    if (openGallery) args['openGallery'] = true;
    if (idCard) args['scanMode'] = 'idCard';
    Get.toNamed(
      AppConstants.scannerRoute,
      arguments: args.isEmpty ? null : args,
    );
  }

  void navigateToGalleryImport() {
    navigateToScanner(openGallery: true);
  }

  void navigateToIdCardScanner() {
    navigateToScanner(idCard: true);
  }

  void navigateToDocuments({bool favoritesOnly = false}) {
    if (Get.isRegistered<MainShellController>()) {
      _switchTab(
        1,
        arguments: favoritesOnly ? {'showFavorites': true} : null,
      );
      return;
    }
    Get.toNamed(
      AppConstants.documentsRoute,
      arguments: favoritesOnly ? {'showFavorites': true} : null,
    );
  }

  void navigateToSettings() {
    if (Get.isRegistered<MainShellController>()) {
      _switchTab(3);
      return;
    }
    Get.toNamed(AppConstants.settingsRoute);
  }

  void navigateToTools() {
    if (Get.isRegistered<MainShellController>()) {
      _switchTab(2);
      return;
    }
    Get.toNamed(AppConstants.toolsRoute);
  }

  void navigateToSignature() {
    Get.toNamed(AppConstants.signatureRoute);
  }

  void openDocument(DocumentModel doc) {
    Get.toNamed(AppConstants.pdfViewerRoute, arguments: doc);
    Get.find<AdService>().maybeShowInterstitialOnAction();
  }

  Future<void> shareDocument(DocumentModel doc) async {
    try {
      await _shareService.shareFile(doc.pdfPath, subject: doc.name);
    } catch (e) {
      AppHelpers.showSnackbar(
        'failed_to_share'.trParams({'error': '$e'}),
        isError: true,
      );
    }
  }

  void onResumed() {
    loadRecentDocuments();
  }
}
