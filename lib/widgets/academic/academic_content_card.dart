import 'package:flutter/material.dart';

import '../../models/academic_content.dart';
import '../../theme/app_theme.dart';

class AcademicContentCard extends StatelessWidget {
  const AcademicContentCard({
    super.key,
    required this.content,
    required this.dateLabel,
    required this.onDownload,
    required this.onEdit,
    required this.onDelete,
  });

  final AcademicContent content;
  final String dateLabel;
  final VoidCallback onDownload;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.surface, AppTheme.surface.withValues(alpha: 0.5)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.defaultShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    content.downloadUrl.toLowerCase().endsWith('.pdf') ? Icons.picture_as_pdf : Icons.description,
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
                        content.subject,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.secondary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              content.major,
                              style: TextStyle(fontSize: 12, color: AppTheme.secondary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.calendar_today, size: 14, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(dateLabel, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (content.description != null && content.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  content.description!,
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onDownload,
                  icon: Icon(Icons.download, color: AppTheme.accent),
                  tooltip: 'تحميل',
                  style: IconButton.styleFrom(backgroundColor: AppTheme.accent.withValues(alpha: 0.1)),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit, color: AppTheme.primary),
                  tooltip: 'تعديل',
                  style: IconButton.styleFrom(backgroundColor: AppTheme.primary.withValues(alpha: 0.1)),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'حذف',
                  style: IconButton.styleFrom(backgroundColor: Colors.red.withValues(alpha: 0.1)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
