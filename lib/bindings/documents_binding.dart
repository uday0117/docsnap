import 'package:get/get.dart';

import '../controllers/documents_controller.dart';
import '../repositories/document_repository.dart';

class DocumentsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DocumentsController>()) {
      Get.lazyPut<DocumentsController>(
        () => DocumentsController(Get.find<DocumentRepository>()),
      );
    }
  }
}
