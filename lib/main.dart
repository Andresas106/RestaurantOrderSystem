import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:tfg/provider/auth_provider_intern.dart';
import 'package:tfg/provider/user_provider_intern.dart';

import 'navigation/AppRouteInformationParser.dart';
import 'navigation/AppRouterDelegate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppRouterDelegate _routerDelegate = AppRouterDelegate();
  final AppRouteInformationParser _routerInformationParser = AppRouteInformationParser();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProviderIntern()),  // Mantienes el AuthProvider
        ChangeNotifierProvider(create: (context) => UserProviderIntern()), // Añades el UserProviderIntern
      ],
      child: MaterialApp.router(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routerDelegate: _routerDelegate,
        routeInformationParser: _routerInformationParser,
        backButtonDispatcher: RootBackButtonDispatcher(),
      ),
    );
  }
}
