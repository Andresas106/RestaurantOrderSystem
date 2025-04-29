import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    List<Page> pages = [];

    if (_currentRoute?.name == '/') {
      pages.add(
        CustomTransitionPage(
          key: ValueKey('SplashScreen'),
          child: SplashScreen(),
        ),
      );
    } else if (_currentRoute?.name == '/login') {
      pages.addAll([
        CustomTransitionPage(
          key: ValueKey('SplashScreen'),
          child: SplashScreen(),
        ),
        CustomTransitionPage(
          key: ValueKey('LoginScreen'),
          child: LoginScreen(),
        ),
      ]);
    } else if (_currentRoute?.name == '/home') {
      final args = _currentRoute?.arguments as Map<String, dynamic>?;
      if (args != null) {
        pages.addAll([
          CustomTransitionPage(
            key: ValueKey('LoginScreen'),
            child: LoginScreen(),
          ),
          CustomTransitionPage(
            key: ValueKey('HomeScreen'),
            child: HomeScreen(uid: args['uid'], role: args['role']),
          ),
        ]);
      }
    }


    return Navigator(
      key: navigatorKey,
      pages: pages,
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        if(_currentRoute?.name == '/home') {
          _setNewRoutePath(RouteSettings(name: '/login'));
          print("Se ejecuta");
        } else if(_currentRoute?.name == '/login') {
          SystemNavigator.pop();
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