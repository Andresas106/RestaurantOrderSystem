import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tfg/screens/HomeScreen.dart';
import 'package:tfg/screens/SplashScreen.dart';
import 'package:tfg/screens/LoginScreen.dart';
import 'package:tfg/screens/management/UserManagement.dart';
import 'package:tfg/screens/orders/NewOrder.dart';

import '../screens/management/TableManagement.dart';
import '../screens/orders/EditOrder.dart';

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

    // Splash Screen
    if (_currentRoute?.name == '/') {
      pages.add(
        CustomTransitionPage(
          key: ValueKey('SplashScreen'),
          child: SplashScreen(),
        ),
      );
    }

    // Login Screen
    else if (_currentRoute?.name == '/login') {
      pages.add(
        CustomTransitionPage(
          key: ValueKey('LoginScreen'),
          child: LoginScreen(),
        ),
      );
    }

    // Home Screen
    else if (_currentRoute?.name == '/home') {
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

    // User Management Screen
    else if (_currentRoute?.name == '/user-management') {
      final args = _currentRoute?.arguments as Map<String, dynamic>?;
      if (args != null) {
        pages.addAll([
          CustomTransitionPage(
            key: ValueKey('HomeScreen'),
            child: HomeScreen(uid: args['uid'], role: args['role']),
          ),
          CustomTransitionPage(
            key: ValueKey('UserManagement'),
            child: UserManagement(),
          ),
        ]);
      }
    }

    else if(_currentRoute?.name == '/table-management') {
      final args = _currentRoute?.arguments as Map<String, dynamic>?;
      if(args != null) {
        pages.addAll([
          CustomTransitionPage(
            key: ValueKey('HomeScreen'),
            child: HomeScreen(uid: args['uid'], role: args['role']),
          ),
          CustomTransitionPage(
            key: ValueKey('UserManagement'),
            child: TableManagement(),
          ),
        ]);
      }
    }

    else if(_currentRoute?.name == '/edit-order') {
      final args = _currentRoute?.arguments as Map<String, dynamic>?;
      if(args!= null) {
        pages.addAll([
          CustomTransitionPage(
            key: ValueKey('HomeScreen'),
            child: HomeScreen(uid: args['uid'], role: args['role']),
          ),
          CustomTransitionPage(
            key: ValueKey('EditOrder'),
            child: EditOrder(groupId: args['group_id']),
          ),
        ]);
      }
    }

    else if(_currentRoute?.name == '/new-order') {
      final args = _currentRoute?.arguments as Map<String, dynamic>?;

      if(args != null) {
        print(args['tables']);
        pages.addAll([
          CustomTransitionPage(
            key: ValueKey('HomeScreen'),
            child: HomeScreen(uid: args['uid'], role: args['role']),
          ),
          CustomTransitionPage(
            key: ValueKey('NewOrder'),
            child: NewOrder(groupId: args['group_id'], tables: args['tables']),
          ),
        ]);
      }
    }

    return Navigator(
      key: navigatorKey,
      pages: pages,
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;

        if (_currentRoute?.name == '/home') {
          _setNewRoutePath(RouteSettings(name: '/login'));
        } else if (_currentRoute?.name == '/login') {
          SystemNavigator.pop(); // Cierra la app
        } else if (_currentRoute?.name == '/user-management') {
          final args = _currentRoute?.arguments as Map<String, dynamic>?;
          if (args != null) {
            _setNewRoutePath(RouteSettings(name: '/home', arguments: args));
          } else {
            // fallback seguro si no hay argumentos
            _setNewRoutePath(RouteSettings(name: '/login'));
          }
        }
        else if(_currentRoute?.name == '/table-management') {
          final args = _currentRoute?.arguments as Map<String, dynamic>?;
          if (args != null) {
            _setNewRoutePath(RouteSettings(name: '/home', arguments: args));
          } else {
            // fallback seguro si no hay argumentos
            _setNewRoutePath(RouteSettings(name: '/login'));
          }
        }
        else if(_currentRoute?.name == '/edit-order') {
          final args = _currentRoute?.arguments as Map<String, dynamic>?;
          if(args != null) {
            _setNewRoutePath(RouteSettings(name: '/home', arguments: args));
          }
        }
        else if(_currentRoute?.name == '/new-order') {
          final args = _currentRoute?.arguments as Map<String, dynamic>?;
          if(args != null) {
            _setNewRoutePath(RouteSettings(name: '/home', arguments: args));
          }
        }

        return true;
      },
    );
  }
}

class CustomTransitionPage extends Page {
  final Widget child;

  const CustomTransitionPage({required LocalKey key, required this.child})
      : super(key: key);

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
