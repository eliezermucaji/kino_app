import 'package:flutter/services.dart';

/// Validações reutilizáveis. O caso "campo vazio" é tratado pelo
/// KinoTextField (abanão + borda escura + aviso no lugar do texto),
/// por isso aqui só validamos o formato de valores já preenchidos.
class KinoValidators {
  static const int phoneLength = 9;

  /// Só permite dígitos de 0 a 9, no máximo 9, e agrupa de 3 em 3
  /// (ex.: 923 456 789).
  static List<TextInputFormatter> get phoneFormatters => [
        KinoPhoneFormatter(),
      ];

  /// Remove espaços e devolve só os dígitos (usa isto ao enviar para a API).
  static String digitsOnly(String value) =>
      value.replaceAll(RegExp(r'[^0-9]'), '');

  /// Telefone / WhatsApp: exatamente 9 dígitos (os espaços de
  /// formatação são ignorados).
  static String? phone(String? value) {
    final v = (value ?? '').replaceAll(' ', '');

    if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
      return 'Usa apenas números de 0 a 9';
    }
    if (v.length < phoneLength) {
      final missing = phoneLength - v.length;
      return 'Número incompleto: falta${missing == 1 ? '' : 'm'} '
          '$missing dígito${missing == 1 ? '' : 's'}';
    }
    if (v.length > phoneLength) {
      return 'Número demasiado longo: máximo $phoneLength dígitos';
    }
    return null;
  }

  /// Email: um único "@", texto antes, domínio com ponto, sem espaços.
  static String? email(String? value) {
    final v = value ?? '';

    if (v != v.trim()) {
      return 'O email não pode ter espaços no início ou no fim';
    }
    if (RegExp(r'\s').hasMatch(v)) {
      return 'O email não pode conter espaços';
    }

    final atCount = '@'.allMatches(v).length;
    if (atCount == 0) return 'O email deve conter o símbolo @';
    if (atCount > 1) return 'O email deve ter apenas um @';

    final parts = v.split('@');
    final user = parts[0];
    final domain = parts[1];

    if (user.isEmpty) return 'Falta o texto antes do @';
    if (domain.isEmpty) return 'Falta o domínio depois do @ (ex.: gmail.com)';
    if (!domain.contains('.')) {
      return 'O domínio deve conter um ponto (ex.: gmail.com)';
    }

    final valid = RegExp(r'^[^\s@]+@([^\s@.]+\.)+[^\s@.]{2,}$').hasMatch(v);
    if (!valid) return 'Domínio inválido (ex.: gmail.com, outlook.com, .ao)';

    return null;
  }

  /// Senha: mínimo de 6 caracteres.
  static String? password(String? value) {
    if ((value ?? '').length < 6) return 'Mínimo 6 caracteres';
    return null;
  }
}

/// Formata o número como "923 456 789": só dígitos, máximo 9,
/// com um espaço a cada 3 dígitos. Se o número for colado com o indicativo
/// de Angola (+244 / 00244), o indicativo é removido.
class KinoPhoneFormatter extends TextInputFormatter {
  static const int maxDigits = 9;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final nonDigit = RegExp(r'[^0-9]');

    var digits = newValue.text.replaceAll(nonDigit, '');
    final oldDigits = oldValue.text.replaceAll(nonDigit, '');

    final cursor = newValue.selection.baseOffset.clamp(0, newValue.text.length);
    var digitsBeforeCursor =
        newValue.text.substring(0, cursor).replaceAll(nonDigit, '').length;

    // Backspace em cima de um espaço: apagaria só o espaço (que é
    // recolocado) e o cursor ficava preso. Apaga o dígito anterior.
    final deletedOnlySpace = newValue.text.length < oldValue.text.length &&
        digits.length == oldDigits.length &&
        digitsBeforeCursor > 0;
    if (deletedOnlySpace) {
      digits = digits.substring(0, digitsBeforeCursor - 1) +
          digits.substring(digitsBeforeCursor);
      digitsBeforeCursor -= 1;
    }

    // Número colado/preenchido de uma vez com indicativo de Angola
    // (+244 923 456 789, 00244923456789, 244923456789): remove o indicativo.
    if (oldDigits.isEmpty && digits.length > maxDigits) {
      if (digits.startsWith('00244')) {
        digits = digits.substring(5);
        digitsBeforeCursor = digits.length;
      } else if (digits.startsWith('244')) {
        digits = digits.substring(3);
        digitsBeforeCursor = digits.length;
      }
    }

    if (digits.length > maxDigits) {
      digits = digits.substring(0, maxDigits);
    }
    if (digitsBeforeCursor > digits.length) {
      digitsBeforeCursor = digits.length;
    }

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }

    final d = digitsBeforeCursor;
    final offset = d == 0 ? 0 : d + (d - 1) ~/ 3;

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}