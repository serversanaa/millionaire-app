// import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
//
// class ConnectivityService {
//   final Connectivity _connectivity = Connectivity();
//
//   // StreamController الآن لقائمة
//   StreamController<List<ConnectivityResult>> connectionStatusController =
//   StreamController<List<ConnectivityResult>>.broadcast();
//
//   ConnectivityService() {
//     _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
//       connectionStatusController.add(results);
//     });
//   }
//
//   // Future لقائمة من النتائج
//   Future<List<ConnectivityResult>> checkConnectivity() async {
//     return await _connectivity.checkConnectivity();
//   }
//
//   Stream<List<ConnectivityResult>> get connectionChange =>
//       connectionStatusController.stream;
//
//   void dispose() {
//     connectionStatusController.close();
//   }
// }


import 'dart:async';
import 'dart:io';

enum ConnectionQuality { none, unstable, stable }

class ConnectionService {
  // ✅ عدة خوادم للفحص — إذا فشل أحدها ينتقل للتالي
  static const List<Map<String, dynamic>> _checkHosts = [
    {'host': '8.8.8.8',   'port': 53},   // Google DNS
    {'host': '1.1.1.1',   'port': 53},   // Cloudflare DNS
    {'host': '208.67.222.222', 'port': 53}, // OpenDNS
  ];

  // ✅ الحد الفاصل بالميلي ثانية
  static const int _unstableThreshold = 1200; // مناسب لشبكات اليمن
  static const int _timeoutSeconds = 5;

  // ═══════════════════════════════════════════════════════
  // 🔍 فحص جودة الاتصال
  // ═══════════════════════════════════════════════════════
  static Future<ConnectionQuality> checkQuality() async {
    // ✅ جرّب كل خادم — أول نجاح يرجع النتيجة
    for (final target in _checkHosts) {
      final quality = await _checkHost(
        host: target['host'] as String,
        port: target['port'] as int,
      );

      // إذا كان none → جرّب الخادم التالي
      if (quality != ConnectionQuality.none) {
        return quality;
      }
    }

    // ✅ كل الخوادم فشلت → لا يوجد اتصال
    return ConnectionQuality.none;
  }

  // ═══════════════════════════════════════════════════════
  // 🔌 فحص خادم واحد
  // ═══════════════════════════════════════════════════════
  static Future<ConnectionQuality> _checkHost({
    required String host,
    required int port,
  }) async {
    try {
      final stopwatch = Stopwatch()..start();

      final socket = await Socket.connect(
        host,
        port,
        timeout: Duration(seconds: _timeoutSeconds),
      );

      stopwatch.stop();
      socket.destroy();

      final ms = stopwatch.elapsedMilliseconds;

      if (ms < _unstableThreshold) return ConnectionQuality.stable;
      return ConnectionQuality.unstable;
    } on SocketException {
      return ConnectionQuality.none;
    } on TimeoutException {
      return ConnectionQuality.none;
    } catch (_) {
      return ConnectionQuality.none;
    }
  }

  // ═══════════════════════════════════════════════════════
  // 📊 فحص متعدد للدقة (اختياري — للعمليات الحساسة)
  // ═══════════════════════════════════════════════════════
  static Future<ConnectionQuality> checkQualityAccurate() async {
    final results = <ConnectionQuality>[];

    // ✅ فحص 3 مرات وأخذ الأغلبية
    for (int i = 0; i < 3; i++) {
      results.add(await checkQuality());
      await Future.delayed(const Duration(milliseconds: 200));
    }

    final noneCount     = results.where((r) => r == ConnectionQuality.none).length;
    final unstableCount = results.where((r) => r == ConnectionQuality.unstable).length;
    final stableCount   = results.where((r) => r == ConnectionQuality.stable).length;

    if (stableCount >= 2)   return ConnectionQuality.stable;
    if (unstableCount >= 2) return ConnectionQuality.unstable;
    if (noneCount >= 2)     return ConnectionQuality.none;

    return ConnectionQuality.unstable;
  }
}
