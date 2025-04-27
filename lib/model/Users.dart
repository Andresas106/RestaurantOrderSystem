class Users {
  final String uid;
  final String role;

  Users({
    required this.uid,
    required this.role,
  });

  factory Users.fromFirestore(Map<String, dynamic> data, String uid) {
    return Users(
      uid: uid,
      role: data['role'] ?? '',
    );
  }
}
