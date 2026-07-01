import 'package:get/get.dart';

import '../controllers/pdf_generator_controller.dart';
import '../repositories/document_repository.dart';
import '../services/pdf_service.dart';

class PdfGeneratorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PdfGeneratorController>(
      () => PdfGeneratorController(
        Get.find<DocumentRepository>(),
        Get.find<PdfService>(),
      ),
      fenix: true,
    );
  }
}
