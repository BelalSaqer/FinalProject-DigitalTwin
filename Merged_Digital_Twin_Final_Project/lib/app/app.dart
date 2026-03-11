import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/dt_colors.dart';
import '../screens/login_screen.dart';
import '../app/routes.dart';
import '../app/state.dart';

class DigitalTwinApp extends StatelessWidget {
  const DigitalTwinApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: DT.bg,
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(primary: DT.blue, secondary: DT.cyan),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: DT.dim(0.45)),
        filled: true,
        fillColor: const Color(0xFF0B1220).alphaF(0.55),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: DT.border(0.70)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: DT.blue, width: 1.6),
        ),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const _Root(),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (!app.isLoggedIn) return const LoginScreen();
    return const AppShell();
  }
}