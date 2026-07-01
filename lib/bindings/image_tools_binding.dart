import 'package:get/get.dart';

import '../controllers/image_tools_controller.dart';

class ImageToolsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageToolsController>(() => ImageToolsController(), fenix: true);
  }
}
