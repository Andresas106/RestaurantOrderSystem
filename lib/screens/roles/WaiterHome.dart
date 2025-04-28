import 'package:flutter/material.dart';

class WaiterHome extends StatelessWidget {
  final String uid;

  const WaiterHome({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 80, color: Colors.green),
          SizedBox(height: 20),
          Text('Welcome Waiter!', style: TextStyle(fontSize: 24)),
          // Aquí podrías mostrar mesas, pedidos abiertos, etc.
        ],
      ),
    );
  }
}
