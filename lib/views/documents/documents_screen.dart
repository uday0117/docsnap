import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/documents_controller.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/document_card.dart';
import '../../widgets/empty_state.dart';

class DocumentsScreen extends GetView<DocumentsController> {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSortBar(context),
          Expanded(child: _buildDocumentList(context)),
        ],
      ),
      floatingActionButton: Obx(
        () => controller.showTrashOnly.value
            ? const SizedBox.shrink()
            : FloatingActionButton(
                onPressed: () => Get.toNamed(AppConstants.scannerRoute),
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return GradientAppBar(
      showBack: false,
      titleWidget: Obx(() {
        if (controller.isSearching.value) {
          return TextField(
            autofocus: true,
            onChanged: controller.setSearch,
            cursorColor: Colors.white,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'search'.tr,
              hintStyle: TextStyle(color: Colors.white.withAlpha(160)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          );
        }
        return Text(
          controller.showTrashOnly.value
              ? 'trash'.tr
              : controller.showFavoritesOnly.value
                  ? 'favorites'.tr
                  : 'my_documents'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        );
      }),
      actions: [
        Obx(
          () => IconButton(
            icon: Icon(
              controller.showTrashOnly.value
                  ? Icons.delete_sweep_rounded
                  : Icons.delete_outline_rounded,
              color: controller.showTrashOnly.value ? Colors.amber : null,
            ),
            tooltip: controller.showTrashOnly.value
                ? 'empty_trash'.tr
                : 'trash'.tr,
            onPressed: controller.showTrashOnly.value
                ? controller.emptyTrash
                : controller.toggleTrashView,
          ),
        ),
        Obx(
          () => controller.showTrashOnly.value
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: controller.toggleTrashView,
                )
              : IconButton(
                  icon: Icon(
                    controller.isSearching.value ? Icons.close : Icons.search,
                  ),
                  onPressed: controller.toggleSearch,
                ),
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.sort),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: controller.setSortBy,
          itemBuilder: (_) => [
            PopupMenuItem(value: 'date', child: Text('sort_by_date'.tr)),
            PopupMenuItem(value: 'name', child: Text('sort_by_name'.tr)),
            PopupMenuItem(value: 'size', child: Text('sort_by_size'.tr)),
          ],
        ),
      ],
      bottom: _FolderTabsBar(),
    );
  }

  Widget _buildSortBar(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Text(
              controller.filteredDocuments.length == 1
                  ? 'document_count_one'.trParams({
                      'count': '${controller.filteredDocuments.length}',
                    })
                  : 'document_count_other'.trParams({
                      'count': '${controller.filteredDocuments.length}',
                    }),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.sort_rounded, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  controller.sortBy.value == 'date'
                      ? 'date'.tr
                      : controller.sortBy.value == 'name'
                          ? 'name'.tr
                          : 'size'.tr,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentList(BuildContext context) {
    return Obx(() {
      if (controller.filteredDocuments.isEmpty) {
        return EmptyState(
          icon: controller.showTrashOnly.value
              ? Icons.delete_outline_rounded
              : controller.showFavoritesOnly.value
                  ? Icons.favorite_border_rounded
                  : Icons.folder_open_rounded,
          title: controller.showTrashOnly.value
              ? 'no_trash'.tr
              : controller.showFavoritesOnly.value
                  ? 'no_favorites'.tr
                  : controller.searchQuery.value.isNotEmpty
                      ? 'no_results'.tr
                      : 'no_documents'.tr,
          subtitle: controller.showTrashOnly.value
              ? 'no_trash_hint'.tr
              : controller.showFavoritesOnly.value
                  ? 'no_favorites_hint'.tr
                  : controller.searchQuery.value.isNotEmpty
                      ? 'try_different_search'.tr
                      : 'scan_import_hint'.tr,
          actionLabel: controller.showTrashOnly.value
              ? 'browse_documents'.tr
              : controller.showFavoritesOnly.value
                  ? 'browse_documents'.tr
                  : 'scan_document'.tr,
          onAction: controller.showTrashOnly.value
              ? controller.toggleTrashView
              : controller.showFavoritesOnly.value
                  ? () {
                      controller.showFavoritesOnly.value = false;
                      controller.setFolder('All Documents');
                    }
                  : () => Get.toNamed(AppConstants.scannerRoute),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => controller.loadDocuments(),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.filteredDocuments.length,
          itemBuilder: (_, index) {
            final doc = controller.filteredDocuments[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DocumentCard(
                document: doc,
                onTap: () => controller.openDocument(doc),
                onShare: controller.showTrashOnly.value
                    ? null
                    : () => controller.shareDocument(doc),
                onDelete: () => controller.deleteDocument(doc),
                onFavorite: controller.showTrashOnly.value
                    ? null
                    : () => controller.toggleFavorite(doc),
                onRename: controller.showTrashOnly.value
                    ? null
                    : () => controller.renameDocument(doc),
                onRestore: controller.showTrashOnly.value
                    ? () => controller.restoreDocument(doc)
                    : null,
              ),
            );
          },
        ),
      );
    });
  }
}

class _FolderTabsBar extends GetView<DocumentsController>
    implements PreferredSizeWidget {
  _FolderTabsBar();

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.showFavoritesOnly.value ||
          controller.showTrashOnly.value) {
        return const SizedBox.shrink();
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Row(
          children: AppConstants.defaultFolders.map((folder) {
            final isSelected = controller.selectedFolder.value == folder;
            return GestureDetector(
              onTap: () => controller.setFolder(folder),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  folder,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryColor : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }
}
