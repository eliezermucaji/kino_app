import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/auth_controller.dart';
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
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthController.instance.login(_email.text.trim(), _password.text);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      return;
    }
    if (!mounted) return;
    // O login foi aberto por cima da tela de onde o utilizador veio
    // (Home, produto, perfil...): fechar devolve-o lá, já com sessão.
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
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
            KinoPanelButton(
              label: _loading ? 'A entrar...' : 'Entrar',
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
