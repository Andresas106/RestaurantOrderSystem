import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg/model/Dishes.dart';

class DishProvider with ChangeNotifier {
  List<Dishes> _allDishes = [];

  List<Dishes> get allDishes => _allDishes;

  Future<void> loadDishes() async {
    final snapshot = await FirebaseFirestore.instance.collection('dishes').get();
    _allDishes = snapshot.docs.map((doc) => Dishes.fromMap(doc.data())).toList();
    notifyListeners();
  }
}
