import 'package:flutter/material.dart';

import '../../models/news.dart';
import '../../theme/app_theme.dart';
import '../../utils/firebase_utils.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({
    super.key,
    required this.news,
    required this.onEdit,
    required this.onDelete,
  });

  final News news;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String _cacheBusted(String url) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final separator = url.contains('?') ? '&' : '?';
    return '$url${separator}t=$timestamp';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final normalized = normalizeFirebaseImageUrl(news.imageUrl);
    final imageUrl = (normalized == null || normalized.trim().isEmpty) ? null : _cacheBusted(normalized);

    return Card(
      margin: const EdgeInsets.all(4),
      elevation: 8,
      shadowColor: AppTheme.primary.withOpacity(0.4),
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppTheme.primary.withOpacity(0.3), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: AppTheme.primary.withOpacity(0.1),
              padding: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: imageUrl == null
                  ? Icon(Icons.image_not_supported, size: 28, color: AppTheme.textSecondary)
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.broken_image,
                        size: 28,
                        color: AppTheme.textSecondary,
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primary,
                          ),
                        );
                      },
                      // Add caching headers
                      cacheWidth: 400,
                    ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: AppTheme.surface,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    news.title.trim(),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    news.text.trim(),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: AppTheme.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            _formatDate(news.timestamp),
                            style: textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit, size: 18),
                            color: AppTheme.primary,
                            tooltip: 'تعديل',
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: onDelete,
                            icon: const Icon(Icons.delete, size: 18),
                            color: AppTheme.error,
                            tooltip: 'حذف',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
