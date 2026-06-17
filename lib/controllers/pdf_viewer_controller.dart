import 'package:get/get.dart';
import '../models/document_model.dart';
import '../repositories/document_repository.dart';
import '../services/share_service.dart';
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
    }
  }

  void updateCurrentPage(int page) {
    currentPage.value = page;
  }

  void toggleControls() {
    showControls.value = !showControls.value;
  }

  Future<void> shareDocument() async {
    await _shareService.shareFile(pdfPath.value, subject: documentName.value);
  }

  Future<void> openSignature() async {
    final result = await Get.toNamed('/signature', arguments: document);
    if (result is DocumentModel) {
      document = result;
      documentName.value = result.name;
      pdfReloadKey.value++;
    }
  }

  Future<void> renameDocument() async {
    final newName = await AppHelpers.showRenameDialog(documentName.value);
    if (newName != null && newName.isNotEmpty && newName != documentName.value) {
      _repository.renameDocument(document.id, newName);
      document = document.copyWith(name: newName);
      documentName.value = newName;
      AppHelpers.showSnackbar('Renamed successfully.');
    }
  }
}
