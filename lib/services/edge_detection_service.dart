import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_document_scanner/flutter_document_scanner.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Document edge detection using flutter_document_scanner (OpenCV / VisionKit)
/// with fallback to content-boundary detection.
class EdgeDetectionService extends GetxService {
  Future<String?> autoCropDocument(String imagePath) async {
    if (!File(imagePath).existsSync()) return null;

    try {
      final pluginResult = await _cropWithPlugin(imagePath);
      if (pluginResult != null) return pluginResult;
    } catch (_) {
      // Fall back to built-in detection below.
    }

    return _cropWithContentBounds(imagePath);
  }

  Future<String?> _cropWithPlugin(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final platform = FlutterDocumentScannerPlatform.instance;

    final contour = await platform.findContourPhoto(
      byteData: Uint8List.fromList(bytes),
      minContourArea: 5000,
    );
    if (contour == null || contour.points.length < 4) return null;

    final cropped = await platform.adjustingPerspective(
      byteData: Uint8List.fromList(bytes),
      contour: contour,
    );
    if (cropped == null) return null;

    final dir = await getTemporaryDirectory();
    final outPath = p.join(dir.path, 'autocrop_${const Uuid().v4()}.jpg');
    await File(outPath).writeAsBytes(cropped);
    return outPath;
  }

  Future<String?> _cropWithContentBounds(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final original = img.decodeImage(bytes);
      if (original == null) return null;

      final working = original.width > 1600
          ? img.copyResize(original, width: 1600)
          : original;
      final scale = original.width / working.width;

      final gray = img.grayscale(working);
      final bounds = _findContentBounds(gray);
      if (bounds == null) return null;

      final left = (bounds.left * scale).round().clamp(0, original.width - 1);
      final top = (bounds.top * scale).round().clamp(0, original.height - 1);
      final width =
          (bounds.width * scale).round().clamp(1, original.width - left);
      final height =
          (bounds.height * scale).round().clamp(1, original.height - top);

      if (width >= original.width * 0.95 && height >= original.height * 0.95) {
        return null;
      }

      final cropped = img.copyCrop(
        original,
        x: left,
        y: top,
        width: width,
        height: height,
      );

      return _writeTempJpeg(cropped);
    } catch (_) {
      return null;
    }
  }

  Future<String> _writeTempJpeg(img.Image cropped) async {
    final dir = await getTemporaryDirectory();
    final outPath = p.join(dir.path, 'autocrop_${const Uuid().v4()}.jpg');
    await File(outPath).writeAsBytes(img.encodeJpg(cropped, quality: 92));
    return outPath;
  }

  _Bounds? _findContentBounds(img.Image gray) {
    const threshold = 240;
    const margin = 8;

    int top = 0;
    int bottom = gray.height - 1;
    int left = 0;
    int right = gray.width - 1;

    bool rowHasContent(int y) {
      for (var x = 0; x < gray.width; x++) {
        if (gray.getPixel(x, y).r < threshold) return true;
      }
      return false;
    }

    bool colHasContent(int x) {
      for (var y = 0; y < gray.height; y++) {
        if (gray.getPixel(x, y).r < threshold) return true;
      }
      return false;
    }

    while (top < bottom && !rowHasContent(top)) {
      top++;
    }
    while (bottom > top && !rowHasContent(bottom)) {
      bottom--;
    }
    while (left < right && !colHasContent(left)) {
      left++;
    }
    while (right > left && !colHasContent(right)) {
      right--;
    }

    top = (top - margin).clamp(0, gray.height - 1);
    left = (left - margin).clamp(0, gray.width - 1);
    bottom = (bottom + margin).clamp(top + 1, gray.height - 1);
    right = (right + margin).clamp(left + 1, gray.width - 1);

    final width = right - left + 1;
    final height = bottom - top + 1;
    if (width < 40 || height < 40) return null;

    return _Bounds(left: left, top: top, width: width, height: height);
  }
}

class _Bounds {
  final int left;
  final int top;
  final int width;
  final int height;

  const _Bounds({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}
