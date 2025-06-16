import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tfg/provider/auth_provider_intern.dart';
import 'package:tfg/provider/dish_provider_intern.dart';
import 'package:tfg/provider/menu_provider_intern.dart';
import 'package:tfg/provider/orderKitchen_provider_intern.dart';
import 'package:tfg/provider/order_provider_intern.dart';
import 'package:tfg/provider/table_provider_intern.dart';
import 'package:tfg/provider/user_provider_intern.dart';
import 'package:tfg/services/PredictionService.dart';

import 'navigation/AppRouteInformationParser.dart';
import 'navigation/AppRouterDelegate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PredictionService().init();

  // 👉 Forzar orientación vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
        ChangeNotifierProvider(create: (context) => AuthProviderIntern()),
        ChangeNotifierProvider(create: (context) => UserProviderIntern()),
        ChangeNotifierProvider(create: (context) => TableProviderIntern()..listenToTables()),
        ChangeNotifierProvider(create: (context) => MenuProviderIntern()),
        ChangeNotifierProvider(create: (context) => OrderProviderIntern()),
        ChangeNotifierProvider(create: (context) => OrderKitchenProvider()),
        ChangeNotifierProvider(create: (context) => DishProvider())
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
