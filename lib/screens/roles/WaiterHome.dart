import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg/model/Orders.dart';

import '../../navigation/AppRouterDelegate.dart';
import '../../provider/dish_provider_intern.dart';
import '../../provider/orderKitchen_provider_intern.dart';
import '../../provider/table_provider_intern.dart';
import '../../services/PredictionService.dart';

class WaiterHome extends StatefulWidget {
  final String uid;
  final String role;

  const WaiterHome({super.key, required this.uid, required this.role});

  @override
  _WaiterHomeState createState() => _WaiterHomeState();
}

class _WaiterHomeState extends State<WaiterHome> {
  // Estado para las mesas seleccionadas
  List<String> selectedTables = [];
  Map<String, int> _estimatedTimes = {};
  late Timer _delayedCheckTimer;
  final _delayedOrders = <String>{};

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
          });
        }

        _delayedCheckTimer = Timer.periodic(Duration(seconds: 5), (_) {
          final orders = orderProvider.pendingOrders;
          for (final order in orders) {
            checkOrderDelays(context, order, _estimatedTimes);
          }
        });
      });
    });
  }

  void checkOrderDelays(
    BuildContext context,
    Orders order,
    Map<String, int> aiEstimatedTimes,
  ) {
    final now = DateTime.now();
    // No hacemos nada si el pedido no está en preparación o no tenemos un tiempo estimado
    if (!aiEstimatedTimes.containsKey(order.id)) return;
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
      Provider.of<OrderKitchenProvider>(
        context,
        listen: false,
      ).markOrderWarnedLate(order.id);
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
      Provider.of<OrderKitchenProvider>(
        context,
        listen: false,
      ).markOrderWarned80(order.id);
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
  void dispose() {
    _delayedCheckTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tableProvider = Provider.of<TableProviderIntern>(context);
    final tables = tableProvider.tables;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // Grid de mesas
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    itemCount: tables.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemBuilder: (context, index) {
                      final table = tables[index];
                      final isSelected = selectedTables.contains(table.id);

                      final orderStatus =
                          table.groupId != null
                              ? tableProvider.groupOrderStatuses[table.groupId!]
                              : null;

                      Color backgroundColor;

                      if (orderStatus == null) {
                        backgroundColor = Colors.green[400]!;
                      } else {
                        switch (orderStatus) {
                          case 'pending':
                            backgroundColor = Colors.orange[400]!;
                            break;
                          case 'inPreparation':
                            backgroundColor = Colors.yellow[600]!;
                            break;
                          case 'ready':
                            backgroundColor = Colors.blue[400]!;
                            break;
                          case 'completed':
                            backgroundColor = Colors.grey[600]!;
                            break;
                          default:
                            backgroundColor = Colors.orange[400]!;
                        }
                      }

                      return GestureDetector(
                        onTap: () {
                          if (table.lockedBy != null &&
                              table.lockedBy != widget.uid) {
                            showDialog(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    title: const Text('Table in use'),
                                    content: const Text(
                                      'Another waiter is managing this table.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                            );
                          } else if (table.groupId != null) {
                            setState(() {
                              selectedTables.clear();
                            });
                            final routerDelegate =
                                Router.of(context).routerDelegate
                                    as AppRouterDelegate;
                            routerDelegate.setNewRoutePath(
                              RouteSettings(
                                name: '/edit-order',
                                arguments: {
                                  'group_id': table.groupId,
                                  'uid': widget.uid,
                                  'role': widget.role,
                                },
                              ),
                            );
                          } else {
                            // Si la mesa ya está seleccionada, la desmarco
                            if (isSelected) {
                              // Desmarcar mesa y desbloquear
                              selectedTables.remove(table.id);
                              tableProvider.unlockTables(table.id);
                            } else {
                              // Marcar mesa y bloquear
                              selectedTables.add(table.id);
                              tableProvider.lockTable(table.id, widget.uid);
                            }
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.white24,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Table ${table.tableNumber}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botón de Crear Pedido
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton.icon(
                  onPressed:
                      selectedTables.isEmpty
                          ? null
                          : () async {
                            // Crear pedido aquí
                            // Por ejemplo, generar un nuevo groupId y actualizar las mesas seleccionadas
                            String newGroupId = generateGroupId();

                            final routerDelegate =
                                Router.of(context).routerDelegate
                                    as AppRouterDelegate;
                            routerDelegate.setNewRoutePath(
                              RouteSettings(
                                name: '/new-order',
                                arguments: {
                                  'group_id': newGroupId,
                                  'uid': widget.uid,
                                  'role': widget.role,
                                  'tables': selectedTables,
                                },
                              ),
                            );

                            // Agregar un pequeño retraso antes de limpiar el estado
                            await Future.delayed(
                              const Duration(milliseconds: 100),
                            );

                            setState(() {
                              selectedTables.clear();
                            });
                          },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text('Create Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 50,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para generar un groupId único (ejemplo simple)
  String generateGroupId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
