import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../model/Tables.dart';

class TableProviderIntern with ChangeNotifier {
  final List<Tables> _tables = [];
  bool _isLoading = false;

  List<Tables> get tables => _tables;
  bool get isLoading => _isLoading;

  /// Escucha los cambios en tiempo real
  void listenToTables() {
    FirebaseFirestore.instance
        .collection('tables')
        .orderBy('table_number')
        .snapshots()
        .listen((snapshot) {
      _tables.clear();
      for (var doc in snapshot.docs) {
        _tables.add(Tables.fromMap(doc.id, doc.data()));
      }
      notifyListeners();
    });
  }

  /// Crea una nueva mesa con número secuencial
  Future<void> addTable() async {
    _isLoading = true;
    notifyListeners();

    final snapshot = await FirebaseFirestore.instance
        .collection('tables')
        .orderBy('table_number', descending: true)
        .limit(1)
        .get();

    int newNumber = 1;
    if (snapshot.docs.isNotEmpty) {
      newNumber = snapshot.docs.first['table_number'] + 1;
    }

    await FirebaseFirestore.instance.collection('tables').add({
      'table_number': newNumber,
      'group_id': null,
    });

    _isLoading = false;
    notifyListeners();
  }

  /// Elimina la última mesa (la de número más alto)
  Future<void> deleteLastTable() async {
    _isLoading = true;
    notifyListeners();

    final snapshot = await FirebaseFirestore.instance
        .collection('tables')
        .orderBy('table_number', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('tables')
          .doc(snapshot.docs.first.id)
          .delete();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateTablesWithGroupId(String groupId, List<String> selectedTables) async {
    _isLoading = true;
    notifyListeners();

    final firebase = FirebaseFirestore.instance;
    final batch = firebase.batch();

    for (var tableId in selectedTables) {
      final docRef = firebase.collection('tables').doc(tableId);
      batch.update(docRef, {
        'group_id': groupId,
      });
    }

    await batch.commit();
    _isLoading = false;
    notifyListeners();
  }
}