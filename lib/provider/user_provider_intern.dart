import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      QuerySnapshot chefSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'chef')
          .get();

      // Consulta para obtener los usuarios con rol 'waiter'
      QuerySnapshot waiterSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'waiter')
          .get();

      // Unir los resultados de ambas consultas
      List<QueryDocumentSnapshot> combinedDocs = []
        ..addAll(chefSnapshot.docs)
        ..addAll(waiterSnapshot.docs);


      _users = combinedDocs.map((doc) {
        return Users.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();
      notifyListeners();
    }catch(e) {
      print("Error fetching users: $e");
    }
  }

  // Método para eliminar un usuario de Firestore
  Future<void> deleteUser(String uid) async {
    try {
      // Buscar el documento del usuario por su UID
      QuerySnapshot userDocSnapshot = await _firestore
          .collection('users')
          .where('uid', isEqualTo: uid)
          .get();

      if (userDocSnapshot.docs.isEmpty) {
        throw Exception('User not found');
      }

      // Eliminar el usuario de Firestore
      await _firestore
          .collection('users')
          .doc(userDocSnapshot.docs.first.id)
          .delete();

      // Actualizar la lista de usuarios en la app
      _users.removeWhere((user) => user.uid == uid);
      notifyListeners();  // Notificar a la UI para que se actualice

      print('User deleted successfully');
    } catch (e) {
      print("Error deleting user: $e");
      throw Exception("Error deleting user: $e");
    }
  }

  // Método para crear un nuevo usuario
  Future<void> createUser(String email, String password, String role) async {
    try {
      // Crear el usuario en Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Crear el objeto de usuario para Firestore
      Users newUser = Users(
        uid: userCredential.user!.uid, // Asignar el UID generado
        role: role,
        email: email,
      );

      // Guardar el nuevo usuario en Firestore
      await _firestore.collection('users').add(newUser.toMap());

      // Recargar los usuarios para reflejar el nuevo
      await _fetchUsers();
      notifyListeners();
    } catch (e) {
      print("Error creating user: $e");
      throw e; // Propagar el error para manejarlo en la UI
    }
  }
}