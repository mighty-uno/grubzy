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
      child: const ZepkitApp(),
    ),
  );
}

class ZepkitApp extends StatelessWidget {
  const ZepkitApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return MaterialApp(
      title: 'Zepkit | Dopamine Delivery Simulator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: state.isInitialized ? const HomeScreen() : const SplashScreen(),
    );
  }
}
