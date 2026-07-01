import 'package:get/get.dart';

import '../controllers/ocr_controller.dart';
import '../repositories/document_repository.dart';

class OcrBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OcrController>(
      () => OcrController(Get.find<DocumentRepository>()),
      fenix: true,
    );
  }
}
