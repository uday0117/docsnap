import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'
    hide PdfViewerController;

import '../../controllers/pdf_viewer_controller.dart';
import '../../themes/app_theme.dart';
import '../../widgets/ad_banner_widget.dart';

class PdfViewerScreen extends GetView<PdfViewerController> {
  const PdfViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.pdfPath.value.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              final file = File(controller.pdfPath.value);
              if (!file.existsSync()) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 56, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('error'.tr),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: Obx(
                      () => SfPdfViewer.file(
                        file,
                        key: ValueKey(
                          '${controller.pdfPath.value}_${controller.pdfReloadKey.value}',
                        ),
                        password: controller.pdfPassword.value.isEmpty
                            ? null
                            : controller.pdfPassword.value,
                        onPageChanged: (PdfPageChangedDetails details) {
                          controller.updateCurrentPage(details.newPageNumber);
                        },
                        onDocumentLoadFailed: (details) {
                          if (controller.needsPassword.value) {
                            controller.promptForPassword();
                          }
                        },
                      ),
                    ),
                  ),
                  _buildPageIndicator(),
                ],
              );
            }),
          ),
          const AdBannerWidget(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      title: Obx(
        () => Text(
          controller.documentName.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded),
          onPressed: controller.shareDocument,
        ),
        IconButton(
          icon: const Icon(Icons.print_rounded),
          onPressed: controller.printDocument,
          tooltip: 'print'.tr,
        ),
        IconButton(
          icon: const Icon(Icons.draw_rounded),
          onPressed: controller.openSignature,
          tooltip: 'signature'.tr,
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            switch (value) {
              case 'rename':
                controller.renameDocument();
                break;
              case 'print':
                controller.printDocument();
                break;
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'print',
              child: Row(
                children: [
                  const Icon(Icons.print_rounded, size: 18),
                  const SizedBox(width: 12),
                  Text('print'.tr),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'rename',
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 18),
                  const SizedBox(width: 12),
                  Text('rename'.tr),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPageIndicator() {
    return Obx(
      () => controller.totalPages.value > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: AppTheme.primaryColor.withAlpha(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf,
                      size: 16, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    '${'page'.tr} ${controller.currentPage.value} ${'of'.tr} ${controller.totalPages.value}',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
