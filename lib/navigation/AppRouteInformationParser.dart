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

    return RouteSettings(name: '/');
  }

  @override
  RouteInformation? restoreRouteInformation(RouteSettings configuration)
  {

    return RouteInformation(uri: Uri.parse(configuration.name ?? '/'));
  }
}