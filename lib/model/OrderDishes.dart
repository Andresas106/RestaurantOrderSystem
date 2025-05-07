import 'package:tfg/model/Dishes.dart';

class OrderDishes {
  final Dishes dish;
  final int quantity;
  final String? notes;

  OrderDishes({required this.dish, required this.quantity, this.notes});

  Map<String, dynamic> toMap() {
    return {
      'dishId': dish.id,
      'quantity': quantity,
      'notes': notes,
    };
  }

  factory OrderDishes.fromMap(Map<String, dynamic> map, Dishes dish) {
    return OrderDishes(
        dish: dish,
        quantity: map['quantity'],
        notes: map['notes']);
  }
}
