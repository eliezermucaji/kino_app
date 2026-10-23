import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/kino_theme.dart';
import '../widgets/kino_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: chamar a tua API de autenticação aqui.
    debugPrint('Login: ${_email.text}');
  }

  @override
  Widget build(BuildContext context) {
    return KinoScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const KinoHeader(
              title: 'Bem Vindo',
              subtitle: 'Faz login e saboreia.',
            ),
            KinoScribbleBehind(
              child: Column(
                children: [
            KinoTextField(
              hint: 'Email',
              icon: const Icon(Icons.person_outline, color: Colors.black, size: 30),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'Email inválido' : null,
            ),
            const SizedBox(height: 18),
            KinoTextField(
              hint: 'Senha',
              icon: const Icon(Icons.lock, color: Colors.black, size: 30),
              controller: _password,
              isPassword: true,
              validator: (v) =>
                  (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/forgot'),
                child: Text(
                  'Esqueci a minha Senha',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: KinoColors.redDark,
                  ),
                ),
              ),
            ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            KinoButton(
              label: 'Entrar',
              trailingIcon: Icons.arrow_forward,
              onPressed: _submit,
            ),
            const KinoDivider('NÃO TEM CONTA ?'),
            KinoButton(
              label: 'Criar Conta',
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, '/register'),
            ),
          ],
        ),
      ),
    );
  }
}
