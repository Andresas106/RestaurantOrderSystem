import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppRouteInformationParser extends RouteInformationParser<RouteSettings> {
  @override
  Future<RouteSettings> parseRouteInformation(RouteInformation routeInformation) async {

    final uri = routeInformation.uri;
    if(uri.pathSegments.length == 1 && uri.pathSegments[0] == 'login') return RouteSettings(name: '/login');

    return RouteSettings(name: '/');
  }

  @override
  RouteInformation? restoreRouteInformation(RouteSettings configuration)
  {

    return RouteInformation(uri: Uri.parse(configuration.name ?? '/'));
  }
}