// import 'package:http/http.dart' as http;
// import 'package:flutter_dotenv/flutter_dotenv.dart';
//
// class WhatsAppService {
//   // ✅ قراءة API Key من ملف .env
//   static String get _apiKey => dotenv.env['WHATSAPP_API_KEY'] ?? '';
//
//   // ✅ دالة لتنظيف رقم الهاتف
//   static String _normalizePhone(String phoneNumber) {
//     String clean = phoneNumber
//         .replaceAll('+', '')
//         .replaceAll('00', '')
//         .replaceAll(' ', '')
//         .replaceAll('-', '')
//         .replaceAll('(', '')
//         .replaceAll(')', '');
//
//     if (clean.startsWith('967')) {
//       clean = clean.substring(3);
//     }
//
//     if (!clean.startsWith('7')) {
//       return clean;
//     }
//
//     return '967$clean';
//   }
//
//   // ✅ إرسال رمز التحقق
//   static Future<bool> sendVerificationCode({
//     required String phoneNumber,
//     required String code,
//   }) async {
//     try {
//       if (_apiKey.isEmpty) {
//         return false;
//       }
//
//       final cleanPhone = _normalizePhone(phoneNumber);
//
//       final message = '''
// 💈 *تطبيق المليونير للحلاقة والعناية بالرجل* 💈
// ━━━━━━━━━━━━━━━━━━
// 🔐 *رمز التحقق الخاص بك*
// ━━━━━━━━━━━━━━━━━━
//
// 🎯 *الرمز:* $code
//
// ⏱️ صالح لمدة: 15 دقيقة
// ⚠️ لا تشارك هذا الرمز مع أي شخص
//
// 📅 شكراً لاستخدامك تطبيق المليونير!
// ━━━━━━━━━━━━━━━━━━
// ''';
//
//
//       final url = Uri.parse('https://api.callmebot.com/whatsapp.php').replace(
//         queryParameters: {
//           'phone': cleanPhone,
//           'text': message,
//           'apikey': _apiKey,
//         },
//       );
//
//       final response = await http.get(url).timeout(
//         const Duration(seconds: 15),
//       );
//
//
//       if (response.statusCode == 200) {
//         if (response.body.contains('Message queued') ||
//             response.body.contains('successfully')) {
//           return true;
//         } else if (response.body.contains('APIKey is invalid')) {
//           return false;
//         } else {
//           return false;
//         }
//       } else {
//         return false;
//       }
//     } catch (e) {
//       return false;
//     }
//   }
//
//   // ✅ إرسال رسالة مخصصة
//   static Future<bool> sendCustomMessage({
//     required String phoneNumber,
//     required String message,
//   }) async {
//     try {
//       if (_apiKey.isEmpty) {
//         return false;
//       }
//
//       final cleanPhone = _normalizePhone(phoneNumber);
//
//       final customMessage = '''
// 💈 *تطبيق المليونير للحلاقة والعناية بالرجل* 💈
// ━━━━━━━━━━━━━━━━━━
// 📢 *إشعار جديد*
// ━━━━━━━━━━━━━━━━━━
//
// $message
//
// ✨ نتمنى لك يوماً أنيقاً ومشرقاً!
// ━━━━━━━━━━━━━━━━━━
// ''';
//
//       final url = Uri.parse('https://api.callmebot.com/whatsapp.php').replace(
//         queryParameters: {
//           'phone': cleanPhone,
//           'text': customMessage,
//           'apikey': _apiKey,
//         },
//       );
//
//       final response = await http.get(url).timeout(
//         const Duration(seconds: 15),
//       );
//
//       return response.statusCode == 200 &&
//           response.body.contains('Message queued');
//     } catch (e) {
//       return false;
//     }
//   }
// }



import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WhatsAppService {
  static String get _token => dotenv.env['WHAPI_TOKEN'] ?? '';
  static const String _apiUrl = 'https://gate.whapi.cloud/messages/text';

  // ═══════════════════════════════════════════════════════════
  // 📞 تنظيف رقم الهاتف
  // ═══════════════════════════════════════════════════════════
  static String _normalizePhone(String phoneNumber) {
    String clean = phoneNumber
        .replaceAll('+', '')
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('(', '')
        .replaceAll(')', '');

    // إزالة 00 من البداية
    if (clean.startsWith('00')) {
      clean = clean.substring(2);
    }

    // إذا يبدأ بـ 967 → جاهز
    if (clean.startsWith('967')) return clean;

    // إذا يبدأ بـ 7 → أضف 967
    if (clean.startsWith('7')) return '967$clean';

    return clean;
  }

  // ═══════════════════════════════════════════════════════════
  // 🔐 إرسال رمز التحقق
  // ═══════════════════════════════════════════════════════════
  static Future<bool> sendVerificationCode({
    required String phoneNumber,
    required String code,
  }) async {
    if (_token.isEmpty) return false;

    final cleanPhone = _normalizePhone(phoneNumber);

    final message =
        '💈 *تطبيق المليونير للحلاقة والعناية بالرجل* 💈\n'
        '━━━━━━━━━━━━━━━━━━\n'
        '🔐 *رمز التحقق الخاص بك*\n'
        '━━━━━━━━━━━━━━━━━━\n\n'
        '🎯 *الرمز:* $code\n\n'
        '⏱️ صالح لمدة: 15 دقيقة\n'
        '⚠️ لا تشارك هذا الرمز مع أي شخص\n\n'
        '📅 شكراً لاستخدامك تطبيق المليونير!\n'
        '━━━━━━━━━━━━━━━━━━';

    return await _sendMessage(
      phone: cleanPhone,
      message: message,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 📢 إرسال رسالة مخصصة
  // ═══════════════════════════════════════════════════════════
  static Future<bool> sendCustomMessage({
    required String phoneNumber,
    required String message,
  }) async {
    if (_token.isEmpty) return false;

    final cleanPhone = _normalizePhone(phoneNumber);

    final fullMessage =
        '💈 *تطبيق المليونير للحلاقة والعناية بالرجل* 💈\n'
        '━━━━━━━━━━━━━━━━━━\n'
        '📢 *إشعار جديد*\n'
        '━━━━━━━━━━━━━━━━━━\n\n'
        '$message\n\n'
        '✨ نتمنى لك يوماً أنيقاً ومشرقاً!\n'
        '━━━━━━━━━━━━━━━━━━';

    return await _sendMessage(
      phone: cleanPhone,
      message: fullMessage,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // 🚀 دالة الإرسال الأساسية
  // ═══════════════════════════════════════════════════════════
  static Future<bool> _sendMessage({
    required String phone,
    required String message,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'to': '$phone@s.whatsapp.net',
          'body': message,
        }),
      )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['sent'] == true || data['id'] != null;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}
