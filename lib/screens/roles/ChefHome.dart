import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg/model/Orders.dart';
import 'package:tfg/provider/orderKitchen_provider_intern.dart';
import 'package:tfg/provider/table_provider_intern.dart';

import '../../model/OrderDishes.dart';
import '../../provider/dish_provider_intern.dart';
import '../../services/PredictionService.dart';

class ChefHome extends StatefulWidget {
  final String uid;
  final String role;

  const ChefHome({super.key, required this.uid, required this.role});

  @override
  State<ChefHome> createState() => _ChefHomeState();
}

class _ChefHomeState extends State<ChefHome> {
  bool _isLoading = true;
  Map<String, int> _estimatedTimes = {};
  Timer? _delayCheckTimer;

  @override
  void initState() {
    super.initState();

    final dishProvider = Provider.of<DishProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderKitchenProvider>(
      context,
      listen: false,
    );
    final predictionService = PredictionService();

    dishProvider.loadDishes().then((_) async {
      await predictionService.init();
      orderProvider.listenToPendingOrders(dishProvider.allDishes);

      // Escuchar cambios en pendingOrders para recalcular tiempos
      orderProvider.addListener(() async {
        final orders = orderProvider.pendingOrders;
        final times = <String, int>{};
        for (var order in orders) {
          final predictedTime = await predictionService.predictPreparationTime(
            order,
          );
          times[order.id] = predictedTime;
        }
        if (mounted) {
          setState(() {
            _estimatedTimes = times;
            _isLoading = false;
          });
        }

        _delayCheckTimer = Timer.periodic(Duration(seconds: 5), (_) {
          final orders = orderProvider.pendingOrders;
          for (final order in orders) {
            checkOrderDelays(context, order, _estimatedTimes);
          }
        });
      });
    });


  }

  void checkOrderDelays(BuildContext context, Orders order, Map<String, int> aiEstimatedTimes,) {
    final now = DateTime.now();
    // No hacemos nada si el pedido no está en preparación o no tenemos un tiempo estimado
    if (!aiEstimatedTimes.containsKey(order.id))
      return;
    final estimatedMinutes = aiEstimatedTimes[order.id]!;
    final estimatedDuration = Duration(minutes: estimatedMinutes);
    final elapsed = now.difference(order.datetime);
    final elapsedPercent = elapsed.inSeconds / estimatedDuration.inSeconds;

    final tableNumbers = Provider.of<TableProviderIntern>(
      context,
      listen: false,
    ).getTableNumbersForGroup(order.groupId);
    final tableString = tableNumbers.join(', ');
    if (elapsedPercent > 1.0 && !order.warnedLate) {
      order.warnedLate = true;
      Provider.of<OrderKitchenProvider>(context, listen: false)
          .markOrderWarnedLate(order.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'The order in the tables $tableString has been delayed',
          ),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 4),
        ),
      );
    } else if (elapsedPercent > 0.8 && !order.warned80) {
      order.warned80 = true;
      Provider.of<OrderKitchenProvider>(context, listen: false)
          .markOrderWarned80(order.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "⏳ An order in the tables $tableString is about to be delayed",
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
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
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: Text(
              'No pending orders',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final tableNumbers = tableProvider.getTableNumbersForGroup(
              order.groupId,
            );
            final tableString = tableNumbers.join(', ');

            Color getOrderStateColor(OrderState state) {
              switch (state) {
                case OrderState.pending:
                  return Colors.orange.shade400;
                case OrderState.inPreparation:
                  return Colors.yellow.shade700;
                case OrderState.ready:
                  return Colors.blue.shade400;
                case OrderState.completed:
                  return Colors.grey.shade600;
              }
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: Colors.grey.shade900.withOpacity(0.8),
              elevation: 6,
              shadowColor: Colors.black87,
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  'Order Tables: $tableString',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Order State:',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: getOrderStateColor(order.state),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButton<OrderState>(
                            dropdownColor: Colors.grey.shade800,
                            isDense: true,
                            value: order.state,
                            underline: const SizedBox(),
                            iconEnabledColor: Colors.white,
                            style: const TextStyle(color: Colors.white),
                            onChanged: (newState) {
                              if (newState != null) {
                                Provider.of<OrderKitchenProvider>(
                                  context,
                                  listen: false,
                                ).updateOrderState(order.id, newState);
                              }
                            },
                            items:
                                OrderState.values.map((state) {
                                  return DropdownMenuItem(
                                    value: state,
                                    child: Text(_formatOrderState(state)),
                                  );
                                }).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Estimated time: ${_estimatedTimes[order.id] ?? '...'} min',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                children:
                    order.dishes.map((dish) {
                      Color getDishStateColor(OrderDishState state) {
                        switch (state) {
                          case OrderDishState.pending:
                            return Colors.orange.shade400;
                          case OrderDishState.inPreparation:
                            return Colors.yellow.shade700;
                          case OrderDishState.ready:
                            return Colors.blue.shade400;
                          default:
                            return Colors.grey;
                        }
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(2, 3),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(
                            '${dish.dish.name} x${dish.quantity}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: getDishStateColor(dish.state),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButton<OrderDishState>(
                              dropdownColor: Colors.grey.shade800,
                              isDense: true,
                              value: dish.state,
                              underline: const SizedBox(),
                              iconEnabledColor: Colors.white,
                              style: const TextStyle(color: Colors.white),
                              onChanged: (newState) {
                                if (newState != null) {
                                  final orderProvider =
                                      Provider.of<OrderKitchenProvider>(
                                        context,
                                        listen: false,
                                      );
                                  orderProvider.updateDishState(
                                    orderId: order.id,
                                    dishId: dish.dish.id,
                                    newState: newState,
                                  );
                                }
                              },
                              items:
                                  OrderDishState.values.map((state) {
                                    return DropdownMenuItem<OrderDishState>(
                                      value: state,
                                      child: Text(_formatState(state)),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            );
          },
        ),
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
