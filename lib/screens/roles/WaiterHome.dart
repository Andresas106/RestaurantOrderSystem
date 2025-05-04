import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/table_provider_intern.dart';

class WaiterHome extends StatefulWidget {
  final String uid;

  const WaiterHome({super.key, required this.uid});

  @override
  _WaiterHomeState createState() => _WaiterHomeState();
}

class _WaiterHomeState extends State<WaiterHome> {
  // Estado para las mesas seleccionadas
  Set<String> selectedTables = {};

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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final table = tables[index];
                      final isSelected = selectedTables.contains(table.id);

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            // Si la mesa ya está seleccionada, la desmarco
                            if (isSelected) {
                              selectedTables.remove(table.id);
                            } else {
                              selectedTables.add(table.id);
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: table.groupId == null
                                ? Colors.green[400]
                                : Colors.orange[400],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.white24,
                                width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(2, 4),
                              )
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
                  onPressed: selectedTables.isEmpty
                      ? null
                      : () {
                    // Crear pedido aquí
                    // Por ejemplo, generar un nuevo groupId y actualizar las mesas seleccionadas
                    String newGroupId = generateGroupId();
                    createOrderForTables(newGroupId);
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Create Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
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

  // Método para crear un pedido y asignar el groupId a las mesas seleccionadas
  void createOrderForTables(String groupId) {
    // Lógica para actualizar Firestore con el nuevo groupId en las mesas seleccionadas
    final tableProvider = Provider.of<TableProviderIntern>(context, listen: false);
    tableProvider.updateTablesWithGroupId(groupId, selectedTables);
    print("SelectedTables: ${selectedTables}");

    // Luego podrías redirigir al usuario a una página de detalle del pedido, por ejemplo.
  }
}
