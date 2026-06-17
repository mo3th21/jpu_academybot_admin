import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/news.dart';

class NewsServiceException implements Exception {
  final String message;
  const NewsServiceException(this.message);
  
  @override
  String toString() => message;
}

class NewsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'news';
  
  // Constants for validation
  static const int _maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int _maxTitleLength = 200;
  static const int _maxTextLength = 5000;

  // جلب جميع الأخبار
  Stream<List<News>> getNews() {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .limit(100) // Limit for performance
        .snapshots()
        .handleError((error) {
          if (kDebugMode) debugPrint('❌ Error fetching news: $error');
          throw NewsServiceException('فشل تحميل الأخبار');
        })
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['newsId'] = doc.id; // إضافة ID للبيانات
            return News.fromMap(data);
          }).toList();
        });
  }

  // إضافة خبر جديد
  Future<void> addNews(News news) async {
    _validateNews(news);
    
    try {
      final docRef = _firestore.collection(_collection).doc();
      final newNews = news.copyWith(newsId: docRef.id, timestamp: DateTime.now());
      await docRef.set(newNews.toMap());
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error adding news: $e');
      throw NewsServiceException('فشل إضافة الخبر');
    }
  }

  // تحديث خبر
  Future<void> updateNews(String id, News news) async {
    if (id.trim().isEmpty) {
      throw const NewsServiceException('معرّف الخبر غير صالح');
    }
    _validateNews(news);
    
    try {
      await _firestore.collection(_collection).doc(id).update(news.toMap());
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error updating news: $e');
      throw NewsServiceException('فشل تحديث الخبر');
    }
  }

  // حذف خبر
  Future<void> deleteNews(String id, String? imageUrl) async {
    if (id.trim().isEmpty) {
      throw const NewsServiceException('معرّف الخبر غير صالح');
    }
    
    try {
      // Delete image first (non-blocking)
      if (imageUrl != null && imageUrl.isNotEmpty) {
        _deleteImageSafely(imageUrl);
      }
      
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error deleting news: $e');
      throw NewsServiceException('فشل حذف الخبر');
    }
  }

  // رفع صورة إلى Firebase Storage
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Validate file size
      final fileSize = await imageFile.length();
      if (fileSize > _maxImageSizeBytes) {
        throw NewsServiceException('حجم الصورة كبير جداً (الحد الأقصى ${_maxImageSizeBytes ~/ (1024 * 1024)}MB)');
      }

      final fileName = 'news_images/${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString()}.jpg';
      final ref = _storage.ref().child(fileName);
      
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploadedAt': DateTime.now().toIso8601String()},
      );
      
      final uploadTask = ref.putFile(imageFile, metadata);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error uploading image: $e');
      if (e is NewsServiceException) rethrow;
      throw NewsServiceException('فشل رفع الصورة');
    }
  }

  // رفع صورة من bytes (للويب) مع حل CORS
  Future<String?> uploadImageBytes(Uint8List imageBytes) async {
    try {
      // Validate size
      if (imageBytes.length > _maxImageSizeBytes) {
        throw NewsServiceException('حجم الصورة كبير جداً (الحد الأقصى ${_maxImageSizeBytes ~/ (1024 * 1024)}MB)');
      }

      final fileName = 'news_images/${DateTime.now().millisecondsSinceEpoch}_${_generateRandomString()}.jpg';
      final ref = _storage.ref().child(fileName);
      
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'uploaded': 'web', 'uploadedAt': DateTime.now().toIso8601String()},
      );
      
      final uploadTask = ref.putData(imageBytes, metadata);
      final snapshot = await uploadTask;
      
      String downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrl = downloadUrl.replaceAll('firebasestorage.googleapis.com', 'storage.googleapis.com');
      
      if (kDebugMode) debugPrint('✅ Image uploaded successfully');
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error uploading image bytes: $e');
      if (e is NewsServiceException) rethrow;
      throw NewsServiceException('فشل رفع الصورة');
    }
  }

  // حذف صورة قديمة عند التحديث
  Future<void> deleteOldImage(String? imageUrl) async {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      await _deleteImageSafely(imageUrl);
    }
  }

  // Private helper methods
  void _validateNews(News news) {
    if (news.title.trim().isEmpty) {
      throw const NewsServiceException('عنوان الخبر مطلوب');
    }
    if (news.title.length > _maxTitleLength) {
      throw NewsServiceException('عنوان الخبر طويل جداً (الحد الأقصى $_maxTitleLength حرف)');
    }
    if (news.text.trim().isEmpty) {
      throw const NewsServiceException('نص الخبر مطلوب');
    }
    if (news.text.length > _maxTextLength) {
      throw NewsServiceException('نص الخبر طويل جداً (الحد الأقصى $_maxTextLength حرف)');
    }
  }

  Future<void> _deleteImageSafely(String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
      if (kDebugMode) debugPrint('✅ Image deleted successfully');
    } catch (e) {
      // Don't throw - deletion is non-critical
      if (kDebugMode) debugPrint('⚠️ Could not delete image: $e');
    }
  }

  String _generateRandomString() {
    return DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  }
}
