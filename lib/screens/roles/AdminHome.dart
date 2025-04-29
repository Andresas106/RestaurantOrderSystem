import 'package:flutter/material.dart';

class AdminHome extends StatelessWidget {
  final String uid;

  const AdminHome({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.admin_panel_settings, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'ServeSync Admin',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),

              _buildButton(
                context,
                label: 'Manage Users',
                icon: Icons.person,
                routeName: '/user-management',
              ),
              const SizedBox(height: 16),

              _buildButton(
                context,
                label: 'Manage Tables',
                icon: Icons.table_bar,
                routeName: '/table-management',
              ),
              const SizedBox(height: 16),

              _buildButton(
                context,
                label: 'Manage Orders',
                icon: Icons.receipt_long,
                routeName: '/order-management',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context,
      {required String label, required IconData icon, required String routeName}) {
    return ElevatedButton.icon(
      onPressed: () => Navigator.pushNamed(context, routeName),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }
}
