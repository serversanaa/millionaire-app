// import 'package:flutter/material.dart';
// import 'package:millionaire_barber/features/profile/presentation/providers/user_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import '../providers/order_provider.dart';
// import '../../data/models/order_model.dart';
// import 'order_details_screen.dart';
//
// // ✅ Enum للحالات
// enum OrderStatus {
//   all,
//   pending,
//   confirmed,
//   processing,
//   shipped,
//   delivered,
//   cancelled,
// }
//
// extension OrderStatusExtension on OrderStatus {
//   String get label {
//     switch (this) {
//       case OrderStatus.all:
//         return 'الكل';
//       case OrderStatus.pending:
//         return 'قيد الانتظار';
//       case OrderStatus.confirmed:
//         return 'مؤكد';
//       case OrderStatus.processing:
//         return 'قيد التحضير';
//       case OrderStatus.shipped:
//         return 'قيد الشحن';
//       case OrderStatus.delivered:
//         return 'مكتمل';
//       case OrderStatus.cancelled:
//         return 'ملغي';
//     }
//   }
//
//   IconData get icon {
//     switch (this) {
//       case OrderStatus.all:
//         return Icons.list_alt;
//       case OrderStatus.pending:
//         return Icons.schedule;
//       case OrderStatus.confirmed:
//         return Icons.check_circle_outline;
//       case OrderStatus.processing:
//         return Icons.inventory_2_outlined;
//       case OrderStatus.shipped:
//         return Icons.local_shipping_outlined;
//       case OrderStatus.delivered:
//         return Icons.done_all;
//       case OrderStatus.cancelled:
//         return Icons.cancel_outlined;
//     }
//   }
//
//   String get statusValue => name;
// }
//
// class OrdersListScreen extends StatefulWidget {
//   const OrdersListScreen({Key? key}) : super(key: key);
//
//   @override
//   State<OrdersListScreen> createState() => _OrdersListScreenState();
// }
//
// class _OrdersListScreenState extends State<OrdersListScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final List<OrderStatus> _statusFilters = OrderStatus.values;
//   String? _errorMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _statusFilters.length, vsync: this);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadOrders();
//     });
//   }
//
//   Future<void> _loadOrders() async {
//     try {
//       final userProvider = Provider.of<UserProvider>(context, listen: false);
//       final user = userProvider.user;
//
//       if (user == null || user.phone == null || user.phone!.isEmpty) {
//         if (mounted) {
//           setState(() => _errorMessage = 'لم يتم العثور على بيانات المستخدم');
//         }
//         return;
//       }
//
//       debugPrint('🔍 جلب طلبات المستخدم: ${user.phone}');
//
//       if (!mounted) return;
//
//       await context.read<OrderProvider>().fetchUserOrdersByPhone(user.phone!);
//
//       // ✅ تحديث الحالة بعد التحميل
//       if (mounted) {
//         setState(() {
//           _errorMessage = null;
//         });
//       }
//     } catch (e, stackTrace) {
//       debugPrint('❌ Error loading orders: $e');
//       debugPrintStack(stackTrace: stackTrace);
//       if (mounted) {
//         setState(() => _errorMessage = e.toString());
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor:
//           isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
//       appBar: _buildAppBar(isDark),
//       body: Column(
//         children: [
//           // ✅ Tabs ثابت
//           _buildTabBar(isDark),
//
//           // ✅ المحتوى
//           Expanded(
//             child: Consumer<OrderProvider>(
//               builder: (context, orderProvider, _) {
//                 debugPrint(
//                     '🔄 Rebuilding with orders: ${orderProvider.userOrders.length}');
//
//                 if (orderProvider.isLoading) {
//                   return _buildLoadingState();
//                 }
//
//                 if (orderProvider.errorMessage != null) {
//                   return _buildErrorState(orderProvider.errorMessage!, isDark);
//                 }
//
//                 return TabBarView(
//                   controller: _tabController,
//                   children: _statusFilters.map((status) {
//                     final orders = status == OrderStatus.all
//                         ? orderProvider.userOrders
//                         : orderProvider.getOrdersByStatus(status.statusValue);
//
//                     debugPrint(
//                         '📋 Tab ${status.label}: ${orders.length} orders');
//
//                     if (orders.isEmpty) {
//                       return _buildEmptyState(status, isDark);
//                     }
//
//                     return RefreshIndicator(
//                       onRefresh: _loadOrders,
//                       color: const Color(0xFFD4AF37),
//                       backgroundColor:
//                           isDark ? const Color(0xFF1E1E1E) : Colors.white,
//                       child: ListView.builder(
//                         padding: EdgeInsets.all(16.w),
//                         physics: const AlwaysScrollableScrollPhysics(),
//                         itemCount: orders.length,
//                         itemBuilder: (context, index) {
//                           return _buildOrderCard(orders[index], isDark);
//                         },
//                       ),
//                     );
//                   }).toList(),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ✅ AppBar
//   PreferredSizeWidget _buildAppBar(bool isDark) {
//     return AppBar(
//       backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
//       elevation: 0,
//       centerTitle: true,
//       leading: IconButton(
//         onPressed: () => Navigator.pop(context),
//         icon: Container(
//           padding: EdgeInsets.all(8.w),
//           decoration: BoxDecoration(
//             color: const Color(0xFFD4AF37).withValues(alpha:0.1),
//             borderRadius: BorderRadius.circular(12.r),
//           ),
//           child: Icon(
//             Icons.arrow_back_ios_new,
//             size: 18.sp,
//             color: const Color(0xFFD4AF37),
//           ),
//         ),
//       ),
//       title: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             Icons.shopping_bag_outlined,
//             color: const Color(0xFFD4AF37),
//             size: 24.sp,
//           ),
//           SizedBox(width: 8.w),
//           Text(
//             'طلباتي',
//             style: TextStyle(
//               fontSize: 20.sp,
//               fontWeight: FontWeight.bold,
//               color: isDark ? Colors.white : Colors.black87,
//               fontFamily: 'Cairo',
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ✅ TabBar
//   Widget _buildTabBar(bool isDark) {
//     return Container(
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
//         border: Border(
//           bottom: BorderSide(
//             color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
//             width: 1,
//           ),
//         ),
//       ),
//       child: TabBar(
//         controller: _tabController,
//         isScrollable: true,
//         physics: const BouncingScrollPhysics(),
//         indicatorColor: const Color(0xFFD4AF37),
//         indicatorWeight: 3.h,
//         indicatorSize: TabBarIndicatorSize.label,
//         labelColor: const Color(0xFFD4AF37),
//         unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
//         labelStyle: TextStyle(
//           fontSize: 14.sp,
//           fontWeight: FontWeight.w700,
//           fontFamily: 'Cairo',
//         ),
//         unselectedLabelStyle: TextStyle(
//           fontSize: 13.sp,
//           fontWeight: FontWeight.w500,
//         ),
//         labelPadding: EdgeInsets.symmetric(horizontal: 16.w),
//         tabs: _statusFilters.map((status) {
//           return Tab(
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(status.icon, size: 18.sp),
//                 SizedBox(width: 6.w),
//                 Text(status.label),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
//
//   // ✅ كارت الطلب المصحح
//   Widget _buildOrderCard(Order order, bool isDark) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => OrderDetailsScreen(order: order),
//           ),
//         );
//       },
//       child: Container(
//         margin: EdgeInsets.only(bottom: 16.h),
//         decoration: BoxDecoration(
//           color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//           borderRadius: BorderRadius.circular(20.r),
//           border: Border.all(
//             color: isDark
//                 ? Colors.white.withValues(alpha:0.05)
//                 : Colors.black.withValues(alpha:0.03),
//             width: 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: const Color(0xFFD4AF37).withValues(alpha:0.08),
//               blurRadius: 20,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(20.r),
//           child: Column(
//             children: [
//               // ✅ Header
//               Container(
//                 padding: EdgeInsets.all(16.w),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       const Color(0xFFD4AF37).withValues(alpha:0.1),
//                       const Color(0xFFD4AF37).withValues(alpha:0.03),
//                     ],
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     // الأيقونة
//                     Container(
//                       width: 50.w,
//                       height: 50.w,
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFFD4AF37), Color(0xFFF4E5B2)],
//                         ),
//                         borderRadius: BorderRadius.circular(14.r),
//                       ),
//                       child: Icon(
//                         Icons.receipt_long_rounded,
//                         color: Colors.white,
//                         size: 26.sp,
//                       ),
//                     ),
//                     SizedBox(width: 12.w),
//
//                     // ✅ معلومات الطلب مع Flexible
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'طلب #${order.orderNumber}',
//                             style: TextStyle(
//                               fontSize: 14.sp,
//                               fontWeight: FontWeight.bold,
//                               color: isDark ? Colors.white : Colors.black87,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                           SizedBox(height: 4.h),
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.access_time_rounded,
//                                 size: 13.sp,
//                                 color: const Color(0xFFD4AF37),
//                               ),
//                               SizedBox(width: 4.w),
//                               Flexible(
//                                 child: Text(
//                                   _formatDate(order.createdAt),
//                                   style: TextStyle(
//                                     fontSize: 11.sp,
//                                     color: isDark
//                                         ? Colors.grey[400]
//                                         : Colors.grey[600],
//                                   ),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//
//                     // ✅ حالة الطلب
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 10.w,
//                         vertical: 6.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: order.statusColor.withValues(alpha:0.15),
//                         borderRadius: BorderRadius.circular(10.r),
//                         border: Border.all(
//                           color: order.statusColor.withValues(alpha:0.3),
//                           width: 1,
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             order.statusIcon,
//                             size: 14.sp,
//                             color: order.statusColor,
//                           ),
//                           SizedBox(width: 4.w),
//                           Text(
//                             order.statusText,
//                             style: TextStyle(
//                               fontSize: 11.sp,
//                               fontWeight: FontWeight.w700,
//                               color: order.statusColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // ✅ محتوى الطلب
//               Padding(
//                 padding: EdgeInsets.all(16.w),
//                 child: Column(
//                   children: [
//                     // معلومات الطلب
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildInfoRow(
//                             Icons.inventory_2_rounded,
//                             '${order.items?.length ?? 0} منتج',
//                             isDark,
//                           ),
//                         ),
//                         SizedBox(width: 12.w),
//                         Expanded(
//                           flex: 2,
//                           child: _buildInfoRow(
//                             Icons.location_on_rounded,
//                             order.deliveryAddress,
//                             isDark,
//                             maxLines: 1,
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     SizedBox(height: 16.h),
//                     Divider(
//                       height: 1,
//                       color: isDark ? Colors.grey[800] : Colors.grey[300],
//                     ),
//                     SizedBox(height: 16.h),
//
//                     // المجموع
//                     Row(
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'المبلغ الإجمالي',
//                               style: TextStyle(
//                                 fontSize: 12.sp,
//                                 color: isDark
//                                     ? Colors.grey[400]
//                                     : Colors.grey[600],
//                               ),
//                             ),
//                             SizedBox(height: 4.h),
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text(
//                                   order.totalAmount.toStringAsFixed(0),
//                                   style: TextStyle(
//                                     fontSize: 22.sp,
//                                     fontWeight: FontWeight.bold,
//                                     color: const Color(0xFFD4AF37),
//                                     height: 1,
//                                   ),
//                                 ),
//                                 SizedBox(width: 4.w),
//                                 Padding(
//                                   padding: EdgeInsets.only(bottom: 2.h),
//                                   child: Text(
//                                     'ر.ي',
//                                     style: TextStyle(
//                                       fontSize: 13.sp,
//                                       fontWeight: FontWeight.w600,
//                                       color: const Color(0xFFD4AF37),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         const Spacer(),
//                         Container(
//                           padding: EdgeInsets.all(10.w),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFD4AF37).withValues(alpha:0.1),
//                             borderRadius: BorderRadius.circular(12.r),
//                           ),
//                           child: Icon(
//                             Icons.arrow_forward_ios_rounded,
//                             color: const Color(0xFFD4AF37),
//                             size: 16.sp,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(IconData icon, String text, bool isDark,
//       {int maxLines = 1}) {
//     return Row(
//       children: [
//         Container(
//           padding: EdgeInsets.all(6.w),
//           decoration: BoxDecoration(
//             color: const Color(0xFFD4AF37).withValues(alpha:0.1),
//             borderRadius: BorderRadius.circular(8.r),
//           ),
//           child: Icon(
//             icon,
//             size: 14.sp,
//             color: const Color(0xFFD4AF37),
//           ),
//         ),
//         SizedBox(width: 6.w),
//         Expanded(
//           child: Text(
//             text,
//             style: TextStyle(
//               fontSize: 12.sp,
//               color: isDark ? Colors.grey[300] : Colors.grey[700],
//               fontWeight: FontWeight.w500,
//             ),
//             maxLines: maxLines,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLoadingState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const CircularProgressIndicator(color: Color(0xFFD4AF37)),
//           SizedBox(height: 16.h),
//           Text(
//             'جاري تحميل الطلبات...',
//             style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmptyState(OrderStatus status, bool isDark) {
//     String message = status == OrderStatus.all
//         ? 'لم تقم بأي طلبات بعد'
//         : 'لا توجد طلبات ${status.label}';
//
//     return Center(
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.receipt_long_outlined,
//               size: 80.sp,
//               color: Colors.grey[400],
//             ),
//             SizedBox(height: 16.h),
//             Text(
//               message,
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[600],
//               ),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               'ابدأ بالتسوق الآن!',
//               style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildErrorState(String error, bool isDark) {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.all(24.w),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 70.sp, color: Colors.red[300]),
//             SizedBox(height: 16.h),
//             Text(
//               'حدث خطأ',
//               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               error,
//               style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 24.h),
//             ElevatedButton(
//               onPressed: _loadOrders,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFD4AF37),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//               ),
//               child: const Text('إعادة المحاولة'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
//
//     if (difference.inDays == 0) {
//       if (difference.inHours == 0) {
//         return 'منذ ${difference.inMinutes} دقيقة';
//       }
//       return 'منذ ${difference.inHours} ساعة';
//     } else if (difference.inDays == 1) {
//       return 'أمس';
//     } else if (difference.inDays < 7) {
//       return 'منذ ${difference.inDays} أيام';
//     }
//
//     return DateFormat('d/M/yyyy', 'ar').format(date);
//   }
// }


import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:millionaire_barber/features/profile/presentation/providers/user_provider.dart';
import '../providers/order_provider.dart';
import '../../data/models/order_model.dart';
import 'order_details_screen.dart';

// ══════════════════════════════════════════════════════════════════
// ENUM
// ══════════════════════════════════════════════════════════════════
enum OrderStatus {
  all,
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.all:        return 'الكل';
      case OrderStatus.pending:    return 'قيد الانتظار';
      case OrderStatus.confirmed:  return 'مؤكد';
      case OrderStatus.processing: return 'قيد التحضير';
      case OrderStatus.shipped:    return 'قيد الشحن';
      case OrderStatus.delivered:  return 'مكتمل';
      case OrderStatus.cancelled:  return 'ملغي';
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.all:        return Icons.list_alt;
      case OrderStatus.pending:    return Icons.schedule;
      case OrderStatus.confirmed:  return Icons.check_circle_outline;
      case OrderStatus.processing: return Icons.inventory_2_outlined;
      case OrderStatus.shipped:    return Icons.local_shipping_outlined;
      case OrderStatus.delivered:  return Icons.done_all;
      case OrderStatus.cancelled:  return Icons.cancel_outlined;
    }
  }

  String get statusValue => name;
}

