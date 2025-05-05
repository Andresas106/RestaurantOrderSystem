import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewOrder extends StatelessWidget {
  final String groupId;
  final Set<String> tables;

  const NewOrder({super.key, required this.groupId, required this.tables});

  @override
  Widget build(BuildContext context) {
    print(tables);
    // Aquí cargarías el pedido con ese groupId desde Firestore
    return Scaffold(
      appBar: AppBar(title: Text('Nuevo Pedido $groupId')),
      body: Center(
        child: Text(tables.toString()),
      ),
    );
  }
}
