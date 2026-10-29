import '../../models/app_user.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

abstract class AuthRepository {
  Future<AppUser> login(String email, String password);
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String whatsapp,
    required String password,
  });
}

/// API fake. Conta de teste: danielgil@gmail.com / 123456
/// (contas criadas no registo também funcionam, até fechar a app).
class FakeAuthRepository implements AuthRepository {
  static const _delay = Duration(milliseconds: 500);

  final Map<String, ({AppUser user, String password})> _accounts = {
    'danielgil@gmail.com': (
      user: const AppUser(
        name: 'Daniel Gil',
        email: 'danielgil@gmail.com',
        phone: '999 999 999',
        whatsapp: '999 999 999',
      ),
      password: '123456',
    ),
  };

  @override
  Future<AppUser> login(String email, String password) async {
    await Future.delayed(_delay);
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const AuthException('Email ou senha incorrectos');
    }
    return account.user;
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String whatsapp,
    required String password,
  }) async {
    await Future.delayed(_delay);
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) {
      throw const AuthException('Este email já está registado');
    }
    _accounts[key] = (
      user: AppUser(name: name, email: key, phone: phone, whatsapp: whatsapp),
      password: password,
    );
  }
}
