import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg/model/Orders.dart';
import 'package:tfg/provider/orderKitchen_provider_intern.dart';
import 'package:tfg/provider/table_provider_intern.dart';

import '../../model/OrderDishes.dart';
import '../../provider/dish_provider_intern.dart';

class ChefHome extends StatefulWidget {
  final String uid;
  final String role;

  const ChefHome({super.key, required this.uid, required this.role});

  @override
  State<ChefHome> createState() => _ChefHomeState();
}

class _ChefHomeState extends State<ChefHome> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final dishProvider = Provider.of<DishProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderKitchenProvider>(context, listen: false);

    dishProvider.loadDishes().then((_) {
      orderProvider.listenToPendingOrders(dishProvider.allDishes);
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderKitchenProvider>(context);
    final orders = orderProvider.pendingOrders;
    final tableProvider = Provider.of<TableProviderIntern>(context);


    if (_isLoading || tableProvider.tables.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orders.isEmpty) {
      return const Center(child: Text('No hay pedidos pendientes'));
    }

    return Scaffold(
      body: ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final tableProvider = Provider.of<TableProviderIntern>(context, listen: false);
          final tableNumbers = tableProvider.getTableNumbersForGroup(order.groupId);
          final tableString = tableNumbers.join(', ');
          return Card(
            margin: const EdgeInsets.all(8),
            child: ExpansionTile(
              title: Text('Order Tables ${tableString}'),
              subtitle: Row(
                children: [
                  const Text('Order State'),
                  const SizedBox(width: 10,),
                  DropdownButton<OrderState>(
                    value: order.state,
                    onChanged: (newState) {
                      if(newState != null) Provider.of<OrderKitchenProvider>(context, listen: false)
                          .updateOrderState(order.id, newState);

                    },
                    items: OrderState.values.map((state) {
                      return DropdownMenuItem(
                        value: state,
                        child: Text(_formatOrderState(state)),
                      );
                    }).toList(),
                  )
                ],
              ),
              children: order.dishes.map((dish) {
                return ListTile(
                  title: Text('${dish.dish.name} x${dish.quantity}'),
                  subtitle: Text('Notas: ${dish.notes ?? "Ninguna"}'),
                  trailing: DropdownButton<OrderDishState>(
                    value: dish.state,
                    onChanged: (newState) {
                      if (newState != null) {
                        final orderProvider = Provider.of<OrderKitchenProvider>(context, listen: false);

                        orderProvider.updateDishState(
                          orderId: order.id,
                          dishId: dish.dish.id,
                          newState: newState,
                        );
                      }
                    },
                    items: OrderDishState.values.map((state) {
                      return DropdownMenuItem<OrderDishState>(
                        value: state,
                        child: Text(_formatState(state)),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  String _formatState(OrderDishState state) {
    switch (state) {
      case OrderDishState.pending:
        return 'Pending';
      case OrderDishState.inPreparation:
        return 'In preparation';
      case OrderDishState.ready:
        return 'Ready';
      default:
        return 'Unknown';
    }
  }

  String _formatOrderState(OrderState state) {
    switch (state) {
      case OrderState.pending:
        return 'Pending';
      case OrderState.inPreparation:
        return 'In preparation';
      case OrderState.ready:
        return 'Ready';
      case OrderState.completed:
        return 'Completed';
    }
  }
}
