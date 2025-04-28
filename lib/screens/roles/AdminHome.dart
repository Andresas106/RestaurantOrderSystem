import 'package:flutter/material.dart';

class AdminHome extends StatelessWidget {
  final String uid;

  const AdminHome({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.admin_panel_settings, size: 80, color: Colors.blue),
          SizedBox(height: 20),
          Text('Welcome Admin!', style: TextStyle(fontSize: 24)),
          // Aquí puedes poner botones de gestionar usuarios, estadísticas, etc.
        ],
      ),
    );
  }
}
