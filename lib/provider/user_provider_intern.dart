import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/Users.dart';

class UserProviderIntern with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Users> _users = [];

  List<Users> get users => _users;

  UserProviderIntern() {
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      _users = querySnapshot.docs.map((doc) {
        return Users.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
      notifyListeners();
    }catch(e) {
      print("Error fetching users: $e");
    }
  }

  Future<void> loadUsersEmails() async {
    for(var user in _users) {
      String? email = await user.getEmail();
    }
  }
}