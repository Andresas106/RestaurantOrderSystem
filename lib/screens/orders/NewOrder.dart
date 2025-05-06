import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg/model/Tables.dart';
import 'package:tfg/provider/table_provider_intern.dart';

import '../../provider/menu_provider_intern.dart';
import '../../provider/order_provider_intern.dart';

class NewOrder extends StatefulWidget {
  final String groupId;
  final List<String> tables;

  const NewOrder({super.key, required this.groupId, required this.tables});

  @override
  State<NewOrder> createState() => _NewOrderState();



}

class _NewOrderState extends State<NewOrder> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeOrder();
    });
  }

  Future<void> _initializeOrder() async {
      final tablesProvider = Provider.of<TableProviderIntern>(context, listen: false);
      await tablesProvider.selectTablesOrder(widget.tables);
  }

  @override
  Widget build(BuildContext context) {
    final tableProvider = Provider.of<TableProviderIntern>(context);
    final selectedTableNumbers = tableProvider.selectedTables.map((table) => table.tableNumber.toString()).join(', ');

    void _showOrderSummary(BuildContext context) {
      final orderProvider = Provider.of<OrderProviderIntern>(context, listen: false);
      final orderItems = orderProvider.items;

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.grey.shade900,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                if (orderItems.isEmpty)
                  const Text('There are no dishes in the order.', style: TextStyle(color: Colors.white70))
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
                              _showOrderSummary(context); // Recargar el modal
                            },
                          ),
                          Text('$quantity', style: const TextStyle(color: Colors.white)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.greenAccent),
                            onPressed: () {
                              orderProvider.addDish(dish);
                              Navigator.pop(context);
                              _showOrderSummary(context); // Recargar el modal
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
                    onPressed: () {
                      // Aquí puedes guardar la orden en Firestore o seguir al siguiente paso
                      orderProvider.clearOrder();
                      Navigator.pop(context);
                    },
                    child: const Text('Confirm Order'),
                  ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Tables $selectedTableNumbers',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
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
        child: Consumer<MenuProviderIntern>(
          builder: (context, menuProvider, _) {
            if (menuProvider.isLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            return ListView.builder(
              itemCount: menuProvider.categories.length,
              itemBuilder: (context, index) {
                final category = menuProvider.categories[index];
                final dishes = menuProvider.getDishesByCategory(category.id);

                return ExpansionTile(
                  collapsedIconColor: Colors.white,
                  iconColor: Colors.white,
                  title: Text(
                    category.name,
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
                      title: Text(
                        dish.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        '${dish.price.toStringAsFixed(2)} €',
                        style: TextStyle(color: Colors.grey.shade300),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          Provider.of<OrderProviderIntern>(context, listen: false).addDish(dish);
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showOrderSummary(context),
        icon: const Icon(Icons.shopping_cart, color: Colors.white,),
        label: const Text('View Order', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blue.shade800,
      ),
    );




  }
}
