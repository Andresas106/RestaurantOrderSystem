import 'package:firebase_auth/firebase_auth.dart';

class Users {
  final String uid;
  final String role;

  Users({
    required this.uid,
    required this.role,
  });

  factory Users.fromFirestore(Map<String, dynamic> data) {
    return Users(
      uid: data['uid'],
      role: data['role'] ?? '',
    );
  }

  // Método que obtiene el email desde FirebaseAuth
  Future<String?> getEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.email;
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
    };
  }
}
