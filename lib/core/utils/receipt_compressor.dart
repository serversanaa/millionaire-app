// lib/core/utils/receipt_compressor.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ReceiptCompressor {
  static const int _quality       = 72;
  static const int _minWidth      = 1280;
  static const int _minHeight     = 1280;
  static const int _maxFileSizeKB = 800;

  static Future<File> compress(File file) async {
    final ext    = file.path.split('.').last.toLowerCase();
    if (ext == 'pdf') return file;

    final sizeKB = await file.length() / 1024;
    if (sizeKB <= _maxFileSizeKB) {
      debugPrint('✅ الملف صغير (${sizeKB.toInt()} KB) لا حاجة للضغط');
      return file;
    }

    debugPrint('🗜️ جاري ضغط الإيصال: ${sizeKB.toInt()} KB');

    try {
      final tempDir    = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/receipt_compressed_'
          '${DateTime.now().millisecondsSinceEpoch}.jpg';

      // ✅ الإصلاح: file.absolute.path بدلاً من file.absolutePath
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality:   _adaptiveQuality(sizeKB),
        minWidth:  _minWidth,
        minHeight: _minHeight,
        format:    CompressFormat.jpeg,
        keepExif:  false,
      );

      if (result == null) return file;

      final compressed     = File(result.path);
      final compressedSize = await compressed.length() / 1024;

      debugPrint(
        '✅ تم الضغط: ${sizeKB.toInt()} KB → ${compressedSize.toInt()} KB '
            '(وفّر ${((1 - compressedSize / sizeKB) * 100).toInt()}%)',
      );

      return compressed;
    } catch (e) {
      debugPrint('❌ خطأ في الضغط: $e');
      return file;
    }
  }

  static int _adaptiveQuality(double sizeKB) {
    if (sizeKB > 5000) return 55;
    if (sizeKB > 3000) return 62;
    if (sizeKB > 1500) return 68;
    return _quality;
  }

  static Future<void> cleanTemp(File compressed, File original) async {
    try {
      if (compressed.path != original.path &&
          await compressed.exists()) {
        await compressed.delete();
        debugPrint('🧹 تم حذف الملف المؤقت');
      }
    } catch (_) {}
  }
}
