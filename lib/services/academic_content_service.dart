import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_selector/file_selector.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class AcademicContentException implements Exception {
  final String message;
  const AcademicContentException(this.message);
  
  @override
  String toString() => message;
}

class AcademicContentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Constants
  static const int _maxFileSizeBytes = 10 * 1024 * 1024; // 10MB
  static const List<String> _allowedExtensions = ['pdf', 'doc', 'docx'];
  static const int _maxSubjectLength = 200;
  static const int _maxDescriptionLength = 1000;

  Query get contentsQuery => _firestore
      .collection('academic_contents')
      .orderBy('uploadedAt', descending: true)
      .limit(100); // Performance limit

  List<QueryDocumentSnapshot> filterContents(
    List<QueryDocumentSnapshot> docs,
    String majorFilter,
    String searchText,
  ) {
    var filtered = docs;
    
    // Filter by major
    if (majorFilter != 'All') {
      filtered = filtered.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['major'] == majorFilter;
      }).toList();
    }
    
    // Filter by search text
    final search = searchText.trim().toLowerCase();
    if (search.isNotEmpty) {
      filtered = filtered.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final subject = (data['subject'] ?? '').toString().toLowerCase();
        final description = (data['description'] ?? '').toString().toLowerCase();
        return subject.contains(search) || description.contains(search);
      }).toList();
    }
    
    return filtered;
  }

  Future<Map<String, String>> uploadFile(XFile file) async {
    try {
      // Validate file extension
      final extension = file.name.split('.').last.toLowerCase();
      if (!_allowedExtensions.contains(extension)) {
        throw AcademicContentException('نوع الملف غير مدعوم. المسموح: ${_allowedExtensions.join(", ")}');
      }

      // Validate file size
      final bytes = await file.readAsBytes();
      if (bytes.length > _maxFileSizeBytes) {
        throw AcademicContentException('حجم الملف كبير جداً (الحد الأقصى ${_maxFileSizeBytes ~/ (1024 * 1024)}MB)');
      }

      final uid = _auth.currentUser?.uid ?? 'anon';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final randomStr = timestamp.toRadixString(36);
      final sanitizedName = _sanitizeFilename(file.name);
      final name = '${uid}_${randomStr}_$sanitizedName';
      final ref = _storage.ref('academic_files/$name');

      final metadata = SettableMetadata(
        contentType: _getContentType(extension),
        customMetadata: {
          'originalName': file.name,
          'uploadedBy': uid,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      final snapshot = await ref.putData(bytes, metadata);
      final url = await snapshot.ref.getDownloadURL();
      
      if (kDebugMode) debugPrint('✅ File uploaded: $name');
      return {'url': url, 'filename': file.name};
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Upload error: $e');
      if (e is AcademicContentException) rethrow;
      throw const AcademicContentException('فشل رفع الملف');
    }
  }

  // إضافة محتوى أكاديمي جديد
  Future<void> addContent({
    required String subject,
    required String major,
    String? description,
    required String downloadUrl,
    required String filename,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AcademicContentException('يجب تسجيل الدخول');
    }

    _validateContent(subject, description, downloadUrl, filename);

    final data = {
      'adminId': user.uid,
      'downloadUrl': downloadUrl.trim(),
      'filename': filename.trim(),
      'subject': subject.trim(),
      'major': major.trim(),
      'description': (description?.trim().isEmpty ?? true) ? null : description!.trim(),
      'uploadedAt': FieldValue.serverTimestamp(),
    };

    try {
      final collection = _firestore.collection('academic_contents');
      final docRef = collection.doc();
      await docRef.set({...data, 'contractId': docRef.id});
      if (kDebugMode) debugPrint('✅ Content added: ${docRef.id}');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Add error: $e');
      throw const AcademicContentException('فشل إضافة المحتوى');
    }
  }

  // تحديث محتوى أكاديمي موجود
  Future<void> updateContent({
    required String docId,
    required String subject,
    required String major,
    String? description,
    required String downloadUrl,
    required String filename,
  }) async {
    if (docId.trim().isEmpty) {
      throw const AcademicContentException('معرّف المحتوى غير صالح');
    }

    final user = _auth.currentUser;
    if (user == null) {
      throw const AcademicContentException('يجب تسجيل الدخول');
    }

    _validateContent(subject, description, downloadUrl, filename);

    final data = {
      'adminId': user.uid,
      'downloadUrl': downloadUrl.trim(),
      'filename': filename.trim(),
      'subject': subject.trim(),
      'major': major.trim(),
      'description': (description?.trim().isEmpty ?? true) ? null : description!.trim(),
      'uploadedAt': FieldValue.serverTimestamp(),
    };

    try {
      await _firestore.collection('academic_contents').doc(docId).update(data);
      if (kDebugMode) debugPrint('✅ Content updated: $docId');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Update error: $e');
      throw const AcademicContentException('فشل تحديث المحتوى');
    }
  }

  // للتوافق مع الكود القديم - استخدام addContent أو updateContent بدلاً منه
  @Deprecated('Use addContent() or updateContent() instead')
  Future<void> saveContent({
    String? docId,
    required String subject,
    required String major,
    String? description,
    required String downloadUrl,
    required String filename,
  }) async {
    if (docId == null) {
      await addContent(
        subject: subject,
        major: major,
        description: description,
        downloadUrl: downloadUrl,
        filename: filename,
      );
    } else {
      await updateContent(
        docId: docId,
        subject: subject,
        major: major,
        description: description,
        downloadUrl: downloadUrl,
        filename: filename,
      );
    }
  }

  // Private validation helper
  void _validateContent(String subject, String? description, String downloadUrl, String filename) {
    if (subject.trim().isEmpty) {
      throw const AcademicContentException('اسم المادة مطلوب');
    }
    if (subject.length > _maxSubjectLength) {
      throw AcademicContentException('اسم المادة طويل جداً (الحد الأقصى $_maxSubjectLength حرف)');
    }
    if (description != null && description.length > _maxDescriptionLength) {
      throw AcademicContentException('الوصف طويل جداً (الحد الأقصى $_maxDescriptionLength حرف)');
    }
    if (downloadUrl.trim().isEmpty || filename.trim().isEmpty) {
      throw const AcademicContentException('الملف مطلوب');
    }
  }

  Future<void> deleteContent({
    required String docId,
    required String downloadUrl,
  }) async {
    if (docId.trim().isEmpty) {
      throw const AcademicContentException('معرّف المحتوى غير صالح');
    }

    try {
      await _firestore.collection('academic_contents').doc(docId).delete();
      if (kDebugMode) debugPrint('✅ Content deleted: $docId');
      
      // Delete file (non-blocking)
      if (downloadUrl.isNotEmpty) {
        _deleteFileSafely(downloadUrl);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Delete error: $e');
      throw const AcademicContentException('فشل الحذف');
    }
  }

  // Private helpers
  String _getContentType(String extension) {
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'doc':
        return 'application/msword';
      default:
        return 'application/octet-stream';
    }
  }

  String _sanitizeFilename(String filename) {
    // Remove special characters for security
    return filename.replaceAll(RegExp(r'[^\w\s.-]'), '_');
  }

  Future<void> _deleteFileSafely(String url) async {
    try {
      await _storage.refFromURL(url).delete();
      if (kDebugMode) debugPrint('✅ File deleted from storage');
    } catch (e) {
      if (kDebugMode) debugPrint('⚠️ Could not delete file: $e');
    }
  }
}
