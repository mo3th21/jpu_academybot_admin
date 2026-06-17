import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  final String adminId; // Admin_ID
  final String displayName;
  final String email;
  final Timestamp createdAt;
  final Timestamp? lastLoginAt;

  Admin({
    required this.adminId,
    required this.displayName,
    required this.email,
    required this.createdAt,
    this.lastLoginAt,
  });

  // fromMap (e.g., when using data from Firestore)
  factory Admin.fromMap(Map<String, dynamic> map, {String? id}) {
    return Admin(
      adminId: map['Admin_ID'] as String? ?? (id ?? ''),
      displayName: map['displayName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      lastLoginAt: map['lastLoginAt'] as Timestamp?,
    );
  }

  // from DocumentSnapshot
  factory Admin.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Admin.fromMap(data, id: doc.id);
  }

  // toMap for writing to Firestore
  Map<String, dynamic> toMap({bool useServerTimestampForCreated = false}) {
    return {
      'Admin_ID': adminId,
      'displayName': displayName,
      'email': email,
      'createdAt': useServerTimestampForCreated ? FieldValue.serverTimestamp() : createdAt,
      'lastLoginAt': lastLoginAt,
    };
  }
}