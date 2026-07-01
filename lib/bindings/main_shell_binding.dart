import 'package:get/get.dart';

import '../controllers/documents_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/main_shell_controller.dart';
import '../repositories/document_repository.dart';

class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainShellController>(() => MainShellController());
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(
        () => HomeController(Get.find<DocumentRepository>()),
      );
    }
    if (!Get.isRegistered<DocumentsController>()) {
      Get.lazyPut<DocumentsController>(
        () => DocumentsController(Get.find<DocumentRepository>()),
      );
    }
    // SettingsController is permanent from main.dart
  }
}
