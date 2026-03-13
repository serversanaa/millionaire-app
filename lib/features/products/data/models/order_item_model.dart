// lib/features/products/data/models/order_item_model.dart

class OrderItem {
  final int id;
  final String orderId;
  final String productId;
  final String productName;
  final String? productNameEn;
  final String? productImageUrl;
  final double unitPrice;
  final int quantity;
  final double discountPercentage;
  final double discountAmount;
  final double subtotal;
  final double total;
  final String? notes;
  final DateTime createdAt;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    this.productNameEn,
    this.productImageUrl,
    required this.unitPrice,
    required this.quantity,
    required this.discountPercentage,
    required this.discountAmount,
    required this.subtotal,
    required this.total,
    this.notes,
    required this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      productNameEn: json['product_name_en'] as String?,
      productImageUrl: json['product_image_url'] as String?,
      unitPrice: (json['unit_price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      discountPercentage: (json['discount_percentage'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'product_name_en': productNameEn,
      'product_image_url': productImageUrl,
      'unit_price': unitPrice,
      'quantity': quantity,
      'discount_percentage': discountPercentage,
      'discount_amount': discountAmount,
      'subtotal': subtotal,
      'total': total,
      'notes': notes,
    };
  }
}
