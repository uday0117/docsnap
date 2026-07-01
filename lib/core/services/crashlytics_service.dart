import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Firebase Crashlytics wrapper — safe no-op when Firebase is unavailable.
class CrashlyticsService extends GetxService {
  FirebaseCrashlytics? _crashlytics;

  Future<CrashlyticsService> init() async {
    if (kIsWeb) return this;
    try {
      _crashlytics = FirebaseCrashlytics.instance;
      FlutterError.onError = _crashlytics!.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics!.recordError(error, stack, fatal: true);
        return true;
      };
      await _crashlytics!.setCrashlyticsCollectionEnabled(!kDebugMode);
    } catch (_) {
      _crashlytics = null;
    }
    return this;
  }

  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    await _crashlytics?.recordError(
      exception,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  Future<void> log(String message) async {
    await _crashlytics?.log(message);
  }

  Future<void> setUserId(String id) async {
    await _crashlytics?.setUserIdentifier(id);
  }
}
