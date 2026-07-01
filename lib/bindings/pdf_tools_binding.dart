import 'package:get/get.dart';

import '../controllers/pdf_tools_controller.dart';
import '../repositories/document_repository.dart';
import '../services/pdf_service.dart';

class PdfToolsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PdfToolsController>(
      () => PdfToolsController(
        Get.find<DocumentRepository>(),
        Get.find<PdfService>(),
      ),
      fenix: true,
    );
  }
}
