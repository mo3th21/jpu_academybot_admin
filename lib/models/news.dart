import 'package:cloud_firestore/cloud_firestore.dart';

class News {
  final String newsId;
  final String adminId;
  final String title;
  final String text;
  final String? imageUrl;
  final DateTime timestamp;

  News({
    required this.newsId,
    required this.adminId,
    required this.title,
    required this.text,
    required this.timestamp,
    this.imageUrl,
  });

  // للتوافق - getter للمحتوى
  String get content => text;

  // Constructor إضافي للتوافق مع الكود القديم
  factory News.legacy({
    String? id,
    required String title,
    required String text,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return News(
      newsId: id ?? '',
      adminId: 'admin',
      title: title,
      text: text,
      imageUrl: imageUrl,
      timestamp: createdAt ?? DateTime.now(),
    );
  }

  // Getters للتوافق مع الكود القديم
  String? get id => newsId.isEmpty ? null : newsId;
  DateTime get createdAt => timestamp;

  Map<String, dynamic> toMap() {
    return {
      'newsId': newsId,
      'adminId': adminId,
      'title': title,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory News.fromMap(Map<String, dynamic> map) {
    return News(
      newsId: map['newsId'] ?? '',
      adminId: map['adminId'] ?? 'admin',
      title: map['title'] ?? '',
      text: map['text'] ?? '',
      imageUrl: map['imageUrl'],
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] is Timestamp
              ? (map['timestamp'] as Timestamp).toDate()
              : DateTime.parse(map['timestamp'].toString()))
          : DateTime.now(),
    );
  }

  News copyWith({
    String? newsId,
    String? adminId,
    String? title,
    String? text,
    String? imageUrl,
    DateTime? timestamp,
  }) {
    return News(
      newsId: newsId ?? this.newsId,
      adminId: adminId ?? this.adminId,
      title: title ?? this.title,
      text: text ?? this.text,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}