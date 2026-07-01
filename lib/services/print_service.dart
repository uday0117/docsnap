import 'dart:io';

import 'package:get/get.dart';
import 'package:printing/printing.dart';

class PrintService extends GetxService {
  Future<void> printPdf(String path, {String? name}) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('PDF file not found.');
    }

    final bytes = await file.readAsBytes();
    await Printing.layoutPdf(
      name: name ?? 'DocSnap',
      onLayout: (_) async => bytes,
    );
  }
}
