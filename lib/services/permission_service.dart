import 'dart:io';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/app_helpers.dart';

class PermissionService extends GetxService {
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

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 13+ (API 33+) uses granular media permissions
      final androidInfo = await _getAndroidVersion();
      if (androidInfo >= 33) {
        // Request photos permission for Android 13+
        final status = await Permission.photos.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          AppHelpers.showSnackbar(
            'Photos permission is required to access images.',
            isError: true,
          );
          if (status.isPermanentlyDenied) {
            await openAppSettings();
          }
          return false;
        }
        return status.isGranted || status.isLimited;
      } else {
        // For Android 12 and below, use storage permission
        final status = await Permission.storage.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          AppHelpers.showSnackbar(
            'Storage permission is required to access files.',
            isError: true,
          );
          if (status.isPermanentlyDenied) {
            await openAppSettings();
          }
          return false;
        }
        return status.isGranted;
      }
    } else {
      // iOS uses photos permission
      final status = await Permission.photos.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        AppHelpers.showSnackbar(
          'Photos permission is required to access images.',
          isError: true,
        );
        if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
        return false;
      }
      return status.isGranted || status.isLimited;
    }
  }

  Future<int> _getAndroidVersion() async {
    if (!Platform.isAndroid) return 0;
    try {
      // Get Android SDK version from device_info_plus
      // This is a placeholder - in reality you'd use device_info_plus
      // For now, we'll assume Android 13+ if we can't determine
      return 33; // Assume Android 13+
    } catch (_) {
      return 33; // Default to Android 13+ behavior
    }
  }

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;
    try {
      final version =
          int.tryParse(Platform.operatingSystemVersion.split(' ').last) ?? 0;
      return version >= 13;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  Future<bool> checkStoragePermission() async {
    return await Permission.storage.isGranted ||
        await Permission.photos.isGranted;
  }
}
