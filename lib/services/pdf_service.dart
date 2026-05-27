import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:uuid/uuid.dart';

class PdfService extends GetxService {
  Future<String> generatePdf({
    required String name,
    required List<String> imagesPaths,
    String quality = 'High',
  }) async {
    final pdf = pw.Document();
    final pageFormat = PdfPageFormat.a4;

    int jpgQuality;
    switch (quality) {
      case 'Low':
        jpgQuality = 50;
        break;
      case 'Medium':
        jpgQuality = 75;
        break;
      case 'High':
      default:
        jpgQuality = 95;
        break;
    }

    for (final imagePath in imagesPaths) {
      final bytes = await File(imagePath).readAsBytes();
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
    final fileName = '${_sanitizeName(name)}_${const Uuid().v4().substring(0, 8)}.pdf';
    final filePath = p.join(pdfDir.path, fileName);

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }

  Future<String> mergePdfs(List<String> pdfPaths, String outputName) async {
    final mergedDoc = pw.Document();

    for (final path in pdfPaths) {
      final bytes = await File(path).readAsBytes();
      final existingDoc = pw.Document();
      mergedDoc.addPage(
        pw.Page(
          build: (context) => pw.Center(
            child: pw.Text('Page from $path'),
          ),
        ),
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final outPath = p.join(
      dir.path,
      'docsnap',
      'pdfs',
      '${_sanitizeName(outputName)}_merged.pdf',
    );
    await File(outPath).writeAsBytes(await mergedDoc.save());
    return outPath;
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