// ══════════════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════════════
class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({Key? key}) : super(key: key);

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen>
    with SingleTickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────────
  late TabController _tabController;

  // ── State ─────────────────────────────────────────────────────────
  final List<OrderStatus> _statusFilters = OrderStatus.values;
  String? _errorMessage;

  // ── فلتر التاريخ ─────────────────────────────────────────────────
  DateTime? _filterFromDate;
  DateTime? _filterToDate;

  // ── تصدير ────────────────────────────────────────────────────────
  bool _isExporting = false;

  // ── فحص وجود فلتر نشط ────────────────────────────────────────────
  bool get _hasDateFilter => _filterFromDate != null || _filterToDate != null;

  // ══════════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ══════════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusFilters.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════
  // DATA LOADING
  // ══════════════════════════════════════════════════════════════════
  Future<void> _loadOrders() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;

      if (user == null || user.phone == null || user.phone!.isEmpty) {
        if (mounted) setState(() => _errorMessage = 'لم يتم العثور على بيانات المستخدم');
        return;
      }

      debugPrint('🔍 جلب طلبات المستخدم: ${user.phone}');
      if (!mounted) return;

      await context.read<OrderProvider>().fetchUserOrdersByPhone(user.phone!);

      if (mounted) setState(() => _errorMessage = null);
    } catch (e, st) {
      debugPrint('❌ Error loading orders: $e');
      debugPrintStack(stackTrace: st);
      if (mounted) setState(() => _errorMessage = e.toString());
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // FILTER LOGIC
  // ══════════════════════════════════════════════════════════════════
  List<Order> _applyDateFilter(List<Order> list) {
    if (!_hasDateFilter) return list;

    return list.where((o) {
      final d = DateTime(o.createdAt.year, o.createdAt.month, o.createdAt.day);

      if (_filterFromDate != null) {
        final from = DateTime(
            _filterFromDate!.year, _filterFromDate!.month, _filterFromDate!.day);
        if (d.isBefore(from)) return false;
      }

      if (_filterToDate != null) {
        final to = DateTime(
            _filterToDate!.year, _filterToDate!.month, _filterToDate!.day,
            23, 59, 59);
        if (d.isAfter(to)) return false;
      }

      return true;
    }).toList();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now    = DateTime.now();

    final initial = isFrom
        ? (_filterFromDate ?? now.subtract(const Duration(days: 7)))
        : (_filterToDate   ?? now);

    final picked = await showDatePicker(
      context:     context,
      initialDate: initial,
      firstDate:   DateTime(2020),
      lastDate:    DateTime(now.year + 1),
      locale:      const Locale('ar'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor:  const Color(0xFFD4AF37),
            brightness: isDark ? Brightness.dark : Brightness.light,
          ),
        ),
        child: child!,
      ),
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (isFrom) {
        _filterFromDate = picked;
        if (_filterToDate != null && picked.isAfter(_filterToDate!)) {
          _filterToDate = picked;
        }
      } else {
        _filterToDate = picked;
        if (_filterFromDate != null && picked.isBefore(_filterFromDate!)) {
          _filterFromDate = picked;
        }
      }
    });
  }

  void _clearDateFilter() => setState(() {
    _filterFromDate = null;
    _filterToDate   = null;
  });

  // ══════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
        isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF8F9FA),
        appBar: _buildAppBar(isDark),
        body: Column(
          children: [
            // ── شريط الفلترة ──────────────────────────────────────
            _buildFilterBar(isDark),

            // ── التابات ───────────────────────────────────────────
            _buildTabBar(isDark),

            // ── المحتوى ───────────────────────────────────────────
            Expanded(
              child: Consumer<OrderProvider>(
                builder: (context, orderProvider, _) {
                  if (orderProvider.isLoading) return _buildLoadingState();

                  if (orderProvider.errorMessage != null) {
                    return _buildErrorState(orderProvider.errorMessage!, isDark);
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: _statusFilters.map((status) {
                      final raw = status == OrderStatus.all
                          ? orderProvider.userOrders
                          : orderProvider.getOrdersByStatus(status.statusValue);

                      final orders = _applyDateFilter(raw);

                      if (orders.isEmpty) return _buildEmptyState(status, isDark);

                      return RefreshIndicator(
                        onRefresh:       _loadOrders,
                        color:           const Color(0xFFD4AF37),
                        backgroundColor: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.white,
                        child: ListView.builder(
                          padding:  EdgeInsets.all(16.w),
                          physics:  const AlwaysScrollableScrollPhysics(),
                          itemCount: orders.length,
                          itemBuilder: (_, i) =>
                              _buildOrderCard(orders[i], isDark),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // APP BAR (مع زر التصدير فقط)
  // ══════════════════════════════════════════════════════════════════
  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      elevation:       0,
      centerTitle:     true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding:    EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color:        const Color(0xFFD4AF37).withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(Icons.arrow_back_ios_new,
              size: 18.sp, color: const Color(0xFFD4AF37)),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined,
              color: const Color(0xFFD4AF37), size: 24.sp),
          SizedBox(width: 8.w),
          Text(
            'طلباتي',
            style: TextStyle(
              fontSize:   20.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
      // ── زر التصدير في الـ AppBar ──────────────────────────────
      actions: [
        if (_hasDateFilter)
          IconButton(
            tooltip:  'مسح فلتر التاريخ',
            onPressed: _clearDateFilter,
            icon: Container(
              padding:    EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color:        Colors.orange.withValues(alpha:0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.filter_alt_off_rounded,
                  size: 18.sp, color: Colors.orange),
            ),
          ),
        IconButton(
          tooltip:  'تصدير / طباعة',
          onPressed: _isExporting ? null : _showExportSheet,
          icon: _isExporting
              ? SizedBox(
            width: 20.w,
            height: 20.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFD4AF37),
            ),
          )
              : Container(
            padding:    EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color:        const Color(0xFFD4AF37).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.file_download_rounded,
                size: 20.sp, color: const Color(0xFFD4AF37)),
          ),
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // FILTER BAR (يظهر دائماً تحت الـ AppBar)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildFilterBar(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // ── أيقونة فلتر التاريخ ───────────────────────────────
          Container(
            padding:    EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color:        const Color(0xFFD4AF37).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.date_range_rounded,
                size: 16.sp, color: const Color(0xFFD4AF37)),
          ),
          SizedBox(width: 8.w),

          // ── من تاريخ ──────────────────────────────────────────
          Expanded(
            child: _buildDateChip(
              label:    _filterFromDate != null
                  ? DateFormat('dd/MM/yyyy').format(_filterFromDate!)
                  : 'من تاريخ',
              isActive: _filterFromDate != null,
              isDark:   isDark,
              onTap:    () => _pickDate(isFrom: true),
            ),
          ),

          SizedBox(width: 8.w),
          Icon(Icons.arrow_left_rounded,
              color: Colors.grey.shade400, size: 20.sp),
          SizedBox(width: 8.w),

          // ── إلى تاريخ ─────────────────────────────────────────
          Expanded(
            child: _buildDateChip(
              label:    _filterToDate != null
                  ? DateFormat('dd/MM/yyyy').format(_filterToDate!)
                  : 'إلى تاريخ',
              isActive: _filterToDate != null,
              isDark:   isDark,
              onTap:    () => _pickDate(isFrom: false),
            ),
          ),

          // ── زر مسح الفلتر ─────────────────────────────────────
          if (_hasDateFilter) ...[
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: _clearDateFilter,
              child: Container(
                padding:    EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color:  Colors.red.withValues(alpha:0.1),
                  shape:  BoxShape.circle,
                ),
                child: Icon(Icons.close_rounded,
                    size: 14.sp, color: Colors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateChip({
    required String       label,
    required bool         isActive,
    required bool         isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFD4AF37).withValues(alpha:0.1)
              : (isDark ? const Color(0xFF0A0A0A) : Colors.grey[100]),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isActive
                ? const Color(0xFFD4AF37)
                : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size:  12.sp,
              color: isActive
                  ? const Color(0xFFD4AF37)
                  : Colors.grey.shade500,
            ),
            SizedBox(width: 5.w),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize:   11.sp,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? const Color(0xFFD4AF37)
                      : (isDark ? Colors.grey[400] : Colors.grey[700]),
                  fontFamily: 'Cairo',
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // TAB BAR (بدون تغيير)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildTabBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller:             _tabController,
        isScrollable:           true,
        physics:                const BouncingScrollPhysics(),
        indicatorColor:         const Color(0xFFD4AF37),
        indicatorWeight:        3.h,
        indicatorSize:          TabBarIndicatorSize.label,
        labelColor:             const Color(0xFFD4AF37),
        unselectedLabelColor:   isDark ? Colors.grey[400] : Colors.grey[600],
        labelStyle: TextStyle(
          fontSize:   14.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Cairo',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize:   13.sp,
          fontWeight: FontWeight.w500,
        ),
        labelPadding: EdgeInsets.symmetric(horizontal: 16.w),
        tabs: _statusFilters.map((status) {
          return Tab(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(status.icon, size: 18.sp),
              SizedBox(width: 6.w),
              Text(status.label),
            ]),
          );
        }).toList(),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // ORDER CARD (بدون تغيير)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildOrderCard(Order order, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => OrderDetailsScreen(order: order)),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color:        isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha:0.05)
                : Colors.black.withValues(alpha:0.03),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color:      const Color(0xFFD4AF37).withValues(alpha:0.08),
              blurRadius: 20,
              offset:     const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Column(children: [
            // ── Header ───────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  const Color(0xFFD4AF37).withValues(alpha: 0.1),
                  const Color(0xFFD4AF37).withValues(alpha:0.03),
                ]),
              ),
              child: Row(children: [
                Container(
                  width:  50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFF4E5B2)]),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(Icons.receipt_long_rounded,
                      color: Colors.white, size: 26.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طلب #${order.orderNumber}',
                        style: TextStyle(
                          fontSize:   14.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(children: [
                        Icon(Icons.access_time_rounded,
                            size: 13.sp, color: const Color(0xFFD4AF37)),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            _formatDate(order.createdAt),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
                // ── الحالة ───────────────────────────────────────
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: order.statusColor.withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                        color: order.statusColor.withValues(alpha:0.3), width: 1),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(order.statusIcon,
                        size: 14.sp, color: order.statusColor),
                    SizedBox(width: 4.w),
                    Text(
                      order.statusText,
                      style: TextStyle(
                        fontSize:   11.sp,
                        fontWeight: FontWeight.w700,
                        color:      order.statusColor,
                      ),
                    ),
                  ]),
                ),
              ]),
            ),

            // ── Body ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(children: [
                Row(children: [
                  Expanded(
                    child: _buildInfoRow(
                      Icons.inventory_2_rounded,
                      '${order.items?.length ?? 0} منتج',
                      isDark,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 2,
                    child: _buildInfoRow(
                      Icons.location_on_rounded,
                      order.deliveryAddress,
                      isDark,
                      maxLines: 1,
                    ),
                  ),
                ]),
                SizedBox(height: 16.h),
                Divider(height: 1,
                    color: isDark ? Colors.grey[800] : Colors.grey[300]),
                SizedBox(height: 16.h),
                // ── المجموع ──────────────────────────────────────
                Row(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المبلغ الإجمالي',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            order.totalAmount.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize:   22.sp,
                              fontWeight: FontWeight.bold,
                              color:      const Color(0xFFD4AF37),
                              height:     1,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: Text(
                              'ر.ي',
                              style: TextStyle(
                                fontSize:   13.sp,
                                fontWeight: FontWeight.w600,
                                color:      const Color(0xFFD4AF37),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding:    EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color:        const Color(0xFFD4AF37).withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(Icons.arrow_forward_ios_rounded,
                        color: const Color(0xFFD4AF37), size: 16.sp),
                  ),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isDark,
      {int maxLines = 1}) {
    return Row(children: [
      Container(
        padding:    EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color:        const Color(0xFFD4AF37).withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 14.sp, color: const Color(0xFFD4AF37)),
      ),
      SizedBox(width: 6.w),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize:   12.sp,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }

  // ══════════════════════════════════════════════════════════════════
  // LOADING / EMPTY / ERROR STATES (بدون تغيير)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildLoadingState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const CircularProgressIndicator(color: Color(0xFFD4AF37)),
        SizedBox(height: 16.h),
        Text('جاري تحميل الطلبات...',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
      ]),
    );
  }

  Widget _buildEmptyState(OrderStatus status, bool isDark) {
    final message = _hasDateFilter
        ? 'لا توجد طلبات في الفترة المحددة'
        : (status == OrderStatus.all
        ? 'لم تقم بأي طلبات بعد'
        : 'لا توجد طلبات ${status.label}');

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.receipt_long_outlined,
              size: 80.sp, color: Colors.grey[400]),
          SizedBox(height: 16.h),
          Text(message,
              style: TextStyle(
                fontSize:   16.sp,
                fontWeight: FontWeight.w600,
                color:      Colors.grey[600],
              )),
          SizedBox(height: 8.h),
          Text(
            _hasDateFilter
                ? 'جرّب تغيير نطاق التاريخ'
                : 'ابدأ بالتسوق الآن!',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
          ),
          if (_hasDateFilter) ...[
            SizedBox(height: 16.h),
            TextButton.icon(
              onPressed: _clearDateFilter,
              icon: const Icon(Icons.filter_alt_off_rounded,
                  color: Color(0xFFD4AF37)),
              label: Text(
                'مسح فلتر التاريخ',
                style: TextStyle(
                    color: const Color(0xFFD4AF37),
                    fontSize: 13.sp,
                    fontFamily: 'Cairo'),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _buildErrorState(String error, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error_outline, size: 70.sp, color: Colors.red[300]),
          SizedBox(height: 16.h),
          Text('حدث خطأ',
              style: TextStyle(
                  fontSize: 18.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 8.h),
          Text(error,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
              textAlign: TextAlign.center),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _loadOrders,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // DATE FORMATTER
  // ══════════════════════════════════════════════════════════════════
  String _formatDate(DateTime date) {
    final now        = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) return 'منذ ${difference.inMinutes} دقيقة';
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    }
    return DateFormat('d/M/yyyy', 'ar').format(date);
  }

  // ══════════════════════════════════════════════════════════════════
  // EXPORT BOTTOM SHEET
  // ══════════════════════════════════════════════════════════════════
  void _showExportSheet() {
    final orderProvider = context.read<OrderProvider>();
    final filtered      = _applyDateFilter(orderProvider.userOrders);
    final isDark        = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: SafeArea(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // ── Handle ───────────────────────────────────────────
              Container(
                width: 40.w, height: 4.h,
                decoration: BoxDecoration(
                  color:        Colors.grey[500],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),

              // ── Title ────────────────────────────────────────────
              Row(children: [
                Container(
                  padding:    EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color:        const Color(0xFFD4AF37).withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.receipt_long_rounded,
                      color: const Color(0xFFD4AF37), size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تصدير طلباتي',
                        style: TextStyle(
                          fontSize:   18.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        'سيتم تصدير ${filtered.length} طلب'
                            '${_hasDateFilter ? ' (مفلتر بالتاريخ)' : ''}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color:    Colors.grey[500],
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
              SizedBox(height: 16.h),

              // ── عرض نطاق التاريخ إن وُجد ─────────────────────────
              if (_hasDateFilter)
                Container(
                  padding: EdgeInsets.all(12.r),
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha:0.07),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha:0.2)),
                  ),
                  child: Row(children: [
                    Icon(Icons.date_range_rounded,
                        color: const Color(0xFFD4AF37), size: 16.sp),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        '${_filterFromDate != null ? DateFormat('d MMM yyyy', 'ar').format(_filterFromDate!) : 'البداية'}'
                            '  ←  '
                            '${_filterToDate != null ? DateFormat('d MMM yyyy', 'ar').format(_filterToDate!) : 'اليوم'}',
                        style: TextStyle(
                          fontSize:   12.sp,
                          fontWeight: FontWeight.bold,
                          color:      const Color(0xFFD4AF37),
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ]),
                ),

              // ── خيارات التصدير ────────────────────────────────────
              _buildExportOption(
                icon:     Icons.picture_as_pdf_rounded,
                color:    Colors.red,
                title:    'طباعة / تصدير PDF',
                subtitle: 'كشف طلبات منسّق للطباعة أو المشاركة',
                isDark:   isDark,
                onTap: () {
                  Navigator.pop(context);
                  _exportOrdersPdf(filtered);
                },
              ),
              SizedBox(height: 10.h),
              _buildExportOption(
                icon:     Icons.table_chart_rounded,
                color:    Colors.green,
                title:    'تصدير CSV',
                subtitle: 'مناسب لبرنامج Excel أو Google Sheets',
                isDark:   isDark,
                onTap: () {
                  Navigator.pop(context);
                  _exportOrdersCsv(filtered);
                },
              ),
              SizedBox(height: 10.h),
              _buildExportOption(
                icon:     Icons.share_rounded,
                color:    Colors.blue,
                title:    'مشاركة ملخص نصي',
                subtitle: 'إرسال كشف الطلبات عبر واتساب أو غيره',
                isDark:   isDark,
                onTap: () {
                  Navigator.pop(context);
                  _shareTextSummary(filtered);
                },
              ),
              SizedBox(height: 20.h),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required IconData     icon,
    required Color        color,
    required String       title,
    required String       subtitle,
    required bool         isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:    EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[50],
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
        ),
        child: Row(children: [
          Container(
            padding:    EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color:  color.withValues(alpha:0.1),
              shape:  BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      fontSize:   15.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                      fontFamily: 'Cairo',
                    )),
                Text(subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color:    Colors.grey[500],
                      fontFamily: 'Cairo',
                    )),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 14.sp, color: Colors.grey[400]),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // EXPORT PDF
  // ══════════════════════════════════════════════════════════════════
  // Future<void> _exportOrdersPdf(List<Order> orders) async {
  //   if (!mounted || orders.isEmpty) {
  //     _showSnack('لا توجد طلبات للتصدير', Colors.orange);
  //     return;
  //   }
  //   setState(() => _isExporting = true);
  //
  //   try {
  //     final pdf = pw.Document();
  //
  //     // تحميل الخط العربي
  //     final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
  //     final boldData = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');
  //     final ttf      = pw.Font.ttf(fontData);
  //     final ttfBold  = pw.Font.ttf(boldData);
  //
  //     // إحصائيات
  //     final total     = orders.fold<double>(0, (s, o) => s + o.totalAmount);
  //     final delivered = orders.where((o) => o.status == 'delivered').length;
  //     final dateRange = _hasDateFilter
  //         ? 'من ${_filterFromDate != null ? DateFormat('dd/MM/yyyy').format(_filterFromDate!) : 'البداية'}'
  //         ' إلى ${_filterToDate != null ? DateFormat('dd/MM/yyyy').format(_filterToDate!) : 'اليوم'}'
  //         : 'جميع الفترات';
  //
  //     pdf.addPage(
  //       pw.MultiPage(
  //           pageFormat:     PdfPageFormat.a4,
  //           textDirection:  pw.TextDirection.rtl,
  //           theme: pw.ThemeData.withFont(base: ttf, bold: ttfBold),
  //           margin: const pw.EdgeInsets.all(32),
  //           header: (ctx) => pw.Container(
  //             margin: const pw.EdgeInsets.only(bottom: 16),
  //             padding: const pw.EdgeInsets.all(16),
  //             decoration: pw.BoxDecoration(
  //               color:        PdfColor.fromHex('#D4AF37'),
  //               borderRadius: pw.BorderRadius.circular(12),
  //             ),
  //             child: pw.Row(
  //               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //               children: [
  //                 pw.Column(
  //                   crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                   children: [
  //                     pw.Text('كشف طلباتي',
  //                         style: pw.TextStyle(
  //                             font:      ttfBold,
  //                             fontSize:  22,
  //                             color:     PdfColors.white)),
  //                     pw.SizedBox(height: 4),
  //                     pw.Text(dateRange,
  //                         style: pw.TextStyle(
  //                             font:    ttf,
  //                             fontSize: 10,
  //                             color:   PdfColors.white)),
  //                   ],
  //                 ),
  //                 pw.Text(
  //                   DateFormat('dd/MM/yyyy').format(DateTime.now()),
  //                   style: pw.TextStyle(
  //                       font:    ttf,
  //                       fontSize: 10,
  //                       color:   PdfColors.white),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           build: (ctx) => [
  //           // ── ملخص إحصائي ──────────────────────────────────────
  //           pw.Container(
  //       padding: const pw.EdgeInsets.all(12),
  //       margin: const pw.EdgeInsets.only(bottom: 16),
  //       decoration: pw.BoxDecoration(
  //         border: pw.Border.all(color: PdfColors.grey400),
  //         borderRadius: pw.BorderRadius.circular(8),
  //       ),
  //       child: pw.Row(
  //         mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
  //         children: [
  //           _pdfStatBox('إجمالي الطلبات', '${orders.length}', ttf, ttfBold),
  //           _pdfStatBox('المكتملة', '$delivered', ttf, ttfBold),
  //           _pdfStatBox('الإجمالي', '${total.toStringAsFixed(0)} ر.ي', ttf, ttfBold),
  //         ],
  //       ),
  //     ),
  //
  //   // ── جدول الطلبات ─────────────────────────────────────
  //   pw.Table(
  //   border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.7),
  //     columnWidths: {
  //       0: const pw.FlexColumnWidth(1.8),
  //       1: const pw.FlexColumnWidth(1.8),
  //       2: const pw.FlexColumnWidth(2),
  //       3: const pw.FlexColumnWidth(1.8),
  //       4: const pw.FlexColumnWidth(1.8),
  //     },
  //     children: [
  //       // رأس الجدول
  //       pw.TableRow(
  //         decoration: const pw.BoxDecoration(color: PdfColors.grey300),
  //         children: [
  //           _pdfHeaderCell('رقم الطلب',   ttfBold),
  //           _pdfHeaderCell('التاريخ',      ttfBold),
  //           _pdfHeaderCell('الحالة',       ttfBold),
  //           _pdfHeaderCell('طريقة الدفع',  ttfBold),
  //           _pdfHeaderCell('المجموع',      ttfBold),
  //         ],
  //       ),
  //       // صفوف البيانات
  //       ...orders.asMap().entries.map((entry) {
  //         final i = entry.key;
  //         final o = entry.value;
  //         return pw.TableRow(
  //           decoration: pw.BoxDecoration(
  //             color: i.isEven ? PdfColors.grey100 : PdfColors.white,
  //           ),
  //           children: [
  //             _pdfCell('#${o.orderNumber}', ttf),
  //             _pdfCell(DateFormat('dd/MM/yyyy').format(o.createdAt), ttf),
  //             _pdfCell(o.statusText, ttf),
  //             _pdfCell(o.paymentMethodText, ttf),
  //             _pdfCell('${o.totalAmount.toStringAsFixed(0)} ر.ي', ttf),
  //           ],
  //         );
  //       }),
  //       // صف الإجمالي
  //       pw.TableRow(
  //         decoration: const pw.BoxDecoration(color: PdfColors.grey200),
  //         children: [
  //           _pdfHeaderCell('الإجمالي الكلي', ttfBold),
  //           pw.Container(),
  //           pw.Container(),
  //           pw.Container(),
  //           _pdfHeaderCell(
  //             '${orders.fold<double>(0, (s, o) => s + o.totalAmount).toStringAsFixed(0)} ر.ي',
  //             ttfBold,
  //           ),
  //         ],
  //       ),
  //     ],
  //   ),
  //             pw.SizedBox(height: 20),
  //
  //             // ── ملاحظات ────────────────────────────────────────
  //             pw.Container(
  //               padding: const pw.EdgeInsets.all(12),
  //               decoration: pw.BoxDecoration(
  //                 color:        PdfColors.grey200,
  //                 borderRadius: pw.BorderRadius.circular(8),
  //               ),
  //               child: pw.Column(
  //                 crossAxisAlignment: pw.CrossAxisAlignment.start,
  //                 children: [
  //                   pw.Text('ملاحظات:',
  //                       style: pw.TextStyle(font: ttfBold, fontSize: 11)),
  //                   pw.SizedBox(height: 4),
  //                   pw.Text(
  //                     '• هذا الكشف يعرض الطلبات حسب الفلاتر المطبقة',
  //                     style: pw.TextStyle(font: ttf, fontSize: 9),
  //                   ),
  //                   pw.Text(
  //                     '• للاستفسارات يرجى التواصل مع فريق الدعم',
  //                     style: pw.TextStyle(font: ttf, fontSize: 9),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         footer: (ctx) => pw.Container(
  //           alignment: pw.Alignment.centerLeft,
  //           margin: const pw.EdgeInsets.only(top: 8),
  //           child: pw.Text(
  //             'صفحة ${ctx.pageNumber} من ${ctx.pagesCount}',
  //             style: pw.TextStyle(
  //                 font: ttf, fontSize: 9, color: PdfColors.grey600),
  //           ),
  //         ),
  //       ),
  //     );
  //
  //     // عرض معاينة الطباعة
  //     await Printing.layoutPdf(
  //       name:     'my_orders_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf',
  //       onLayout: (PdfPageFormat format) async => pdf.save(),
  //     );
  //   } catch (e) {
  //     if (mounted) _showSnack('خطأ في إنشاء PDF: $e', Colors.red);
  //   } finally {
  //     if (mounted) setState(() => _isExporting = false);
  //   }
  // }
  //
  // // ── مساعدات PDF ───────────────────────────────────────────────────
  // pw.Widget _pdfStatBox(
  //     String label, String value, pw.Font font, pw.Font boldFont) {
  //   return pw.Column(
  //     crossAxisAlignment: pw.CrossAxisAlignment.center,
  //     children: [
  //       pw.Text(value,
  //           style: pw.TextStyle(
  //               font:    boldFont,
  //               fontSize: 16,
  //               color:   PdfColor.fromHex('#D4AF37'))),
  //       pw.SizedBox(height: 4),
  //       pw.Text(label,
  //           style: pw.TextStyle(
  //               font: font, fontSize: 10, color: PdfColors.grey700)),
  //     ],
  //   );
  // }
  //
  // pw.Widget _pdfHeaderCell(String text, pw.Font font) {
  //   return pw.Padding(
  //     padding: const pw.EdgeInsets.all(7),
  //     child: pw.Text(
  //       text,
  //       style: pw.TextStyle(font: font, fontSize: 10),
  //       textAlign: pw.TextAlign.center,
  //     ),
  //   );
  // }
  //
  // pw.Widget _pdfCell(String text, pw.Font font) {
  //   return pw.Padding(
  //     padding: const pw.EdgeInsets.all(6),
  //     child: pw.Text(
  //       text,
  //       style: pw.TextStyle(font: font, fontSize: 9),
  //       textAlign: pw.TextAlign.center,
  //     ),
  //   );
  // }


  Future<void> _exportOrdersPdf(List<Order> orders) async {
    if (!mounted || orders.isEmpty) {
      _showSnack('لا توجد طلبات للتصدير', Colors.orange);
      return;
    }

    setState(() => _isExporting = true);

    try {
      final pdf = pw.Document();

      /// تحميل الخطوط
      final regularFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Cairo-Regular.ttf'),
      );

      final boldFont = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Cairo-Bold.ttf'),
      );

      /// تحميل الشعار
      final logo = pw.MemoryImage(
        (await rootBundle.load('assets/images/logo.png'))
            .buffer
            .asUint8List(),
      );

      /// إحصائيات
      final total = orders.fold<double>(0, (s, o) => s + o.totalAmount);
      final delivered = orders.where((o) => o.status == 'delivered').length;

      final dateRange = _hasDateFilter
          ? 'من ${_filterFromDate != null ? _formatDate(_filterFromDate!) : "البداية"}'
          ' إلى ${_filterToDate != null ? _formatDate(_filterToDate!) : "اليوم"}'
          : 'جميع الفترات';

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          margin: const pw.EdgeInsets.all(32),

          theme: pw.ThemeData.withFont(
            base: regularFont,
            bold: boldFont,
          ),

          /// HEADER
          header: (context) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 20),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#D4AF37'),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Row(

                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [

                  /// الشعار
                  pw.Container(
                    width: 60,
                    height: 60,
                    child: pw.Image(logo),
                  ),

                  /// النص
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'كشف طلباتي',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 20,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.Text(
                        dateRange,
                        style: pw.TextStyle(
                          font: regularFont,
                          fontSize: 10,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },

          build: (context) => [

            /// الإحصائيات
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              margin: const pw.EdgeInsets.only(bottom: 16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _pdfStatBox('إجمالي الطلبات', '${orders.length}', regularFont, boldFont),
                  _pdfStatBox('المكتملة', '$delivered', regularFont, boldFont),
                  _pdfStatBox('الإجمالي', _currency(total), regularFont, boldFont),
                ],
              ),
            ),

            /// جدول الطلبات RTL
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),

              columnWidths: const {
                0: pw.FlexColumnWidth(1.8),
                1: pw.FlexColumnWidth(1.8),
                2: pw.FlexColumnWidth(2),
                3: pw.FlexColumnWidth(1.8),
                4: pw.FlexColumnWidth(1.8),
              },

              children: [

                /// رأس الجدول
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  children: [
                    _pdfHeaderCell('المجموع', boldFont),
                    _pdfHeaderCell('طريقة الدفع', boldFont),
                    _pdfHeaderCell('الحالة', boldFont),
                    _pdfHeaderCell('التاريخ', boldFont),
                    _pdfHeaderCell('رقم الطلب', boldFont),
                  ],
                ),

                /// الصفوف
                ...orders.asMap().entries.map((entry) {

                  final i = entry.key;
                  final o = entry.value;

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: i.isEven
                          ? PdfColors.grey100
                          : PdfColors.white,
                    ),
                    children: [
                      _pdfCell(_currency(o.totalAmount), regularFont),
                      _pdfCell(o.paymentMethodText, regularFont),
                      _pdfCell(o.statusText, regularFont),
                      _pdfCell(_formatDate(o.createdAt), regularFont),
                      _pdfCell('#${o.orderNumber}', regularFont),
                    ],
                  );
                }),

                /// الإجمالي
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                  ),
                  children: [
                    _pdfHeaderCell(_currency(total), boldFont),
                    pw.Container(),
                    pw.Container(),
                    pw.Container(),
                    _pdfHeaderCell('الإجمالي الكلي', boldFont),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            /// الملاحظات
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('ملاحظات:',
                      style: pw.TextStyle(font: boldFont, fontSize: 11)),
                  pw.Text(
                    '• هذا الكشف يعرض الطلبات حسب الفلاتر المطبقة',
                    style: pw.TextStyle(font: regularFont, fontSize: 9),
                  ),
                  pw.Text(
                    '• للاستفسارات يرجى التواصل مع فريق الدعم',
                    style: pw.TextStyle(font: regularFont, fontSize: 9),
                  ),
                ],
              ),
            ),
          ],

          /// Footer
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerLeft,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'صفحة ${context.pageNumber} من ${context.pagesCount}',
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 9,
                color: PdfColors.grey600,
              ),
            ),
          ),
        ),
      );

      await Printing.layoutPdf(
        name: 'orders_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf',
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      if (mounted) {
        _showSnack('خطأ في إنشاء PDF: $e', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  pw.Widget _pdfStatBox(
      String label,
      String value,
      pw.Font font,
      pw.Font boldFont,
      ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 16,
            color: PdfColor.fromHex('#D4AF37'),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: pw.TextStyle(font: font, fontSize: 10),
        ),
      ],
    );
  }

  pw.Widget _pdfHeaderCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(7),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: font, fontSize: 10),
      ),
    );
  }

  pw.Widget _pdfCell(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: font, fontSize: 9),
      ),
    );
  }

  String _currency(num value) {
    final f = NumberFormat('#,###', 'ar');
    return '${f.format(value)} ريال';
  }


  // ══════════════════════════════════════════════════════════════════
  // EXPORT CSV
  // ══════════════════════════════════════════════════════════════════
  Future<void> _exportOrdersCsv(List<Order> orders) async {
    if (!mounted || orders.isEmpty) {
      _showSnack('لا توجد طلبات للتصدير', Colors.orange);
      return;
    }
    setState(() => _isExporting = true);

    try {
      final buffer = StringBuffer();

      // ترويسة BOM للعربية في Excel
      buffer.write('\uFEFF');
      buffer.writeln('رقم الطلب,التاريخ,الوقت,الحالة,طريقة الدفع,طريقة التوصيل,المجموع الفرعي,الخصم,التوصيل,الضريبة,المجموع الكلي');

      for (final o in orders) {
        final date    = DateFormat('yyyy-MM-dd').format(o.createdAt);
        final time    = DateFormat('HH:mm').format(o.createdAt);
        final status  = o.statusText.replaceAll(',', '،');
        final payment = o.paymentMethodText.replaceAll(',', '،');
        final delivery = o.deliveryMethodText.replaceAll(',', '،');

        buffer.writeln(
          '"#${o.orderNumber}",'
              '"$date",'
              '"$time",'
              '"$status",'
              '"$payment",'
              '"$delivery",'
              '"${o.subtotal.toStringAsFixed(2)}",'
              '"${o.discountAmount.toStringAsFixed(2)}",'
              '"${o.deliveryFee.toStringAsFixed(2)}",'
              '"${o.taxAmount.toStringAsFixed(2)}",'
              '"${o.totalAmount.toStringAsFixed(2)}"',
        );
      }

      // صف الإجمالي
      final total = orders.fold<double>(0, (s, o) => s + o.totalAmount);
      buffer.writeln('');
      buffer.writeln('"الإجمالي الكلي","","","","","","","","","","${total.toStringAsFixed(2)}"');

      final dir      = await getTemporaryDirectory();
      final fileName = 'orders_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
      final file     = File('${dir.path}/$fileName');
      await file.writeAsString(buffer.toString(), encoding: utf8);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'كشف طلباتي',
      );
    } catch (e) {
      if (mounted) _showSnack('خطأ في تصدير CSV: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // SHARE TEXT SUMMARY
  // ══════════════════════════════════════════════════════════════════
  Future<void> _shareTextSummary(List<Order> orders) async {
    if (orders.isEmpty) {
      _showSnack('لا توجد طلبات للمشاركة', Colors.orange);
      return;
    }

    final total     = orders.fold<double>(0, (s, o) => s + o.totalAmount);
    final delivered = orders.where((o) => o.status == 'delivered').length;
    final dateRange = _hasDateFilter
        ? '\n📅 الفترة: ${_filterFromDate != null ? DateFormat('d MMM yyyy', 'ar').format(_filterFromDate!) : 'البداية'}'
        ' ← ${_filterToDate != null ? DateFormat('d MMM yyyy', 'ar').format(_filterToDate!) : 'اليوم'}'
        : '';

    final buffer = StringBuffer();
    buffer.writeln('🛍️ كشف طلباتي');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📦 إجمالي الطلبات: ${orders.length}$dateRange');
    buffer.writeln('✅ المكتملة: $delivered');
    buffer.writeln('💰 الإجمالي: ${total.toStringAsFixed(0)} ر.ي');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('');

    for (final o in orders.take(10)) {
      final statusIcon = o.status == 'delivered'
          ? '✅'
          : o.status == 'cancelled'
          ? '❌'
          : '⏳';
      final date = DateFormat('d MMM', 'ar').format(o.createdAt);
      buffer.writeln('$statusIcon طلب #${o.orderNumber} | $date | ${o.totalAmount.toStringAsFixed(0)} ر.ي');
    }

    if (orders.length > 10) {
      buffer.writeln('... و${orders.length - 10} طلب آخر');
    }

    await Share.share(buffer.toString(), subject: 'كشف طلباتي');
  }

  // ══════════════════════════════════════════════════════════════════
  // SNACKBAR HELPER
  // ══════════════════════════════════════════════════════════════════
  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp)),
        backgroundColor: color,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }
}
