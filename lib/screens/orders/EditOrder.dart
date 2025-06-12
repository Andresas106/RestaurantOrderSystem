import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg/provider/table_provider_intern.dart';

import '../../provider/menu_provider_intern.dart';
import '../../provider/order_provider_intern.dart';

class EditOrder extends StatefulWidget {
  final String groupId;
  final String uid;

  const EditOrder({super.key, required this.groupId, required this.uid});

  @override
  State<EditOrder> createState() => _EditOrderState();
}

class _EditOrderState extends State<EditOrder> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrderData();
    _loadLock();
  }

  Future<void> _loadLock() async {
    final tableProvider = Provider.of<TableProviderIntern>(context, listen: false);

    // Primero, carga las mesas relacionadas con este pedido (groupId)
    await tableProvider.selectTablesOrderByGroupId(widget.groupId);

    for (var table in tableProvider.selectedTables) {
      // Aquí podrías implementar un método que devuelva si el lock fue exitoso
      await tableProvider.lockTable(table.id, widget.uid);
      // En un sistema real deberías comprobar si ya está bloqueado por otro, y si no pudo bloquear => allLocked = false;
    }
  }

  Future<void> _loadOrderData() async {
    final orderProvider = Provider.of<OrderProviderIntern>(context, listen: false);
    await orderProvider.loadOrder(widget.groupId);
    setState(() {
      isLoading = false;
    });
  }

  void _showOrderSummary(BuildContext context) {
    final orderProvider = Provider.of<OrderProviderIntern>(context, listen: false);
    final tableProvider = Provider.of<TableProviderIntern>(context, listen: false);
    final orderItems = orderProvider.items;



    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  if (orderItems.isEmpty)
                    const Text('There are no dishes in the order', style: TextStyle(color: Colors.white70))
                  else
                    ...orderItems.entries.map((entry) {
                      final dish = entry.key;
                      final quantity = entry.value;
                      return ListTile(
                        title: Text(dish.name, style: const TextStyle(color: Colors.white)),
                        subtitle: Text('${dish.price.toStringAsFixed(2)} € x $quantity',
                            style: const TextStyle(color: Colors.white70)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                              onPressed: () {
                                orderProvider.removeDish(dish);
                                Navigator.pop(context);
                                _showOrderSummary(context);
                              },
                            ),
                            Text('$quantity', style: const TextStyle(color: Colors.white)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.greenAccent),
                              onPressed: () {
                                orderProvider.addDish(dish);
                                Navigator.pop(context);
                                _showOrderSummary(context);
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  const Divider(color: Colors.white38),
                  if (orderItems.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 16, color: Colors.white)),
                        Text(
                          '${orderProvider.getTotalPrice.toStringAsFixed(2)} €',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  if (orderItems.isNotEmpty)
                    ElevatedButton(
                      onPressed: () async {
                        await orderProvider.updateOrder(widget.groupId);
                        for(var table in tableProvider.selectedTables) {
                          tableProvider.unlockTables(table.id);
                        }
                        Navigator.pop(context); // Cierra bottom sheet
                        Navigator.pop(context); // Cierra pantalla EditOrder
                      },
                      child: const Text('Update Order'),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProviderIntern>(context);
    final menuProvider = Provider.of<MenuProviderIntern>(context);
    final tableProvider = Provider.of<TableProviderIntern>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Order ${widget.groupId}', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            for(var table in tableProvider.selectedTables) {
              tableProvider.unlockTables(table.id);
            }

            Navigator.of(context).pop();
          }

        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading || menuProvider.isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : ListView.builder(
          itemCount: menuProvider.categories.length,
          itemBuilder: (context, index) {
            final category = menuProvider.categories[index];
            final dishes = menuProvider.getDishesByCategory(category.id);

            return ExpansionTile(
              collapsedIconColor: Colors.white,
              iconColor: Colors.white,
              title: Text(
                category.name[0].toUpperCase() + category.name.substring(1),
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              children: dishes.map((dish) {
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      dish.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(dish.name, style: const TextStyle(color: Colors.white)),
                  subtitle: Text('${dish.price.toStringAsFixed(2)} €',
                      style: TextStyle(color: Colors.grey.shade300)),
                  trailing: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      orderProvider.addDish(dish);
                    },
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
      floatingActionButton: Consumer<OrderProviderIntern>(
        builder: (context, orderProvider, _) {
          final totalItems = orderProvider.items.values.fold<int>(0, (sum, item) => sum + item);

          return FloatingActionButton.extended(
            onPressed: () => _showOrderSummary(context),
            backgroundColor: Colors.blue.shade800,
            label: Row(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.white),
                const SizedBox(width: 8),
                const Text('View Order', style: TextStyle(color: Colors.white)),
                if (totalItems > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$totalItems',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
