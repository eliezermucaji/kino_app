import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/kino_theme.dart';
import '../core/validators.dart';
import '../widgets/kino_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const int _resendSeconds = 60;

  final _formKey = GlobalKey<FormState>();
  final _otpKey = GlobalKey<_OtpRowState>();
  final _email = TextEditingController();

  Timer? _timer;
  int _secondsLeft = _resendSeconds;
  int _step = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
      }
      setState(() => _secondsLeft = math.max(0, _secondsLeft - 1));
    });
  }

  String get _countdown {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _sendCode() {
    if (!_formKey.currentState!.validate()) return;
    // TODO: pedir à API para enviar o código de 6 dígitos para _email.text
    setState(() => _step = 1);
    _startTimer();
  }

  void _resendCode() {
    // TODO: pedir à API para reenviar o código.
    _startTimer();
  }

  void _verifyCode() {
    final otp = _otpKey.currentState;
    if (otp == null || !otp.validate()) return;
    // TODO: validar o código na API e avançar para a tela de nova senha.
    debugPrint('Código inserido: ${otp.code}');
  }

  void _backToEmail() {
    _timer?.cancel();
    setState(() => _step = 0);
  }

  @override
  Widget build(BuildContext context) {
    return KinoAuthScaffold(
      title: 'Esqueceu a Senha ?',
      subtitle: 'Nós ajudamos a recuperar.',
      footer: KinoFooterLink(
        text: 'Não tem conta ?',
        action: 'Crie uma Conta',
        onTap: () => Navigator.pushReplacementNamed(context, '/register'),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _step == 0 ? _buildEmailStep() : _buildCodeStep(),
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
            hint: 'Insira o seu email',
            icon: kinoFieldIcon(Icons.mail_outline),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            emptyMessage: 'Email Inválido',
            validator: KinoValidators.email,
          ),
          const SizedBox(height: 14),
          KinoPanelButton(label: 'Continuar', onPressed: _sendCode),
          const SizedBox(height: 10),
          KinoPanelButton(
            label: 'Voltar',
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeStep() {
    final white = GoogleFonts.inter(fontSize: 15, color: Colors.white);
    final canResend = _secondsLeft == 0;

    return Column(
      key: const ValueKey('code'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OtpRow(key: _otpKey),
        const SizedBox(height: 14),
        canResend
            ? GestureDetector(
                onTap: _resendCode,
                child: Text(
                  'Reenviar código',
                  style: white.copyWith(
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
              )
            : Text('Reenviar código em $_countdown', style: white),
        const SizedBox(height: 14),
        KinoPanelButton(label: 'Enviar', onPressed: _verifyCode),
        const SizedBox(height: 10),
        KinoPanelButton(label: 'Voltar', onPressed: _backToEmail),
      ],
    );
  }
}

/// 6 caixas para o código. Se estiver incompleto ao enviar, abana de leve
/// e as bordas ficam vermelhas.
class _OtpRow extends StatefulWidget {
  const _OtpRow({super.key});

  @override
  State<_OtpRow> createState() => _OtpRowState();
}

class _OtpRowState extends State<_OtpRow> with SingleTickerProviderStateMixin {
  static const int _length = 6;

  final _controllers = List.generate(_length, (_) => TextEditingController());
  final _nodes = List.generate(_length, (_) => FocusNode());
  late final AnimationController _shake;
  bool _error = false;

  String get code => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    for (final n in _nodes) {
      n.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  /// Devolve true se os 6 dígitos estão preenchidos; senão abana.
  bool validate() {
    final ok = code.length == _length;
    setState(() => _error = !ok);
    if (!ok) _shake.forward(from: 0);
    return ok;
  }

  void _onChanged(int i, String value) {
    if (_error) setState(() => _error = false);
    if (value.isNotEmpty && i < _length - 1) _nodes[i + 1].requestFocus();
    if (value.isEmpty && i > 0) _nodes[i - 1].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _shake,
          builder: (context, child) => Transform.translate(
            offset: Offset(-math.sin(_shake.value * 2 * math.pi * 2) * 5, 0),
            child: child,
          ),
          child: Row(
            children: [
              for (var i = 0; i < _length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: _box(i)),
              ],
            ],
          ),
        ),
        if (_error)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              'Insere os 6 dígitos do código',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _box(int i) {
    return AspectRatio(
      aspectRatio: 0.92,
      child: Container(
        decoration: BoxDecoration(
          color: KinoColors.field,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _error
                ? KinoColors.error
                : (_nodes[i].hasFocus ? Colors.black : Colors.transparent),
            width: 1.2,
          ),
        ),
        child: TextField(
          controller: _controllers[i],
          focusNode: _nodes[i],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
          ),
          onChanged: (v) => _onChanged(i, v),
        ),
      ),
    );
  }
}