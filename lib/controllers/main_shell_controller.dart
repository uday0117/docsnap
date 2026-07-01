import 'package:get/get.dart';

import '../controllers/documents_controller.dart';
import '../controllers/home_controller.dart';

class MainShellController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void switchToTab(int index, {Map<String, dynamic>? arguments}) {
    if (index < 0 || index > 3) return;
    currentIndex.value = index;

    if (index == 0 && Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadRecentDocuments();
    }

    if (index == 1 && Get.isRegistered<DocumentsController>()) {
      final docs = Get.find<DocumentsController>();
      docs.loadDocuments();
      if (arguments?['showFavorites'] == true) {
        docs.showFavoritesOnly.value = true;
      }
    }
  }
}
