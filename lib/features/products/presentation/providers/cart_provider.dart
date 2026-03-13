import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

/// ✅ Cart Item Model
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  /// إجمالي سعر الصنف
  double get totalPrice => product.finalPrice * quantity;

  /// مبلغ الخصم للصنف
  double get discountAmount {
    if (!product.hasDiscount) return 0.0;
    return (product.price - product.finalPrice) * quantity;
  }

  /// السعر الأصلي قبل الخصم
  double get originalPrice => product.price * quantity;

  /// تحويل إلى Map
  Map<String, dynamic> toMap() {
    return {
      'product_id': product.id,
      'product_name': product.name,
      'quantity': quantity,
      'unit_price': product.finalPrice,
      'subtotal': totalPrice,
      'discount_amount': discountAmount,
      'image_url': product.imageUrl,
    };
  }
}

/// ✅ Cart Provider
class CartProvider with ChangeNotifier {
  // ✅ استخدام String بدلاً من int (لأن Product.id هو String)
  final Map<String, CartItem> _items = {};

  // ════════════════════════════════════════════════════════════
  // ✅ GETTERS
  // ════════════════════════════════════════════════════════════

  Map<String, CartItem> get items => {..._items};
  int get itemCount => _items.length;

  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  /// ✅ المجموع الفرعي
  double get subtotal {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// ✅ رسوم التوصيل
  double get deliveryFee => subtotal > 0 ? 0.0 : 0.0;

  /// ✅ الضريبة (15% VAT)
  // double get tax => subtotal * 0.15;

  /// ✅ إجمالي الخصومات
  double get totalDiscount {
    return _items.values.fold(0.0, (sum, item) => sum + item.discountAmount);
  }

  /// ✅ المجموع النهائي
  double get total => subtotal + deliveryFee ;

  /// ✅ Alias for products_screen
  double get totalPrice => total;

  /// ✅ السعر الأصلي قبل الخصومات
  double get originalTotal {
    return _items.values.fold(0.0, (sum, item) => sum + item.originalPrice);
  }

  // ════════════════════════════════════════════════════════════
  // ✅ METHODS
  // ════════════════════════════════════════════════════════════

  /// ✅ إضافة منتج إلى السلة
  void addItem(Product product, {int quantity = 1}) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += quantity;
    } else {
      _items[product.id] = CartItem(
        product: product,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  /// ✅ إزالة منتج من السلة
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  /// ✅ تحديث كمية منتج
  void updateQuantity(String productId, int newQuantity) {
    if (!_items.containsKey(productId)) return;

    if (newQuantity <= 0) {
      removeItem(productId);
    } else {
      _items[productId]!.quantity = newQuantity;
      notifyListeners();
    }
  }

  /// ✅ زيادة الكمية بمقدار 1
  void increaseQuantity(String productId) {
    if (!_items.containsKey(productId)) return;
    _items[productId]!.quantity++;
    notifyListeners();
  }

  /// ✅ تقليل الكمية بمقدار 1
  void decreaseQuantity(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity--;
      notifyListeners();
    } else {
      removeItem(productId);
    }
  }

  /// ✅ مسح السلة بالكامل
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// ✅ التحقق من وجود منتج في السلة
  bool isInCart(String productId) {
    return _items.containsKey(productId);
  }

  /// ✅ الحصول على كمية منتج معين
  int getQuantity(String productId) {
    return _items[productId]?.quantity ?? 0;
  }

  /// ✅ الحصول على CartItem معين
  CartItem? getCartItem(String productId) {
    return _items[productId];
  }

  /// ✅ تحويل عناصر السلة إلى قائمة Maps (للـ Order)
  List<Map<String, dynamic>> getOrderItems() {
    return _items.values.map((item) => item.toMap()).toList();
  }

  /// ✅ الحصول على ملخص الطلب
  Map<String, dynamic> getOrderSummary() {
    return {
      'items': getOrderItems(),
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'total_discount': totalDiscount,
      'total': total,
      'item_count': itemCount,
      'total_quantity': totalQuantity,
    };
  }

  /// ✅ التحقق من توفر المنتجات
  bool checkStock() {
    for (var item in _items.values) {
      if (!item.product.isAvailable) {
        return false;
      }
    }
    return true;
  }

  /// ✅ حساب التوفير الكلي
  double get totalSavings {
    return originalTotal - subtotal;
  }

  /// ✅ نسبة الخصم الإجمالي
  double get discountPercentage {
    if (originalTotal == 0) return 0.0;
    return (totalSavings / originalTotal) * 100;
  }

  @override
  String toString() {
    return 'CartProvider(items: ${_items.length}, total: $total)';
  }

  void printCart() {
    debugPrint('═══════════════════════════════════════');
    debugPrint('📦 Cart Summary');
    debugPrint('═══════════════════════════════════════');
    debugPrint('Items Count: $itemCount');
    debugPrint('Total Quantity: $totalQuantity');
    debugPrint('Subtotal: ${subtotal.toStringAsFixed(2)} ريال');
    debugPrint('Delivery: ${deliveryFee.toStringAsFixed(2)} ريال');
    // debugPrint('Tax (15%): ${tax.toStringAsFixed(2)} SAR');
    debugPrint('Total: ${total.toStringAsFixed(2)} ريال');
    debugPrint('═══════════════════════════════════════');

    _items.forEach((id, item) {
      debugPrint(
          '${item.product.name} x${item.quantity} = ${item.totalPrice.toStringAsFixed(2)} SAR'
      );
    });
    debugPrint('═══════════════════════════════════════');
  }
}
