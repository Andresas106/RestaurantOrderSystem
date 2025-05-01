import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppRouteInformationParser extends RouteInformationParser<RouteSettings> {
  @override
  Future<RouteSettings> parseRouteInformation(RouteInformation routeInformation) async {

    final uri = routeInformation.uri;
    if(uri.pathSegments.length == 1 && uri.pathSegments[0] == 'login') return RouteSettings(name: '/login');
    if(uri.pathSegments.length == 3 && uri.pathSegments[0] == 'home') {
      String uid = uri.pathSegments[1];
      String role = uri.pathSegments[2];
      return RouteSettings(name: '/home', arguments: {'uid': uid, 'role': role});
    }
    if(uri.pathSegments.length == 1 && uri.pathSegments[0] == 'user-management') {
      return RouteSettings(name: '/user-management');
    }
    //user-management

    return RouteSettings(name: '/');
  }

  @override
  RouteInformation? restoreRouteInformation(RouteSettings configuration)
  {

    if(configuration.name == '/login') {
      return RouteInformation(uri: Uri.parse('/login'));
    }

    if (configuration.name == '/home') {
      // Si la ruta es '/home', entonces toma los argumentos 'uid' y 'role' y los agrega a la URI
      final arguments = configuration.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        final uid = arguments['uid'];
        final role = arguments['role'];
        return RouteInformation(uri: Uri.parse('/home/$uid/$role'));
      }
    }

    if (configuration.name == '/user-management') {
      return RouteInformation(uri: Uri.parse('/user-management'));
    }

    return RouteInformation(uri: Uri.parse(configuration.name ?? '/'));
  }
}