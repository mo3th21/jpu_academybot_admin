import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/news.dart';
import '../../services/news_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/firebase_utils.dart';

class NewsFormDialog extends StatefulWidget {
  const NewsFormDialog({
    super.key,
    required this.newsService,
    this.news,
  });

  final NewsService newsService;
  final News? news;

  @override
  State<NewsFormDialog> createState() => _NewsFormDialogState();
}

class _NewsFormDialogState extends State<NewsFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  Uint8List? _webImage;
  String? _existingImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.news != null) {
      _titleController.text = widget.news!.title;
      _contentController.text = widget.news!.text;
      _existingImageUrl = normalizeFirebaseImageUrl(widget.news!.imageUrl);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        const typeGroup = XTypeGroup(label: 'images', extensions: ['jpg', 'jpeg', 'png']);
        final file = await openFile(acceptedTypeGroups: [typeGroup]);
        if (file != null) {
          final bytes = await file.readAsBytes();
          setState(() {
            _webImage = bytes;
            _imageFile = null;
          });
        }
        return;
      }

      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _webImage = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في اختيار الصورة: $e')),
      );
    }
  }

  Future<void> _saveNews() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String? imageUrl = _existingImageUrl;

      if (_imageFile != null || _webImage != null) {
        if (_existingImageUrl != null && widget.news != null) {
          await widget.newsService.deleteOldImage(_existingImageUrl);
        }
        if (kIsWeb && _webImage != null) {
          imageUrl = await widget.newsService.uploadImageBytes(_webImage!);
        } else if (_imageFile != null) {
          imageUrl = await widget.newsService.uploadImage(_imageFile!);
        }
        if (imageUrl == null) throw Exception('فشل رفع الصورة');
      }

      final news = News(
        newsId: widget.news?.newsId ?? '',
        adminId: 'admin',
        title: _titleController.text.trim(),
        text: _contentController.text.trim(),
        imageUrl: imageUrl,
        timestamp: widget.news?.timestamp ?? DateTime.now(),
      );

      if (widget.news == null) {
        await widget.newsService.addNews(news);
      } else {
        await widget.newsService.updateNews(widget.news!.newsId, news);
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.news == null ? 'تم إضافة الخبر بنجاح' : 'تم تحديث الخبر بنجاح'),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.news == null ? 'إضافة خبر جديد' : 'تعديل الخبر',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppTheme.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'عنوان الخبر',
                    prefixIcon: Icon(Icons.title, color: AppTheme.primary),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'الرجاء إدخال عنوان الخبر' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'محتوى الخبر',
                    prefixIcon: Icon(Icons.article, color: AppTheme.primary),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'الرجاء إدخال محتوى الخبر' : null,
                ),
                const SizedBox(height: 16),
                if (_imageFile != null || _webImage != null || _existingImageUrl != null)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb && _webImage != null
                          ? Image.memory(_webImage!, fit: BoxFit.cover)
                          : _imageFile != null
                              ? Image.file(_imageFile!, fit: BoxFit.cover)
                              : Image.network(
                                  _existingImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: AppTheme.background,
                                    child: Icon(Icons.broken_image, size: 50, color: AppTheme.error),
                                  ),
                                ),
                    ),
                  ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _pickImage,
                  icon: Icon(Icons.image, color: AppTheme.primary),
                  label: Text(
                    _imageFile != null || _webImage != null || _existingImageUrl != null ? 'تغيير الصورة' : 'اختيار صورة',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppTheme.primary),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: Text(
                        'إلغاء',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.textSecondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveNews,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text('حفظ', style: Theme.of(context).textTheme.labelLarge),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
