import 'package:get/get.dart';

import '../bindings/annotation_binding.dart';
import '../bindings/cloud_backup_binding.dart';
import '../bindings/crop_editor_binding.dart';
import '../bindings/image_tools_binding.dart';
import '../bindings/documents_binding.dart';
import '../bindings/filters_binding.dart';
import '../bindings/main_shell_binding.dart';
import '../bindings/pdf_generator_binding.dart';
import '../bindings/pdf_viewer_binding.dart';
import '../bindings/ocr_binding.dart';
import '../bindings/pdf_tools_binding.dart';
import '../bindings/scanner_binding.dart';
import '../bindings/settings_binding.dart';
import '../bindings/signature_binding.dart';
import '../bindings/splash_binding.dart';
import '../utils/app_constants.dart';
import '../views/annotation/annotation_screen.dart';
import '../views/cloud_backup/cloud_backup_screen.dart';
import '../views/crop_editor/crop_editor_screen.dart';
import '../views/image_tools/image_tools_screen.dart';
import '../views/documents/documents_screen.dart';
import '../views/filters/filters_screen.dart';
import '../views/main/main_shell_screen.dart';
import '../views/onboarding/onboarding_screen.dart';
import '../views/ocr/ocr_screen.dart';
import '../views/pdf_generator/pdf_generator_screen.dart';
import '../views/pdf_tools/pdf_tools_screen.dart';
import '../views/pdf_viewer/pdf_viewer_screen.dart';
import '../views/qr_scanner/qr_scanner_screen.dart';
import '../views/scanner/scanner_screen.dart';
import '../views/settings/settings_screen.dart';
import '../views/signature/signature_screen.dart';
import '../views/splash/splash_screen.dart';
import '../views/tools/tools_screen.dart';

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
      name: AppConstants.onboardingRoute,
      page: () => const OnboardingScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppConstants.homeRoute,
      page: () => const MainShellScreen(),
      binding: MainShellBinding(),
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
      binding: CropEditorBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppConstants.filtersRoute,
      page: () => const FiltersScreen(),
      binding: FiltersBinding(),
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
    GetPage(
      name: AppConstants.toolsRoute,
      page: () => const ToolsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppConstants.qrScannerRoute,
      page: () => const QrScannerScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppConstants.ocrRoute,
      page: () => const OcrScreen(),
      binding: OcrBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppConstants.pdfToolsRoute,
      page: () => const PdfToolsScreen(),
      binding: PdfToolsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppConstants.imageToolsRoute,
      page: () => const ImageToolsScreen(),
      binding: ImageToolsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppConstants.annotationRoute,
      page: () => const AnnotationScreen(),
      binding: AnnotationBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppConstants.cloudBackupRoute,
      page: () => const CloudBackupScreen(),
      binding: CloudBackupBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
