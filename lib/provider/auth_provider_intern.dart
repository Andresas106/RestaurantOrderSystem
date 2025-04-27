import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/Users.dart';



class AuthProviderIntern with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  Users? _userCustom;

  User? get user => _user;
  Users? get userCustom => _userCustom;

  AuthProviderIntern() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (_user != null) {
        await _loadUserDetails(_user!.uid);
      }
      notifyListeners(); // Notificar a los widgets que escuchan
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> _loadUserDetails(String uid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users')
          .where('uid', isEqualTo: uid)  // Filtra los documentos que tengan el UID que buscas
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Si hay al menos un documento que coincide
        DocumentSnapshot doc = querySnapshot.docs.first;
        _userCustom = Users.fromFirestore(doc.data() as Map<String, dynamic>, uid);
      } else {
        print('No se encontró el usuario en Firestore');
      }
    } catch (e) {
      print('Error cargando datos del usuario: $e');
    }
  }
}
