import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../services/ad_service.dart';

/// Listens for app resume and shows app-open ads on Android (with cooldown).
class AppLifecycleHandler extends StatefulWidget {
  final Widget child;

  const AppLifecycleHandler({super.key, required this.child});

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        Get.isRegistered<AdService>()) {
      Get.find<AdService>().showAppOpenAdOnResume();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
