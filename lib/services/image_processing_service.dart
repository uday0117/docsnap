import 'dart:io';

import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageAdjustments {
  final double brightness;
  final double contrast;
  final double saturation;
  final double sharpness;
  final double exposure;
  final double temperature;
  final double tint;

  const ImageAdjustments({
    this.brightness = 1.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.sharpness = 1.0,
    this.exposure = 0.0,
    this.temperature = 0.0,
    this.tint = 0.0,
  });

  ImageAdjustments copyWith({
    double? brightness,
    double? contrast,
    double? saturation,
    double? sharpness,
    double? exposure,
    double? temperature,
    double? tint,
  }) {
    return ImageAdjustments(
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      sharpness: sharpness ?? this.sharpness,
      exposure: exposure ?? this.exposure,
      temperature: temperature ?? this.temperature,
      tint: tint ?? this.tint,
    );
  }

  bool get hasChanges =>
      brightness != 1.0 ||
      contrast != 1.0 ||
      saturation != 1.0 ||
      sharpness != 1.0 ||
      exposure != 0.0 ||
      temperature != 0.0 ||
      tint != 0.0;
}

class ImageProcessingService extends GetxService {
  Future<String> applyFilter(String imagePath, String filterName) async {
    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return imagePath;

    img.Image processed;
    switch (filterName) {
      case 'Auto Enhance':
        processed = _applyAutoEnhance(original);
        break;
      case 'Black & White':
        processed = img.grayscale(original);
        _applyThreshold(processed, 128);
        break;
      case 'Magic Color':
        processed = _applyMagicColor(original);
        break;
      case 'Grayscale':
        processed = img.grayscale(original);
        break;
      case 'Color':
        processed = img.adjustColor(original, saturation: 1.35, contrast: 1.1);
        break;
      case 'Document':
        processed = _applyDocumentFilter(original);
        break;
      case 'Receipt':
        processed = _applyReceiptFilter(original);
        break;
      case 'High Contrast':
        processed = img.adjustColor(original, contrast: 1.8, brightness: 1.05);
        break;
      case 'Original':
      default:
        return imagePath;
    }

    return _saveProcessed(processed);
  }

  Future<String> applyAdjustments(
    String imagePath,
    ImageAdjustments adjustments,
  ) async {
    if (!adjustments.hasChanges) return imagePath;

    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return imagePath;

    var processed = img.adjustColor(
      original,
      brightness: adjustments.brightness + adjustments.exposure * 0.15,
      contrast: adjustments.contrast,
      saturation: adjustments.saturation,
    );

    if (adjustments.temperature != 0 || adjustments.tint != 0) {
      processed = _applyTemperatureTint(
        processed,
        adjustments.temperature,
        adjustments.tint,
      );
    }

    if (adjustments.sharpness > 1.0) {
      processed = img.convolution(
        processed,
        filter: [
          0, -1, 0,
          -1, 5 + (adjustments.sharpness - 1) * 2, -1,
          0, -1, 0,
        ],
      );
    }

    return _saveProcessed(processed);
  }

  /// Book mode: flatten curves, remove shadows, enhance paper tone.
  Future<String> applyBookModeEnhancements(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return imagePath;

    var processed = img.grayscale(original);
    processed = img.adjustColor(processed, contrast: 1.4, brightness: 1.08);
    _applyThreshold(processed, 200);
    processed = img.adjustColor(
      img.colorOffset(processed, red: 8, green: 6, blue: -4),
      contrast: 1.05,
    );
    return _saveProcessed(processed);
  }

  Future<String> flipImage(String imagePath, {bool horizontal = true}) async {
    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return imagePath;

    final flipped = horizontal
        ? img.flipHorizontal(original)
        : img.flipVertical(original);
    return _saveProcessed(flipped, subdir: 'flipped');
  }

  Future<String> compressImage(
    String imagePath, {
    int quality = 75,
    int? maxWidth,
  }) async {
    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return imagePath;

    final resized = maxWidth != null && original.width > maxWidth
        ? img.copyResize(original, width: maxWidth)
        : original;

    final dir = await getApplicationDocumentsDirectory();
    final outPath = p.join(
      dir.path,
      'docsnap',
      'compressed',
      '${const Uuid().v4()}.jpg',
    );
    await Directory(p.dirname(outPath)).create(recursive: true);
    await File(outPath).writeAsBytes(img.encodeJpg(resized, quality: quality));
    return outPath;
  }

