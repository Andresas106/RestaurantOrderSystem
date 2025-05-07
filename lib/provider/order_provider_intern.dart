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

      final List<OrderDishes> orderDishes = _items.entries.map((e) => OrderDishes(dish: e.key, quantity: e.value)).toList();

      final newOrder = new Orders(
          id: '',
          groupId: groupId,
          waiterId: waiterId,
          datetime: now,
          state: 'pending',
          sendToKitchen: false,
          sendToKitchenIn: null,
          servedIn: null,
          dishes: orderDishes);

      await FirebaseFirestore.instance.collection('orders').add(newOrder.toMap());

      clearOrder();
  }

  void clearOrder() {
    _items.clear();
    notifyListeners();
  }

  double get getTotalPrice => _items.entries
      .map((e) => e.key.price * e.value)
      .fold(0, (prev, curr) => prev + curr);
}
