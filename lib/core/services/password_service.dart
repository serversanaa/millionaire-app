import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordService {
  /// ✅ تشفير كلمة المرور باستخدام SHA-256
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// ✅ التحقق من تطابق كلمة المرور مع الهاش
  static bool verifyPassword(String password, String hashedPassword) {
    final hash = hashPassword(password);
    return hash == hashedPassword;
  }

  /// ✅ التحقق من قوة كلمة المرور
  static bool isPasswordStrong(String password) {
    // على الأقل 8 أحرف، تحتوي على حرف كبير وصغير ورقم
    if (password.length < 8) return false;

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));

    return hasUppercase && hasLowercase && hasDigit;
  }

  /// ✅ الحصول على رسالة قوة كلمة المرور
  static String getPasswordStrengthMessage(String password) {
    if (password.isEmpty) return '';
    if (password.length < 8) return 'كلمة المرور قصيرة جداً (8 أحرف على الأقل)';

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));

    if (!hasUppercase) return 'يجب أن تحتوي على حرف كبير';
    if (!hasLowercase) return 'يجب أن تحتوي على حرف صغير';
    if (!hasDigit) return 'يجب أن تحتوي على رقم';

    return 'كلمة مرور قوية ✓';
  }
}
