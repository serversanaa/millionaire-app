// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:millionaire_barber/features/products/data/models/order_model.dart';
// import 'package:millionaire_barber/features/products/presentation/providers/cart_provider.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../../../core/utils/receipt_compressor.dart';
// import '../models/order_item_model.dart';
// import '../../presentation/widgets/product_payment_sheet.dart';
//
// class OrderRepository {
//   final SupabaseClient _supabase = Supabase.instance.client;
//   static const String _bucket   = 'order-receipts';
//
//   // ══════════════════════════════════════════════════════
//   // ✅ إنشاء طلب جديد مع دعم الدفع الإلكتروني
//   // ══════════════════════════════════════════════════════
//   Future<Order> createOrder({
//     required int                userId,
//     required String             customerName,
//     required String             customerPhone,
//     required String             deliveryAddress,
//     required String?            deliveryNotes,
//     required double             subtotal,
//     required double             deliveryFee,
//     required double             totalAmount,
//     required List<CartItem>     cartItems,
//     required OrderPaymentResult paymentResult,
//   }) async {
//     // ✅ رفع الإيصال أولاً إن وجد
//     String? receiptUrl;
//     File?   compressedFile;
//
//     try {
//       if (paymentResult.receiptFile != null) {
//         compressedFile = await ReceiptCompressor.compress(
//             paymentResult.receiptFile!);
//         receiptUrl = await _uploadReceipt(
//           userId:   userId,
//           file:     compressedFile,
//           original: paymentResult.receiptFile!,
//         );
//       }
//
//       // ✅ بناء بيانات الطلب
//       final orderData = <String, dynamic>{
//         'user_id':              userId,
//         'customer_name':        customerName,
//         'customer_phone':       customerPhone,
//         'delivery_address':     deliveryAddress,
//         'delivery_notes':       deliveryNotes,
//         'subtotal':             subtotal,
//         'delivery_fee':         deliveryFee,
//         'tax_amount':           0.0,
//         'discount_amount':      0.0,
//         'total_amount':         totalAmount,
//         'payment_method':       paymentResult.paymentMethod,
//         'payment_status':       paymentResult.isCash ? 'unpaid' : 'under_review',
//         'delivery_method':      'home_delivery',
//         'status':               'pending',
//         'loyalty_points_used':  0,
//         'loyalty_points_earned': (totalAmount * 0.01).round(),
//         if (receiptUrl     != null) 'receipt_url':  receiptUrl,
//         if (paymentResult.wallet != null) ...{
//           'wallet_type':  paymentResult.wallet!.walletType,
//           'wallet_phone': paymentResult.wallet!.phoneNumber,
//         },
//       };
//
//       // ✅ INSERT الطلب
//       final orderResponse = await _supabase
//           .from('orders')
//           .insert(orderData)
//           .select()
//           .single();
//
//       final orderId = orderResponse['id'] as String;
//       debugPrint('✅ Order created: $orderId');
//
//       // ✅ INSERT order_items
//       final items = cartItems.map((item) => {
//         'order_id':         orderId,
//         'product_id':       item.product.id,
//         'product_name':     item.product.name,
//         'product_name_en':  item.product.nameEn ?? '',
//         'product_image_url':item.product.imageUrl,
//         'unit_price':       item.product.finalPrice,
//         'quantity':         item.quantity,
//         'discount_percentage': item.product.discountPercentage ?? 0.0,
//         'discount_amount':  0.0,
//         'subtotal':         item.product.finalPrice * item.quantity,
//         'total':            item.totalPrice,
//       }).toList();
//
//       await _supabase.from('order_items').insert(items);
//       debugPrint('✅ Inserted ${items.length} order items');
//
//       // ✅ جلب الطلب كاملاً مع العناصر
//       final fullOrder = await _supabase
//           .from('orders')
//           .select('*, order_items(*)')
//           .eq('id', orderId)
//           .single();
//
//       return Order.fromJson(fullOrder as Map<String, dynamic>);
//     } catch (e) {
//       debugPrint('❌ خطأ في إنشاء الطلب: $e');
//       rethrow;
//     } finally {
//       if (compressedFile != null && paymentResult.receiptFile != null) {
//         await ReceiptCompressor.cleanTemp(
//             compressedFile, paymentResult.receiptFile!);
//       }
//     }
//   }
//
//   // ══════════════════════════════════════════════════════
//   // رفع الإيصال إلى bucket المنتجات
//   // ══════════════════════════════════════════════════════
//   Future<String> _uploadReceipt({
//     required int  userId,
//     required File file,
//     required File original,
//   }) async {
//     final isPdf = original.path.toLowerCase().endsWith('.pdf');
//     final ext   = isPdf ? 'pdf' : 'jpg';
//     final ts    = DateTime.now().millisecondsSinceEpoch;
//     final path  = 'user_$userId/order_receipt_$ts.$ext';
//
//     try {
//       await _supabase.storage
//           .from(_bucket)
//           .upload(
//         path,
//         file,
//         fileOptions: FileOptions(
//           contentType:  isPdf ? 'application/pdf' : 'image/jpeg',
//           cacheControl: '3600',
//           upsert:       false,
//         ),
//       );
//
//       final url = _supabase.storage.from(_bucket).getPublicUrl(path);
//       debugPrint('✅ Receipt uploaded: $url');
//       return url;
//     } on StorageException catch (e) {
//       debugPrint('❌ Storage Error: ${e.message} | ${e.statusCode}');
//       rethrow;
//     }
//   }
//
//   // ══════════════════════════════════════════════════════
//   // جلب طلبات المستخدم
//   // ══════════════════════════════════════════════════════
//   Future<List<Order>> getUserOrders(int userId) async {
//     try {
//       final response = await _supabase
//           .from('orders')
//           .select('*, order_items(*, products(id,name,image_url,final_price))')
//           .eq('user_id', userId)
//           .order('created_at', ascending: false);
//
//       return (response as List)
//           .map((j) => Order.fromJson(j as Map<String, dynamic>))
//           .toList();
//     } catch (e) {
//       debugPrint('❌ خطأ في جلب الطلبات: $e');
//       return [];
//     }
//   }
//
//   // ══════════════════════════════════════════════════════
//   // جلب طلب واحد
//   // ══════════════════════════════════════════════════════
//   Future<Order?> getOrderById(String orderId) async {
//     try {
//       final response = await _supabase
//           .from('orders')
//           .select('*, order_items(*)')
//           .eq('id', orderId)
//           .single();
//       return Order.fromJson(response as Map<String, dynamic>);
//     } catch (e) {
//       return null;
//     }
//   }
//
//   // ══════════════════════════════════════════════════════
//   // إلغاء طلب
//   // ══════════════════════════════════════════════════════
//   Future<bool> cancelOrder(String orderId, {String? reason}) async {
//     try {
//       await _supabase.from('orders').update({
//         'status':              'cancelled',
//         'cancellation_reason': reason,
//         'cancelled_at':        DateTime.now().toIso8601String(),
//       }).eq('id', orderId);
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }
// }



