import 'package:get/get.dart';
import '../models/document_model.dart';
import '../services/share_service.dart';
import '../utils/app_helpers.dart';

class PdfViewerController extends GetxController {
  final _shareService = Get.find<ShareService>();

  final RxString pdfPath = ''.obs;
  final RxString documentName = ''.obs;
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 0.obs;
  final RxBool showControls = true.obs;
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

  void openSignature() {
    Get.toNamed('/signature', arguments: document);
  }

  Future<void> renameDocument() async {
    final newName = await AppHelpers.showRenameDialog(documentName.value);
    if (newName != null && newName.isNotEmpty) {
      documentName.value = newName;
      AppHelpers.showSnackbar('Renamed successfully.');
    }
  }
}
