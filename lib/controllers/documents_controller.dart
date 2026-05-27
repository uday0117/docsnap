import 'package:get/get.dart';
import '../models/document_model.dart';
import '../repositories/document_repository.dart';
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

  @override
  void onInit() {
    super.onInit();
    loadDocuments();
    ever(searchQuery, (_) => _applyFilters());
    ever(selectedFolder, (_) => _applyFilters());
    ever(sortBy, (_) => _applyFilters());
  }

  void loadDocuments() {
    documents.value = _repository.getAllDocuments();
    _applyFilters();
  }

  void _applyFilters() {
    List<DocumentModel> result;

    if (selectedFolder.value == 'All Documents') {
      result = List<DocumentModel>.from(documents);
    } else {
      result =
          documents.where((d) => d.folder == selectedFolder.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final lower = searchQuery.value.toLowerCase();
      result =
          result.where((d) => d.name.toLowerCase().contains(lower)).toList();
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
  }

  Future<void> renameDocument(DocumentModel doc) async {
    final newName = await AppHelpers.showRenameDialog(doc.name);
    if (newName != null && newName.isNotEmpty && newName != doc.name) {
      _repository.renameDocument(doc.id, newName);
      loadDocuments();
      AppHelpers.showSnackbar('Document renamed successfully.');
    }
  }

  Future<void> deleteDocument(DocumentModel doc) async {
    final confirmed = await AppHelpers.showConfirmDialog(
      title: 'Delete Document',
      message:
          'Are you sure you want to delete "${doc.name}"? This cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (confirmed == true) {
      _repository.deleteDocument(doc.id);
      loadDocuments();
      AppHelpers.showSnackbar('Document deleted.');
    }
  }

  void toggleFavorite(DocumentModel doc) {
    _repository.toggleFavorite(doc.id);
    loadDocuments();
  }

  Future<void> shareDocument(DocumentModel doc) async {
    await _shareService.shareFile(doc.pdfPath, subject: doc.name);
  }

  void moveToFolder(DocumentModel doc, String folder) {
    _repository.moveToFolder(doc.id, folder);
    loadDocuments();
    AppHelpers.showSnackbar('Moved to $folder.');
  }
}
