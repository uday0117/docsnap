import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Firebase Analytics wrapper — safe no-op when Firebase is unavailable.
class AnalyticsService extends GetxService {
  FirebaseAnalytics? _analytics;
  FirebaseAnalyticsObserver? observer;

  Future<AnalyticsService> init() async {
    if (kIsWeb) return this;
    try {
      _analytics = FirebaseAnalytics.instance;
      observer = FirebaseAnalyticsObserver(analytics: _analytics!);
    } catch (_) {
      _analytics = null;
      observer = null;
    }
    return this;
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics?.logScreenView(screenName: screenName);
  }

  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    await _analytics?.logEvent(name: name, parameters: parameters);
  }

  Future<void> logScanStarted({String source = 'camera'}) => logEvent(
        'scan_started',
        parameters: {'source': source},
      );

  Future<void> logPdfGenerated({
    required int pageCount,
    required String quality,
  }) =>
      logEvent(
        'pdf_generated',
        parameters: {
          'page_count': pageCount,
          'quality': quality,
        },
      );

  Future<void> logPdfToolUsed(String tool) => logEvent(
        'pdf_tool_used',
        parameters: {'tool': tool},
      );

  Future<void> logOcrUsed({required String source}) => logEvent(
        'ocr_used',
        parameters: {'source': source},
      );

  Future<void> logQrScanned({required String type}) => logEvent(
        'qr_scanned',
        parameters: {'type': type},
      );

  Future<void> logDocumentAction(String action) => logEvent(
        'document_action',
        parameters: {'action': action},
      );

  Future<void> logOnboardingCompleted() => logEvent('onboarding_completed');

  Future<void> logLanguageChanged(String language) => logEvent(
        'language_changed',
        parameters: {'language': language},
      );

  Future<void> logShare({required String type}) => logEvent(
        'share',
        parameters: {'type': type},
      );

  Future<void> logCompression({required int originalBytes, required int compressedBytes}) =>
      logEvent(
        'pdf_compressed',
        parameters: {
          'original_bytes': originalBytes,
          'compressed_bytes': compressedBytes,
        },
      );

  Future<void> logConversion({required String from, required String to}) =>
      logEvent(
        'conversion',
        parameters: {'from': from, 'to': to},
      );

  Future<void> logAdWatched(String adType) => logEvent(
        'ad_watched',
        parameters: {'ad_type': adType},
      );
}
