import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../model/Tables.dart';

class TableProviderIntern with ChangeNotifier {
  List<Tables> _tables = [];
  bool _isLoading = false;
  List<Tables> _selectedTables = [];
  Map<String, String> _groupOrderStatuses = {};

  List<Tables> get tables => _tables;
  bool get isLoading => _isLoading;
  List<Tables> get selectedTables => _selectedTables;
  Map<String, String> get groupOrderStatuses => _groupOrderStatuses;

  /// Escucha los cambios en tiempo real
  void listenToTables() {
    FirebaseFirestore.instance
        .collection('tables')
        .orderBy('table_number')
        .snapshots()
        .listen((snapshot) async {
      final updatedTables = <Tables>[];
      final updatedStatuses = <String, String>{};
      final futures = <Future<void>>[];

      for (var doc in snapshot.docs) {
        final table = Tables.fromMap(doc.id, doc.data());
        updatedTables.add(table);

        if (table.groupId != null) {
          // Añadimos la petición a la lista de futures
          futures.add(FirebaseFirestore.instance
              .collection('orders')
              .where('groupId', isEqualTo: table.groupId)
              .limit(1)
              .get()
              .then((querySnapshot) {
            if (querySnapshot.docs.isNotEmpty) {
              final status = querySnapshot.docs.first.data()['state'] as String?;
              if (status != null) {
                updatedStatuses[table.groupId!] = status;
              }
            }
          }));
        }
      }

      // Esperamos a que todas las peticiones paralelas terminen
      await Future.wait(futures);

      _tables = updatedTables;
      _groupOrderStatuses = updatedStatuses;
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
      'locked_by': null
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

  Future<void> updateTablesWithGroupId(String groupId, List<Tables> selectedTables) async {
    _isLoading = true;
    notifyListeners();

    final firebase = FirebaseFirestore.instance;
    final batch = firebase.batch();

    for (var table in selectedTables) {
      final docRef = firebase.collection('tables').doc(table.id);
      batch.update(docRef, {
        'group_id': groupId,
      });
    }

    await batch.commit();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectTablesOrder(List<String> selectedTables) async {
    _isLoading = true;
    notifyListeners();

    final firebase = FirebaseFirestore.instance;

    // Consulta todas las mesas con IDs en selectedTables
    final tablesQuery = await firebase
        .collection('tables')
        .where(FieldPath.documentId, whereIn: selectedTables)
        .get();

    _selectedTables = tablesQuery.docs.map((doc) {
        return Tables.fromMap(doc.id, doc.data());
    }).toList();

    _isLoading = false;
    notifyListeners();

  }

  Future<void> lockTable(String tableId, String uid) async {
    await FirebaseFirestore.instance.collection('tables').doc(tableId).update({
      'locked_by': uid,
    });
  }

  Future<void> unlockTables(String tableId) async {
    await FirebaseFirestore.instance.collection('tables').doc(tableId).update({
      'locked_by': null,
    });
  }

  Future<void> selectTablesOrderByGroupId(String groupId) async {
    final firebase = FirebaseFirestore.instance;

    final tablesQuery = await firebase
        .collection('tables')
        .where('group_id', isEqualTo: groupId)
        .get();

    _selectedTables = tablesQuery.docs.map((doc) {
      return Tables.fromMap(doc.id, doc.data());
    }).toList();
  }

  List<int> getTableNumbersForGroup(String groupId) {
    return _tables
        .where((table) => table.groupId == groupId)
        .map((table) => table.tableNumber)
        .toList();
  }
}