import 'package:get/get.dart';

import '../bindings/documents_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/pdf_generator_binding.dart';
import '../bindings/pdf_viewer_binding.dart';
import '../bindings/scanner_binding.dart';
import '../bindings/settings_binding.dart';
import '../bindings/signature_binding.dart';
import '../bindings/splash_binding.dart';
import '../utils/app_constants.dart';
import '../views/crop_editor/crop_editor_screen.dart';
import '../views/documents/documents_screen.dart';
import '../views/filters/filters_screen.dart';
import '../views/home/home_screen.dart';
import '../views/pdf_generator/pdf_generator_screen.dart';
import '../views/pdf_viewer/pdf_viewer_screen.dart';
import '../views/scanner/scanner_screen.dart';
import '../views/settings/settings_screen.dart';
import '../views/signature/signature_screen.dart';
import '../views/splash/splash_screen.dart';

class AppRoutes {
  AppRoutes._();

  static final pages = [
    GetPage(
      name: AppConstants.splashRoute,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppConstants.homeRoute,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppConstants.scannerRoute,
      page: () => const ScannerScreen(),
      binding: ScannerBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppConstants.cropEditorRoute,
      page: () => const CropEditorScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppConstants.filtersRoute,
      page: () => const FiltersScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppConstants.documentsRoute,
      page: () => const DocumentsScreen(),
      binding: DocumentsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppConstants.pdfViewerRoute,
      page: () => const PdfViewerScreen(),
      binding: PdfViewerBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppConstants.signatureRoute,
      page: () => const SignatureScreen(),
      binding: SignatureBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppConstants.settingsRoute,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppConstants.pdfGeneratorRoute,
      page: () => const PdfGeneratorScreen(),
      binding: PdfGeneratorBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
