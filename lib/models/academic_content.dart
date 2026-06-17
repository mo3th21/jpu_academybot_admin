import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج المحتوى الأكاديمي
class AcademicContent {
  final String contractId; // document id
  final String adminId;
  final String downloadUrl;
  final String filename;
  final Timestamp uploadedAt;
  final String subject;
  final String major;
  final String? description;

  AcademicContent({
    required this.contractId,
    required this.adminId,
    required this.downloadUrl,
    required this.filename,
    required this.uploadedAt,
    required this.subject,
    required this.major,
    this.description,
  });

  factory AcademicContent.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AcademicContent(
      contractId: doc.id,
      adminId: data['adminId'] as String? ?? '',
      downloadUrl: data['downloadUrl'] as String? ?? '',
      filename: data['filename'] as String? ?? '',
      uploadedAt: data['uploadedAt'] as Timestamp? ?? Timestamp.now(),
      subject: data['subject'] as String? ?? '',
      major: data['major'] as String? ?? '',
      description: data['description'] as String?,
    );
  }

  Map<String, dynamic> toMap({bool useServerTimestamp = false}) {
    return {
      'adminId': adminId,
      'downloadUrl': downloadUrl,
      'filename': filename,
      'uploadedAt': useServerTimestamp ? FieldValue.serverTimestamp() : uploadedAt,
      'subject': subject,
      'major': major,
      'description': description,
    };
  }
}