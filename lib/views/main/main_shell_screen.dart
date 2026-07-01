import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/main_shell_controller.dart';
import '../../utils/app_constants.dart';
import '../../widgets/ad_banner_widget.dart';
import '../../widgets/app_bottom_nav.dart';
import '../documents/documents_screen.dart';
import '../home/home_screen.dart';
import '../settings/settings_screen.dart';
import '../tools/tools_screen.dart';

class MainShellScreen extends GetView<MainShellController> {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            HomeScreen(),
            DocumentsScreen(),
            ToolsScreen(),
            SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdBannerWidget(),
          AppBottomNav(
            currentIndexRx: controller.currentIndex,
            onTabSelected: controller.switchToTab,
            onScanTap: () => Get.toNamed(AppConstants.scannerRoute),
          ),
        ],
      ),
    );
  }
}
