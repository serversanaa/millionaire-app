import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';

class OrderService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// ✅ إنشاء طلب جديد - مُحدّث
  Future<Order> createOrder({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> orderItems,
  }) async {
    try {
      debugPrint('📝 بدء إنشاء طلب جديد...');

      // 1️⃣ إنشاء الطلب
      final orderResponse = await _supabase
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      final orderId = orderResponse['id'] as String;
      debugPrint('✅ تم إنشاء الطلب: $orderId');

      // 2️⃣ إضافة order_id لكل عنصر
      final itemsWithOrderId = orderItems.map((item) {
        return {...item, 'order_id': orderId};
      }).toList();

      // 3️⃣ إنشاء عناصر الطلب مع جلب البيانات
      final insertedItems = await _supabase
          .from('order_items')
          .insert(itemsWithOrderId)
          .select('''
            *,
            products (
              id,
              name,
              name_en,
              image_url,
              thumbnail_url,
              price,
              discount_percentage,
              final_price
            )
          ''');

      debugPrint('✅ تم إضافة ${insertedItems.length} عنصر');

      // 4️⃣ ✅ جلب الطلب الكامل مع العناصر
      final completeOrder = await getOrderById(orderId);

      debugPrint('✅ تم إنشاء الطلب الكامل: ${completeOrder.orderNumber}');
      debugPrint('📦 عدد العناصر: ${completeOrder.items?.length ?? 0}');

      return completeOrder;
    } catch (e, stackTrace) {
      debugPrint('❌ خطأ في إنشاء الطلب: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw Exception('فشل في إنشاء الطلب: $e');
    }
  }

  /// ✅ جلب طلب واحد بالتفصيل - محسّن
  Future<Order> getOrderById(String orderId) async {
    try {
      debugPrint('🔍 جلب الطلب: $orderId');

      // ✅ جلب الطلب مع العناصر والمنتجات
      final orderResponse = await _supabase
          .from('orders')
          .select('''
            *,
            order_items (
              *,
              products (
                id,
                name,
                name_en,
                image_url,
                thumbnail_url,
                price,
                discount_percentage,
                final_price
              )
            )
          ''')
          .eq('id', orderId)
          .single();

      debugPrint('✅ تم جلب الطلب بنجاح');
      debugPrint('📦 عدد order_items: ${orderResponse['order_items']?.length ?? 0}');

      final order = Order.fromJson(orderResponse);

      debugPrint('✅ Order Model - Items: ${order.items?.length ?? 0}');

      return order;
    } catch (e, stackTrace) {
      debugPrint('❌ خطأ في جلب الطلب: $e');
      debugPrintStack(stackTrace: stackTrace);
      throw Exception('فشل في جلب الطلب: $e');
    }
  }

  /// جلب جميع الطلبات (Admin فقط)
  Future<List<Order>> getAllOrders({
    String? status,
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = _supabase.from('orders').select('''
        *,
        order_items (
          *,
          products (*)
        )
      ''');

      if (status != null) {
        query = query.eq('status', status);
      }

      query = query.order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 20) - 1);
      }

      final response = await query;

      return (response as List)
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب الطلبات: $e');
    }
  }

  /// تحديث حالة الطلب
  Future<Order> updateOrderStatus(
      String orderId,
      String newStatus,
      ) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': newStatus, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', orderId);

      return await getOrderById(orderId);
    } catch (e) {
      throw Exception('فشل في تحديث حالة الطلب: $e');
    }
  }

  /// تحديث حالة الدفع
  Future<Order> updatePaymentStatus(
      String orderId,
      String paymentStatus,
      ) async {
    try {
      await _supabase
          .from('orders')
          .update({'payment_status': paymentStatus, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', orderId);

      return await getOrderById(orderId);
    } catch (e) {
      throw Exception('فشل في تحديث حالة الدفع: $e');
    }
  }

  /// إلغاء طلب
  Future<bool> cancelOrder(String orderId) async {
    try {
      await _supabase
          .from('orders')
          .update({
        'status': 'cancelled',
        'updated_at': DateTime.now().toIso8601String()
      })
          .eq('id', orderId); // ✅ استخدام UUID مباشرة

      debugPrint('✅ تم إلغاء الطلب #$orderId');
      return true;
    } catch (e) {
      debugPrint('❌ Error cancelling order: $e');
      rethrow;
    }
  }



  /// ✅ جلب طلبات المستخدم حسب رقم الهاتف
  Future<List<Order>> getUserOrdersByPhone(String customerPhone) async {
    try {
      debugPrint('🔍 جلب طلبات الهاتف: $customerPhone');

      final response = await _supabase
          .from('orders')
          .select('''
            *,
            order_items (
              *,
              products (
                id,
                name,
                name_en,
                image_url,
                thumbnail_url,
                price,
                discount_percentage,
                final_price
              )
            )
          ''')
          .eq('customer_phone', customerPhone)
          .order('created_at', ascending: false);

      debugPrint('✅ تم جلب ${response.length} طلب');

      return (response as List)
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching orders by phone: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// جلب الطلبات حسب user_id
  Future<List<Order>> getUserOrders(int userId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('''
            *,
            order_items (
              *,
              products (*)
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Order.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching orders: $e');
      rethrow;
    }
  }

}
