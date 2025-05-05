import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditOrder extends StatelessWidget {
  final String groupId;

  const EditOrder({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    // Aquí cargarías el pedido con ese groupId desde Firestore
    return Scaffold(
      appBar: AppBar(title: Text('Editar Pedido $groupId')),
      body: Center(
        child: Text('Contenido del pedido aquí...'),
      ),
    );
  }
}
