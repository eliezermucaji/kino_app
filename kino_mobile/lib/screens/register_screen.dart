import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../widgets/kino_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

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
    if (_step1Key.currentState!.validate()) setState(() => _step = 1);
  }

  void _createAccount() {
    if (!_step2Key.currentState!.validate()) return;
    // TODO: enviar _name, _email, _phone, _whatsapp, _password para a API.
    debugPrint('Criar conta: ${_email.text}');
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null;

  @override
  Widget build(BuildContext context) {
    return KinoScaffold(
      child: Column(
        children: [
          const KinoHeader(
            title: 'Cria a tua Conta',
            subtitle: 'Cria conta e mata a fome !',
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _step == 0 ? _buildStep1() : _buildStep2(),
          ),
          const KinoDivider('JÁ TEM CONTA ?'),
          KinoButton(
            label: 'Fazer Login',
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Form(
      key: _step1Key,
      child: Column(
        key: const ValueKey('step1'),
        children: [
          KinoTextField(
            hint: 'Nome Completo',
            icon: const Icon(Icons.person_outline, color: Colors.black, size: 30),
            controller: _name,
            validator: _required,
          ),
          const SizedBox(height: 18),
          KinoTextField(
            hint: 'Email',
            icon: const Icon(Icons.mail, color: Colors.black, size: 30),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Email inválido' : null,
          ),
          const SizedBox(height: 18),
          KinoTextField(
            hint: 'Telefone para Chamada',
            icon: const Icon(Icons.phone_in_talk, color: Colors.black, size: 30),
            controller: _phone,
            keyboardType: TextInputType.phone,
            validator: _required,
          ),
          const SizedBox(height: 28),
          KinoButton(
            label: 'Continuar',
            trailingIcon: Icons.arrow_forward,
            onPressed: _next,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _step2Key,
      child: Column(
        key: const ValueKey('step2'),
        children: [
          KinoTextField(
            hint: 'Telefone para Whatsapp',
            icon: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.whatsapp,
                    color: Colors.white, size: 18),
              ),
            ),
            controller: _whatsapp,
            keyboardType: TextInputType.phone,
            validator: _required,
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
          const SizedBox(height: 18),
          KinoTextField(
            hint: 'Confirmar Senha',
            icon: const Icon(Icons.lock, color: Colors.black, size: 30),
            controller: _confirm,
            isPassword: true,
            validator: (v) =>
                v != _password.text ? 'As senhas não coincidem' : null,
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: KinoButton(
                  label: 'Editar\nDados',
                  leadingIcon: Icons.arrow_back,
                  reversed: true,
                  compact: true,
                  onPressed: () => setState(() => _step = 0),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: KinoButton(
                  label: 'Criar\nConta',
                  trailingIcon: Icons.arrow_forward,
                  compact: true,
                  onPressed: _createAccount,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
