import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/document_model.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_helpers.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/empty_state.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, settingsCtrl),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildStatsRow(context),
                const SizedBox(height: 20),
                _buildQuickActions(context),
                const SizedBox(height: 24),
                _buildRecentDocuments(context),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.navigateToScanner,
        icon: const Icon(Icons.document_scanner_rounded),
        label: Text('scan'.tr),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(
      BuildContext context, SettingsController settingsCtrl) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () => Get.toNamed(AppConstants.documentsRoute),
        ),
        Obx(
          () => IconButton(
            icon: Icon(
              settingsCtrl.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () =>
                settingsCtrl.toggleDarkMode(!settingsCtrl.isDarkMode),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          onPressed: controller.navigateToSettings,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16, right: 140),
        title: const Text(
          'DocSnap',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryDark, AppTheme.primaryLight],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: 20,
                child: Opacity(
                  opacity: 0.12,
                  child: Icon(
                    Icons.document_scanner_rounded,
                    size: 160,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => _StatCard(
                icon: Icons.description_rounded,
                label: 'total_documents'.tr,
                value: '${controller.totalDocuments.value}',
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => _StatCard(
                icon: Icons.layers_rounded,
                label: 'total_pages'.tr,
                value: '${controller.totalPages.value}',
                color: AppTheme.accentColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.folder_rounded,
              label: 'folder'.tr,
              value: '${AppConstants.defaultFolders.length - 1}',
              color: AppTheme.warningColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Quick Actions'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.document_scanner_rounded,
                  label: 'Scan\nDocument',
                  color: AppTheme.primaryColor,
                  onTap: controller.navigateToScanner,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.photo_library_rounded,
                  label: 'Import from\nGallery',
                  color: const Color(0xFF7B1FA2),
                  onTap: controller.navigateToScanner,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.folder_open_rounded,
                  label: 'My\nDocuments',
                  color: AppTheme.warningColor,
                  onTap: controller.navigateToDocuments,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.draw_rounded,
                  label: 'Sign\nPDF',
                  color: AppTheme.successColor,
                  onTap: controller.navigateToSignature,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDocuments(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'recent_documents'.tr,
            actionLabel: 'documents'.tr,
            onAction: controller.navigateToDocuments,
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (controller.recentDocuments.isEmpty) {
              return EmptyState(
                icon: Icons.description_outlined,
                title: 'no_documents'.tr,
                subtitle: 'start_scanning'.tr,
                actionLabel: 'scan'.tr,
                onAction: controller.navigateToScanner,
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.recentDocuments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final doc = controller.recentDocuments[index];
                return _RecentDocumentTile(
                  doc: doc,
                  onTap: () => controller.openDocument(doc),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(50), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentDocumentTile extends StatelessWidget {
  final DocumentModel doc;
  final VoidCallback onTap;

  const _RecentDocumentTile({required this.doc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 44,
            height: 54,
            child: doc.thumbnailPath != null &&
                    File(doc.thumbnailPath!).existsSync()
                ? Image.file(File(doc.thumbnailPath!), fit: BoxFit.cover)
                : Container(
                    color: Colors.red.shade50,
                    child: Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red.shade400,
                      size: 24,
                    ),
                  ),
          ),
        ),
        title: Text(
          doc.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${doc.pageCount} pages • ${AppHelpers.formatDate(doc.updatedAt)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }
}
