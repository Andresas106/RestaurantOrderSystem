import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../navigation/AppRouterDelegate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(Duration(seconds: 3), () {
      final routerDelegate = Router.of(context).routerDelegate as AppRouterDelegate;
      routerDelegate.setNewRoutePath(RouteSettings(name: '/login'));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // Esto hace que el Stack ocupe toda la pantalla
        children: [
          // Degradado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Imagen PNG que ocupa toda la pantalla
          Center(
            child: SvgPicture.asset(
              'images/logo.svg',
              width: 500,
            ),
          ),

        ],
      ),
    );
  }
}
