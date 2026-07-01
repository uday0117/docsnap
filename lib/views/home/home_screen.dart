import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/home_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../models/document_model.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_helpers.dart';
import '../../utils/app_theme_mode.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/empty_state.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsCtrl = Get.find<SettingsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppTheme.primaryColor,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(context, settingsCtrl, isDark),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildScanHero(context),
                    const SizedBox(height: 20),
                    _buildStatsRow(context),
                    const SizedBox(height: 24),
                    _buildQuickTools(context),
                    const SizedBox(height: 24),
                    _buildShareCard(context),
                    const SizedBox(height: 24),
                    _buildPinnedSection(context),
                    _buildPdfTools(context),
                    const SizedBox(height: 24),
                    _buildRecentSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    SettingsController settingsCtrl,
    bool isDark,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryDark, AppTheme.primaryLight],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.document_scanner_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'app_name'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'app_subtitle'.tr,
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(35),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'free_forever_badge'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search_rounded, color: Colors.white),
                    onPressed: controller.navigateToDocuments,
                    tooltip: 'search_documents'.tr,
                  ),
                  Obx(
                    () {
                      final mode = settingsCtrl.settings.value.themeMode;
                      return IconButton(
                        icon: Icon(
                          switch (mode) {
                            AppThemeMode.dark => Icons.light_mode_rounded,
                            AppThemeMode.system => Icons.brightness_auto_rounded,
                            AppThemeMode.light => Icons.dark_mode_rounded,
                          },
                          color: Colors.white,
                        ),
                        onPressed: () {
                          final next = switch (mode) {
                            AppThemeMode.light => AppThemeMode.dark,
                            AppThemeMode.dark => AppThemeMode.system,
                            AppThemeMode.system => AppThemeMode.light,
                          };
                          settingsCtrl.setThemeMode(next);
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _greeting(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'greeting_morning'.tr;
    if (hour < 17) return 'greeting_afternoon'.tr;
    return 'greeting_evening'.tr;
  }

  Widget _buildScanHero(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: controller.navigateToScanner,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withAlpha(40),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryDark, AppTheme.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'scan'.tr,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'scan_subtitle'.tr,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, duration: 400.ms);
  }

  Widget _buildStatsRow(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _StatChip(
              icon: Icons.description_rounded,
              value: '${controller.totalDocuments.value}',
              label: 'total_documents'.tr,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatChip(
              icon: Icons.layers_rounded,
              value: '${controller.totalPages.value}',
              label: 'total_pages'.tr,
              color: AppTheme.accentColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _StatChip(
              icon: Icons.sd_storage_rounded,
              value: AppHelpers.formatFileSize(
                controller.totalStorageBytes.value,
              ),
              label: 'storage'.tr,
              color: AppTheme.warningColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareCard(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Share.share(
            'share_app_message'.trParams({'url': AppConstants.rateAppUrl}),
            subject: 'share_app_subject'.tr,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.successColor.withAlpha(30),
                AppTheme.primaryColor.withAlpha(20),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.successColor.withAlpha(50)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'share_card_title'.tr,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'share_card_subtitle'.tr,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppTheme.successColor.withAlpha(180),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 350.ms);
  }

  Widget _buildQuickTools(BuildContext context) {
    final tools = [
      _QuickTool(
        icon: Icons.badge_rounded,
        label: 'id_card_short'.tr,
        color: const Color(0xFF4527A0),
        onTap: controller.navigateToIdCardScanner,
      ),
      _QuickTool(
        icon: Icons.photo_library_rounded,
        label: 'gallery'.tr,
        color: const Color(0xFF7B1FA2),
        onTap: controller.navigateToGalleryImport,
      ),
      _QuickTool(
        icon: Icons.draw_rounded,
        label: 'sign_pdf'.tr,
        color: AppTheme.successColor,
        onTap: () => Get.toNamed(
          AppConstants.pdfToolsRoute,
          arguments: {'mode': 'sign'},
        ),
      ),
      _QuickTool(
        icon: Icons.text_snippet_rounded,
        label: 'ocr_short'.tr,
        color: const Color(0xFFE65100),
        onTap: () => Get.toNamed(AppConstants.ocrRoute),
      ),
      _QuickTool(
        icon: Icons.qr_code_scanner_rounded,
        label: 'qr_scan'.tr,
        color: const Color(0xFF00695C),
        onTap: () => Get.toNamed(AppConstants.qrScannerRoute),
      ),
      _QuickTool(
        icon: Icons.folder_open_rounded,
        label: 'docs'.tr,
        color: AppTheme.warningColor,
        onTap: controller.navigateToDocuments,
      ),
      _QuickTool(
        icon: Icons.star_rounded,
        label: 'favorites_short'.tr,
        color: Colors.amber.shade700,
        onTap: () => controller.navigateToDocuments(favoritesOnly: true),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'quick_actions'.tr),
        const SizedBox(height: 12),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tools.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final tool = tools[index];
              return _QuickToolChip(tool: tool);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPinnedSection(BuildContext context) {
    return Obx(() {
      if (controller.pinnedDocuments.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'pinned_documents'.tr),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.pinnedDocuments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                final doc = controller.pinnedDocuments[index];
                return _RecentDocCard(
                  doc: doc,
                  onTap: () => controller.openDocument(doc),
                  onShare: () => controller.shareDocument(doc),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    });
  }

  Widget _buildPdfTools(BuildContext context) {
    final tools = [
      _PdfTool(
        icon: Icons.merge_rounded,
        label: 'merge'.tr,
        color: const Color(0xFF880E4F),
        mode: 'merge',
      ),
      _PdfTool(
        icon: Icons.call_split_rounded,
        label: 'split'.tr,
        color: const Color(0xFF4A148C),
        mode: 'split',
      ),
      _PdfTool(
        icon: Icons.compress_rounded,
        label: 'compress'.tr,
        color: const Color(0xFF33691E),
        mode: 'compress',
      ),
      _PdfTool(
        icon: Icons.water_rounded,
        label: 'watermark'.tr,
        color: const Color(0xFF01579B),
        mode: 'watermark',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'pdf_tools'.tr,
          actionLabel: 'see_all'.tr,
          onAction: controller.navigateToTools,
        ),
        const SizedBox(height: 12),
        Row(
          children: tools
              .map(
                (t) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: t != tools.last ? 10 : 0,
                    ),
                    child: _PdfToolTile(tool: t),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRecentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'recent_documents'.tr,
          actionLabel: 'documents'.tr,
          onAction: controller.navigateToDocuments,
        ),
        const SizedBox(height: 12),
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

          return SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.recentDocuments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                final doc = controller.recentDocuments[index];
                return _RecentDocCard(
                  doc: doc,
                  onTap: () => controller.openDocument(doc),
                  onShare: () => controller.shareDocument(doc),
                )
                    .animate(delay: Duration(milliseconds: 60 * index))
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: 0.05, duration: 300.ms);
              },
            ),
          );
        }),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(35)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _QuickTool {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickTool({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _QuickToolChip extends StatelessWidget {
  final _QuickTool tool;

  const _QuickToolChip({required this.tool});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tool.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 80,
          height: 92,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tool.color.withAlpha(40)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: tool.color.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(tool.icon, color: tool.color, size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  tool.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: tool.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PdfTool {
  final IconData icon;
  final String label;
  final Color color;
  final String mode;

  const _PdfTool({
    required this.icon,
    required this.label,
    required this.color,
    required this.mode,
  });
}

class _PdfToolTile extends StatelessWidget {
  final _PdfTool tool;

  const _PdfToolTile({required this.tool});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed(
          AppConstants.pdfToolsRoute,
          arguments: {'mode': tool.mode},
        ),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: tool.color.withAlpha(15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: tool.color.withAlpha(35)),
          ),
          child: Column(
            children: [
              Icon(tool.icon, color: tool.color, size: 24),
              const SizedBox(height: 6),
              Text(
                tool.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: tool.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentDocCard extends StatelessWidget {
  final DocumentModel doc;
  final VoidCallback onTap;
  final VoidCallback onShare;

  const _RecentDocCard({
    required this.doc,
    required this.onTap,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    doc.thumbnailPath != null &&
                            File(doc.thumbnailPath!).existsSync()
                        ? Image.file(
                            File(doc.thumbnailPath!),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.red.shade50,
                            child: Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red.shade400,
                              size: 40,
                            ),
                          ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onShare,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.share_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'pages_count'.trParams({'count': '${doc.pageCount}'}),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
