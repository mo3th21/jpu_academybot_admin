import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

import '../../models/academic_content.dart';
import '../../theme/app_theme.dart';
import '../../services/academic_content_service.dart';
import 'academic_major_dropdown.dart';
import 'academic_text_form_field.dart';

class AcademicContentDialogResult {
  final String subject;
  final String major;
  final String description;
  final String downloadUrl;
  final String filename;

  const AcademicContentDialogResult({
    required this.subject,
    required this.major,
    required this.description,
    required this.downloadUrl,
    required this.filename,
  });
}

Future<AcademicContentDialogResult?> showAcademicContentDialog({
  required BuildContext context,
  required AcademicContentService service,
  required void Function(String message) showFeedback,
  AcademicContent? existingContent,
}) {
  return showDialog<AcademicContentDialogResult>(
    context: context,
    builder: (ctx) => AcademicContentDialog(
      service: service,
      showFeedback: showFeedback,
      existingContent: existingContent,
    ),
  );
}

class AcademicContentDialog extends StatefulWidget {
  final AcademicContentService service;
  final void Function(String message) showFeedback;
  final AcademicContent? existingContent;

  const AcademicContentDialog({
    super.key,
    required this.service,
    required this.showFeedback,
    this.existingContent,
  });

  @override
  State<AcademicContentDialog> createState() => _AcademicContentDialogState();
}

class _AcademicContentDialogState extends State<AcademicContentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _subjectCtrl;
  late TextEditingController _descCtrl;
  late String _major;
  String? _fileUrl;
  String? _filename;
  bool _fileUploaded = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _subjectCtrl = TextEditingController(text: widget.existingContent?.subject);
    _descCtrl = TextEditingController(text: widget.existingContent?.description);
    _major = widget.existingContent?.major ?? 'أمن سيبراني';
    _fileUrl = widget.existingContent?.downloadUrl;
    _filename = widget.existingContent?.filename;
    _fileUploaded = widget.existingContent != null;
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleUpload() async {
    final xf = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(label: 'documents', extensions: ['pdf', 'doc', 'docx'])
      ],
    );
    if (xf == null) return;

    setState(() => _isUploading = true);
    try {
      final uploaded = await widget.service.uploadFile(xf);
      setState(() {
        _fileUrl = uploaded['url'];
        _filename = uploaded['filename'];
        _fileUploaded = true;
      });
      widget.showFeedback('تم رفع الملف بنجاح ✓');
    } on AcademicContentException catch (e) {
      widget.showFeedback(e.message);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          widget.existingContent == null ? 'إضافة محتوى أكاديمي' : 'تعديل المحتوى',
          style: TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AcademicTextFormField(
                  controller: _subjectCtrl,
                  label: 'اسم المادة',
                  icon: Icons.book,
                  isRequired: true,
                ),
                const SizedBox(height: 16),
                AcademicMajorDropdown(
                  value: _major,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _major = v);
                  },
                ),
                const SizedBox(height: 16),
                AcademicTextFormField(
                  controller: _descCtrl,
                  label: 'الوصف',
                  icon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _handleUpload,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: _fileUploaded ? Colors.green : AppTheme.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            _fileUploaded ? Icons.check_circle : Icons.upload_file,
                            color: Colors.white,
                          ),
                    label: Text(
                      _isUploading
                          ? 'جارٍ الرفع...'
                          : _fileUploaded
                              ? 'تم رفع الملف ✓'
                              : 'رفع ملف',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                if (_fileUploaded && _filename != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _filename!,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              if (_fileUrl == null) {
                widget.showFeedback('الرجاء رفع ملف');
                return;
              }
              Navigator.pop(
                context,
                AcademicContentDialogResult(
                  subject: _subjectCtrl.text.trim(),
                  major: _major,
                  description: _descCtrl.text.trim(),
                  downloadUrl: _fileUrl!,
                  filename: _filename ?? '',
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text('حفظ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
