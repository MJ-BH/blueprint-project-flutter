import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';
import 'package:explorer_repository/explorer_repository.dart';
import 'package:core/core.dart';
import 'core/app_core.dart';
import 'features/explorer/bloc/explorer_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Attach Global BLoC Observer from lib/core/utils
  Bloc.observer = AppBlocObserver();

  runApp(const OolabApp());
}

class OolabApp extends StatelessWidget {
  const OolabApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<ExplorerRepository>(
      create: (_) => MockExplorerRepository(),
      child: BlocProvider<ExplorerBloc>(
        create: (context) => ExplorerBloc(
          repository: context.read<ExplorerRepository>(),
        )..add(const LoadExplorerItems()),
        child: MaterialApp(
          title: 'Oolab Cloud Explorer — Flutter Edition',
          theme: AppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: AppRouter.onGenerateRoute,
          initialRoute: AppRoutes.home,
        ),
      ),
    );
  }
}
