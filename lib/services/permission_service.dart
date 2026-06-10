import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/app_helpers.dart';

class PermissionService extends GetxService {
  /// Camera permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      AppHelpers.showSnackbar(
        'Camera permission is required to scan documents.',
        isError: true,
      );

      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }

      return false;
    }

    return status.isGranted;
  }

  /// Camera permission check
  Future<bool> checkCameraPermission() async {
    return Permission.camera.isGranted;
  }

  /// No storage permission required
  Future<bool> checkStoragePermission() async {
    return true;
  }

  /// Optional microphone permission
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
}
