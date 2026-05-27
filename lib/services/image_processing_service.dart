import 'dart:io';

import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageProcessingService extends GetxService {
  Future<String> applyFilter(String imagePath, String filterName) async {
    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return imagePath;

    img.Image processed;
    switch (filterName) {
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
      case 'High Contrast':
        processed = img.adjustColor(original, contrast: 1.8, brightness: 1.05);
        break;
      case 'Original':
      default:
        return imagePath;
    }

    final dir = await getApplicationDocumentsDirectory();
    final outPath =
        p.join(dir.path, 'docsnap', 'filtered', '${const Uuid().v4()}.jpg');
    await Directory(p.dirname(outPath)).create(recursive: true);
    await File(outPath).writeAsBytes(img.encodeJpg(processed, quality: 92));
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

  Future<String> rotateImage(String imagePath, double degrees) async {
    final bytes = await File(imagePath).readAsBytes();
    final original = img.decodeImage(bytes);
    if (original == null) return imagePath;

    final rotated = img.copyRotate(original, angle: degrees);
    final dir = await getApplicationDocumentsDirectory();
    final outPath =
        p.join(dir.path, 'docsnap', 'rotated', '${const Uuid().v4()}.jpg');
    await Directory(p.dirname(outPath)).create(recursive: true);
    await File(outPath).writeAsBytes(img.encodeJpg(rotated, quality: 92));
    return outPath;
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
    final dir = await getApplicationDocumentsDirectory();
    final outPath =
        p.join(dir.path, 'docsnap', 'cropped', '${const Uuid().v4()}.jpg');
    await Directory(p.dirname(outPath)).create(recursive: true);
    await File(outPath).writeAsBytes(img.encodeJpg(cropped, quality: 92));
    return outPath;
  }

  Future<String> saveImageToDocsnap(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final docDir = Directory(p.join(dir.path, 'docsnap', 'pages'));
    await docDir.create(recursive: true);
    final destPath = p.join(docDir.path, '${const Uuid().v4()}.jpg');
    await File(sourcePath).copy(destPath);
    return destPath;
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
