


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg/provider/table_provider_intern.dart';

class TableManagement extends StatelessWidget {
  const TableManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final tableProvider = Provider.of<TableProviderIntern>(context);
    final tables = tableProvider.tables;
    final isLoading = tableProvider.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tables Overview',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                final isFree = table.groupId == null;
                final status = isFree ? 'Available' : 'Occupied';

                return GestureDetector(
                  onTap: () {
                    // Aquí se navegará o seleccionará la mesa
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(
                          'Table ${table.tableNumber} - $status')),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isFree ? Colors.green[400] : Colors.orange[400],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Table ${table.tableNumber}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            status,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

}