import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/kino_theme.dart';

/// Caminhos dos assets (coloca as imagens em assets/images/).
class KinoAssets {
  static const logo = 'assets/images/kino_logo.png';
  static const iceCream = 'assets/images/ice_cream.png';
  static const cupcake = 'assets/images/cupcake.png';
  static const scribble = 'assets/images/scribble.png';
}

/// Fundo creme com as decorações (gelado, cupcake, rabisco vermelho).
class KinoScaffold extends StatelessWidget {
  final Widget child;
  final bool scribbleAtBottom;

  const KinoScaffold({
    super.key,
    required this.child,
    this.scribbleAtBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KinoColors.background,
      body: Stack(
        children: [
          if (scribbleAtBottom)
            Align(
              alignment: const Alignment(1.25, 1.1),
              child: _Deco(KinoAssets.scribble, width: 190),
            ),
          Align(
            alignment: const Alignment(-1.1, 1.05),
            child: Opacity(
              opacity: 0.35,
              child: _Deco(KinoAssets.cupcake, width: 80),
            ),
          ),
          Align(
            alignment: const Alignment(-0.9, -0.95),
            child: _Deco(KinoAssets.iceCream, width: 52),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Coloca o rabisco vermelho atrás do [child] (os campos), preso ao topo dele.
class KinoScribbleBehind extends StatelessWidget {
  final Widget child;
  const KinoScribbleBehind({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          right: -70,
          top: -35,
          child: IgnorePointer(
            child: Image.asset(
              KinoAssets.scribble,
              width: 180,
              height: 170,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _Deco extends StatelessWidget {
  final String asset;
  final double width;
  const _Deco(this.asset, {required this.width});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Image.asset(
        asset,
        width: width,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}

/// Logo + título + subtítulo.
class KinoHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const KinoHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          KinoAssets.logo,
          width: 210,
          errorBuilder: (_, __, ___) => Text(
            'kino',
            style: GoogleFonts.inter(
              fontSize: 72,
              fontWeight: FontWeight.w800,
              color: KinoColors.redDark,
            ),
          ),
        ),
        const SizedBox(height: 16),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            letterSpacing: 2,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

/// Campo de texto em "pílula" com sombra suave e validação.
///
/// Se o utilizador tentar avançar com o campo vazio:
///  - o campo abana de leve (esquerda, direita, esquerda, direita);
///  - a borda fica vermelha e o aviso (no lugar do texto) também;
///  - o texto de dica é substituído por [emptyMessage].
/// Se estiver preenchido mas inválido, o campo também abana, a borda fica
/// vermelha e a mensagem do [validator] aparece por baixo do campo.
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
    // Ao tocar no campo, o aviso de "vazio" desaparece.
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
  double _shakeOffset() {
    return -math.sin(_shake.value * 2 * math.pi * 2) * 5;
  }

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
        final highlighted = _emptyError || _errorMsg != null;

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
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: highlighted
                        ? KinoColors.error
                        : (_focus.hasFocus ? Colors.black : Colors.transparent),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 12,
                        offset: Offset(0, 6)),
                    BoxShadow(
                        color: Colors.white,
                        blurRadius: 10,
                        offset: Offset(-4, -4)),
                  ],
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
                      color: _emptyError ? KinoColors.error : Colors.black87,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: widget.icon,
                    ),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 56),
                    suffixIcon: widget.isPassword
                        ? IconButton(
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: KinoColors.eyeOrange,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 22),
                  ),
                ),
              ),
            ),
            if (_errorMsg != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
                child: Text(
                  _errorMsg!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: KinoColors.redDark,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Botão com gradiente vermelho → laranja.
class KinoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  final IconData? leadingIcon;
  final bool reversed;
  final bool compact;

  const KinoButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingIcon,
    this.leadingIcon,
    this.reversed = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      textAlign: TextAlign.center,
      style: GoogleFonts.inter(
        fontSize: compact ? 16 : 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1.1,
      ),
    );

    final Widget content = compact
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, color: Colors.white, size: 30),
                const SizedBox(width: 8),
              ],
              Flexible(child: text),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(trailingIcon, color: Colors.white, size: 30),
              ],
            ],
          )
        : Stack(
            alignment: Alignment.center,
            children: [
              text,
              if (leadingIcon != null)
                Positioned(
                  left: 26,
                  child: Icon(leadingIcon, color: Colors.white, size: 28),
                ),
              if (trailingIcon != null)
                Positioned(
                  right: 26,
                  child: Icon(trailingIcon, color: Colors.white, size: 28),
                ),
            ],
          );

    return Container(
      height: 64,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient:
            reversed ? KinoColors.gradientReversed : KinoColors.gradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
              color: Color(0x40000000), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(32),
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 0),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Linha — texto — linha (ex.: "NÃO TEM CONTA ?").
class KinoDivider extends StatelessWidget {
  final String text;
  const KinoDivider(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Colors.black, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.black),
            ),
          ),
          const Expanded(child: Divider(color: Colors.black, thickness: 1)),
        ],
      ),
    );
  }
}