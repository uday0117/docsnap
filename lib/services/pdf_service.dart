import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
import 'package:uuid/uuid.dart';

import '../utils/app_constants.dart';

class PdfService extends GetxService {
  Future<String> generatePdf({
    required String name,
    required List<String> imagesPaths,
    String quality = AppConstants.qualityHigh,
    String? watermarkText,
    String? userPassword,
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
          build: (context) => pw.Stack(
            children: [
              pw.FullPage(
                ignoreMargins: true,
                child: pw.Image(image, fit: pw.BoxFit.contain),
              ),
              if (watermarkText != null && watermarkText.trim().isNotEmpty)
                pw.Positioned(
                  bottom: 24,
                  right: 24,
                  child: pw.Opacity(
                    opacity: 0.35,
                    child: pw.Text(
                      watermarkText.trim(),
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),
                ),
            ],
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
    var pdfBytes = Uint8List.fromList(await pdf.save());
    if (userPassword != null && userPassword.isNotEmpty) {
      pdfBytes = Uint8List.fromList(await _encryptPdfBytes(pdfBytes, userPassword));
    }
    await file.writeAsBytes(pdfBytes);
    return filePath;
  }

  /// Places ID card front/back images on a single A4 page.
  Future<String> generateIdCardPdf({
    required String name,
    required String frontPath,
    required String backPath,
    String quality = AppConstants.qualityHigh,
    String? userPassword,
  }) async {
    final pdf = pw.Document();
    final pageFormat = PdfPageFormat.a4;
    final jpgQuality = _qualityToJpegQuality(quality);

    final frontBytes = await _compressImageForPdf(frontPath, jpgQuality);
    final backBytes = await _compressImageForPdf(backPath, jpgQuality);
    final frontImage = pw.MemoryImage(frontBytes);
    final backImage = pw.MemoryImage(backBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Expanded(
              child: pw.Center(
                child: pw.AspectRatio(
                  aspectRatio: AppConstants.idCardAspectRatio,
                  child: pw.Image(frontImage, fit: pw.BoxFit.contain),
                ),
              ),
            ),
            pw.SizedBox(height: 24),
            pw.Expanded(
              child: pw.Center(
                child: pw.AspectRatio(
                  aspectRatio: AppConstants.idCardAspectRatio,
                  child: pw.Image(backImage, fit: pw.BoxFit.contain),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final pdfDir = Directory(p.join(dir.path, 'docsnap', 'pdfs'));
    await pdfDir.create(recursive: true);
    final fileName =
        '${_sanitizeName(name)}_${const Uuid().v4().substring(0, 8)}.pdf';
    final filePath = p.join(pdfDir.path, fileName);

    final file = File(filePath);
    var pdfBytes = Uint8List.fromList(await pdf.save());
    if (userPassword != null && userPassword.isNotEmpty) {
      pdfBytes = Uint8List.fromList(await _encryptPdfBytes(pdfBytes, userPassword));
    }
    await file.writeAsBytes(pdfBytes);
    return filePath;
  }

  Future<Uint8List> _encryptPdfBytes(Uint8List bytes, String password) async {
    final document = sf.PdfDocument(inputBytes: Uint8List.fromList(bytes));
    document.security.userPassword = password;
    document.security.ownerPassword = password;
    document.security.algorithm = sf.PdfEncryptionAlgorithm.aesx256Bit;
    document.security.permissions.addAll([
      sf.PdfPermissionsFlags.print,
      sf.PdfPermissionsFlags.copyContent,
    ]);
    final secured = await document.save();
    document.dispose();
    return Uint8List.fromList(secured);
  }

  /// Overlays a signature PNG on the last page and regenerates the PDF.
  Future<({String pdfPath, List<String> pageImagePaths})> applySignatureToPdf({
    required String pdfPath,
    required List<String> pageImagePaths,
    required String signatureImagePath,
    String quality = AppConstants.qualityHigh,
  }) async {
    if (pageImagePaths.isEmpty) {
      throw Exception('No page images available for this document.');
    }

    for (final path in pageImagePaths) {
      if (!await File(path).exists()) {
        throw Exception(
          'Page images are missing. Please scan the document again.',
        );
      }
    }
    if (!await File(signatureImagePath).exists()) {
      throw Exception('Signature image not found.');
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
    return (pdfPath: pdfPath, pageImagePaths: imagePaths);
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

    img.compositeImage(
      page,
      resizedSig,
      dstX: x,
      dstY: y,
      blend: img.BlendMode.alpha,
    );

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
    var decoded = img.decodeImage(bytes);

    if (decoded == null) {
      return Uint8List.fromList(bytes);
    }

    decoded = img.bakeOrientation(decoded);

    if (decoded.numChannels == 4) {
      decoded = decoded.convert(numChannels: 3);
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

  Future<String> generatePdfFromImages({
    required String name,
    required List<String> imagesPaths,
    String quality = AppConstants.qualityHigh,
    String? watermarkText,
  }) {
    return generatePdf(
      name: name,
      imagesPaths: imagesPaths,
      quality: quality,
      watermarkText: watermarkText,
    );
  }

  Future<String> mergeImagesToPdf({
    required String name,
    required List<String> imagesPaths,
    String quality = AppConstants.qualityHigh,
  }) {
    return generatePdf(
      name: name,
      imagesPaths: imagesPaths,
      quality: quality,
    );
  }

  Future<String> compressPdf({
    required String name,
    required List<String> imagesPaths,
    String quality = AppConstants.qualityLow,
  }) {
    return generatePdf(
      name: name,
      imagesPaths: imagesPaths,
      quality: quality,
    );
  }

  Future<String> addWatermark({
    required String name,
    required List<String> imagesPaths,
    required String watermarkText,
    String quality = AppConstants.qualityHigh,
  }) {
    return generatePdf(
      name: name,
      imagesPaths: imagesPaths,
      quality: quality,
      watermarkText: watermarkText,
    );
  }

  Future<String> splitPagesToPdf({
    required String name,
    required List<String> imagesPaths,
    String quality = AppConstants.qualityHigh,
  }) {
    return generatePdf(
      name: name,
      imagesPaths: imagesPaths,
      quality: quality,
    );
  }
}
