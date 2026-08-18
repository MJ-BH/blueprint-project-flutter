import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';

abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState { final String userId; AuthAuthenticated(this.userId); }

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  void login(String username, String password) async {
    emit(AuthLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(AuthAuthenticated('usr_hera_99'));
  }
}

void main() {
  runApp(
    BlocProvider(
      create: (_) => AuthCubit(),
      child: const BlueprintFlutterApp(),
    ),
  );
}

class BlueprintFlutterApp extends StatelessWidget {
  const BlueprintFlutterApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blueprint Project Flutter',
      theme: AppTheme.darkTheme,
      home: Scaffold(
        appBar: AppBar(title: const Text('Blueprint Project Flutter (Clean Architecture)')),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AuthAuthenticated) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified, size: 64, color: AppColors.accent),
                    const SizedBox(height: 16),
                    Text('Authenticated Session: ${state.userId}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }
            return Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.lock_open),
                label: const Text('Test BLoC Authentication Flow'),
                onPressed: () => context.read<AuthCubit>().login('jihed', 'secure_pass'),
              ),
            );
          },
        ),
      ),
    );
  }
}
