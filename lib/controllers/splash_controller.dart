import 'package:get/get.dart';
import '../utils/app_constants.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    Get.offAllNamed(AppConstants.homeRoute);
  }
}
