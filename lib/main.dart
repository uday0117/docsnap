import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'bindings/initial_binding.dart';
import 'controllers/settings_controller.dart';
import 'repositories/document_repository.dart';
import 'repositories/signature_repository.dart';
import 'routes/app_routes.dart';
import 'services/image_processing_service.dart';
import 'services/permission_service.dart';
import 'services/share_service.dart';
import 'services/storage_service.dart';
import 'themes/app_theme.dart';
import 'utils/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

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
  // Register services before InitialBinding runs
  Get.put<StorageService>(storageService, permanent: true);
  Get.put<PermissionService>(PermissionService(), permanent: true);
  Get.put<ShareService>(ShareService(), permanent: true);
  Get.put<ImageProcessingService>(ImageProcessingService(), permanent: true);
  // Register repositories and settings eagerly so routes work on first frame
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

class DocSnapApp extends StatelessWidget {
  const DocSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: InitialBinding(),
      initialRoute: AppConstants.splashRoute,
      getPages: AppRoutes.pages,
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
    );
  }
}
