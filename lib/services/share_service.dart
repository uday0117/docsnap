import 'dart:io';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class ShareService extends GetxService {
  Future<void> shareFile(String filePath, {String? subject}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      Get.snackbar('Error', 'File not found', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: subject ?? 'Shared from DocSnap',
      text: 'Shared via DocSnap - PDF Scanner',
    );
  }

  Future<void> shareMultipleFiles(List<String> filePaths, {String? subject}) async {
    final xFiles = filePaths
        .where((p) => File(p).existsSync())
        .map((p) => XFile(p))
        .toList();
    if (xFiles.isEmpty) return;
    await Share.shareXFiles(
      xFiles,
      subject: subject ?? 'Shared from DocSnap',
      text: 'Shared via DocSnap - PDF Scanner',
    );
  }

  Future<void> shareText(String text) async {
    await Share.share(text);
  }
}
