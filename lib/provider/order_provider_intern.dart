import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:tfg/model/Dishes.dart';
import 'package:tfg/model/OrderDishes.dart';

import '../model/Orders.dart';

class OrderProviderIntern with ChangeNotifier {
  final Map<Dishes, int> _items = {};

  Map<Dishes, int> get items => _items;

  void addDish(Dishes dish) {
    if (_items.containsKey(dish)) {
      _items[dish] = _items[dish]! + 1;
    } else {
      _items[dish] = 1;
    }
    notifyListeners();
  }

  void removeDish(Dishes dish) {
    if (_items.containsKey(dish)) {
      if (_items[dish]! > 1) {
        _items[dish] = _items[dish]! - 1;
      } else {
        _items.remove(dish);
      }
      notifyListeners();
    }
  }

  Future<void> createOrder(String groupId, String waiterId) async {
      if(_items.isEmpty) return;

      final now = DateTime.now();

      final List<OrderDishes> orderDishes = _items.entries.map((e) =>
          OrderDishes(
            dish: e.key,
            quantity: e.value,
            state: OrderDishState.pending,
          )
      ).toList();

      final newOrder = new Orders(
          id: '',
          groupId: groupId,
          waiterId: waiterId,
          datetime: now,
          state: OrderState.pending,
          sendToKitchen: false,
          sendToKitchenIn: null,
          servedIn: null,
          dishes: orderDishes);

      await FirebaseFirestore.instance.collection('orders').add(newOrder.toMap());

      clearOrder();
  }

  Future<void> updateOrder(String groupId) async {
    if(_items.isEmpty) return;

    final query = await FirebaseFirestore.instance
    .collection('orders')
    .where('groupId', isEqualTo: groupId)
    .limit(1)
    .get();

    if(query.docs.isEmpty) return;

    final docId = query.docs.first.id;

    final List<Map<String, dynamic>> updatedDishes = _items.entries.map((entry) {
      return {
        'dishId': entry.key.id,
        'quantity': entry.value
      };
    }).toList();

    await FirebaseFirestore.instance
    .collection('orders')
    .doc(docId)
    .update({
      'dishes': updatedDishes,
      'updatedAt': DateTime.now()
    });

    notifyListeners();
  }

  Future<void> loadOrder(String groupId) async {
    _items.clear();

    final query = await FirebaseFirestore.instance
    .collection('orders')
    .where('groupId', isEqualTo: groupId)
    .limit(1)
    .get();

    if(query.docs.isEmpty) return;

    final orderData = query.docs.first.data();
    final List<dynamic> dishesList = orderData['dishes'];

    for(var dishEntry in dishesList) {
      final int dishId = dishEntry['dishId'];
      final int quantity = dishEntry['quantity'];

      final dishSnapshot = await FirebaseFirestore.instance
      .collection('dishes')
      .where('id', isEqualTo: dishId)
      .limit(1)
      .get();

      if(dishSnapshot.docs.isNotEmpty) {
        final dish = Dishes.fromMap(dishSnapshot.docs.first.data());
        _items[dish] = quantity;
      }
    }

    notifyListeners();
  }

  void clearOrder() {
    _items.clear();
    notifyListeners();
  }

  double get getTotalPrice => _items.entries
      .map((e) => e.key.price * e.value)
      .fold(0, (prev, curr) => prev + curr);
}
