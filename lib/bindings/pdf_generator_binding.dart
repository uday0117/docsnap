import 'package:get/get.dart';

import '../controllers/pdf_generator_controller.dart';
import '../services/pdf_service.dart';

class PdfGeneratorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PdfService>(() => PdfService());
    Get.lazyPut<PdfGeneratorController>(
      () => PdfGeneratorController(Get.find(), Get.find()),
    );
  }
}
