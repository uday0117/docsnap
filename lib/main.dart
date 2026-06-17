import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'bindings/initial_binding.dart';
import 'controllers/home_controller.dart';
import 'controllers/settings_controller.dart';
import 'firebase_options.dart';
import 'repositories/document_repository.dart';
import 'repositories/signature_repository.dart';
import 'routes/app_routes.dart';
import 'services/ad_service.dart';
import 'services/image_processing_service.dart';
import 'services/pdf_service.dart';
import 'services/permission_service.dart';
import 'services/share_service.dart';
import 'services/storage_service.dart';
import 'themes/app_theme.dart';
import 'translations/app_translations.dart';
import 'utils/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  await _initFirebase();
  await _initAds();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final storageService = StorageService();
  await storageService.init();
  Get.put<StorageService>(storageService, permanent: true);
  Get.put<PermissionService>(PermissionService(), permanent: true);
  Get.put<ShareService>(ShareService(), permanent: true);
  Get.put<ImageProcessingService>(ImageProcessingService(), permanent: true);
  Get.put<PdfService>(PdfService(), permanent: true);
  Get.put<DocumentRepository>(
    DocumentRepository(storageService),
    permanent: true,
  );
  Get.put<SignatureRepository>(
    SignatureRepository(storageService),
    permanent: true,
  );
  Get.put<SettingsController>(
    SettingsController(storageService),
    permanent: true,
  );

  runApp(const DocSnapApp());
}

Future<void> _initFirebase() async {
  if (kIsWeb) return;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Firebase config may be incomplete on some platforms during development.
  }
}

Future<void> _initAds() async {
  if (kIsWeb) return;
  if (!Platform.isAndroid && !Platform.isIOS) return;

  final adService = AdService();
  await adService.init();
  Get.put<AdService>(adService, permanent: true);
}

class DocSnapApp extends StatelessWidget {
  const DocSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();

    return Obx(
      () => GetMaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settingsCtrl.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        translations: AppTranslations(),
        locale: settingsCtrl.getLocale(),
        fallbackLocale: const Locale('en', 'US'),
        initialBinding: InitialBinding(),
        initialRoute: AppConstants.splashRoute,
        getPages: AppRoutes.pages,
        routingCallback: (routing) {
          if (routing?.current == AppConstants.homeRoute &&
              Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().loadRecentDocuments();
          }
        },
        defaultTransition: Transition.fade,
        transitionDuration: const Duration(milliseconds: 300),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
              ),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
