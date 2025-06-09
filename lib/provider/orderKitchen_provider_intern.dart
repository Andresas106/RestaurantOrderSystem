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
        .where('state', isEqualTo: 'pending')
        .orderBy('datetime', descending: false)
        .snapshots()
        .listen((snapshot) {
      final orders = snapshot.docs.map((doc) {
        return Orders.fromMap(doc.id, doc.data(), allDishes);
      }).toList();



      _pendingOrders = orders;
      notifyListeners();
    });
  }

  Future<void> updateDishState({
    required String orderId,
    required int dishId,
    required OrderDishState newState,
  }) async {
    final orderRef = FirebaseFirestore.instance.collection('orders').doc(orderId);

    final snapshot = await orderRef.get();
    if (!snapshot.exists) return;

    final data = snapshot.data();
    if (data == null || !data.containsKey('dishes')) return;

    final List<dynamic> updatedDishes = (data['dishes'] as List<dynamic>).map((dishMap) {
      if (dishMap['dishId'] == dishId) {
        return {
          ...dishMap,
          'state': newState.name,
        };
      }
      return dishMap;
    }).toList();

    await orderRef.update({
      'dishes': updatedDishes,
    });

    // Opcional: recargar pedidos para reflejar cambios
    // Puedes hacerlo si quieres que se vea instantáneamente
    notifyListeners();
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}
