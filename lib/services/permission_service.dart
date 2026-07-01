import 'dart:io';

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

  /// Gallery / photo library permission
  Future<bool> requestPhotosPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true;
    }

    final photos = await Permission.photos.request();
    if (photos.isGranted || photos.isLimited) {
      return true;
    }

    if (Platform.isAndroid) {
      final storage = await Permission.storage.request();
      if (storage.isGranted) {
        return true;
      }
    }

    if (photos.isPermanentlyDenied ||
        (Platform.isAndroid && await Permission.storage.isPermanentlyDenied)) {
      AppHelpers.showSnackbar(
        'Photo access is required to import images.',
        isError: true,
      );
      await openAppSettings();
      return false;
    }

    AppHelpers.showSnackbar(
      'Photo access is required to import images.',
      isError: true,
    );
    return false;
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
