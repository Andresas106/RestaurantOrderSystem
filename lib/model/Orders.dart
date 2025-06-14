import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tfg/model/OrderDishes.dart';

import 'Dishes.dart';


enum OrderState {
  pending,
  inPreparation,
  ready,
  completed
}

class Orders {
  final String id;
  final String groupId;
  final String waiterId;
  final DateTime datetime;
  final OrderState state;
  final List<OrderDishes> dishes;

  bool warned80;
  bool warnedLate;

  Orders({
    required this.id,
    required this.groupId,
    required this.waiterId,
    required this.datetime,
    required this.state,
    required this.dishes,
    this.warned80 = false,
    this.warnedLate = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'waiterId': waiterId,
      'datetime': Timestamp.fromDate(datetime),
      'state': state.name,
      'dishes': dishes.map((d) => d.toMap()).toList(),
      'warned80': warned80,
      'warnedLate': warnedLate,
    };
  }

  factory Orders.fromMap(String id, Map<String, dynamic> map, List<Dishes> allDishes) {
    List<OrderDishes> dishList = [];

    for (var dishMap in List<Map<String, dynamic>>.from(map['dishes'])) {
      final matchedDish = allDishes.firstWhere((d) => d.id == dishMap['dishId'], orElse: () => throw Exception('Dish not found'));
      dishList.add(OrderDishes.fromMap(dishMap, matchedDish));
    }

    return Orders(
      id: id,
      groupId: map['groupId'],
      waiterId: map['waiterId'],
      datetime: (map['datetime'] as Timestamp).toDate(),
        state: _orderStateFromString(map['state']),
      dishes: dishList,
      warned80: map['warned80'] ?? false,
      warnedLate: map['warnedLate'] ?? false,
    );
  }

  static OrderState _orderStateFromString(String stateString) {
    return OrderState.values.firstWhere(
          (e) => e.name == stateString,
      orElse: () => OrderState.pending,
    );
  }
}
