import 'package:flutter/material.dart';

class ChefHome extends StatelessWidget {
  final String uid;

  const ChefHome({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.kitchen, size: 80, color: Colors.red),
          SizedBox(height: 20),
          Text('Welcome Chef!', style: TextStyle(fontSize: 24)),
          // Aquí puedes mostrar las comandas que tiene que preparar
        ],
      ),
    );
  }
}
