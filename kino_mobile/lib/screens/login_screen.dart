import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/validators.dart';
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
    return KinoAuthScaffold(
      title: 'Bem Vindo',
      subtitle: 'Faz login e saboreia.',
      footer: KinoFooterLink(
        text: 'Não tem conta ?',
        action: 'Crie uma Conta',
        onTap: () => Navigator.pushReplacementNamed(context, '/register'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            KinoTextField(
              hint: 'Insira o seu email',
              icon: kinoFieldIcon(Icons.mail_outline),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              emptyMessage: 'Email Inválido',
              validator: KinoValidators.email,
            ),
            const SizedBox(height: 12),
            KinoTextField(
              hint: 'Insira a sua senha',
              icon: kinoFieldIcon(Icons.lock_outline),
              controller: _password,
              isPassword: true,
              emptyMessage: 'Senha Inválida',
              validator: KinoValidators.password,
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
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            KinoPanelButton(label: 'Entrar', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}