import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/filters_controller.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../widgets/app_button.dart';

class FiltersScreen extends StatelessWidget {
  const FiltersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<FiltersController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('choose_filter'.tr),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(child: _buildPreview(ctrl)),
          _buildFiltersBar(ctrl, context),
          _buildActions(ctrl),
        ],
      ),
    );
  }

  Widget _buildPreview(FiltersController ctrl) {
    return Obx(() {
      if (ctrl.previewImagePath.value.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }
      return Stack(
        alignment: Alignment.center,
        children: [
          InteractiveViewer(
            minScale: 0.5,
            maxScale: 4,
            child: Image.file(
              File(ctrl.previewImagePath.value),
              fit: BoxFit.contain,
              key: ValueKey(ctrl.previewImagePath.value),
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 64,
              ),
            ),
          ),
          if (ctrl.isProcessing.value)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildFiltersBar(FiltersController ctrl, BuildContext context) {
    return Container(
      color: const Color(0xFF1A1A2E),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: AppConstants.filters.length,
          itemBuilder: (_, index) {
            final filter = AppConstants.filters[index];
            return Obx(
              () => GestureDetector(
                onTap: () => ctrl.applyPreview(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ctrl.selectedFilter.value == filter
                          ? AppTheme.primaryLight
                          : Colors.transparent,
                      width: 2.5,
                    ),
                    color: ctrl.selectedFilter.value == filter
                        ? AppTheme.primaryColor.withAlpha(40)
                        : Colors.white.withAlpha(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: _getFilterColor(filter),
                        ),
                        child: Icon(
                          _getFilterIcon(filter),
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        filter,
                        style: TextStyle(
                          color: ctrl.selectedFilter.value == filter
                              ? AppTheme.primaryLight
                              : Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getFilterColor(String filter) {
    switch (filter) {
      case AppConstants.filterBW:
        return Colors.grey.shade700;
      case AppConstants.filterMagicColor:
        return Colors.purple.shade700;
      case AppConstants.filterGrayscale:
        return Colors.blueGrey.shade700;
      case AppConstants.filterHighContrast:
        return Colors.indigo.shade700;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case AppConstants.filterBW:
        return Icons.contrast_rounded;
      case AppConstants.filterMagicColor:
        return Icons.auto_awesome_rounded;
      case AppConstants.filterGrayscale:
        return Icons.gradient_rounded;
      case AppConstants.filterHighContrast:
        return Icons.brightness_high_rounded;
      default:
        return Icons.image_rounded;
    }
  }

  Widget _buildActions(FiltersController ctrl) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      color: const Color(0xFF1A1A2E),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'cancel'.tr,
              onPressed: ctrl.cancel,
              isOutlined: true,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              label: 'apply_filter'.tr,
              icon: Icons.check_rounded,
              onPressed: ctrl.applyFilter,
            ),
          ),
        ],
      ),
    );
  }
}
