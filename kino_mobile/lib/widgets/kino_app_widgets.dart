import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/kino_theme.dart';

/// Imagem de asset ou de URL, com fundo neutro se falhar a carregar
/// (útil enquanto as fotos ainda não estão em assets/images/).
class KinoImage extends StatelessWidget {
  final String src;
  final BoxFit fit;

  const KinoImage(this.src, {super.key, this.fit = BoxFit.cover});

  Widget _fallback() => Container(
        color: const Color(0xFFE9DFC3),
        alignment: Alignment.center,
        child: const Icon(Icons.fastfood, color: KinoColors.panel, size: 36),
      );

  @override
  Widget build(BuildContext context) {
    if (src.isEmpty) return _fallback();
    if (src.startsWith('http')) {
      return Image.network(
        src,
        fit: fit,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return Image.asset(
      src,
      fit: fit,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }
}

/// Seta laranja de voltar, como nos desenhos.
class KinoBackArrow extends StatelessWidget {
  final VoidCallback? onTap;
  const KinoBackArrow({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      child: const Padding(
        padding: EdgeInsets.all(8),
        child: Icon(Icons.arrow_back, color: KinoColors.panel, size: 36),
      ),
    );
  }
}

/// Barra inferior laranja com cantos de cima arredondados.
class KinoBottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const KinoBottomBar({super.key, required this.index, required this.onTap});

  static const _icons = [
    Icons.home_outlined,
    Icons.search,
    Icons.receipt_long_outlined,
    Icons.person_outline,
    Icons.storefront_outlined,
  ];
  static const _labels = ['Home', 'Pesquisar', 'Pedidos', 'Perfil', 'Loja'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: KinoColors.panel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < _icons.length; i++)
                _item(i, selected: i == index),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int i, {required bool selected}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(i),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // creme opaco se seleccionado, ~70% se não
                color: selected
                    ? KinoColors.background
                    : const Color(0xB3F7F2DE),
              ),
              child: Icon(_icons[i], color: KinoColors.panel, size: 26),
            ),
            const SizedBox(height: 2),
            Text(
              _labels[i],
              maxLines: 1,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado de carregamento / erro / vazio para listas vindas da API.
class KinoMessage extends StatelessWidget {
  final String text;
  final VoidCallback? onRetry;

  const KinoMessage(this.text, {super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: KinoColors.panel,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                child: const Text('Tentar de novo'),
              ),
          ],
        ),
      ),
    );
  }
}
