import 'package:firebase_auth/firebase_auth.dart';

class Users {
  final String uid;
  final String role;
  final String? email; // Email opcional

  Users({
    required this.uid,
    required this.role,
    this.email
  });

  factory Users.fromFirestore(Map<String, dynamic> data) {
    return Users(
      uid: data['uid'],
      role: data['role'] ?? '',
      email: data['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
      if(email != null) 'email': email,
    };
  }
}
