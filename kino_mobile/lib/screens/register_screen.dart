import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/kino_theme.dart';
import '../core/validators.dart';
import '../widgets/kino_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const int _lastStep = 2;

  final _formKeys = List.generate(3, (_) => GlobalKey<FormState>());

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  int _step = 0;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _whatsapp, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() {
    if (!_formKeys[_step].currentState!.validate()) return;
    if (_step < _lastStep) {
      setState(() => _step++);
    } else {
      _createAccount();
    }
  }

  void _back() {
    if (_step == 0) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() => _step--);
    }
  }

  void _createAccount() {
    // TODO: enviar para a API. Os telefones seguem sem espaços:
    final phone = KinoValidators.digitsOnly(_phone.text);
    final whatsapp = KinoValidators.digitsOnly(_whatsapp.text);
    debugPrint('Criar conta: ${_name.text} | ${_email.text} | $phone | $whatsapp');
  }

  @override
  Widget build(BuildContext context) {
    return KinoAuthScaffold(
      title: 'Criar Conta',
      subtitle: 'Cria conta e mata a fome !',
      footer: KinoFooterLink(
        text: 'Já tem conta ?',
        action: 'Faça Login',
        onTap: () => Navigator.pushReplacementNamed(context, '/login'),
      ),
      body: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Form(
              key: _formKeys[_step],
              child: Column(
                key: ValueKey('step$_step'),
                children: _fieldsForStep(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          KinoPanelButton(
            label: _step == _lastStep ? 'Criar Conta' : 'Continuar',
            onPressed: _next,
          ),
          const SizedBox(height: 10),
          KinoPanelButton(label: 'Voltar', onPressed: _back),
        ],
      ),
    );
  }

  List<Widget> _fieldsForStep() {
    switch (_step) {
      case 0:
        return [
          KinoTextField(
            hint: 'Insira o seu nome completo',
            icon: kinoFieldIcon(Icons.person_outline),
            controller: _name,
            emptyMessage: 'Nome Inválido',
          ),
          const SizedBox(height: 12),
          KinoTextField(
            hint: 'Insira o seu email',
            icon: kinoFieldIcon(Icons.mail_outline),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            emptyMessage: 'Email Inválido',
            validator: KinoValidators.email,
          ),
        ];
      case 1:
        return [
          KinoTextField(
            hint: 'Insira o seu telefone',
            icon: kinoFieldIcon(Icons.call_outlined),
            controller: _phone,
            keyboardType: TextInputType.number,
            inputFormatters: KinoValidators.phoneFormatters,
            emptyMessage: 'Telefone Inválido',
            validator: KinoValidators.phone,
          ),
          const SizedBox(height: 12),
          KinoTextField(
            hint: 'Insira o seu whatsapp',
            icon: const FaIcon(
              FontAwesomeIcons.whatsapp,
              color: KinoColors.panel,
              size: 24,
            ),
            controller: _whatsapp,
            keyboardType: TextInputType.number,
            inputFormatters: KinoValidators.phoneFormatters,
            emptyMessage: 'WhatsApp Inválido',
            validator: KinoValidators.phone,
          ),
        ];
      default:
        return [
          KinoTextField(
            hint: 'Insira a sua senha',
            icon: kinoFieldIcon(Icons.lock_outline),
            controller: _password,
            isPassword: true,
            emptyMessage: 'Senha Inválida',
            validator: KinoValidators.password,
          ),
          const SizedBox(height: 12),
          KinoTextField(
            hint: 'Repita a sua senha',
            icon: kinoFieldIcon(Icons.lock_outline),
            controller: _confirm,
            isPassword: true,
            emptyMessage: 'Confirmação Inválida',
            validator: (v) =>
                v != _password.text ? 'As senhas não coincidem' : null,
          ),
        ];
    }
  }
}