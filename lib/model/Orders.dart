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
  final bool sendToKitchen;
  final DateTime? sendToKitchenIn;
  final DateTime? servedIn;
  final List<OrderDishes> dishes;

  Orders({
    required this.id,
    required this.groupId,
    required this.waiterId,
    required this.datetime,
    required this.state,
    required this.sendToKitchen,
    this.sendToKitchenIn,
    this.servedIn,
    required this.dishes,
  });

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'waiterId': waiterId,
      'datetime': Timestamp.fromDate(datetime),
      'state': state.name,
      'sendToKitchen': sendToKitchen,
      'sendToKitchenIn': sendToKitchenIn != null ? Timestamp.fromDate(sendToKitchenIn!) : null,
      'servedIn': servedIn != null ? Timestamp.fromDate(servedIn!) : null,
      'dishes': dishes.map((d) => d.toMap()).toList(),
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
      sendToKitchen: map['sendToKitchen'],
      sendToKitchenIn: map['sendToKitchenIn'] != null ? (map['sendToKitchenIn'] as Timestamp).toDate() : null,
      servedIn: map['servedIn'] != null ? (map['servedIn'] as Timestamp).toDate() : null,
      dishes: dishList,
    );
  }

  static OrderState _orderStateFromString(String stateString) {
    return OrderState.values.firstWhere(
          (e) => e.name == stateString,
      orElse: () => OrderState.pending,
    );
  }
}
