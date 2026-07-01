import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'core/services/crashlytics_service.dart';
import 'bindings/initial_binding.dart';
import 'controllers/documents_controller.dart';
import 'controllers/home_controller.dart';
import 'controllers/settings_controller.dart';
import 'firebase_options.dart';
import 'repositories/document_repository.dart';
import 'repositories/signature_repository.dart';
import 'routes/app_routes.dart';
import 'services/ad_service.dart';
import 'services/review_prompt_service.dart';
import 'widgets/app_lifecycle_handler.dart';
import 'services/annotation_service.dart';
import 'services/cloud_backup_service.dart';
import 'services/analytics_service.dart';
import 'services/image_processing_service.dart';
import 'services/pdf_service.dart';
import 'services/permission_service.dart';
import 'services/edge_detection_service.dart';
import 'services/print_service.dart';
import 'services/share_service.dart';
import 'services/storage_service.dart';
import 'themes/app_theme.dart';
import 'translations/app_translations.dart';
import 'utils/app_constants.dart';
import 'utils/app_theme_mode.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  await _initFirebase();
  await _initCrashlytics();
  await _initAnalytics();
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
  Get.put<EdgeDetectionService>(EdgeDetectionService(), permanent: true);
  Get.put<PrintService>(PrintService(), permanent: true);
  Get.put<PdfService>(PdfService(), permanent: true);
  Get.put<AnnotationService>(AnnotationService(), permanent: true);
  final cloudBackupService = CloudBackupService();
  await cloudBackupService.init();
  Get.put<CloudBackupService>(cloudBackupService, permanent: true);
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
  Get.put<ReviewPromptService>(ReviewPromptService(), permanent: true);

  runApp(const DocSnapApp());
}

Future<void> _initFirebase() async {
  if (kIsWeb) return;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stack) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('$stack');
  }
}

Future<void> _initCrashlytics() async {
  if (kIsWeb) return;
  final crashlytics = CrashlyticsService();
  await crashlytics.init();
  Get.put<CrashlyticsService>(crashlytics, permanent: true);
}

Future<void> _initAnalytics() async {
  if (kIsWeb) return;
  final analyticsService = AnalyticsService();
  await analyticsService.init();
  Get.put<AnalyticsService>(analyticsService, permanent: true);
}

Future<void> _initAds() async {
  if (kIsWeb) return;

  final adService = AdService();
  if (Platform.isAndroid) {
    await adService.init();
  }
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
        themeMode: switch (settingsCtrl.themeMode) {
          AppThemeMode.dark => ThemeMode.dark,
          AppThemeMode.system => ThemeMode.system,
          AppThemeMode.light => ThemeMode.light,
        },
        translations: AppTranslations(),
        locale: settingsCtrl.getLocale(),
        fallbackLocale: const Locale('en', 'US'),
        initialBinding: InitialBinding(),
        initialRoute: AppConstants.splashRoute,
        getPages: AppRoutes.pages,
        routingCallback: (routing) {
          final route = routing?.current;
          if (route != null && Get.isRegistered<AnalyticsService>()) {
            Get.find<AnalyticsService>().logScreenView(route);
          }
          if (routing?.current == AppConstants.homeRoute) {
            if (Get.isRegistered<HomeController>()) {
              Get.find<HomeController>().loadRecentDocuments();
            }
            if (Get.isRegistered<DocumentsController>()) {
              Get.find<DocumentsController>().loadDocuments();
            }
            if (Get.isRegistered<AdService>()) {
              Get.find<AdService>().showAppOpenAdOnColdStart();
            }
          }
          if (routing?.current == AppConstants.documentsRoute &&
              Get.isRegistered<DocumentsController>()) {
            Get.find<DocumentsController>().loadDocuments();
          }
        },
        defaultTransition: Transition.fade,
        transitionDuration: const Duration(milliseconds: 300),
        builder: (context, child) {
          return AppLifecycleHandler(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(
                  MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.2),
                ),
              ),
              child: child!,
            ),
          );
        },
      ),
    );
  }
}
