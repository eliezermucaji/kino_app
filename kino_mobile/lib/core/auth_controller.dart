import 'package:flutter/material.dart';

import '../data/api.dart';
import '../models/app_user.dart';

/// Estado de sessão da app. Sem pacotes extra: é um ChangeNotifier simples.
class AuthController extends ChangeNotifier {
  AuthController._();
  static final AuthController instance = AuthController._();

  AppUser? _user;
  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;

  Future<void> login(String email, String password) async {
    _user = await Api.auth.login(email, password);
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String whatsapp,
    required String password,
  }) {
    return Api.auth.register(
      name: name,
      email: email,
      phone: phone,
      whatsapp: whatsapp,
      password: password,
    );
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}

/// Garante sessão iniciada. Se o utilizador não estiver logado, abre o
/// login e espera. Devolve true se, no fim, está logado.
///
/// Uso: `if (!await requireLogin(context)) return;`
Future<bool> requireLogin(BuildContext context) async {
  final auth = AuthController.instance;
  if (auth.isLoggedIn) return true;
  await Navigator.of(context).pushNamed('/login');
  return auth.isLoggedIn;
}
