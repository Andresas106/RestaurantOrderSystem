import 'package:flutter/cupertino.dart';
import 'package:tfg/model/Dishes.dart';

class OrderProvider with ChangeNotifier {
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

  void clearOrder() {
    _items.clear();
    notifyListeners();
  }

  double get getTotalPrice => _items.entries
      .map((e) => e.key.price * e.value)
      .fold(0, (prev, curr) => prev + curr);
}
