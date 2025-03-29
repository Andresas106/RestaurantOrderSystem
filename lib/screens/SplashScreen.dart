import 'dart:async';

import 'package:flutter/material.dart';

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
      //routerDelegate.setNewRoutePath(RouteSettings(name: '/login'));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset('assets/logo.png', fit: BoxFit.cover,),
          ),
          Center(
            child: Text(
              'Recipe Application',
              textAlign: TextAlign.center,
              style: textTheme.displayLarge!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
