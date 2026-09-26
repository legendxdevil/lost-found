import 'package:lost_and_found/features/auth/domain/entities/app_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDTO {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? fcmToken;
  final bool isAdmin;
  final DateTime createdAt;

  const UserDTO({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.fcmToken,
    required this.isAdmin,
    required this.createdAt,
  });

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is Timestamp) return date.toDate();
    if (date is String) {
      return DateTime.tryParse(date) ?? DateTime.now();
    }
    return DateTime.now();
  }

  factory UserDTO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserDTO(
      uid: data['uid']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString(),
      fcmToken: data['fcmToken']?.toString(),
      isAdmin: data['isAdmin'] == true,
      createdAt: _parseDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'fcmToken': fcmToken,
      'isAdmin': isAdmin,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppUser toDomain() {
    return AppUser(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      fcmToken: fcmToken,
      isAdmin: isAdmin,
      createdAt: createdAt,
    );
  }

  factory UserDTO.fromDomain(AppUser user) {
    return UserDTO(
      uid: user.uid,
      name: user.name,
      email: user.email,
      phone: user.phone,
      fcmToken: user.fcmToken,
      isAdmin: user.isAdmin,
      createdAt: user.createdAt,
    );
  }
}
