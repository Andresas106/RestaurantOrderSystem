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

    if(uri.pathSegments.length == 1 && uri.pathSegments[0] == 'table-management') {
      return RouteSettings(name: '/table-management');
    }
    if(uri.pathSegments.length == 2 && uri.pathSegments[0] == 'edit-order') {
      String groupId = uri.pathSegments[1];
      return RouteSettings(name: '/edit-order', arguments: {'group_id': groupId});
    }
    if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'new-order') {
      String groupId = uri.pathSegments[1];
      List<String> tables = uri.queryParameters['tables']?.split(',') ?? []; // Dividir las mesas de la query string
      String? uid = uri.queryParameters['uid'];
      return RouteSettings(name: '/new-order', arguments: {'group_id': groupId, 'tables': tables, 'uid': uid});
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

    if(configuration.name == '/table-management') {
      return RouteInformation(uri: Uri.parse('/table-management'));
    }

    if (configuration.name == '/edit-order') {
      // Si la ruta es '/home', entonces toma los argumentos 'uid' y 'role' y los agrega a la URI
      final arguments = configuration.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        final group_id = arguments['group_id'];
        return RouteInformation(uri: Uri.parse('/edit-order/$group_id'));
      }
    }

    if (configuration.name == '/new-order') {
      final arguments = configuration.arguments as Map<String, dynamic>?;

      if (arguments != null) {
        final groupId = arguments['group_id'];
        final tables = arguments['tables'] as List<String>;
        final uid = arguments['uid'];


        // Convertir List<String> a una cadena separada por comas
        final tablesQuery = tables.join(',');
        return RouteInformation(uri: Uri.parse('/new-order/$groupId?tables=$tablesQuery&uid=$uid'));
      }
    }

    return RouteInformation(uri: Uri.parse(configuration.name ?? '/'));
  }
}