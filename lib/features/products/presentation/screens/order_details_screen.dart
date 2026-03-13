// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../data/models/order_model.dart';
// import '../../data/models/order_item_model.dart';
// import '../providers/order_provider.dart';
//
// class OrderDetailsScreen extends StatefulWidget {
//   final Order order;
//
//   const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);
//
//   @override
//   State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
// }
//
// class _OrderDetailsScreenState extends State<OrderDetailsScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   bool _isCancelling = false;
//
//   static const String _supportPhone = '+967773999921';
//   static const Color _goldColor = Color(0xFFD4AF37);
//   static const Color _goldDark = Color(0xFFB8860B);
//
//   @override
//   void initState() {
//     super.initState();
//     _initAnimations();
//   }
//
//   void _initAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
//     );
//
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOutCubic,
//     ));
//
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   bool get _canCancelOrder {
//     final status = widget.order.status.toLowerCase();
//     return status == 'pending' || status == 'confirmed';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8FAFC),
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           _buildSliverAppBar(isDark),
//           SliverPadding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//             sliver: SliverList(
//               delegate: SliverChildListDelegate([
//                 FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: SlideTransition(
//                     position: _slideAnimation,
//                     child: Column(
//                       children: [
//                         SizedBox(height: 16.h),
//                         _buildOrderTimeline(isDark),
//                         SizedBox(height: 20.h),
//                         _buildStatusCard(isDark),
//                         SizedBox(height: 16.h),
//                         _buildOrderItemsCard(isDark),
//                         SizedBox(height: 16.h),
//                         _buildCustomerInfoCard(isDark),
//                         SizedBox(height: 16.h),
//                         _buildPricingSummaryCard(isDark),
//                         SizedBox(height: 16.h),
//                         _buildOrderInfoCard(isDark),
//                         SizedBox(height: 100.h),
//                       ],
//                     ),
//                   ),
//                 ),
//               ]),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: _buildBottomActions(isDark),
//     );
//   }
//
//   Widget _buildSliverAppBar(bool isDark) {
//     return SliverAppBar(
//       expandedHeight: 120.h,
//       floating: false,
//       pinned: true,
//       backgroundColor: isDark ? const Color(0xFF1A1A1A) : _goldColor,
//       elevation: 0,
//       leading: IconButton(
//         icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
//         onPressed: () => Navigator.pop(context),
//       ),
//       flexibleSpace: FlexibleSpaceBar(
//         centerTitle: true,
//         title: Text(
//           'طلب #${widget.order.orderNumber}',
//           style: TextStyle(
//             fontSize: 18.sp,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         background: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [_goldColor, _goldDark],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOrderTimeline(bool isDark) {
//     final statusSteps = [
//       {'status': 'pending', 'label': 'قيد الانتظار', 'icon': Icons.schedule},
//       {'status': 'confirmed', 'label': 'مؤكد', 'icon': Icons.check_circle},
//       {'status': 'preparing', 'label': 'قيد التحضير', 'icon': Icons.inventory_2},
//       {'status': 'delivered', 'label': 'مكتمل', 'icon': Icons.done_all},
//     ];
//
//     int currentStepIndex = statusSteps.indexWhere(
//           (step) => step['status'] == widget.order.status.toLowerCase(),
//     );
//     if (currentStepIndex == -1) currentStepIndex = 0;
//
//     return Container(
//       padding: EdgeInsets.all(20.w),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: isDark
//               ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
//               : [Colors.white, Colors.grey[50]!],
//         ),
//         borderRadius: BorderRadius.circular(20.r),
//         border: Border.all(
//           color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
//           width: 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: _goldColor.withValues(alpha:0.1),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'مسار الطلب',
//             style: TextStyle(
//               fontSize: 16.sp,
//               fontWeight: FontWeight.bold,
//               color: isDark ? Colors.white : Colors.black87,
//             ),
//           ),
//           SizedBox(height: 20.h),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: List.generate(statusSteps.length, (index) {
//               final isCompleted = index <= currentStepIndex;
//               final isCurrent = index == currentStepIndex;
//               final step = statusSteps[index];
//
//               return Expanded(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     AnimatedContainer(
//                       duration: const Duration(milliseconds: 500),
//                       curve: Curves.easeInOut,
//                       width: 44.w,
//                       height: 44.h,
//                       decoration: BoxDecoration(
//                         gradient: isCompleted
//                             ? const LinearGradient(
//                           colors: [_goldColor, _goldDark],
//                         )
//                             : null,
//                         color: isCompleted ? null : Colors.grey[300],
//                         shape: BoxShape.circle,
//                         boxShadow: isCurrent
//                             ? [
//                           BoxShadow(
//                             color: _goldColor.withValues(alpha:0.5),
//                             blurRadius: 15,
//                             spreadRadius: 2,
//                           ),
//                         ]
//                             : [],
//                       ),
//                       child: Icon(
//                         step['icon'] as IconData,
//                         color: isCompleted ? Colors.white : Colors.grey,
//                         size: 22.sp,
//                       ),
//                     ),
//                     SizedBox(height: 8.h),
//                     SizedBox(
//                       width: 70.w,
//                       child: Text(
//                         step['label'] as String,
//                         style: TextStyle(
//                           fontSize: 10.sp,
//                           fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
//                           color: isCompleted ? _goldColor : Colors.grey,
//                         ),
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatusCard(bool isDark) {
//     return Hero(
//       tag: 'order_status_${widget.order.id}',
//       child: Container(
//         padding: EdgeInsets.all(24.w),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               widget.order.statusColor,
//               widget.order.statusColor.withValues(alpha:0.8),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(20.r),
//           boxShadow: [
//             BoxShadow(
//               color: widget.order.statusColor.withValues(alpha:0.4),
//               blurRadius: 25,
//               offset: const Offset(0, 12),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(16.w),
//               decoration: BoxDecoration(
//                 color: Colors.white.withValues(alpha:0.25),
//                 borderRadius: BorderRadius.circular(16.r),
//               ),
//               child: Icon(
//                 widget.order.statusIcon,
//                 color: Colors.white,
//                 size: 36.sp,
//               ),
//             ),
//             SizedBox(width: 20.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'حالة الطلب',
//                     style: TextStyle(
//                       fontSize: 13.sp,
//                       color: Colors.white.withValues(alpha:0.95),
//                     ),
//                   ),
//                   SizedBox(height: 6.h),
//                   Text(
//                     widget.order.statusText,
//                     style: TextStyle(
//                       fontSize: 22.sp,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOrderItemsCard(bool isDark) {
//     return Container(
//       padding: EdgeInsets.all(20.w),
//       decoration: _cardDecoration(isDark),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(10.w),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [_goldColor.withValues(alpha:0.2), Colors.transparent],
//                       ),
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     child: Icon(Icons.shopping_bag, color: _goldColor, size: 22.sp),
//                   ),
//                   SizedBox(width: 12.w),
//                   Text(
//                     'المنتجات',
//                     style: TextStyle(
//                       fontSize: 17.sp,
//                       fontWeight: FontWeight.bold,
//                       color: isDark ? Colors.white : Colors.black87,
//                     ),
//                   ),
//                 ],
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [_goldColor.withValues(alpha:0.2), _goldColor.withValues(alpha:0.1)],
//                   ),
//                   borderRadius: BorderRadius.circular(20.r),
//                 ),
//                 child: Text(
//                   '${widget.order.items?.length ?? 0} منتج',
//                   style: TextStyle(
//                     fontSize: 13.sp,
//                     fontWeight: FontWeight.bold,
//                     color: _goldColor,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20.h),
//           if (widget.order.items != null && widget.order.items!.isNotEmpty)
//             ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: widget.order.items!.length,
//               separatorBuilder: (_, __) => SizedBox(height: 12.h),
//               itemBuilder: (context, index) {
//                 return _buildOrderItemRow(widget.order.items![index], isDark);
//               },
//             )
//           else
//             Center(
//               child: Padding(
//                 padding: EdgeInsets.all(20.h),
//                 child: Text(
//                   'لا توجد منتجات',
//                   style: TextStyle(color: Colors.grey, fontSize: 14.sp),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOrderItemRow(OrderItem item, bool isDark) {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(
//           color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 56.w,
//             height: 56.h,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [_goldColor.withValues(alpha:0.2), _goldColor.withValues(alpha:0.1)],
//               ),
//               borderRadius: BorderRadius.circular(14.r),
//             ),
//             child: Center(
//               child: Text(
//                 '×${item.quantity}',
//                 style: TextStyle(
//                   fontSize: 18.sp,
//                   fontWeight: FontWeight.bold,
//                   color: _goldColor,
//                 ),
//               ),
//             ),
//           ),
//           SizedBox(width: 16.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.productName,
//                   style: TextStyle(
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.w600,
//                     color: isDark ? Colors.white : Colors.black87,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: 6.h),
//                 Text(
//                   '${item.unitPrice.toStringAsFixed(2)} ر.ي للقطعة',
//                   style: TextStyle(
//                     fontSize: 13.sp,
//                     color: isDark ? Colors.grey[400] : Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 item.subtotal.toStringAsFixed(2),
//                 style: TextStyle(
//                   fontSize: 17.sp,
//                   fontWeight: FontWeight.bold,
//                   color: _goldColor,
//                 ),
//               ),
//               Text(
//                 'ر.ي',
//                 style: TextStyle(fontSize: 12.sp, color: _goldColor),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCustomerInfoCard(bool isDark) {
//     return Container(
//       padding: EdgeInsets.all(20.w),
//       decoration: _cardDecoration(isDark),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(10.w),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [_goldColor.withValues(alpha:0.2), Colors.transparent],
//                   ),
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//                 child: Icon(Icons.person, color: _goldColor, size: 22.sp),
//               ),
//               SizedBox(width: 12.w),
//               Text(
//                 'معلومات العميل',
//                 style: TextStyle(
//                   fontSize: 17.sp,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white : Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20.h),
//           _buildInfoRow(Icons.badge, 'الاسم', widget.order.customerName, isDark),
//           _buildDivider(isDark),
//           _buildInfoRow(Icons.phone_android, 'الجوال', widget.order.customerPhone, isDark),
//           _buildDivider(isDark),
//           _buildInfoRow(Icons.location_on, 'العنوان', widget.order.deliveryAddress, isDark),
//           if (widget.order.notes != null && widget.order.notes!.isNotEmpty) ...[
//             _buildDivider(isDark),
//             _buildInfoRow(Icons.note_alt, 'ملاحظات', widget.order.notes!, isDark),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPricingSummaryCard(bool isDark) {
//     return Container(
//       padding: EdgeInsets.all(24.w),
//       decoration: _cardDecoration(isDark),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(10.w),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [_goldColor.withValues(alpha:0.2), Colors.transparent],
//                   ),
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//                 child: Icon(Icons.receipt_long, color: _goldColor, size: 22.sp),
//               ),
//               SizedBox(width: 12.w),
//               Text(
//                 'ملخص الفاتورة',
//                 style: TextStyle(
//                   fontSize: 17.sp,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white : Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20.h),
//           _buildPriceRow('المجموع الفرعي', widget.order.subtotal, isDark),
//           SizedBox(height: 14.h),
//           _buildPriceRow('رسوم التوصيل', widget.order.deliveryFee, isDark),
//           if (widget.order.discountAmount > 0) ...[
//             SizedBox(height: 14.h),
//             _buildPriceRow('الخصم', -widget.order.discountAmount, isDark, isDiscount: true),
//           ],
//           Padding(
//             padding: EdgeInsets.symmetric(vertical: 16.h),
//             child: Divider(
//               height: 1,
//               thickness: 1.5,
//               color: isDark ? Colors.grey[800] : Colors.grey[300],
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.all(16.w),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [_goldColor.withValues(alpha:0.15), _goldColor.withValues(alpha:0.05)],
//               ),
//               borderRadius: BorderRadius.circular(16.r),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'الإجمالي',
//                   style: TextStyle(
//                     fontSize: 19.sp,
//                     fontWeight: FontWeight.bold,
//                     color: isDark ? Colors.white : Colors.black87,
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     Text(
//                       widget.order.totalAmount.toStringAsFixed(2),
//                       style: TextStyle(
//                         fontSize: 24.sp,
//                         fontWeight: FontWeight.bold,
//                         color: _goldColor,
//                       ),
//                     ),
//                     SizedBox(width: 6.w),
//                     Text(
//                       'ر.ي',
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w600,
//                         color: _goldColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOrderInfoCard(bool isDark) {
//     return Container(
//       padding: EdgeInsets.all(20.w),
//       decoration: _cardDecoration(isDark),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(10.w),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [_goldColor.withValues(alpha:0.2), Colors.transparent],
//                   ),
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//                 child: Icon(Icons.info_outline, color: _goldColor, size: 22.sp),
//               ),
//               SizedBox(width: 12.w),
//               Text(
//                 'معلومات إضافية',
//                 style: TextStyle(
//                   fontSize: 17.sp,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white : Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20.h),
//           _buildInfoRow(
//             Icons.calendar_today,
//             'تاريخ الطلب',
//             DateFormat('yyyy/MM/dd - hh:mm a', 'ar').format(widget.order.createdAt),
//             isDark,
//           ),
//           _buildDivider(isDark),
//           _buildInfoRow(Icons.payment, 'طريقة الدفع', _getPaymentMethodText(), isDark),
//           _buildDivider(isDark),
//           _buildInfoRow(Icons.verified, 'حالة الدفع', _getPaymentStatusText(), isDark),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(IconData icon, String label, String? value, bool isDark) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4.h),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: EdgeInsets.all(8.w),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [_goldColor.withValues(alpha:0.15), Colors.transparent],
//               ),
//               borderRadius: BorderRadius.circular(10.r),
//             ),
//             child: Icon(icon, size: 20.sp, color: _goldColor),
//           ),
//           SizedBox(width: 14.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 13.sp,
//                     color: isDark ? Colors.grey[400] : Colors.grey[600],
//                   ),
//                 ),
//                 SizedBox(height: 6.h),
//                 Text(
//                   value ?? 'غير متوفر',
//                   style: TextStyle(
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.w600,
//                     color: isDark ? Colors.white : Colors.black87,
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildPriceRow(String label, double amount, bool isDark, {bool isDiscount = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 15.sp,
//             color: isDark ? Colors.grey[400] : Colors.grey[700],
//           ),
//         ),
//         Text(
//           '${isDiscount ? '-' : ''}${amount.toStringAsFixed(2)} ر.ي',
//           style: TextStyle(
//             fontSize: 15.sp,
//             fontWeight: FontWeight.bold,
//             color: isDiscount ? Colors.green : (isDark ? Colors.white : Colors.black87),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDivider(bool isDark) {
//     return Divider(
//       height: 28.h,
//       color: isDark ? Colors.grey[800] : Colors.grey[300],
//     );
//   }
//
//   Widget _buildBottomActions(bool isDark) {
//     return Container(
//       padding: EdgeInsets.all(20.w),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha:0.1),
//             blurRadius: 20,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             if (_canCancelOrder) ...[
//               Expanded(
//                 child: OutlinedButton.icon(
//                   onPressed: _isCancelling ? null : _showCancelDialog,
//                   icon: _isCancelling
//                       ? SizedBox(
//                     width: 18.w,
//                     height: 18.h,
//                     child: const CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation(Colors.red),
//                     ),
//                   )
//                       : Icon(Icons.cancel_outlined, size: 20.sp),
//                   label: Text(
//                     _isCancelling ? 'جاري الإلغاء...' : 'إلغاء الطلب',
//                     style: TextStyle(fontSize: 14.sp),
//                   ),
//                   style: OutlinedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(vertical: 16.h),
//                     side: const BorderSide(color: Colors.red, width: 2),
//                     foregroundColor: Colors.red,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16.r),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(width: 12.w),
//             ],
//             Expanded(
//               flex: _canCancelOrder ? 2 : 1,
//               child: ElevatedButton.icon(
//                 onPressed: _callSupport,
//                 icon: Icon(Icons.phone, size: 22.sp),
//                 label: Text('تواصل معنا', style: TextStyle(fontSize: 16.sp)),
//                 style: ElevatedButton.styleFrom(
//                   padding: EdgeInsets.symmetric(vertical: 16.h),
//                   backgroundColor: _goldColor,
//                   foregroundColor: Colors.white,
//                   elevation: 0,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16.r),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showCancelDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
//         title: Row(
//           children: [
//             Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28.sp),
//             SizedBox(width: 12.w),
//             Text('إلغاء الطلب', style: TextStyle(fontSize: 18.sp)),
//           ],
//         ),
//         content: Text(
//           'هل أنت متأكد من إلغاء هذا الطلب؟\nلن تتمكن من التراجع عن هذا الإجراء.',
//           style: TextStyle(fontSize: 14.sp, height: 1.5),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('رجوع', style: TextStyle(color: Colors.grey[600])),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _cancelOrder();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//             ),
//             child: const Text('تأكيد الإلغاء'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _cancelOrder() async {
//     setState(() => _isCancelling = true);
//
//     try {
//       final success = await context.read<OrderProvider>().cancelOrder(widget.order.id);
//
//       if (!mounted) return;
//
//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 const Icon(Icons.check_circle, color: Colors.white),
//                 SizedBox(width: 12.w),
//                 const Text('تم إلغاء الطلب بنجاح'),
//               ],
//             ),
//             backgroundColor: Colors.green,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//           ),
//         );
//         Navigator.pop(context);
//       } else {
//         throw Exception('فشل إلغاء الطلب');
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('حدث خطأ: ${e.toString()}'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       if (mounted) setState(() => _isCancelling = false);
//     }
//   }
//
//   Future<void> _callSupport() async {
//     final Uri phoneUri = Uri(scheme: 'tel', path: _supportPhone);
//
//     try {
//       if (await canLaunchUrl(phoneUri)) {
//         await launchUrl(phoneUri);
//       } else {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('رقم الدعم الفني: $_supportPhone'),
//             duration: const Duration(seconds: 5),
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('❌ Error launching phone: $e');
//     }
//   }
//
//   BoxDecoration _cardDecoration(bool isDark) {
//     return BoxDecoration(
//       gradient: LinearGradient(
//         colors: isDark
//             ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
//             : [Colors.white, Colors.grey[50]!],
//       ),
//       borderRadius: BorderRadius.circular(20.r),
//       border: Border.all(
//         color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
//         width: 1,
//       ),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withValues(alpha:0.05),
//           blurRadius: 20,
//           offset: const Offset(0, 10),
//         ),
//       ],
//     );
//   }
//
//   String? _getPaymentMethodText() {
//     switch (widget.order.paymentMethod?.toLowerCase()) {
//       case 'cash':
//         return 'الدفع عند الاستلام';
//       case 'card':
//         return 'البطاقة الائتمانية';
//       case 'wallet':
//         return 'المحفظة الإلكترونية';
//       default:
//         return widget.order.paymentMethod ?? 'غير محدد';
//     }
//   }
//
//   String _getPaymentStatusText() {
//     final status = widget.order.paymentStatus.toLowerCase();
//
//     switch (status) {
//       case 'pending':
//         return 'قيد الانتظار ⏳';
//       case 'paid':
//         return 'مدفوع ✓';
//       case 'unpaid':
//         return 'غير مدفوع ✗'; // ✅ التعريب
//       case 'failed':
//         return 'فشل ✗';
//       case 'refunded':
//         return 'مسترجع 💵';
//       default:
//         return 'غير محدد'; // ✅ default بالعربية
//     }
//   }
//
// }



import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/order_model.dart';
import '../../data/models/order_item_model.dart';
import '../providers/order_provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isCancelling = false;

  static const String _supportPhone = '+967773999921';
  static const Color _goldColor     = Color(0xFFD4AF37);
  static const Color _goldDark      = Color(0xFFB8860B);

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _canCancelOrder {
    final status = widget.order.status.toLowerCase();
    return status == 'pending' || status == 'confirmed';
  }

  // ✅ هل الدفع إلكتروني؟
  bool get _isElectronicPayment =>
      widget.order.paymentMethod?.toLowerCase() == 'wallet';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(isDark),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        SizedBox(height: 16.h),
                        _buildOrderTimeline(isDark),
                        SizedBox(height: 20.h),
                        _buildStatusCard(isDark),
                        SizedBox(height: 16.h),
                        _buildOrderItemsCard(isDark),
                        SizedBox(height: 16.h),
                        _buildCustomerInfoCard(isDark),
                        SizedBox(height: 16.h),
                        _buildPricingSummaryCard(isDark),
                        SizedBox(height: 16.h),
                        _buildOrderInfoCard(isDark),

                        // ✅ بطاقة المحفظة والإيصال (تظهر فقط عند الدفع الإلكتروني)
                        if (_isElectronicPayment) ...[
                          SizedBox(height: 16.h),
                          _buildElectronicPaymentCard(isDark),
                        ],

                        SizedBox(height: 100.h),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(isDark),
    );
  }

  // ══════════════════════════════════════════════════════
  // ✅ بطاقة تفاصيل الدفع الإلكتروني
  // ══════════════════════════════════════════════════════
  Widget _buildElectronicPaymentCard(bool isDark) {
    final order        = widget.order;
    final hasReceipt   = order.receiptUrl != null && order.receiptUrl!.isNotEmpty;
    final walletName   = _getWalletDisplayName();
    final walletPhone  = order.walletPhone;

    return Container(
      padding:    EdgeInsets.all(20.w),
      decoration: _cardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header
          Row(
            children: [
              Container(
                padding:    EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.2),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.blue[600],
                  size:  22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'تفاصيل الدفع الإلكتروني',
                style: TextStyle(
                  fontSize:   17.sp,
                  fontWeight: FontWeight.bold,
                  color:      isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // ── اسم المحفظة
          _buildInfoRow(
            Icons.wallet_rounded,
            'المحفظة الإلكترونية',
            walletName,
            isDark,
          ),

          // ── رقم المحفظة (إن وجد)
          if (walletPhone != null && walletPhone.isNotEmpty) ...[
            _buildDivider(isDark),
            _buildInfoRow(
              Icons.phone_rounded,
              'رقم المحفظة',
              walletPhone,
              isDark,
            ),
          ],

          // ── حالة الدفع
          _buildDivider(isDark),
          _buildPaymentStatusBadge(isDark),

          // ── الإيصال
          SizedBox(height: 20.h),
          _buildReceiptSection(isDark, hasReceipt),
        ],
      ),
    );
  }

  // ✅ شارة حالة الدفع مع لون ديناميكي
  Widget _buildPaymentStatusBadge(bool isDark) {
    final status = widget.order.paymentStatus.toLowerCase();

    final config = switch (status) {
      'paid'          => (Colors.green,  Icons.check_circle_rounded,  'تم التأكيد ✓'),
      'under_review'  => (Colors.orange, Icons.hourglass_bottom_rounded, 'قيد المراجعة ⏳'),
      'unpaid'        => (Colors.red,    Icons.cancel_rounded,         'غير مدفوع ✗'),
      'refunded'      => (Colors.blue,   Icons.replay_rounded,         'مسترجع 💵'),
      _               => (Colors.grey,   Icons.info_rounded,           _getPaymentStatusText()),
    };

    return Row(
      children: [
        Container(
          padding:    EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color:        config.$1.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(config.$2, color: config.$1, size: 20.sp),
        ),
        SizedBox(width: 14.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'حالة المراجعة',
              style: TextStyle(
                fontSize: 13.sp,
                color:    isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              padding:    EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color:        config.$1.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20.r),
                border:       Border.all(
                  color: config.$1.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                config.$3,
                style: TextStyle(
                  fontSize:   13.sp,
                  fontWeight: FontWeight.bold,
                  color:      config.$1,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ✅ قسم الإيصال مع معاينة الصورة
  Widget _buildReceiptSection(bool isDark, bool hasReceipt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.receipt_long_rounded, color: _goldColor, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              'إيصال التحويل',
              style: TextStyle(
                fontSize:   15.sp,
                fontWeight: FontWeight.bold,
                color:      isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        if (hasReceipt) ...[
          // ── معاينة الإيصال
          GestureDetector(
            onTap: () => _viewReceiptFullScreen(widget.order.receiptUrl!),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl:   widget.order.receiptUrl!,
                    width:      double.infinity,
                    height:     200.h,
                    fit:        BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height:     200.h,
                      color:      isDark ? Colors.grey[800] : Colors.grey[200],
                      child:      Center(
                        child: CircularProgressIndicator(color: _goldColor),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height:     200.h,
                      decoration: BoxDecoration(
                        color:        isDark ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image_rounded,
                              color: Colors.grey, size: 40.sp),
                          SizedBox(height: 8.h),
                          Text(
                            'تعذّر تحميل الإيصال',
                            style: TextStyle(
                              color:    Colors.grey,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ── طبقة تكبير
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end:   Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12.h,
                    left:   12.w,
                    child:  Container(
                      padding:    EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color:        Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in_rounded,
                              color: Colors.white, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'اضغط للتكبير',
                            style: TextStyle(
                              color:    Colors.white,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),

          // ── زر فتح الإيصال
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openReceiptUrl(widget.order.receiptUrl!),
              icon:  Icon(Icons.open_in_new_rounded, size: 18.sp),
              label: Text('فتح الإيصال', style: TextStyle(fontSize: 14.sp)),
              style: OutlinedButton.styleFrom(
                padding:          EdgeInsets.symmetric(vertical: 12.h),
                side:             BorderSide(color: _goldColor, width: 1.5),
                foregroundColor:  _goldColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ] else ...[
          // ── لا يوجد إيصال
          Container(
            width:      double.infinity,
            padding:    EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color:        isDark
                  ? Colors.orange.withOpacity(0.08)
                  : Colors.orange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(14.r),
              border:       Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.hourglass_empty_rounded,
                    color: Colors.orange, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'لم يتم رفع إيصال التحويل بعد',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color:    Colors.orange[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════
  // عرض الإيصال بالشاشة الكاملة
  // ══════════════════════════════════════════════════════
  void _viewReceiptFullScreen(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ReceiptFullScreenViewer(imageUrl: imageUrl),
      ),
    );
  }

  Future<void> _openReceiptUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('❌ Error opening receipt: $e');
    }
  }

  // ══════════════════════════════════════════════════════
  // اسم المحفظة الإلكترونية
  // ══════════════════════════════════════════════════════
  String _getWalletDisplayName() {
    // 1️⃣ الاسم العربي المخزون مع الطلب
    if (widget.order.walletNameAr != null &&
        widget.order.walletNameAr!.isNotEmpty) {
      return widget.order.walletNameAr!;
    }

    // 2️⃣ fallback من walletType
    return switch (widget.order.walletType?.toLowerCase()) {
      'jawali'     => 'كاش',
      'floosak'  => 'فلوسك',
      'jaib' => 'جوالي',
      null       => 'محفظة إلكترونية',
      _          => widget.order.walletType ?? 'محفظة إلكترونية',
    };
  }


  // ══════════════════════════════════════════════════════
  // باقي الـ widgets (بدون تغيير)
  // ══════════════════════════════════════════════════════

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating:       false,
      pinned:         true,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : _goldColor,
      elevation:      0,
      leading: IconButton(
        icon:      Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          'طلب #${widget.order.orderNumber}',
          style: TextStyle(
            fontSize:   18.sp,
            fontWeight: FontWeight.bold,
            color:      Colors.white,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors:   [_goldColor, _goldDark],
              begin:    Alignment.topLeft,
              end:      Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTimeline(bool isDark) {
    final statusSteps = [
      {'status': 'pending',   'label': 'قيد الانتظار', 'icon': Icons.schedule},
      {'status': 'confirmed', 'label': 'مؤكد',         'icon': Icons.check_circle},
      {'status': 'preparing', 'label': 'قيد التحضير',  'icon': Icons.inventory_2},
      {'status': 'delivered', 'label': 'مكتمل',        'icon': Icons.done_all},
    ];

    int currentStepIndex = statusSteps.indexWhere(
          (step) => step['status'] == widget.order.status.toLowerCase(),
    );
    if (currentStepIndex == -1) currentStepIndex = 0;

    return Container(
      padding:    EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:      _goldColor.withOpacity(0.1),
            blurRadius: 20,
            offset:     const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مسار الطلب',
            style: TextStyle(
              fontSize:   16.sp,
              fontWeight: FontWeight.bold,
              color:      isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(statusSteps.length, (index) {
              final isCompleted = index <= currentStepIndex;
              final isCurrent   = index == currentStepIndex;
              final step        = statusSteps[index];

              return Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration:  const Duration(milliseconds: 500),
                      curve:     Curves.easeInOut,
                      width:     44.w,
                      height:    44.h,
                      decoration: BoxDecoration(
                        gradient: isCompleted
                            ? const LinearGradient(
                            colors: [_goldColor, _goldDark])
                            : null,
                        color:  isCompleted ? null : Colors.grey[300],
                        shape:  BoxShape.circle,
                        boxShadow: isCurrent
                            ? [BoxShadow(
                          color:       _goldColor.withOpacity(0.5),
                          blurRadius:  15,
                          spreadRadius: 2,
                        )]
                            : [],
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        color: isCompleted ? Colors.white : Colors.grey,
                        size:  22.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      width: 70.w,
                      child: Text(
                        step['label'] as String,
                        style: TextStyle(
                          fontSize:   10.sp,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isCompleted ? _goldColor : Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                        maxLines:  2,
                        overflow:  TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isDark) {
    return Hero(
      tag: 'order_status_${widget.order.id}',
      child: Container(
        padding:    EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.order.statusColor,
              widget.order.statusColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color:      widget.order.statusColor.withOpacity(0.4),
              blurRadius: 25,
              offset:     const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding:    EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color:        Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                widget.order.statusIcon,
                color: Colors.white,
                size:  36.sp,
              ),
            ),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حالة الطلب',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color:    Colors.white.withOpacity(0.95),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    widget.order.statusText,
                    style: TextStyle(
                      fontSize:   22.sp,
                      fontWeight: FontWeight.bold,
                      color:      Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard(bool isDark) {
    return Container(
      padding:    EdgeInsets.all(20.w),
      decoration: _cardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:    EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _goldColor.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.shopping_bag,
                        color: _goldColor, size: 22.sp),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'المنتجات',
                    style: TextStyle(
                      fontSize:   17.sp,
                      fontWeight: FontWeight.bold,
                      color:      isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding:    EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _goldColor.withOpacity(0.2),
                      _goldColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${widget.order.items?.length ?? 0} منتج',
                  style: TextStyle(
                    fontSize:   13.sp,
                    fontWeight: FontWeight.bold,
                    color:      _goldColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          if (widget.order.items != null && widget.order.items!.isNotEmpty)
            ListView.separated(
              shrinkWrap:      true,
              physics:         const NeverScrollableScrollPhysics(),
              itemCount:       widget.order.items!.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder:     (_, index) =>
                  _buildOrderItemRow(widget.order.items![index], isDark),
            )
          else
            Center(
              child: Padding(
                padding: EdgeInsets.all(20.h),
                child: Text(
                  'لا توجد منتجات',
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderItemRow(OrderItem item, bool isDark) {
    return Container(
      padding:    EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color:        isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16.r),
        border:       Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width:  56.w,
            height: 56.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _goldColor.withOpacity(0.2),
                  _goldColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Center(
              child: Text(
                '×${item.quantity}',
                style: TextStyle(
                  fontSize:   18.sp,
                  fontWeight: FontWeight.bold,
                  color:      _goldColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize:   15.sp,
                    fontWeight: FontWeight.w600,
                    color:      isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Text(
                  '${item.unitPrice.toStringAsFixed(2)} ر.ي للقطعة',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color:    isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.subtotal.toStringAsFixed(2),
                style: TextStyle(
                  fontSize:   17.sp,
                  fontWeight: FontWeight.bold,
                  color:      _goldColor,
                ),
              ),
              Text(
                'ر.ي',
                style: TextStyle(fontSize: 12.sp, color: _goldColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard(bool isDark) {
    return Container(
      padding:    EdgeInsets.all(20.w),
      decoration: _cardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:    EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_goldColor.withOpacity(0.2), Colors.transparent],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.person, color: _goldColor, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                'معلومات العميل',
                style: TextStyle(
                  fontSize:   17.sp,
                  fontWeight: FontWeight.bold,
                  color:      isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildInfoRow(Icons.badge,       'الاسم',    widget.order.customerName,    isDark),
          _buildDivider(isDark),
          _buildInfoRow(Icons.phone_android,'الجوال',  widget.order.customerPhone,   isDark),
          _buildDivider(isDark),
          _buildInfoRow(Icons.location_on, 'العنوان',  widget.order.deliveryAddress, isDark),
          if (widget.order.notes != null && widget.order.notes!.isNotEmpty) ...[
            _buildDivider(isDark),
            _buildInfoRow(Icons.note_alt,  'ملاحظات', widget.order.notes!,          isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingSummaryCard(bool isDark) {
    return Container(
      padding:    EdgeInsets.all(24.w),
      decoration: _cardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:    EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_goldColor.withOpacity(0.2), Colors.transparent],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.receipt_long, color: _goldColor, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                'ملخص الفاتورة',
                style: TextStyle(
                  fontSize:   17.sp,
                  fontWeight: FontWeight.bold,
                  color:      isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildPriceRow('المجموع الفرعي', widget.order.subtotal,    isDark),
          SizedBox(height: 14.h),
          _buildPriceRow('رسوم التوصيل',   widget.order.deliveryFee, isDark),
          if (widget.order.discountAmount > 0) ...[
            SizedBox(height: 14.h),
            _buildPriceRow('الخصم', -widget.order.discountAmount,
                isDark, isDiscount: true),
          ],
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Divider(
              height:    1,
              thickness: 1.5,
              color:     isDark ? Colors.grey[800] : Colors.grey[300],
            ),
          ),
          Container(
            padding:    EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _goldColor.withOpacity(0.15),
                  _goldColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإجمالي',
                  style: TextStyle(
                    fontSize:   19.sp,
                    fontWeight: FontWeight.bold,
                    color:      isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      widget.order.totalAmount.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize:   24.sp,
                        fontWeight: FontWeight.bold,
                        color:      _goldColor,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'ر.ي',
                      style: TextStyle(
                        fontSize:   16.sp,
                        fontWeight: FontWeight.w600,
                        color:      _goldColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(bool isDark) {
    return Container(
      padding:    EdgeInsets.all(20.w),
      decoration: _cardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:    EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_goldColor.withOpacity(0.2), Colors.transparent],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.info_outline, color: _goldColor, size: 22.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                'معلومات إضافية',
                style: TextStyle(
                  fontSize:   17.sp,
                  fontWeight: FontWeight.bold,
                  color:      isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _buildInfoRow(
            Icons.calendar_today,
            'تاريخ الطلب',
            DateFormat('yyyy/MM/dd - hh:mm a', 'ar').format(widget.order.createdAt),
            isDark,
          ),
          _buildDivider(isDark),
          _buildInfoRow(Icons.payment,  'طريقة الدفع', _getPaymentMethodText(), isDark),
          _buildDivider(isDark),
          _buildInfoRow(Icons.verified, 'حالة الدفع',  _getPaymentStatusText(), isDark),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:    EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_goldColor.withOpacity(0.15), Colors.transparent],
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 20.sp, color: _goldColor),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color:    isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  value ?? 'غير متوفر',
                  style: TextStyle(
                    fontSize:   15.sp,
                    fontWeight: FontWeight.w600,
                    color:      isDark ? Colors.white : Colors.black87,
                    height:     1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, bool isDark,
      {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            color:    isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        Text(
          '${isDiscount ? '-' : ''}${amount.toStringAsFixed(2)} ر.ي',
          style: TextStyle(
            fontSize:   15.sp,
            fontWeight: FontWeight.bold,
            color:      isDiscount
                ? Colors.green
                : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 28.h,
      color:  isDark ? Colors.grey[800] : Colors.grey[300],
    );
  }

  Widget _buildBottomActions(bool isDark) {
    return Container(
      padding:    EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset:     const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_canCancelOrder) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isCancelling ? null : _showCancelDialog,
                  icon: _isCancelling
                      ? SizedBox(
                    width:  18.w,
                    height: 18.h,
                    child:  const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:  AlwaysStoppedAnimation(Colors.red),
                    ),
                  )
                      : Icon(Icons.cancel_outlined, size: 20.sp),
                  label: Text(
                    _isCancelling ? 'جاري الإلغاء...' : 'إلغاء الطلب',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding:          EdgeInsets.symmetric(vertical: 16.h),
                    side:             const BorderSide(color: Colors.red, width: 2),
                    foregroundColor:  Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
            ],
            Expanded(
              flex: _canCancelOrder ? 2 : 1,
              child: ElevatedButton.icon(
                onPressed: _callSupport,
                icon:  Icon(Icons.phone, size: 22.sp),
                label: Text('تواصل معنا', style: TextStyle(fontSize: 16.sp)),
                style: ElevatedButton.styleFrom(
                  padding:         EdgeInsets.symmetric(vertical: 16.h),
                  backgroundColor: _goldColor,
                  foregroundColor: Colors.white,
                  elevation:       0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.orange, size: 28.sp),
            SizedBox(width: 12.w),
            Text('إلغاء الطلب', style: TextStyle(fontSize: 18.sp)),
          ],
        ),
        content: Text(
          'هل أنت متأكد من إلغاء هذا الطلب؟\nلن تتمكن من التراجع عن هذا الإجراء.',
          style: TextStyle(fontSize: 14.sp, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:     Text('رجوع',
                style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelOrder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: const Text('تأكيد الإلغاء'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrder() async {
    setState(() => _isCancelling = true);
    try {
      final success = await context
          .read<OrderProvider>()
          .cancelOrder(widget.order.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12.w),
                const Text('تم إلغاء الطلب بنجاح'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior:        SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception('فشل إلغاء الطلب');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  Future<void> _callSupport() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: _supportPhone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:  Text('رقم الدعف الفني: $_supportPhone'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error launching phone: $e');
    }
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
            : [Colors.white, Colors.grey[50]!],
      ),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(
        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color:      Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset:     const Offset(0, 10),
        ),
      ],
    );
  }

  String _getPaymentMethodText() {
    return switch (widget.order.paymentMethod?.toLowerCase()) {
      'cash'   => 'الدفع عند الاستلام 💵',
      'wallet' => 'محفظة إلكترونية — ${_getWalletDisplayName()}',
      'card'   => 'البطاقة الائتمانية 💳',
      _        => widget.order.paymentMethod ?? 'غير محدد',
    };
  }

  String _getPaymentStatusText() {
    return switch (widget.order.paymentStatus.toLowerCase()) {
      'paid'         => 'مدفوع ✓',
      'unpaid'       => 'غير مدفوع ✗',
      'under_review' => 'قيد المراجعة ⏳',
      'partial'      => 'دفع جزئي',
      'refunded'     => 'مسترجع 💵',
      _              => widget.order.paymentStatus,
    };
  }
}

// ══════════════════════════════════════════════════════════
// ✅ شاشة عرض الإيصال بالحجم الكامل
// ══════════════════════════════════════════════════════════
class _ReceiptFullScreenViewer extends StatelessWidget {
  final String imageUrl;
  const _ReceiptFullScreenViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor:  Colors.black,
        iconTheme:        const IconThemeData(color: Colors.white),
        title: const Text('إيصال التحويل',
            style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: CachedNetworkImage(
            imageUrl:    imageUrl,
            fit:         BoxFit.contain,
            placeholder: (_, __) => const CircularProgressIndicator(
              color: Color(0xFFD4AF37),
            ),
            errorWidget: (_, __, ___) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image,
                    color: Colors.grey, size: 60),
                const SizedBox(height: 12),
                const Text('تعذّر تحميل الإيصال',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
