class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? fcmToken;
  final bool isAdmin;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.fcmToken,
    required this.isAdmin,
    required this.createdAt,
  });
}
