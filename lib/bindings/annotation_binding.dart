import 'package:get/get.dart';

import '../controllers/annotation_controller.dart';
import '../repositories/document_repository.dart';
import '../services/annotation_service.dart';

class AnnotationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnnotationService>(() => AnnotationService(), fenix: true);
    Get.lazyPut<AnnotationController>(
      () => AnnotationController(
        Get.find<DocumentRepository>(),
        Get.find<AnnotationService>(),
      ),
      fenix: true,
    );
  }
}
