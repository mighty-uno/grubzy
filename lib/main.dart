import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/design_tokens.dart';
import 'models/app_state.dart';
import 'views/home_screen.dart';
import 'views/splash_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const GrubzyApp(),
    ),
  );
}

class GrubzyApp extends StatelessWidget {
  const GrubzyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return MaterialApp(
      title: 'Grubzy | Dopamine Delivery Simulator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: state.isInitialized ? const HomeScreen() : const SplashScreen(),
    );
  }
}
