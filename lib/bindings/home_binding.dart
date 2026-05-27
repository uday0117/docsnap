import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // DocumentRepository and SettingsController are permanent (registered in main).
    // Only register HomeController which is screen-scoped.
    Get.lazyPut<HomeController>(() => HomeController(Get.find()));
  }
}