import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:millionaire_barber/features/products/data/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:millionaire_barber/core/utils/receipt_compressor.dart';
import '../../presentation/widgets/product_payment_sheet.dart';
import '../../presentation/providers/cart_provider.dart';

class OrderRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String  _bucket  = 'order-receipts';

  // ══════════════════════════════════════════════════════
  // ✅ إنشاء طلب مع ضغط الإيصال
  // ══════════════════════════════════════════════════════
  Future<Order> createOrder({
    required int                userId,
    required String             customerName,
    required String             customerPhone,
    required String             deliveryAddress,
    required String?            deliveryNotes,
    required double             subtotal,
    required double             deliveryFee,
    required double             totalAmount,
    required List<CartItem>     cartItems,
    required OrderPaymentResult paymentResult,
  }) async {
    String? receiptUrl;
    File?   compressedFile;

    try {
      // ✅ ضغط الإيصال ورفعه إن وجد
      if (paymentResult.receiptFile != null) {
        debugPrint('🗜️ جاري ضغط الإيصال...');
        compressedFile = await ReceiptCompressor.compress(
          paymentResult.receiptFile!,
        );
        debugPrint('✅ تم الضغط: ${compressedFile.lengthSync()} bytes');

        receiptUrl = await _uploadReceipt(
          userId:   userId,
          file:     compressedFile,
          original: paymentResult.receiptFile!,
        );
      }

      // ✅ payment_status صحيح حسب طريقة الدفع
      final paymentStatus = switch (paymentResult.paymentMethod) {
        'cash'   => 'unpaid',
        'wallet' => 'under_review',
        _        => 'unpaid',
      };

      final orderData = <String, dynamic>{
        'user_id':              userId,
        'customer_name':        customerName,
        'customer_phone':       customerPhone,
        'delivery_address':     deliveryAddress,
        if (deliveryNotes != null && deliveryNotes.isNotEmpty)
          'delivery_notes':     deliveryNotes,
        'subtotal':             subtotal,
        'delivery_fee':         deliveryFee,
        'tax_amount':           0.0,
        'discount_amount':      0.0,
        'total_amount':         totalAmount,
        'payment_method':       paymentResult.paymentMethod, // 'cash' | 'wallet'
        'payment_status':       paymentStatus,               // ✅ مصحح
        'delivery_method':      'home_delivery',
        'status':               'pending',
        'loyalty_points_used':  0,
        'loyalty_points_earned': (totalAmount * 0.01).round(),
        if (receiptUrl != null)
          'receipt_url':        receiptUrl,
        if (paymentResult.wallet != null) ...{
          'wallet_type':    paymentResult.wallet!.walletType,
          'wallet_phone':   paymentResult.wallet!.phoneNumber,
          'wallet_name_ar': paymentResult.wallet!.walletNameAr,
        },
      };

      debugPrint('📦 إنشاء طلب: $orderData');

      final orderResponse = await _supabase
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      final orderId = orderResponse['id'] as String;
      debugPrint('✅ تم إنشاء الطلب: $orderId');

      // ✅ إضافة عناصر الطلب
      final items = cartItems.map((item) => {
        'order_id':          orderId,
        'product_id':        item.product.id,
        'product_name':      item.product.name,
        'product_name_en':   item.product.nameEn ?? '',
        'product_image_url': item.product.imageUrl,
        'unit_price':        item.product.finalPrice,
        'quantity':          item.quantity,
        'discount_percentage': item.product.discountPercentage ?? 0.0,
        'discount_amount':   0.0,
        'subtotal':          item.product.finalPrice * item.quantity,
        'total':             item.totalPrice,
      }).toList();

      await _supabase.from('order_items').insert(items);
      debugPrint('✅ تم إضافة ${items.length} عنصر');

      // ✅ جلب الطلب كاملاً
      final fullOrder = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', orderId)
          .single();

      return Order.fromJson(fullOrder as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ خطأ في إنشاء الطلب: $e');
      rethrow;
    } finally {
      // ✅ حذف الملف المؤقت دائماً
      if (compressedFile != null && paymentResult.receiptFile != null) {
        await ReceiptCompressor.cleanTemp(
          compressedFile,
          paymentResult.receiptFile!,
        );
        debugPrint('🧹 تم حذف الملف المؤقت');
      }
    }
  }

  // ══════════════════════════════════════════════════════
  // رفع الإيصال المضغوط
  // ══════════════════════════════════════════════════════
  Future<String> _uploadReceipt({
    required int    userId,
    required File   file,
    required File   original,
  }) async {
    final isPdf = original.path.toLowerCase().endsWith('.pdf');
    final ext   = isPdf ? 'pdf' : 'jpg';
    final ts    = DateTime.now().millisecondsSinceEpoch;
    final path  = 'user_$userId/order_receipt_$ts.$ext';

    debugPrint('⬆️ رفع الإيصال: $path');

    try {
      await _supabase.storage
          .from(_bucket)
          .upload(
        path,
        file,
        fileOptions: FileOptions(
          contentType:  isPdf ? 'application/pdf' : 'image/jpeg',
          cacheControl: '3600',
          upsert:       false,
        ),
      );

      final url = _supabase.storage.from(_bucket).getPublicUrl(path);
      debugPrint('✅ تم الرفع: $url');
      return url;
    } on StorageException catch (e) {
      debugPrint('❌ خطأ في الرفع: ${e.message} | ${e.statusCode}');
      rethrow;
    }
  }

  // ══════════════════════════════════════════════════════
  // جلب طلبات المستخدم
  // ══════════════════════════════════════════════════════
  Future<List<Order>> getUserOrders(int userId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, order_items(*, products(id,name,image_url,final_price))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((j) => Order.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ خطأ في جلب الطلبات: $e');
      return [];
    }
  }

  // ══════════════════════════════════════════════════════
  // جلب طلب واحد
  // ══════════════════════════════════════════════════════
  Future<Order?> getOrderById(String orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, order_items(*)')
          .eq('id', orderId)
          .single();
      return Order.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      debugPrint('❌ خطأ في جلب الطلب: $e');
      return null;
    }
  }

  // ══════════════════════════════════════════════════════
  // إلغاء طلب
  // ══════════════════════════════════════════════════════
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    try {
      await _supabase.from('orders').update({
        'status':              'cancelled',
        'cancellation_reason': reason,
        'cancelled_at':        DateTime.now().toIso8601String(),
      }).eq('id', orderId);
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في إلغاء الطلب: $e');
      return false;
    }
  }
}
