import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'models/academic_content.dart';
import 'theme/app_theme.dart';
import 'widgets/academic/academic_content_card.dart';
import 'widgets/academic/academic_filter_bar.dart';
import 'widgets/academic/academic_content_dialog.dart';
import 'services/academic_content_service.dart';

class AcademicManagementPage extends StatefulWidget {
  const AcademicManagementPage({super.key});

  @override
  State<AcademicManagementPage> createState() => _AcademicManagementPageState();
}

class _AcademicManagementPageState extends State<AcademicManagementPage> {
  final _searchCtrl = TextEditingController();
  final _service = AcademicContentService();
  String _majorFilter = 'All';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Query _buildQuery() => _service.contentsQuery;

  void _showSnackbar(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _showContentDialog({String? docId, AcademicContent? item}) async {
    final result = await showAcademicContentDialog(
      context: context,
      service: _service,
      showFeedback: _showSnackbar,
      existingContent: item,
    );
    if (result == null) return;
    try {
      if (docId == null) {
        // إضافة محتوى جديد
        await _service.addContent(
          subject: result.subject,
          major: result.major,
          description: result.description,
          downloadUrl: result.downloadUrl,
          filename: result.filename,
        );
        _showSnackbar('تم الإضافة بنجاح');
      } else {
        // تحديث محتوى موجود
        await _service.updateContent(
          docId: docId,
          subject: result.subject,
          major: result.major,
          description: result.description,
          downloadUrl: result.downloadUrl,
          filename: result.filename,
        );
        _showSnackbar('تم التعديل بنجاح');
      }
    } on AcademicContentException catch (e) {
      _showSnackbar(e.message);
    }
  }

  Future<void> _deleteContent(String docId, String url) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد من حذف هذا المحتوى؟'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('لا')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('نعم', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
    if (confirm != true) return;
    try {
      await _service.deleteContent(docId: docId, downloadUrl: url);
      _showSnackbar('تم الحذف');
    } on AcademicContentException catch (e) {
      _showSnackbar(e.message);
    }
  }

  // تحسين فتح الملف - معاينة ثم تحميل
  void _openUrl(String url) async {
    if (url.isEmpty) {
      _showSnackbar('لا يوجد رابط');
      return;
    }
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.file_download, color: AppTheme.primary),
              const SizedBox(width: 12),
              const Text('تحميل الملف'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('هل تريد فتح/تحميل هذا الملف؟'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      url.toLowerCase().endsWith('.pdf') 
                          ? Icons.picture_as_pdf 
                          : Icons.description,
                      color: AppTheme.accent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        url.split('/').last.split('?').first,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              icon: const Icon(Icons.open_in_new, color: Colors.white, size: 18),
              label: const Text('فتح', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (confirm != true) return;

    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url, mode: LaunchMode.externalApplication);
      } else {
        _showSnackbar('لا يمكن فتح الرابط');
      }
    } catch (_) {
      _showSnackbar('خطأ في فتح الرابط');
    }
  }

  List<QueryDocumentSnapshot> _filterDocs(List<QueryDocumentSnapshot> docs) =>
      _service.filterContents(docs, _majorFilter, _searchCtrl.text.trim());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('إدارة المحتوى الأكاديمي'),
          backgroundColor: AppTheme.surface,
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showContentDialog(),
          backgroundColor: AppTheme.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('إضافة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: Column(
          children: [
            AcademicFilterBar(
              searchController: _searchCtrl,
              onSearchChanged: (_) => setState(() {}),
              selectedMajor: _majorFilter,
              onMajorChanged: (v) => setState(() => _majorFilter = v ?? 'All'),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _buildQuery().snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Center(child: Text('خطأ: ${snapshot.error}'));
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  // تطبيق فلتر البحث محلياً
                  final docs = _filterDocs(snapshot.data!.docs);
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open, size: 80, color: AppTheme.textSecondary.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text('لا يوجد محتوى', style: TextStyle(fontSize: 18, color: AppTheme.textSecondary)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (ctx, i) {
                      final item = AcademicContent.fromDoc(docs[i]);
                      final docId = docs[i].id;
                      final date = item.uploadedAt.toDate();
                      final dateStr = '${date.day}/${date.month}/${date.year}';

                      return AcademicContentCard(
                        content: item,
                        dateLabel: dateStr,
                        onDownload: () => _openUrl(item.downloadUrl),
                        onEdit: () => _showContentDialog(docId: docId, item: item),
                        onDelete: () => _deleteContent(docId, item.downloadUrl),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}