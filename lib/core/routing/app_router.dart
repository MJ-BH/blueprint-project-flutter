import 'package:flutter/material.dart';
import '../../features/explorer/ui/explorer_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String explorer = '/explorer';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
      case AppRoutes.explorer:
        return MaterialPageRoute(
          builder: (_) => const ExplorerPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
