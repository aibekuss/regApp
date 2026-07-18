// main.dart
//
// Entry point of the Flutter application. Sets up a modern theme with an
// indigo/violet accent, soft rounded inputs, and gradient buttons that are
// reused across the login, register and home screens.

import 'package:flutter/material.dart';
import 'login_page.dart';

// Shared palette used across the whole app (import where needed).
class AppColors {
  static const Color primary = Color(0xFF6C63FF); // indigo/violet
  static const Color primaryDark = Color(0xFF463AF7);
  static const Color accent = Color(0xFF00D9C0); // teal accent
  static const Color bgTop = Color(0xFF120E2A);
  static const Color bgMid = Color(0xFF1B1440);
  static const Color bgBottom = Color(0xFF2A1E5C);
  static const Color danger = Color(0xFFFF5C7A);
  static const Color success = Color(0xFF2ED47A);

  static const LinearGradient background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgTop, bgMid, bgBottom],
  );

  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, primaryDark],
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Registration',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: Color(0xFF1E1A3E),
          error: AppColors.danger,
        ),
        scaffoldBackgroundColor: AppColors.bgTop,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white60),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.06),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.6),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.4),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
          ),
          prefixIconColor: Colors.white54,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
          errorStyle: const TextStyle(color: AppColors.danger),
        ),
      ),
      home: const LoginPage(),
    );
  }
}