import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/document_model.dart';
import '../themes/app_theme.dart';
import '../utils/app_helpers.dart';

class DocumentCard extends StatelessWidget {
  final DocumentModel document;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final VoidCallback? onFavorite;
  final VoidCallback? onRename;
  final VoidCallback? onRestore;

  const DocumentCard({
    super.key,
    required this.document,
    this.onTap,
    this.onShare,
    this.onDelete,
    this.onFavorite,
    this.onRename,
    this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildThumbnail(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          size: 14,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            document.pageCount == 1
                                ? 'page_count_one'.trParams(
                                    {'count': '${document.pageCount}'})
                                : 'pages_count'.trParams(
                                    {'count': '${document.pageCount}'}),
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.storage,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            AppHelpers.formatFileSize(document.sizeBytes),
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 13,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            document.folder,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            AppHelpers.formatDate(document.updatedAt),
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onFavorite != null)
                    IconButton(
                      icon: Icon(
                        document.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 20,
                        color: document.isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: onFavorite,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  if (onRestore != null)
                    IconButton(
                      icon: const Icon(Icons.restore_from_trash_rounded,
                          size: 20, color: AppTheme.primaryColor),
                      tooltip: 'restore'.tr,
                      onPressed: onRestore,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'share':
                          onShare?.call();
                          break;
                        case 'rename':
                          onRename?.call();
                          break;
                        case 'restore':
                          onRestore?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (_) => [
                      if (onRestore != null)
                        PopupMenuItem(
                          value: 'restore',
                          child: Row(
                            children: [
                              const Icon(Icons.restore_from_trash_rounded,
                                  size: 18),
                              const SizedBox(width: 12),
                              Text('restore'.tr),
                            ],
                          ),
                        ),
                      if (onShare != null)
                        PopupMenuItem(
                          value: 'share',
                          child: Row(
                            children: [
                              const Icon(Icons.share, size: 18),
                              const SizedBox(width: 12),
                              Text('share'.tr),
                            ],
                          ),
                        ),
                      if (onRename != null)
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
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete_outline,
                                size: 18, color: Colors.red),
                            const SizedBox(width: 12),
                            Text('delete'.tr,
                                style: const TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 56,
        height: 70,
        child: document.thumbnailPath != null &&
                File(document.thumbnailPath!).existsSync()
            ? Image.file(
                File(document.thumbnailPath!),
                fit: BoxFit.cover,
              )
            : Container(
                color: Colors.red.shade50,
                child: Center(
                  child: Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red.shade400,
                    size: 28,
                  ),
                ),
              ),
      ),
    );
  }
}
