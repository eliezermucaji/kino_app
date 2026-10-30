import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/auth_controller.dart';
import '../core/kino_theme.dart';
import '../models/app_user.dart';
import '../widgets/kino_app_widgets.dart';
import 'orders_screen.dart';

class ProfileScreen extends StatelessWidget {
  /// Seta de voltar (no shell volta à Home).
  final VoidCallback? onBack;

  /// Chamado depois de sair da conta.
  final VoidCallback? onLoggedOut;

  const ProfileScreen({super.key, this.onBack, this.onLoggedOut});

  /// 999999998 -> "999 999 998" (a API guarda sem espaços).
  String _phone(String raw) {
    final d = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length != 9) return raw;
    return '${d.substring(0, 3)} ${d.substring(3, 6)} ${d.substring(6)}';
  }

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Em breve')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthController.instance.user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 22, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  KinoBackArrow(onTap: onBack),
                  GestureDetector(
                    onTap: () => _soon(context),
                    child: const Icon(
                      Icons.settings,
                      color: KinoColors.panel,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            _avatar(user),
            Expanded(
              child: Container(
                width: double.infinity,
                color: KinoColors.panel,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 24),
                  child: Column(
                    children: [
                      _Field(label: 'Nome', value: user.name),
                      _Field(label: 'Email', value: user.email),
                      _Field(label: 'Telefone', value: _phone(user.phone)),
                      _Field(label: 'Whatsapp', value: _phone(user.whatsapp)),
                      const _Field(label: 'Senha', value: '*********'),
                      _historyRow(context),
                      const SizedBox(height: 16),
                      _buttons(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Avatar quadrado com moldura creme que "morde" o painel laranja.
  Widget _avatar(AppUser user) {
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          top: 60,
          child: Container(
            decoration: const BoxDecoration(
              color: KinoColors.panel,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(36),
                topRight: Radius.circular(36),
              ),
            ),
          ),
        ),
        Center(
          child: Container(
            width: 130,
            height: 130,
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: KinoColors.background,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
                bottom: Radius.circular(28),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: user.avatar.isEmpty
                  ? Container(
                      color: const Color(0xFFD9D9D9),
                      child: const Icon(
                        Icons.person_outline,
                        size: 90,
                        color: KinoColors.panel,
                      ),
                    )
                  : KinoImage(user.avatar),
            ),
          ),
        ),
      ],
    );
  }

  Widget _historyRow(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OrdersScreen()),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Histórico de Pedidos',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buttons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => _soon(context),
              icon: const Icon(Icons.edit_note, color: KinoColors.panel),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Editar Perfil',
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: KinoColors.panel,
                  ),
                ),
              ),
              iconAlignment: IconAlignment.end,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFBE9BF),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                AuthController.instance.logout();
                onLoggedOut?.call();
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: Text(
                'Sair',
                style: GoogleFonts.inter(fontSize: 15, color: Colors.white),
              ),
              iconAlignment: IconAlignment.end,
              style: ElevatedButton.styleFrom(
                backgroundColor: KinoColors.redDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Campo só de leitura com o rótulo em cima da borda.
class _Field extends StatelessWidget {
  final String label;
  final String value;
  const _Field({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: 52,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0x80FFFFFF), width: 1.5),
            ),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: -11,
            child: Container(
              color: KinoColors.panel,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xCCFFFFFF),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
