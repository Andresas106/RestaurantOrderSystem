import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:tfg/model/Categories.dart';
import 'package:tfg/model/Dishes.dart';

class MenuProvider with ChangeNotifier {
  final List<Dishes> _dishes = [];
  final List<Categories> _categories = [];

  List<Dishes> get dishes => _dishes;
  List<Categories> get categories => _categories;

  MenuProvider() {
    _fetchCategories();
    _fetchDishes();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _fetchCategories() {
    FirebaseFirestore.instance.collection('categories').snapshots().listen((
      snapshot,
    ) {
      _categories.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('id')) {
          _categories.add(Categories.fromMap(data));
        }
      }
      notifyListeners();
    });
  }

  void _fetchDishes() {
    FirebaseFirestore.instance.collection('dishes').snapshots().listen((snapshot) {
      _dishes.clear();
      for(var doc in snapshot.docs) {
        final data = doc.data();
        if(data.containsKey('id')) {
          _dishes.add(Dishes.fromMap(data));
        }
      }
      notifyListeners();
    });
  }

  List<Dishes> getDishesByCategory(int categoryId) {
    return _dishes.where((dish) => dish.categoryId == categoryId).toList();
  }
}
