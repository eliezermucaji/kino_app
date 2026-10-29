import 'package:flutter/material.dart';

import 'core/kino_theme.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/register_screen.dart';

void main() => runApp(const KinoApp());

class KinoApp extends StatelessWidget {
  const KinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kino',
      debugShowCheckedModeBanner: false,
      theme: KinoTheme.light,
      // A app abre direto na Home (sem login).
      initialRoute: '/',
      routes: {
        '/': (_) => const MainShell(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
      },
    );
  }
}
