import 'package:flutter/foundation.dart';
import '../../data/models/order_model.dart';
import '../../data/services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService;

  // ✅ States محسّنة مع caching
  List<Order> _orders = [];
  List<Order> _userOrders = [];
  bool _isLoading = false;
  String? _errorMessage;
  Order? _selectedOrder;
  String? _lastFetchedPhone;

  // ✅ Getters
  List<Order> get orders => List.unmodifiable(_orders);
  List<Order> get userOrders => List.unmodifiable(_userOrders);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Order? get selectedOrder => _selectedOrder;
  bool get hasUserOrders => _userOrders.isNotEmpty;
  bool get hasOrders => _orders.isNotEmpty;

  OrderProvider({OrderService? orderService})
      : _orderService = orderService ?? OrderService();

  /// ✅ جلب طلبات المستخدم حسب رقم الهاتف
  Future<void> fetchUserOrdersByPhone(String customerPhone) async {
    // تجنب الطلبات المكررة
    if (_lastFetchedPhone == customerPhone && _userOrders.isNotEmpty) {
      debugPrint('✅ Orders already cached for phone: $customerPhone');
      return;
    }

    _setLoading(true);
    _lastFetchedPhone = customerPhone;

    try {
      final orders = await _orderService.getUserOrdersByPhone(customerPhone);
      _userOrders = orders;
      _errorMessage = null;
      debugPrint('✅ Fetched ${_userOrders.length} orders for phone: $customerPhone');
    } catch (e, stackTrace) {
      _errorMessage = 'فشل في جلب الطلبات: ${e.toString()}';
      _userOrders = [];
      debugPrint('❌ Error fetching orders: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ إنشاء طلب جديد
  Future<Order?> createOrder({
    required Map<String, dynamic> orderData,
    required List<Map<String, dynamic>> orderItems,
  }) async {
    _setLoading(true);

    try {
      final newOrder = await _orderService.createOrder(
        orderData: orderData,
        orderItems: orderItems,
      );

      if (newOrder != null) {
        _orders.insert(0, newOrder);
        _userOrders.insert(0, newOrder);
        _errorMessage = null;
      }

      return newOrder;
    } catch (e, stackTrace) {
      _errorMessage = 'فشل في إنشاء الطلب: ${e.toString()}';
      debugPrint('❌ Error creating order: $e');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ جلب طلب واحد حسب ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final order = await _orderService.getOrderById(orderId);
      if (order != null) {
        _selectedOrder = order;
        _errorMessage = null;
        notifyListeners();
      }
      return order;
    } catch (e, stackTrace) {
      _errorMessage = 'فشل في جلب الطلب: ${e.toString()}';
      debugPrint('❌ Error fetching order: $e');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  /// ✅ جلب جميع الطلبات (Admin)
  Future<void> fetchAllOrders({
    String? status,
    int? limit,
    int? offset,
  }) async {
    _setLoading(true);

    try {
      _orders = await _orderService.getAllOrders(
        status: status,
        limit: limit,
        offset: offset,
      );
      _errorMessage = null;
    } catch (e, stackTrace) {
      _errorMessage = 'فشل في جلب الطلبات: ${e.toString()}';
      _orders = [];
      debugPrint('❌ Error fetching all orders: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ تحديث حالة الطلب
  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    // Optimistic update
    final originalOrders = List<Order>.from(_orders);
    final originalUserOrders = List<Order>.from(_userOrders);

    _updateOrderInListsOptimistic(
      orderId,
          (order) => order.copyWith(status: newStatus),
    );

    try {
      final updatedOrder = await _orderService.updateOrderStatus(
        orderId,
        newStatus,
      );

      if (updatedOrder != null) {
        _updateOrderInLists(updatedOrder);
        _errorMessage = null;
        return true;
      } else {
        // Rollback
        _orders = originalOrders;
        _userOrders = originalUserOrders;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      _errorMessage = 'فشل في تحديث حالة الطلب: ${e.toString()}';
      // Rollback
      _orders = originalOrders;
      _userOrders = originalUserOrders;
      debugPrint('❌ Error updating order status: $e');
      debugPrintStack(stackTrace: stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// ✅ تحديث حالة الدفع
  Future<bool> updatePaymentStatus(String orderId, String paymentStatus) async {
    final originalOrders = List<Order>.from(_orders);
    final originalUserOrders = List<Order>.from(_userOrders);

    _updateOrderInListsOptimistic(
      orderId,
          (order) => order.copyWith(paymentStatus: paymentStatus),
    );

    try {
      final updatedOrder = await _orderService.updatePaymentStatus(
        orderId,
        paymentStatus,
      );

      if (updatedOrder != null) {
        _updateOrderInLists(updatedOrder);
        _errorMessage = null;
        return true;
      } else {
        _orders = originalOrders;
        _userOrders = originalUserOrders;
        notifyListeners();
        return false;
      }
    } catch (e, stackTrace) {
      _errorMessage = 'فشل في تحديث حالة الدفع: ${e.toString()}';
      _orders = originalOrders;
      _userOrders = originalUserOrders;
      debugPrint('❌ Error updating payment status: $e');
      debugPrintStack(stackTrace: stackTrace);
      notifyListeners();
      return false;
    }
  }

  /// ✅ إلغاء طلب
  Future<bool> cancelOrder(String orderId) async {
    try {
      final success = await _orderService.cancelOrder(orderId);

      if (success) {
        // ✅ استخدام copyWith بدلاً من Order الجديد
        final index = _userOrders.indexWhere((order) => order.id == orderId);

        if (index != -1) {
          _userOrders[index] = _userOrders[index].copyWith(
            status: 'cancelled',
            cancelledAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      debugPrint('❌ Error in cancelOrder: $e');
      return false;
    }
  }

  /// ✅ فلترة الطلبات حسب الحالة
  List<Order> getOrdersByStatus(String status) {
    return List.unmodifiable(
      _userOrders.where((order) => order.status == status),
    );
  }

  /// ✅ اختيار طلب
  void selectOrder(Order? order) {
    _selectedOrder = order;
    notifyListeners();
  }

  /// ✅ مسح الأخطاء
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// ✅ إعادة تحميل الطلبات (للـ Pull to Refresh)
  Future<void> refreshOrders() async {
    if (_lastFetchedPhone != null) {
      _lastFetchedPhone = null; // إعادة تعيين الكاش
      await fetchUserOrdersByPhone(_lastFetchedPhone!);
    }
  }

  /// ✅ إعادة تعيين الحالة
  void reset() {
    _orders = [];
    _userOrders = [];
    _selectedOrder = null;
    _errorMessage = null;
    _lastFetchedPhone = null;
    _isLoading = false;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════
  // 🔧 PRIVATE METHODS
  // ═══════════════════════════════════════════════════════════

  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void _updateOrderInLists(Order updatedOrder) {
    final orderIndex = _orders.indexWhere((o) => o.id == updatedOrder.id);
    if (orderIndex != -1) {
      _orders[orderIndex] = updatedOrder;
    }

    final userOrderIndex = _userOrders.indexWhere((o) => o.id == updatedOrder.id);
    if (userOrderIndex != -1) {
      _userOrders[userOrderIndex] = updatedOrder;
    }

    if (_selectedOrder?.id == updatedOrder.id) {
      _selectedOrder = updatedOrder;
    }

    notifyListeners();
  }

  void _updateOrderInListsOptimistic(
      String orderId,
      Order Function(Order) updater,
      ) {
    final orderIndex = _orders.indexWhere((o) => o.id == orderId);
    if (orderIndex != -1) {
      _orders[orderIndex] = updater(_orders[orderIndex]);
    }

    final userOrderIndex = _userOrders.indexWhere((o) => o.id == orderId);
    if (userOrderIndex != -1) {
      _userOrders[userOrderIndex] = updater(_userOrders[userOrderIndex]);
    }

    notifyListeners();
  }
}
