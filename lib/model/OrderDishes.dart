import 'package:tfg/model/Dishes.dart';



enum OrderDishState {
  pending,
  inPreparation,
  ready,
}

class OrderDishes {
  final Dishes dish;
  final int quantity;
  final OrderDishState state;
  final String? notes;



  OrderDishes({required this.dish, required this.quantity, required this.state, this.notes});

  Map<String, dynamic> toMap() {
    return {
      'dishId': dish.id,
      'quantity': quantity,
      'notes': notes,
      'state': state.name
    };
  }

  factory OrderDishes.fromMap(Map<String, dynamic> map, Dishes dish) {

    final stateString = map['state'] as String?;
    final state = stateString != null
        ? OrderDishState.values.byName(stateString)
        : OrderDishState.pending; // Valor por defecto en caso de null

    return OrderDishes(
        dish: dish,
        quantity: map['quantity'],
        notes: map['notes'],
        state: state
    );
  }
}
