import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_ui/app_ui.dart';
import 'package:core/core.dart';
import 'core/app_core.dart';
import 'main_client_a.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  Bloc.observer = AppBlocObserver();

  // Configure Client B Target (e.g. Beta Mobility Partner)
  final config = AppConfig(
    brandName: 'Beta Mobility (Client B)',
    apiBaseUrl: 'https://api.beta-mobility.fr/v1',
    primaryColor: const Color(0xFF10B981),
    enableMobilityModule: false,
  );

  runApp(ClientApp(config: config));
}
