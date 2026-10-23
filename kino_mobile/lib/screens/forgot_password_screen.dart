import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/kino_theme.dart';
import '../widgets/kino_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  int _step = 0;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _sendCode() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: pedir à API para enviar o código de 4 dígitos para _email.text
    setState(() => _step = 1);
  }

  void _verifyCode(String code) {
    // TODO: validar o código na API e avançar para a tela de nova senha.
    debugPrint('Código inserido: $code');
  }

  @override
  Widget build(BuildContext context) {
    return KinoScaffold(
      scribbleAtBottom: true,
      child: Column(
        children: [
          KinoHeader(
            title: 'Esqueceu a Senha',
            subtitle: _step == 0
                ? 'Esqueceste-te da senha?\nNós ajudamos-te a voltar.'
                : 'Insira o código de 4 dígitos\nenviado para o seu email',
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _step == 0 ? _buildEmailStep() : _buildCodeStep(),
          ),
          const KinoDivider('NÃO TEM CONTA ?'),
          KinoButton(
            label: 'Criar Conta',
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/register'),
          ),
          const KinoDivider('LEMBROU A SENHA?'),
          KinoButton(
            label: 'Fazer Login',
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailStep() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('email'),
        children: [
          KinoTextField(
            hint: 'Insere o Teu Email',
            icon: const Icon(Icons.person_outline, color: Colors.black, size: 30),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Email inválido' : null,
          ),
          const SizedBox(height: 22),
          KinoButton(
            label: 'Continuar',
            trailingIcon: Icons.arrow_forward,
            onPressed: _sendCode,
          ),
        ],
      ),
    );
  }

  Widget _buildCodeStep() {
    return Column(
      key: const ValueKey('code'),
      children: [
        _OtpRow(onCompleted: _verifyCode),
        const SizedBox(height: 22),
        KinoButton(
          label: 'Editar Email',
          leadingIcon: Icons.arrow_back,
          onPressed: () => setState(() => _step = 0),
        ),
      ],
    );
  }
}

/// 4 caixas para o código, com avanço automático de foco.
class _OtpRow extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  const _OtpRow({required this.onCompleted});

  @override
  State<_OtpRow> createState() => _OtpRowState();
}

class _OtpRowState extends State<_OtpRow> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _nodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _onChanged(int i, String value) {
    if (value.isNotEmpty && i < 3) _nodes[i + 1].requestFocus();
    if (value.isEmpty && i > 0) _nodes[i - 1].requestFocus();

    final code = _controllers.map((c) => c.text).join();
    if (code.length == 4) widget.onCompleted(code);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (i) {
        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: KinoColors.field,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black, width: 1),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 12,
                  offset: Offset(0, 6)),
            ],
          ),
          child: TextField(
            controller: _controllers[i],
            focusNode: _nodes[i],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
            ),
            onChanged: (v) => _onChanged(i, v),
          ),
        );
      }),
    );
  }
}
