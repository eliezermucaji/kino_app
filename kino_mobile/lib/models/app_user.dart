class AppUser {
  final String name;
  final String email;
  final String phone;
  final String whatsapp;

  /// Asset ou URL. Vazio = ícone de pessoa por defeito.
  final String avatar;

  const AppUser({
    required this.name,
    required this.email,
    required this.phone,
    required this.whatsapp,
    this.avatar = '',
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        name: json['name'] as String,
        email: json['email'] as String,
        phone: (json['phone'] ?? '') as String,
        whatsapp: (json['whatsapp'] ?? '') as String,
        avatar: (json['avatar'] ?? '') as String,
      );
}
