import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/documents_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/main_shell_controller.dart';
import '../themes/app_theme.dart';
import '../utils/app_constants.dart';

class AppHelpers {
  AppHelpers._();

  static void showSnackbar(
    String message, {
    String? title,
    bool isError = false,
  }) {
    final safeMessage =
        message.length > 180 ? '${message.substring(0, 180)}…' : message;
    final resolvedTitle = title ?? (isError ? 'error'.tr : 'success'.tr);

    Get.snackbar(
      resolvedTitle,
      safeMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      maxWidth: Get.width > 0 ? Get.width - 32 : 400,
      titleText: Text(
        resolvedTitle,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      messageText: Text(
        safeMessage,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
    );
  }

  static void showLoading([String? message]) {
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: AppTheme.primaryLight,
                    ),
                    if (message != null && message.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.35,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black54,
    );
  }

  static String translateFilterName(String filter) {
    switch (filter) {
      case AppConstants.filterOriginal:
        return 'original'.tr;
      case AppConstants.filterAutoEnhance:
        return 'filter_auto_enhance'.tr;
      case AppConstants.filterMagicColor:
        return 'magic_color'.tr;
      case AppConstants.filterBW:
        return 'black_white'.tr;
      case AppConstants.filterGrayscale:
        return 'grayscale'.tr;
      case AppConstants.filterColor:
        return 'filter_color'.tr;
      case AppConstants.filterDocument:
        return 'filter_document'.tr;
      case AppConstants.filterReceipt:
        return 'filter_receipt'.tr;
      case AppConstants.filterHighContrast:
        return 'high_contrast'.tr;
      default:
        return filter;
    }
  }

  static String translateQuality(String quality) {
    switch (quality) {
      case AppConstants.qualityHigh:
        return 'high'.tr;
      case AppConstants.qualityMedium:
        return 'medium'.tr;
      case AppConstants.qualityLow:
        return 'low'.tr;
      default:
        return quality;
    }
  }

  static void hideLoading() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  static Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    return await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: isDestructive
                ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static Future<String?> showRenameDialog(String currentName) async {
    final controller = TextEditingController(text: currentName);
    return await Get.dialog<String>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Rename Document'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Document name',
            hintText: 'Enter new name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: controller.text.trim()),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) return '${diff.inMinutes}m ago';
      return '${diff.inHours}h ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Refreshes document lists on home and documents tabs when registered.
  static void refreshDocumentLists() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadRecentDocuments();
    }
    if (Get.isRegistered<DocumentsController>()) {
      Get.find<DocumentsController>().loadDocuments();
    }
  }

  /// Returns to the home tab inside the main shell, or the home route.
  static void navigateToHomeTab() {
    if (Get.isRegistered<MainShellController>()) {
      Get.until((route) => route.settings.name == AppConstants.homeRoute);
      Get.find<MainShellController>().switchToTab(0);
      return;
    }
    Get.offAllNamed(AppConstants.homeRoute);
  }

  /// Returns to the documents tab inside the main shell, or the documents route.
  static void navigateToDocumentsTab() {
    if (Get.isRegistered<MainShellController>()) {
      Get.until((route) => route.settings.name == AppConstants.homeRoute);
      Get.find<MainShellController>().switchToTab(1);
      return;
    }
    Get.offNamedUntil(
      AppConstants.documentsRoute,
      (route) => route.settings.name == AppConstants.homeRoute,
    );
  }

  /// Pops back to home/documents and shows a snackbar on the stable route.
  static Future<void> finishWithSnackbar(
    String message, {
    bool goToDocuments = false,
  }) async {
    refreshDocumentLists();
    if (goToDocuments) {
      navigateToDocumentsTab();
    } else {
      navigateToHomeTab();
    }
    await Future.delayed(const Duration(milliseconds: 150));
    showSnackbar(message);
  }
}
