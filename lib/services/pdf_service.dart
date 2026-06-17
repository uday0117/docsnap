import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uuid/uuid.dart';

import '../utils/app_constants.dart';

class PdfService extends GetxService {
  Future<String> generatePdf({
    required String name,
    required List<String> imagesPaths,
    String quality = AppConstants.qualityHigh,
  }) async {
    final pdf = pw.Document();
    final pageFormat = PdfPageFormat.a4;
    final jpgQuality = _qualityToJpegQuality(quality);

    for (final imagePath in imagesPaths) {
      final bytes = await _compressImageForPdf(imagePath, jpgQuality);
      final image = pw.MemoryImage(bytes);
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: pw.EdgeInsets.zero,
          build: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Image(image, fit: pw.BoxFit.contain),
          ),
        ),
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final pdfDir = Directory(p.join(dir.path, 'docsnap', 'pdfs'));
    await pdfDir.create(recursive: true);
    final fileName =
        '${_sanitizeName(name)}_${const Uuid().v4().substring(0, 8)}.pdf';
    final filePath = p.join(pdfDir.path, fileName);

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }

  /// Overlays a signature PNG on the last page and regenerates the PDF.
  Future<String> applySignatureToPdf({
    required String pdfPath,
    required List<String> pageImagePaths,
    required String signatureImagePath,
    String quality = AppConstants.qualityHigh,
  }) async {
    if (pageImagePaths.isEmpty) {
      throw Exception('No page images available for this document.');
    }

    final jpgQuality = _qualityToJpegQuality(quality);
    final imagePaths = List<String>.from(pageImagePaths);
    final lastIndex = imagePaths.length - 1;

    final compositePath = await _overlaySignatureOnImage(
      imagePaths[lastIndex],
      signatureImagePath,
      jpgQuality,
    );
    imagePaths[lastIndex] = compositePath;

    final pdf = pw.Document();
    for (final imagePath in imagePaths) {
      final bytes = await _compressImageForPdf(imagePath, jpgQuality);
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.zero,
          build: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
          ),
        ),
      );
    }

    final oldFile = File(pdfPath);
    if (await oldFile.exists()) {
      await oldFile.delete();
    }
    await oldFile.writeAsBytes(await pdf.save());
    return pdfPath;
  }

  Future<String> _overlaySignatureOnImage(
    String pageImagePath,
    String signatureImagePath,
    int jpgQuality,
  ) async {
    final pageBytes = await File(pageImagePath).readAsBytes();
    final sigBytes = await File(signatureImagePath).readAsBytes();

    final page = img.decodeImage(pageBytes);
    final signature = img.decodeImage(sigBytes);
    if (page == null || signature == null) {
      throw Exception('Could not read image for signature overlay.');
    }

    final sigWidth = (page.width * 0.35).round();
    final sigHeight =
        (signature.height * sigWidth / signature.width).round().clamp(40, 200);
    final resizedSig =
        img.copyResize(signature, width: sigWidth, height: sigHeight);

    final x = page.width - sigWidth - 40;
    final y = page.height - sigHeight - 60;

    img.compositeImage(page, resizedSig, dstX: x, dstY: y);

    final dir = await getApplicationDocumentsDirectory();
    final outPath = p.join(
      dir.path,
      'docsnap',
      'signed',
      '${const Uuid().v4()}.jpg',
    );
    await Directory(p.dirname(outPath)).create(recursive: true);
    await File(outPath).writeAsBytes(img.encodeJpg(page, quality: jpgQuality));
    return outPath;
  }

  Future<Uint8List> _compressImageForPdf(
    String imagePath,
    int jpgQuality,
  ) async {
    final bytes = await File(imagePath).readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      return Uint8List.fromList(bytes);
    }

    final maxWidth = jpgQuality >= 90 ? 2400 : (jpgQuality >= 75 ? 1800 : 1200);

    final resized = decoded.width > maxWidth
        ? img.copyResize(decoded, width: maxWidth)
        : decoded;

    return Uint8List.fromList(
      img.encodeJpg(
        resized,
        quality: jpgQuality,
      ),
    );
  }

  int _qualityToJpegQuality(String quality) {
    switch (quality) {
      case AppConstants.qualityLow:
        return 60;
      case AppConstants.qualityMedium:
        return 80;
      case AppConstants.qualityHigh:
      default:
        return 92;
    }
  }

  String _sanitizeName(String name) {
    return name.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_');
  }

  Future<int> getPdfFileSize(String path) async {
    final file = File(path);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }
}
