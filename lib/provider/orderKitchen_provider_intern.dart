import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/Dishes.dart';
import '../model/OrderDishes.dart';
import '../model/Orders.dart';

class OrderKitchenProvider with ChangeNotifier {
  List<Orders> _pendingOrders = [];
  List<Orders> get pendingOrders => _pendingOrders;

  StreamSubscription? _ordersSubscription;

  void listenToPendingOrders(List<Dishes> allDishes) {
    _ordersSubscription?.cancel();

    _ordersSubscription = FirebaseFirestore.instance
        .collection('orders')
        .where('state', whereIn: ['pending', 'inPreparation', 'ready'])
        .orderBy('datetime', descending: false)
        .snapshots()
        .listen((snapshot) {
          final orders =
              snapshot.docs.map((doc) {
                return Orders.fromMap(doc.id, doc.data(), allDishes);
              }).toList();

          _pendingOrders = orders;
          notifyListeners();
        });
  }

  Future<void> updateOrderState(String orderId, OrderState newState) async {
    final orderRef = FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId);

    final snapshot = await orderRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data();
    if (data == null || !data.containsKey('dishes')) return;

    List<dynamic> updatedDishes = data['dishes'];
    final groupId = data['groupId'];

    // Si el pedido se marca como "listo", actualiza todos los platos también
    if (newState == OrderState.ready) {
      updatedDishes =
          updatedDishes.map((dishMap) {
            return {...dishMap, 'state': OrderDishState.ready.name};
          }).toList();
    }

    if (newState == OrderState.completed && groupId != null) {
      final tableQuery =
          await FirebaseFirestore.instance
              .collection('tables')
              .where('group_id', isEqualTo: groupId)
              .get();

      for (final doc in tableQuery.docs) {
        await doc.reference.update({'group_id': null});
      }
    }

    await orderRef.update({'state': newState.name, 'dishes': updatedDishes});

    notifyListeners();
  }

  Future<void> updateDishState({required String orderId, required int dishId, required OrderDishState newState,}) async {
      final orderRef = FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId);

      final snapshot = await orderRef.get();
      if (!snapshot.exists) return;

      final data = snapshot.data();
      if (data == null || !data.containsKey('dishes')) return;

      final List<dynamic> updatedDishes =
          (data['dishes'] as List<dynamic>).map((dishMap) {
            if (dishMap['dishId'] == dishId) {
              return {...dishMap, 'state': newState.name};
            }
            return dishMap;
          }).toList();

      await orderRef.update({'dishes': updatedDishes});

      // Opcional: recargar pedidos para reflejar cambios
      // Puedes hacerlo si quieres que se vea instantáneamente
      notifyListeners();
    }

    Future<void> markOrderWarned80(String orderId) async {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'warned80': true});

      // Actualizar en memoria si el pedido ya está cargado
      final index = _pendingOrders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _pendingOrders[index].warned80 = true;
        notifyListeners();
      }
  }

  Future<void> markOrderWarnedLate(String orderId) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'warnedLate': true});

    // Actualizar en memoria si el pedido ya está cargado
    final index = _pendingOrders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _pendingOrders[index].warnedLate = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
