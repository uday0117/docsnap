import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/documents_controller.dart';
import '../../models/document_model.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../widgets/document_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/common_widgets.dart';

class DocumentsScreen extends GetView<DocumentsController> {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildFolderTabs(context),
          _buildSortBar(context),
          Expanded(child: _buildDocumentList(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppConstants.scannerRoute),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Obx(() {
        if (controller.isSearching.value) {
          return TextField(
            autofocus: true,
            onChanged: controller.setSearch,
            decoration: const InputDecoration(
              hintText: 'Search documents...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white70),
            ),
            style: const TextStyle(color: Colors.white),
          );
        }
        return const Text('My Documents');
      }),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryDark, AppTheme.primaryLight],
          ),
        ),
      ),
      actions: [
        Obx(
          () => IconButton(
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
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'date', child: Text('Sort by Date')),
            PopupMenuItem(value: 'name', child: Text('Sort by Name')),
            PopupMenuItem(value: 'size', child: Text('Sort by Size')),
          ],
        ),
      ],
    );
  }

  Widget _buildFolderTabs(BuildContext context) {
    return Container(
      color: AppTheme.primaryColor,
      child: Obx(
        () => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    color:
                        isSelected ? Colors.white : Colors.white.withAlpha(30),
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
        ),
      ),
    );
  }

  Widget _buildSortBar(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Text(
              '${controller.filteredDocuments.length} document${controller.filteredDocuments.length == 1 ? '' : 's'}',
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
                      ? 'Date'
                      : controller.sortBy.value == 'name'
                          ? 'Name'
                          : 'Size',
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
          icon: Icons.folder_open_rounded,
          title: controller.searchQuery.value.isNotEmpty
              ? 'No results found'
              : 'No documents yet',
          subtitle: controller.searchQuery.value.isNotEmpty
              ? 'Try a different search term.'
              : 'Scan or import a document to see it here.',
          actionLabel: 'Scan Document',
          onAction: () => Get.toNamed(AppConstants.scannerRoute),
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
                onShare: () => controller.shareDocument(doc),
                onDelete: () => controller.deleteDocument(doc),
                onFavorite: () => controller.toggleFavorite(doc),
                onRename: () => controller.renameDocument(doc),
              ),
            );
          },
        ),
      );
    });
  }
}
