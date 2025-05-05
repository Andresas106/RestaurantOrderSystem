import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tfg/screens/roles/AdminHome.dart';
import 'package:tfg/screens/roles/ChefHome.dart';
import 'package:tfg/screens/roles/WaiterHome.dart';
import '../provider/auth_provider_intern.dart';

class HomeScreen extends StatefulWidget {
  final String uid;
  final String role;

  const HomeScreen({required this.uid, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ServeSync - Home',
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
      body: _buildHomeContent(),
    );
  }

  Widget _buildHomeContent() {
    switch (widget.role) {
      case 'admin':
        return AdminHome(uid: widget.uid, role: widget.role);
      case 'chef':
        return ChefHome(uid: widget.uid);
      case 'waiter':
        return WaiterHome(uid: widget.uid, role: widget.role);
      default:
        return Center(
          child: Text('Role not recognized', style: TextStyle(fontSize: 20)),
        );
    }
  }
}
