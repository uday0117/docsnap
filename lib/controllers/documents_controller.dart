import 'package:get/get.dart';
import '../models/document_model.dart';
import '../repositories/document_repository.dart';
import '../services/ad_service.dart';
import '../services/share_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_helpers.dart';

class DocumentsController extends GetxController {
  final DocumentRepository _repository;
  final _shareService = Get.find<ShareService>();

  DocumentsController(this._repository);

  final RxList<DocumentModel> documents = <DocumentModel>[].obs;
  final RxList<DocumentModel> filteredDocuments = <DocumentModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFolder = 'All Documents'.obs;
  final RxBool isSearching = false.obs;
  final RxString sortBy = 'date'.obs;

  final RxBool showFavoritesOnly = false.obs;
  final RxBool showTrashOnly = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDocuments();
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedFolder, (_) => _applyFilters());
    ever(sortBy, (_) => _applyFilters());
    ever(showFavoritesOnly, (_) => _applyFilters());
    ever(showTrashOnly, (_) => _applyFilters());

    final args = Get.arguments as Map<String, dynamic>?;
    if (args?['showFavorites'] == true) {
      showFavoritesOnly.value = true;
    }
  }

  void loadDocuments() {
    if (showTrashOnly.value) {
      documents.value = _repository.getTrashDocuments();
    } else {
      documents.value = _repository.getAllDocuments();
    }
    _applyFilters();
  }

  void _applyFilters() {
    List<DocumentModel> result;

    if (showTrashOnly.value) {
      result = List<DocumentModel>.from(documents);
    } else if (showFavoritesOnly.value) {
      result = documents.where((d) => d.isFavorite).toList();
    } else if (selectedFolder.value == 'All Documents') {
      result = List<DocumentModel>.from(documents);
    } else {
      result =
          documents.where((d) => d.folder == selectedFolder.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      if (showTrashOnly.value) {
        final lower = searchQuery.value.toLowerCase().trim();
        result = result
            .where((d) => d.name.toLowerCase().contains(lower))
            .toList();
      } else {
        result = _repository.searchDocuments(searchQuery.value);
        if (showFavoritesOnly.value) {
          result = result.where((d) => d.isFavorite).toList();
        } else if (selectedFolder.value != 'All Documents') {
          result =
              result.where((d) => d.folder == selectedFolder.value).toList();
        }
      }
    }

    switch (sortBy.value) {
      case 'name':
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'size':
        result.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
        break;
      case 'date':
      default:
        result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }

    filteredDocuments.value = result;
  }

  void setFolder(String folder) {
    selectedFolder.value = folder;
  }

  void setSearch(String query) {
    searchQuery.value = query;
  }

  void setSortBy(String sort) {
    sortBy.value = sort;
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) searchQuery.value = '';
  }

  void openDocument(DocumentModel doc) {
    Get.toNamed(AppConstants.pdfViewerRoute, arguments: doc);
    Get.find<AdService>().maybeShowInterstitialOnAction();
  }

  Future<void> renameDocument(DocumentModel doc) async {
    final newName = await AppHelpers.showRenameDialog(doc.name);
    if (newName != null && newName.isNotEmpty && newName != doc.name) {
      _repository.renameDocument(doc.id, newName);
      loadDocuments();
      AppHelpers.showSnackbar('document_renamed'.tr);
    }
  }

  Future<void> deleteDocument(DocumentModel doc) async {
    if (showTrashOnly.value) {
      await _deletePermanently(doc);
      return;
    }

    final confirmed = await AppHelpers.showConfirmDialog(
      title: 'delete_document'.tr,
      message: 'delete_document_confirm'.trParams({'name': doc.name}),
      confirmText: 'delete'.tr,
      isDestructive: true,
    );
    if (confirmed == true) {
      _repository.deleteDocument(doc.id);
      loadDocuments();
      AppHelpers.showSnackbar('document_moved_trash'.tr);
    }
  }

  Future<void> _deletePermanently(DocumentModel doc) async {
    final confirmed = await AppHelpers.showConfirmDialog(
      title: 'delete_permanently'.tr,
      message: 'delete_permanently_confirm'.trParams({'name': doc.name}),
      confirmText: 'delete'.tr,
      isDestructive: true,
    );
    if (confirmed == true) {
      _repository.deleteDocument(doc.id, permanent: true);
      loadDocuments();
      AppHelpers.showSnackbar('document_deleted_permanently'.tr);
    }
  }

  void restoreDocument(DocumentModel doc) {
    _repository.restoreDocument(doc.id);
    loadDocuments();
    AppHelpers.showSnackbar('document_restored'.tr);
  }

  Future<void> emptyTrash() async {
    final confirmed = await AppHelpers.showConfirmDialog(
      title: 'empty_trash'.tr,
      message: 'empty_trash_confirm'.tr,
      confirmText: 'empty_trash'.tr,
      isDestructive: true,
    );
    if (confirmed == true) {
      _repository.emptyTrash();
      loadDocuments();
      AppHelpers.showSnackbar('trash_emptied'.tr);
    }
  }

  void toggleTrashView() {
    showTrashOnly.value = !showTrashOnly.value;
    if (showTrashOnly.value) {
      showFavoritesOnly.value = false;
      isSearching.value = false;
      searchQuery.value = '';
    }
    loadDocuments();
  }

  void togglePinned(DocumentModel doc) {
    _repository.togglePinned(doc.id);
    loadDocuments();
  }

  void toggleFavorite(DocumentModel doc) {
    _repository.toggleFavorite(doc.id);
    loadDocuments();
  }

  Future<void> shareDocument(DocumentModel doc) async {
    await _shareService.shareFile(doc.pdfPath, subject: doc.name);
    await Get.find<AdService>().maybeShowInterstitialOnAction();
  }

  void moveToFolder(DocumentModel doc, String folder) {
    _repository.moveToFolder(doc.id, folder);
    loadDocuments();
    AppHelpers.showSnackbar('moved_to_folder'.trParams({'folder': folder}));
  }
}
