import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';
import 'package:core/core.dart';
import 'core/app_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Attach Global BLoC Observer for state tracking
  Bloc.observer = AppBlocObserver();

  // Configure Client A Target (e.g. Alpha Travel Partner)
  final config = AppConfig(
    brandName: 'TRVL Alpha (Client A)',
    apiBaseUrl: 'https://api.alpha-travel.com/v1',
    primaryColor: const Color(0xFF1E3A8A),
    enableMobilityModule: true,
  );

  runApp(ClientApp(config: config));
}

class AppConfig {
  final String brandName;
  final String apiBaseUrl;
  final Color primaryColor;
  final bool enableMobilityModule;

  AppConfig({
    required this.brandName,
    required this.apiBaseUrl,
    required this.primaryColor,
    required this.enableMobilityModule,
  });
}

class ClientApp extends StatelessWidget {
  final AppConfig config;
  const ClientApp({Key? key, required this.config}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: config.brandName,
      theme: AppTheme.darkTheme.copyWith(primaryColor: config.primaryColor),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRoutes.home,
    );
  }
}