  Future<String> convertFormat(
    String imagePath, {
    required String format,
  }) async {
    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return imagePath;

    final dir = await getApplicationDocumentsDirectory();
    final ext = format.toLowerCase();
    final outPath = p.join(
      dir.path,
      'docsnap',
      'converted',
      '${const Uuid().v4()}.$ext',
    );
    await Directory(p.dirname(outPath)).create(recursive: true);

    switch (ext) {
      case 'png':
        await File(outPath).writeAsBytes(img.encodePng(original));
      case 'webp':
        await File(outPath).writeAsBytes(img.encodeJpg(original, quality: 92));
      default:
        await File(outPath).writeAsBytes(img.encodeJpg(original, quality: 92));
    }
    return outPath;
  }

  void _applyThreshold(img.Image image, int threshold) {
    for (final pixel in image) {
      final gray = pixel.r.toInt();
      final val = gray < threshold ? 0 : 255;
      pixel
        ..r = val
        ..g = val
        ..b = val;
    }
  }

  img.Image _applyAutoEnhance(img.Image src) {
    return img.adjustColor(
      src,
      contrast: 1.25,
      brightness: 1.05,
      saturation: 1.15,
    );
  }

  img.Image _applyMagicColor(img.Image src) {
    final out = img.Image.from(src);
    for (final pixel in out) {
      final r = (pixel.r * 1.1).clamp(0, 255).toInt();
      final g = (pixel.g * 1.05).clamp(0, 255).toInt();
      final b = (pixel.b * 0.95).clamp(0, 255).toInt();
      pixel
        ..r = r
        ..g = g
        ..b = b;
    }
    return img.adjustColor(out, contrast: 1.2, saturation: 1.3);
  }

  img.Image _applyDocumentFilter(img.Image src) {
    final gray = img.grayscale(src);
    return img.adjustColor(gray, contrast: 1.5, brightness: 1.1);
  }

  img.Image _applyReceiptFilter(img.Image src) {
    final enhanced = img.adjustColor(src, contrast: 1.3, brightness: 1.08);
    final gray = img.grayscale(enhanced);
    _applyThreshold(gray, 210);
    return img.adjustColor(gray, contrast: 1.1);
  }

  img.Image _applyTemperatureTint(img.Image src, double temp, double tint) {
    final out = img.Image.from(src);
    final rOffset = (temp * 20).round();
    final bOffset = (-temp * 20).round();
    final gOffset = (tint * 15).round();
    return img.colorOffset(out, red: rOffset, green: gOffset, blue: bOffset);
  }

  Future<String> _saveProcessed(img.Image processed, {String subdir = 'filtered'}) async {
    final dir = await getApplicationDocumentsDirectory();
    final outPath =
        p.join(dir.path, 'docsnap', subdir, '${const Uuid().v4()}.jpg');
    await Directory(p.dirname(outPath)).create(recursive: true);
    await File(outPath).writeAsBytes(img.encodeJpg(processed, quality: 92));
    return outPath;
  }

  Future<String> rotateImage(String imagePath, double degrees) async {
    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return imagePath;

    final rotated = img.copyRotate(original, angle: degrees);
    return _saveProcessed(rotated, subdir: 'rotated');
  }

  Future<String> cropImage(
    String imagePath, {
    required double x,
    required double y,
    required double width,
    required double height,
  }) async {
    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return imagePath;

    final cropped = img.copyCrop(
      original,
      x: x.toInt(),
      y: y.toInt(),
      width: width.toInt(),
      height: height.toInt(),
    );
    return _saveProcessed(cropped, subdir: 'cropped');
  }

  Future<String> saveImageToDocsnap(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final docDir = Directory(p.join(dir.path, 'docsnap', 'pages'));
    await docDir.create(recursive: true);
    final destPath = p.join(docDir.path, '${const Uuid().v4()}.jpg');
    await File(sourcePath).copy(destPath);
    return destPath;
  }

  Future<({int width, int height})?> readImageDimensions(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return null;
    return (width: original.width, height: original.height);
  }

  Future<String> generateThumbnail(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return imagePath;

    final thumb = img.copyResize(original, width: 300);
    final dir = await getApplicationDocumentsDirectory();
    final outPath =
        p.join(dir.path, 'docsnap', 'thumbnails', '${const Uuid().v4()}.jpg');
    await Directory(p.dirname(outPath)).create(recursive: true);
    await File(outPath).writeAsBytes(img.encodeJpg(thumb, quality: 75));
    return outPath;
  }
}
