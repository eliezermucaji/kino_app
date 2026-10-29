import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/kino_theme.dart';

/// Caminhos dos assets (coloca as imagens em assets/images/).
class KinoAssets {
  static const logo = 'assets/images/kino_logo.png';
}

/// Ícone laranja para dentro dos campos.
Widget kinoFieldIcon(IconData icon) =>
    Icon(icon, color: KinoColors.panel, size: 26);

/// Estrutura das telas de autenticação:
/// topo creme com o logótipo + painel laranja com cantos arredondados.
class KinoAuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget body;
  final Widget footer;

  const KinoAuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final topHeight = screenHeight * 0.46;

    return Scaffold(
      backgroundColor: KinoColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: topHeight,
              width: double.infinity,
              child: Align(
                alignment: const Alignment(0, 0.45),
                child: Image.asset(
                  KinoAssets.logo,
                  width: 150,
                  errorBuilder: (_, __, ___) => Text(
                    'kino',
                    style: GoogleFonts.inter(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: KinoColors.redDark,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: screenHeight - topHeight),
              padding: EdgeInsets.fromLTRB(32, 40, 32, 28 + bottomInset),
              decoration: const BoxDecoration(
                color: KinoColors.panel,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  body,
                  const SizedBox(height: 18),
                  Center(child: footer),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Botão creme com texto laranja.
class KinoPanelButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const KinoPanelButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KinoColors.field,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: SizedBox(
          height: 46,
          width: double.infinity,
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: KinoColors.panel,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Texto do rodapé com ligação, ex.: "Já tem conta ? **Faça Login**".
class KinoFooterLink extends StatelessWidget {
  final String text;
  final String action;
  final VoidCallback onTap;

  const KinoFooterLink({
    super.key,
    required this.text,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.inter(fontSize: 15, color: Colors.white);
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('$text ', style: style),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: style.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

/// Campo de texto creme com validação.
///
/// - A escrever: borda preta fina.
/// - Vazio ao avançar: abana, borda vermelha e o aviso ([emptyMessage])
///   aparece a vermelho no lugar do texto.
/// - Preenchido mas inválido: abana, borda vermelha e a mensagem do
///   [validator] aparece por baixo do campo.
class KinoTextField extends StatefulWidget {
  final String hint;
  final String emptyMessage;
  final Widget icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isPassword;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const KinoTextField({
    super.key,
    required this.hint,
    required this.icon,
    this.emptyMessage = 'Campo Inválido',
    this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.inputFormatters,
    this.validator,
  });

  @override
  State<KinoTextField> createState() => _KinoTextFieldState();
}

class _KinoTextFieldState extends State<KinoTextField>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final bool _ownsController;
  final FocusNode _focus = FocusNode();
  late final AnimationController _shake;

  bool _obscure = true;
  bool _emptyError = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _focus.addListener(() {
      setState(() {
        if (_focus.hasFocus) _emptyError = false;
      });
    });
  }

  @override
  void dispose() {
    _shake.dispose();
    _focus.dispose();
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  String? _validate(String? _) {
    final text = _controller.text;
    final isEmpty = widget.isPassword ? text.isEmpty : text.trim().isEmpty;

    if (isEmpty) {
      _emptyError = true;
      _errorMsg = null;
      _shake.forward(from: 0);
      return widget.emptyMessage; // não nulo => o Form fica inválido
    }

    _emptyError = false;
    _errorMsg = widget.validator?.call(text);
    if (_errorMsg != null) _shake.forward(from: 0);
    return _errorMsg;
  }

  /// Esquerda → direita → esquerda → direita (2 ciclos), leve e rápido.
  double _shakeOffset() => -math.sin(_shake.value * 2 * math.pi * 2) * 5;

  void _clearErrors() {
    if (_emptyError || _errorMsg != null) {
      setState(() {
        _emptyError = false;
        _errorMsg = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: _validate,
      builder: (_) {
        final hasError = _emptyError || _errorMsg != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedBuilder(
              animation: _shake,
              builder: (context, child) => Transform.translate(
                offset: Offset(_shakeOffset(), 0),
                child: child,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: KinoColors.field,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasError
                        ? KinoColors.error
                        : (_focus.hasFocus ? Colors.black : Colors.transparent),
                    width: 1.2,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  obscureText: widget.isPassword && _obscure,
                  onChanged: (_) => _clearErrors(),
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.black),
                  decoration: InputDecoration(
                    hintText: _emptyError ? widget.emptyMessage : widget.hint,
                    hintStyle: GoogleFonts.inter(
                      fontSize: 16,
                      color: _emptyError
                          ? KinoColors.error
                          : const Color(0xFF6B6B6B),
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: widget.icon,
                    ),
                    prefixIconConstraints: const BoxConstraints(minWidth: 52),
                    suffixIcon: widget.isPassword
                        ? IconButton(
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: KinoColors.panel,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            if (_errorMsg != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 8, 0),
                child: Text(
                  _errorMsg!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}