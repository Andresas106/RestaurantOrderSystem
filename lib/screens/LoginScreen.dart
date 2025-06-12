import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:tfg/navigation/AppRouterDelegate.dart';
import '../provider/auth_provider_intern.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProviderIntern>(context, listen: false);
      await authProvider.signIn(emailController.text, passwordController.text);

      final User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) throw Exception("No user found after login");

      final uid = firebaseUser.uid;

      // Buscar el documento por el campo 'uid'
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Cerrar sesión si no existe en Firestore
        authProvider.signOut();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Access denied: Your account is not in the system')),
        );
        return;
      }

      // Extraer el rol
      final userData = querySnapshot.docs.first.data();
      final role = userData['role'] ?? '';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful')),
      );

      Future.delayed(Duration(milliseconds: 500), () {
        final routerDelegate = Router.of(context).routerDelegate as AppRouterDelegate;
        routerDelegate.setNewRoutePath(
          RouteSettings(name: '/home', arguments: {'uid': uid, 'role': role}),
        );
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade700, Colors.black],
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo y título
                SvgPicture.asset(
                  'images/logo.svg',
                  width: 250,
                ),
                SizedBox(height: 10),
                Text(
                  "ServeSync",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 30),

                // Input de Email
                _buildTextField(emailController, "Email", Icons.email),

                SizedBox(height: 15),

                // Input de Contraseña
                _buildTextField(passwordController, "Password", Icons.lock, obscureText: true),

                SizedBox(height: 20),

                // Botón de Login
                ElevatedButton(
                  onPressed: () => login(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text("Log In", style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Método para construir los campos de texto
  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white10,
        prefixIcon: Icon(icon, color: Colors.white),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}
