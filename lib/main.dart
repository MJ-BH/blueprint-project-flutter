import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';
import 'package:core/core.dart';
import 'core/app_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Attach Global BLoC Observer for app-wide state change logging
  Bloc.observer = AppBlocObserver();

  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Clean Architecture Example App',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRoutes.home,
    );
  }
}
