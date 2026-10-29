import 'package:flutter/material.dart';

import '../core/auth_controller.dart';
import '../widgets/kino_app_widgets.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'store_screen.dart';

/// Ecrã principal com a barra inferior. A app abre aqui, na Home.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  static const _home = 0, _search = 1, _orders = 2, _profile = 3, _store = 4;

  final _auth = AuthController.instance;
  int _index = _home;

  /// Pedidos e Perfil exigem sessão: sem ela, abre o login primeiro.
  Future<void> _go(int i) async {
    if (i == _orders || i == _profile) {
      if (!await requireLogin(context)) return;
      if (!mounted) return;
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _auth,
      builder: (context, _) {
        // Se a sessão terminar numa aba protegida, volta à Home.
        final protected = _index == _orders || _index == _profile;
        final index = (!_auth.isLoggedIn && protected) ? _home : _index;

        return Scaffold(
          body: switch (index) {
            _home => HomeScreen(onSearchTap: () => _go(_search)),
            _search => const SearchScreen(),
            _orders => OrdersScreen(onBack: () => _go(_home)),
            _profile => ProfileScreen(
                onBack: () => _go(_home),
                onLoggedOut: () => setState(() => _index = _home),
              ),
            _ => const StoreScreen(),
          },
          bottomNavigationBar: KinoBottomBar(index: index, onTap: _go),
        );
      },
    );
  }
}
