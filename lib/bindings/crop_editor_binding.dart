import 'package:get/get.dart';

import '../controllers/crop_editor_controller.dart';

class CropEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CropEditorController>(() => CropEditorController());
  }
}
