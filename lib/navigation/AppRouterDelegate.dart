import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tfg/screens/HomeScreen.dart';
import 'package:tfg/screens/SplashScreen.dart';

import '../screens/LoginScreen.dart';


class AppRouterDelegate extends RouterDelegate<RouteSettings>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteSettings> {
  final GlobalKey<NavigatorState> navigatorKey;
  RouteSettings? _currentRoute = RouteSettings(name: '/');

  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  RouteSettings? get currentConfiguration => _currentRoute;

  void _setNewRoutePath(RouteSettings settings) {
    _currentRoute = settings;
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(RouteSettings configuration) async {
    _setNewRoutePath(configuration);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        if(_currentRoute?.name == '/')
          CustomTransitionPage(key: ValueKey('SplashScreen'),
              child: SplashScreen()),
        if(_currentRoute?.name == '/login')
          CustomTransitionPage(key: ValueKey('LoginScreen'), child: LoginScreen()),
        if(_currentRoute?.name == '/home')
          if (_currentRoute?.arguments != null)
          CustomTransitionPage(key: ValueKey('HomeScreen'), child: HomeScreen(
              uid: (_currentRoute?.arguments as Map<String, dynamic>)['uid'],
              role: (_currentRoute?.arguments as Map<String, dynamic>)['role']))
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        return true;
      },
    );
  }
}

class CustomTransitionPage extends Page {
  final Widget child;

  const CustomTransitionPage({required LocalKey key,required  this.child})
  : super(key: key);
  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
        settings: this,
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child,);
        }
    );
  }
}