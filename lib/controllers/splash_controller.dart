import 'package:get/get.dart';

import '../services/storage_service.dart';
import '../utils/app_constants.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(const Duration(milliseconds: 2800));

    final storage = Get.find<StorageService>();
    final onboardingDone = storage.isOnboardingComplete();

    if (!onboardingDone) {
      Get.offAllNamed(AppConstants.onboardingRoute);
    } else {
      Get.offAllNamed(AppConstants.homeRoute);
    }
  }
}
