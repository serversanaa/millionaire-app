// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:flutter_animate/flutter_animate.dart';
// // import 'package:intl/intl.dart';
// // import 'package:millionaire_barber/features/appointments/domain/models/employee_model.dart';
// // import 'package:millionaire_barber/features/appointments/presentation/pages/appointment_success_screen.dart';
// // import 'package:provider/provider.dart';
// // import 'package:shimmer/shimmer.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'dart:ui' as ui;
// // import '../../../../core/constants/app_colors.dart';
// // import '../../../../shared/widgets/custom_snackbar.dart';
// // import '../../../profile/presentation/providers/user_provider.dart';
// // import '../../../services/domain/models/service_model.dart';
// // import '../../../coupons/presentation/providers/coupon_provider.dart';
// // import '../../../coupons/presentation/widgets/coupon_input_widget.dart';
// // import '../../../loyalty/presentation/providers/loyalty_transaction_provider.dart';
// // import '../../../notifications/presentation/providers/notification_provider.dart';
// // import '../providers/appointment_provider.dart';
// //
// // // ✅ استيراد حزمة التقويم
// // import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
// //
// // class BookAppointmentScreen extends StatefulWidget {
// //   final ServiceModel service;
// //
// //   const BookAppointmentScreen({Key? key, required this.service})
// //       : super(key: key);
// //
// //   @override
// //   State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
// // }
// //
// // class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
// //   DateTime? _selectedDate;
// //   String? _selectedTime;
// //   EmployeeModel? _selectedEmployee;
// //   final _notesController = TextEditingController();
// //   int _currentStep = 0;
// //
// //   // ✅ متغير Loader
// //   bool _isConfirming = false;
// //
// //   // ✅ متغيرات العروض
// //   Map<String, dynamic>? _appliedOffer;
// //   String? _appliedPromoCode;
// //   int? _appliedOfferId;
// //   double _discountAmount = 0.0;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _initializeScreen();
// //     });
// //   }
// //
// //   Future<void> _initializeScreen() async {
// //
// //
// //     final appointmentProvider =
// //         Provider.of<AppointmentProvider>(context, listen: false);
// //     appointmentProvider.fetchAvailableEmployees();
// //
// //     // ✅ جلب وقت السيرفر أولاً (مهم جداً!)
// //     await appointmentProvider.fetchServerTime();
// //
// //
// //     final couponProvider = Provider.of<CouponProvider>(context, listen: false);
// //     couponProvider.removeCoupon();
// //
// //     final loyaltyProvider =
// //         Provider.of<LoyaltyTransactionProvider>(context, listen: false);
// //     loyaltyProvider.fetchLoyaltySettings();
// //
// //     // ✅ استقبال العرض من arguments
// //     final args =
// //         ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
// //
// //     if (args != null) {
// //       final offer = args['applied_offer'] as Map<String, dynamic>?;
// //       final offerId = args['offer_id'] as int?;
// //       final promoCode = args['promo_code'] as String?;
// //
// //       if (offer != null) {
// //         setState(() {
// //           _appliedOffer = offer;
// //           _appliedOfferId = offerId;
// //           _appliedPromoCode = promoCode;
// //         });
// //
// //
// //         _calculateOfferDiscount();
// //
// //         Future.delayed(const Duration(milliseconds: 500), () {
// //           if (mounted) {
// //             CustomSnackbar.showSuccess(
// //               context,
// //               '🎉 تم تطبيق عرض: ${offer['title_ar']}',
// //             );
// //           }
// //         });
// //       }
// //     }
// //   }
// //
// //   void _calculateOfferDiscount() {
// //     if (_appliedOffer == null) {
// //       setState(() {
// //         _discountAmount = 0;
// //       });
// //       return;
// //     }
// //
// //     final discountType = _appliedOffer!['discount_type'] as String;
// //     final discountValue = (_appliedOffer!['discount_value'] as num).toDouble();
// //     final minPurchase =
// //         (_appliedOffer!['min_purchase_amount'] as num?)?.toDouble() ?? 0;
// //     final maxDiscount =
// //         (_appliedOffer!['max_discount_amount'] as num?)?.toDouble();
// //     final originalPrice = widget.service.price;
// //
// //     if (originalPrice < minPurchase) {
// //       CustomSnackbar.showError(
// //         context,
// //         'الحد الأدنى للشراء ${minPurchase.toInt()} ر.س',
// //       );
// //       setState(() {
// //         _appliedOffer = null;
// //         _discountAmount = 0;
// //       });
// //       return;
// //     }
// //
// //     double discount = 0;
// //
// //     if (discountType == 'percentage') {
// //       discount = originalPrice * (discountValue / 100);
// //     } else if (discountType == 'fixed_amount') {
// //       discount = discountValue;
// //     }
// //
// //     if (maxDiscount != null && discount > maxDiscount) {
// //       discount = maxDiscount;
// //     }
// //
// //     if (discount > originalPrice) {
// //       discount = originalPrice;
// //     }
// //
// //     setState(() {
// //       _discountAmount = discount;
// //     });
// //   }
// //
// //   @override
// //   void dispose() {
// //     _notesController.dispose();
// //     super.dispose();
// //   }
// //
// //   String _formatDate(DateTime date) {
// //     final days = [
// //       'الأحد',
// //       'الاثنين',
// //       'الثلاثاء',
// //       'الأربعاء',
// //       'الخميس',
// //       'الجمعة',
// //       'السبت'
// //     ];
// //     final months = [
// //       'يناير',
// //       'فبراير',
// //       'مارس',
// //       'أبريل',
// //       'مايو',
// //       'يونيو',
// //       'يوليو',
// //       'أغسطس',
// //       'سبتمبر',
// //       'أكتوبر',
// //       'نوفمبر',
// //       'ديسمبر'
// //     ];
// //
// //     final dayName = days[date.weekday % 7];
// //     final monthName = months[date.month - 1];
// //
// //     return '$dayName، ${date.day} $monthName ${date.year}';
// //   }
// //
// //   /// ✅ تنسيق الوقت - hh:mm ص/م
// //   String _formatTime(String time) {
// //     try {
// //       final parts = time.split(':');
// //       final hour = int.parse(parts[0]);
// //       final minute = parts.length > 1 ? parts[1] : '00';
// //
// //       if (hour == 0) {
// //         return '12:$minute ص';
// //       } else if (hour < 12) {
// //         return '$hour:$minute ص';
// //       } else if (hour == 12) {
// //         return '12:$minute م';
// //       } else {
// //         return '${hour - 12}:$minute م';
// //       }
// //     } catch (e) {
// //       return time;
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final isDark = Theme.of(context).brightness == Brightness.dark;
// //
// //     return Directionality(
// //       textDirection: ui.TextDirection.rtl,
// //       child: Scaffold(
// //         backgroundColor:
// //             isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
// //         appBar: AppBar(
// //           backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
// //           elevation: 0,
// //           leading: IconButton(
// //             icon: Icon(Icons.arrow_back_ios,
// //                 color: isDark ? Colors.white : AppColors.black),
// //             onPressed: () => Navigator.pop(context),
// //           ),
// //           title: Text(
// //             'حجز موعد',
// //             style: TextStyle(
// //               fontSize: 20.sp,
// //               fontWeight: FontWeight.bold,
// //               color: isDark ? Colors.white : AppColors.black,
// //             ),
// //           ),
// //           centerTitle: true,
// //         ),
// //         body: Column(
// //           children: [
// //             _buildStepIndicator(isDark),
// //             Expanded(
// //               child: SingleChildScrollView(
// //                 padding: EdgeInsets.all(20.w),
// //                 child: Column(
// //                   children: [
// //                     _buildServiceCard(isDark),
// //                     SizedBox(height: 24.h),
// //
// //                     // ✅ بطاقة العرض - تظهر في جميع الخطوات
// //                     if (_appliedOffer != null) ...[
// //                       _buildAppliedOfferCard(isDark),
// //                       SizedBox(height: 24.h),
// //                     ],
// //
// //                     // ✅ بطاقة العرض المطبق
// //
// //                     if (_currentStep == 0) _buildDateSelection(isDark),
// //                     if (_currentStep == 1) _buildTimeSelection(isDark),
// //                     if (_currentStep == 2) _buildEmployeeSelection(isDark),
// //                     if (_currentStep == 3) _buildNotesAndSummary(isDark),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //             _buildBottomButtons(isDark),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildStepIndicator(bool isDark) {
// //     return Container(
// //       padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
// //       decoration: BoxDecoration(
// //         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 10,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           _buildStepItem(0, 'التاريخ', Icons.calendar_today_rounded, isDark),
// //           _buildStepLine(0, isDark),
// //           _buildStepItem(1, 'الوقت', Icons.access_time_rounded, isDark),
// //           _buildStepLine(1, isDark),
// //           _buildStepItem(2, 'الموظف', Icons.person_rounded, isDark),
// //           _buildStepLine(2, isDark),
// //           _buildStepItem(3, 'التأكيد', Icons.check_circle_rounded, isDark),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildStepItem(int step, String label, IconData icon, bool isDark) {
// //     final isActive = _currentStep == step;
// //     final isCompleted = _currentStep > step;
// //
// //     return Expanded(
// //       child: Column(
// //         children: [
// //           Container(
// //             width: 40.w,
// //             height: 40.h,
// //             decoration: BoxDecoration(
// //               color: isCompleted || isActive
// //                   ? AppColors.darkRed
// //                   : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200),
// //               shape: BoxShape.circle,
// //             ),
// //             child: Icon(
// //               isCompleted ? Icons.check_rounded : icon,
// //               color:
// //                   isCompleted || isActive ? Colors.white : Colors.grey.shade500,
// //               size: 20.sp,
// //             ),
// //           ),
// //           SizedBox(height: 6.h),
// //           Text(
// //             label,
// //             style: TextStyle(
// //               fontSize: 11.sp,
// //               fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
// //               color: isActive
// //                   ? AppColors.darkRed
// //                   : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildStepLine(int step, bool isDark) {
// //     final isCompleted = _currentStep > step;
// //     return Expanded(
// //       child: Container(
// //         height: 2,
// //         margin: EdgeInsets.only(bottom: 30.h),
// //         color: isCompleted
// //             ? AppColors.darkRed
// //             : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade300),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildServiceCard(bool isDark) {
// //     return Container(
// //       padding: EdgeInsets.all(16.r),
// //       decoration: BoxDecoration(
// //         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
// //         borderRadius: BorderRadius.circular(16.r),
// //         border: Border.all(
// //             color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
// //       ),
// //       child: Row(
// //         children: [
// //           ClipRRect(
// //             borderRadius: BorderRadius.circular(12.r),
// //             child: widget.service.imageUrl != null &&
// //                     widget.service.imageUrl!.isNotEmpty
// //                 ? Image.network(
// //                     widget.service.imageUrl!,
// //                     width: 70.w,
// //                     height: 70.h,
// //                     fit: BoxFit.cover,
// //                     errorBuilder: (_, __, ___) => _buildPlaceholder(isDark),
// //                   )
// //                 : _buildPlaceholder(isDark),
// //           ),
// //           SizedBox(width: 16.w),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   widget.service.serviceNameAr ??
// //                       widget.service.serviceName ??
// //                       '',
// //                   style: TextStyle(
// //                     fontSize: 16.sp,
// //                     fontWeight: FontWeight.bold,
// //                     color: isDark ? Colors.white : AppColors.black,
// //                   ),
// //                 ),
// //                 SizedBox(height: 6.h),
// //                 Row(
// //                   children: [
// //                     Icon(Icons.access_time,
// //                         size: 16.sp, color: Colors.grey.shade500),
// //                     SizedBox(width: 4.w),
// //                     Text(
// //                       '${widget.service.durationMinutes} دقيقة',
// //                       style: TextStyle(
// //                           fontSize: 13.sp, color: Colors.grey.shade500),
// //                     ),
// //                     SizedBox(width: 16.w),
// //                     Icon(Icons.payments_rounded,
// //                         size: 16.sp, color: AppColors.gold),
// //                     SizedBox(width: 4.w),
// //                     Text(
// //                       '${widget.service.price.toStringAsFixed(0)} ريال',
// //                       style: TextStyle(
// //                         fontSize: 14.sp,
// //                         fontWeight: FontWeight.bold,
// //                         color: AppColors.gold,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     ).animate().fadeIn().slideY(begin: 0.2);
// //   }
// //
// //   Widget _buildPlaceholder(bool isDark) {
// //     return Container(
// //       width: 70.w,
// //       height: 70.h,
// //       decoration: BoxDecoration(
// //         color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200,
// //         borderRadius: BorderRadius.circular(12.r),
// //       ),
// //       child:
// //           Icon(Icons.content_cut_rounded, color: AppColors.gold, size: 30.sp),
// //     );
// //   }
// //
// //   /// ✅ بطاقة العرض المطبق
// //   Widget _buildAppliedOfferCard(bool isDark) {
// //     final title = _appliedOffer!['title_ar'] as String;
// //     final discountType = _appliedOffer!['discount_type'] as String;
// //     final discountValue = (_appliedOffer!['discount_value'] as num).toDouble();
// //
// //     String discountText = '';
// //     if (discountType == 'percentage') {
// //       discountText = '${discountValue.toInt()}%';
// //     } else {
// //       discountText = '${discountValue.toInt()} ر.س';
// //     }
// //
// //     return Container(
// //       margin: EdgeInsets.only(bottom: 24.h),
// //       padding: EdgeInsets.all(16.r),
// //       decoration: BoxDecoration(
// //         gradient: const LinearGradient(
// //           colors: [AppColors.gold, AppColors.goldDark],
// //         ),
// //         borderRadius: BorderRadius.circular(16.r),
// //         boxShadow: [
// //           BoxShadow(
// //             color: AppColors.gold.withOpacity(0.3),
// //             blurRadius: 12,
// //             offset: const Offset(0, 6),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           Container(
// //             padding: EdgeInsets.all(12.r),
// //             decoration: BoxDecoration(
// //               color: Colors.white.withOpacity(0.3),
// //               shape: BoxShape.circle,
// //             ),
// //             child: Icon(
// //               Icons.local_offer_rounded,
// //               color: Colors.white,
// //               size: 24.sp,
// //             ),
// //           ),
// //           SizedBox(width: 16.w),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   'عرض مطبق 🎉',
// //                   style: TextStyle(
// //                     fontSize: 12.sp,
// //                     color: Colors.white.withOpacity(0.9),
// //                   ),
// //                 ),
// //                 SizedBox(height: 4.h),
// //                 Text(
// //                   title,
// //                   style: TextStyle(
// //                     fontSize: 16.sp,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.white,
// //                   ),
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Container(
// //             padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(12.r),
// //             ),
// //             child: Text(
// //               discountText,
// //               style: TextStyle(
// //                 fontSize: 18.sp,
// //                 fontWeight: FontWeight.bold,
// //                 color: AppColors.darkRed,
// //               ),
// //             ),
// //           ),
// //           SizedBox(width: 8.w),
// //           IconButton(
// //             onPressed: _removeOffer,
// //             icon: Icon(
// //               Icons.close_rounded,
// //               color: Colors.white,
// //               size: 20.sp,
// //             ),
// //             tooltip: 'إزالة العرض',
// //           ),
// //         ],
// //       ),
// //     ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.3);
// //   }
// //
// //   void _removeOffer() {
// //     setState(() {
// //       _appliedOffer = null;
// //       _appliedOfferId = null;
// //       _appliedPromoCode = null;
// //       _discountAmount = 0;
// //     });
// //
// //     CustomSnackbar.showSuccess(context, 'تم إزالة العرض');
// //   }
// //
// //   Widget _buildDateSelection(bool isDark) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'اختر التاريخ',
// //           style: TextStyle(
// //             fontSize: 18.sp,
// //             fontWeight: FontWeight.bold,
// //             color: isDark ? Colors.white : AppColors.black,
// //           ),
// //         ),
// //         SizedBox(height: 16.h),
// //         PlatformWidget(
// //           material: (_, __) => Container(
// //             padding: EdgeInsets.all(16.r),
// //             decoration: BoxDecoration(
// //               color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
// //               borderRadius: BorderRadius.circular(16.r),
// //               border: Border.all(
// //                   color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
// //             ),
// //             child: CalendarDatePicker(
// //               initialDate: _selectedDate ?? DateTime.now(),
// //               firstDate: DateTime.now(),
// //               lastDate: DateTime.now().add(const Duration(days: 60)),
// //               onDateChanged: (DateTime newDate) {
// //                 setState(() {
// //                   _selectedDate = newDate;
// //                   _selectedTime = null;
// //                 });
// //
// //                 final appointmentProvider =
// //                     Provider.of<AppointmentProvider>(context, listen: false);
// //                 appointmentProvider.fetchAvailableTimeSlots(
// //                   newDate,
// //                   widget.service.durationMinutes ?? 30,
// //                 );
// //               },
// //             ),
// //           ),
// //           cupertino: (_, __) => GestureDetector(
// //             onTap: () => _showCupertinoDatePicker(context),
// //             child: Container(
// //               padding: EdgeInsets.all(20.r),
// //               decoration: BoxDecoration(
// //                 color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
// //                 borderRadius: BorderRadius.circular(16.r),
// //                 border: Border.all(
// //                     color:
// //                         isDark ? Colors.grey.shade800 : Colors.grey.shade200),
// //               ),
// //               child: Row(
// //                 children: [
// //                   Icon(Icons.calendar_month_rounded,
// //                       color: AppColors.darkRed, size: 28.sp),
// //                   SizedBox(width: 16.w),
// //                   Expanded(
// //                     child: Text(
// //                       _selectedDate != null
// //                           ? _formatDate(_selectedDate!)
// //                           : 'اضغط لاختيار التاريخ',
// //                       style: TextStyle(
// //                         fontSize: 16.sp,
// //                         fontWeight: FontWeight.w600,
// //                         color: isDark ? Colors.white : AppColors.black,
// //                       ),
// //                     ),
// //                   ),
// //                   Icon(Icons.arrow_forward_ios,
// //                       size: 16.sp, color: Colors.grey),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //         if (_selectedDate != null) ...[
// //           SizedBox(height: 16.h),
// //           Container(
// //             padding: EdgeInsets.all(16.r),
// //             decoration: BoxDecoration(
// //               color: AppColors.darkRed.withOpacity(0.1),
// //               borderRadius: BorderRadius.circular(12.r),
// //               border: Border.all(color: AppColors.darkRed.withOpacity(0.3)),
// //             ),
// //             child: Row(
// //               children: [
// //                 Icon(Icons.event_available,
// //                     color: AppColors.darkRed, size: 24.sp),
// //                 SizedBox(width: 12.w),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         'التاريخ المحدد',
// //                         style: TextStyle(
// //                           fontSize: 12.sp,
// //                           color: isDark
// //                               ? Colors.grey.shade400
// //                               : AppColors.greyDark,
// //                         ),
// //                       ),
// //                       SizedBox(height: 4.h),
// //                       Text(
// //                         _formatDate(_selectedDate!),
// //                         style: TextStyle(
// //                           fontSize: 15.sp,
// //                           fontWeight: FontWeight.bold,
// //                           color: isDark ? Colors.white : AppColors.black,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ).animate().fadeIn().slideY(begin: 0.2),
// //         ],
// //       ],
// //     );
// //   }
// //
// //   void _showCupertinoDatePicker(BuildContext context) {
// //     showModalBottomSheet(
// //       context: context,
// //       builder: (BuildContext builder) {
// //         return Container(
// //           height: 250.h,
// //           child: CupertinoDatePicker(
// //             mode: CupertinoDatePickerMode.date,
// //             initialDateTime: _selectedDate ?? DateTime.now(),
// //             minimumDate: DateTime.now(),
// //             maximumDate: DateTime.now().add(const Duration(days: 60)),
// //             onDateTimeChanged: (DateTime newDate) {
// //               setState(() {
// //                 _selectedDate = newDate;
// //                 _selectedTime = null;
// //               });
// //
// //               final appointmentProvider =
// //                   Provider.of<AppointmentProvider>(context, listen: false);
// //               appointmentProvider.fetchAvailableTimeSlots(
// //                 newDate,
// //                 widget.service.durationMinutes ?? 30,
// //               );
// //             },
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //
// //   Widget _buildTimeSelection(bool isDark) {
// //     final appointmentProvider = Provider.of<AppointmentProvider>(context);
// //
// //     if (_selectedDate == null) {
// //       return Center(
// //         child: Text('الرجاء اختيار التاريخ أولاً',
// //             style: TextStyle(color: Colors.grey.shade500)),
// //       );
// //     }
// //
// //     if (appointmentProvider.isLoading) {
// //       return _buildTimeSelectionShimmer(isDark);
// //     }
// //
// //     if (appointmentProvider.availableTimeSlots.isEmpty) {
// //       return Center(
// //         child: Column(
// //           children: [
// //             Icon(Icons.event_busy_rounded,
// //                 size: 60.sp, color: Colors.grey.shade400),
// //             SizedBox(height: 16.h),
// //             Text(
// //               'لا توجد أوقات متاحة في هذا اليوم',
// //               style: TextStyle(color: Colors.grey.shade500),
// //             ),
// //           ],
// //         ),
// //       );
// //     }
// //
// //     // ✅ التحقق: هل التاريخ المختار هو اليوم؟
// //     // final now = DateTime.now();
// //     // final isToday = _selectedDate!.year == now.year &&
// //     //     _selectedDate!.month == now.month &&
// //     //     _selectedDate!.day == now.day;
// //     //
// //     // final currentTime = TimeOfDay.now();
// //
// //     // ✅ الحصول على وقت السيرفر (أو وقت الهاتف كاحتياطي)
// //     final serverTime = appointmentProvider.serverTime ?? DateTime.now();
// //
// //     // ✅ التحقق: هل التاريخ المختار = اليوم؟
// //     final isToday = _selectedDate!.year == serverTime.year &&
// //         _selectedDate!.month == serverTime.month &&
// //         _selectedDate!.day == serverTime.day;
// //
// //     // ✅ الوقت الحالي من السيرفر
// //     final currentTime = TimeOfDay.fromDateTime(serverTime);
// //
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'اختر الوقت',
// //           style: TextStyle(
// //             fontSize: 18.sp,
// //             fontWeight: FontWeight.bold,
// //             color: isDark ? Colors.white : AppColors.black,
// //           ),
// //         ),
// //         SizedBox(height: 8.h),
// //         Text(
// //           DateFormat('EEEE, d MMMM', 'ar').format(_selectedDate!),
// //           style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
// //         ),
// //         SizedBox(height: 16.h),
// //         GridView.builder(
// //           shrinkWrap: true,
// //           physics: const NeverScrollableScrollPhysics(),
// //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //             crossAxisCount: 3,
// //             crossAxisSpacing: 10.w,
// //             mainAxisSpacing: 10.h,
// //             childAspectRatio: 2.0,
// //           ),
// //           itemCount: appointmentProvider.availableTimeSlots.length,
// //           itemBuilder: (context, index) {
// //             final time = appointmentProvider.availableTimeSlots[index];
// //             final isSelected = _selectedTime == time;
// //
// //             // ✅ تحليل الوقت من String (format: "HH:mm")
// //             final timeParts = time.split(':');
// //             final timeHour = int.tryParse(timeParts[0]) ?? 0;
// //             final timeMinute = timeParts.length > 1
// //                 ? int.tryParse(timeParts[1]) ?? 0
// //                 : 0;
// //
// //             // ✅ التحقق: هل الوقت في الماضي؟
// //             bool isPastTime = false;
// //             if (isToday) {
// //               if (timeHour < currentTime.hour ||
// //                   (timeHour == currentTime.hour && timeMinute <= currentTime.minute)) {
// //                 isPastTime = true;
// //               }
// //             }
// //
// //             return GestureDetector(
// //               onTap: isPastTime
// //                   ? null // ✅ تعطيل الضغط للأوقات الماضية
// //                   : () => setState(() => _selectedTime = time),
// //               child: Opacity(
// //                 opacity: isPastTime ? 0.4 : 1.0, // ✅ شفافية للأوقات الماضية
// //                 child: Container(
// //                   decoration: BoxDecoration(
// //                     color: isPastTime
// //                         ? (isDark ? const Color(0xFF0A0A0A) : Colors.grey.shade100)
// //                         : (isSelected
// //                         ? AppColors.darkRed
// //                         : (isDark ? const Color(0xFF1E1E1E) : Colors.white)),
// //                     borderRadius: BorderRadius.circular(12.r),
// //                     border: Border.all(
// //                       color: isPastTime
// //                           ? (isDark ? Colors.grey.shade900 : Colors.grey.shade300)
// //                           : (isSelected
// //                           ? AppColors.darkRed
// //                           : (isDark
// //                           ? Colors.grey.shade800
// //                           : Colors.grey.shade300)),
// //                     ),
// //                   ),
// //                   child: Stack(
// //                     children: [
// //                       Center(
// //                         child: Text(
// //                           _formatTime(time),
// //                           style: TextStyle(
// //                             fontSize: 12.sp,
// //                             fontWeight:
// //                             isSelected ? FontWeight.bold : FontWeight.normal,
// //                             color: isPastTime
// //                                 ? Colors.grey.shade600
// //                                 : (isSelected
// //                                 ? Colors.white
// //                                 : (isDark ? Colors.white : AppColors.black)),
// //                             decoration: isPastTime
// //                                 ? TextDecoration.lineThrough
// //                                 : null,
// //                           ),
// //                           textAlign: TextAlign.center,
// //                         ),
// //                       ),
// //                       if (isPastTime)
// //                         Positioned(
// //                           top: 4,
// //                           right: 4,
// //                           child: Icon(
// //                             Icons.block_rounded,
// //                             size: 12.sp,
// //                             color: Colors.red.shade300,
// //                           ),
// //                         ),
// //                     ],
// //                   ),
// //                 )
// //                     .animate(delay: Duration(milliseconds: 50 * index))
// //                     .fadeIn()
// //                     .scale(),
// //               ),
// //             );
// //           },
// //         ),
// //       ],
// //     );
// //   }
// //
// //
// //   /// ✅ Shimmer للأوقات
// //   Widget _buildTimeSelectionShimmer(bool isDark) {
// //     return Shimmer.fromColors(
// //       baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
// //       highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Container(
// //             width: 150.w,
// //             height: 20.h,
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(8.r),
// //             ),
// //           ),
// //           SizedBox(height: 16.h),
// //           GridView.builder(
// //             shrinkWrap: true,
// //             physics: const NeverScrollableScrollPhysics(),
// //             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //               crossAxisCount: 3,
// //               crossAxisSpacing: 10.w,
// //               mainAxisSpacing: 10.h,
// //               childAspectRatio: 2.0,
// //             ),
// //             itemCount: 9,
// //             itemBuilder: (_, i) => Container(
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(12.r),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildEmployeeSelection(bool isDark) {
// //     final appointmentProvider = Provider.of<AppointmentProvider>(context);
// //
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'اختر الموظف',
// //           style: TextStyle(
// //             fontSize: 18.sp,
// //             fontWeight: FontWeight.bold,
// //             color: isDark ? Colors.white : AppColors.black,
// //           ),
// //         ),
// //         SizedBox(height: 8.h),
// //         Text(
// //           'يمكنك اختيار أي موظف متاح أو ترك النظام يختار تلقائياً',
// //           style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
// //         ),
// //         SizedBox(height: 16.h),
// //         GestureDetector(
// //           onTap: () => setState(() => _selectedEmployee = null),
// //           child: Container(
// //             margin: EdgeInsets.only(bottom: 12.h),
// //             padding: EdgeInsets.all(16.r),
// //             decoration: BoxDecoration(
// //               color: _selectedEmployee == null
// //                   ? AppColors.gold.withOpacity(0.1)
// //                   : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
// //               borderRadius: BorderRadius.circular(16.r),
// //               border: Border.all(
// //                 color: _selectedEmployee == null
// //                     ? AppColors.gold
// //                     : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
// //                 width: _selectedEmployee == null ? 2 : 1,
// //               ),
// //             ),
// //             child: Row(
// //               children: [
// //                 Container(
// //                   width: 60.w,
// //                   height: 60.h,
// //                   decoration: BoxDecoration(
// //                     color: AppColors.gold.withOpacity(0.2),
// //                     shape: BoxShape.circle,
// //                   ),
// //                   child: Icon(Icons.auto_awesome_rounded,
// //                       color: AppColors.gold, size: 30.sp),
// //                 ),
// //                 SizedBox(width: 16.w),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         'اختيار تلقائي',
// //                         style: TextStyle(
// //                           fontSize: 16.sp,
// //                           fontWeight: FontWeight.bold,
// //                           color: isDark ? Colors.white : AppColors.black,
// //                         ),
// //                       ),
// //                       SizedBox(height: 4.h),
// //                       Text(
// //                         'سيتم اختيار أفضل موظف متاح تلقائياً',
// //                         style: TextStyle(
// //                             fontSize: 12.sp, color: Colors.grey.shade500),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 if (_selectedEmployee == null)
// //                   Icon(Icons.check_circle_rounded,
// //                       color: AppColors.gold, size: 28.sp),
// //               ],
// //             ),
// //           ).animate().fadeIn().slideX(begin: 0.2),
// //         ),
// //         if (appointmentProvider.isLoading)
// //           Center(
// //             child: Padding(
// //               padding: EdgeInsets.all(40.r),
// //               child: Column(
// //                 children: [
// //                   const CircularProgressIndicator(),
// //                   SizedBox(height: 16.h),
// //                   Text('جارٍ تحميل الموظفين...',
// //                       style: TextStyle(color: Colors.grey.shade500)),
// //                 ],
// //               ),
// //             ),
// //           )
// //         else if (appointmentProvider.employees.isNotEmpty)
// //           ListView.builder(
// //             shrinkWrap: true,
// //             physics: const NeverScrollableScrollPhysics(),
// //             itemCount: appointmentProvider.employees.length,
// //             itemBuilder: (context, index) {
// //               final employee = appointmentProvider.employees[index];
// //               final isSelected = _selectedEmployee?.id == employee.id;
// //
// //               return GestureDetector(
// //                 onTap: () => setState(() => _selectedEmployee = employee),
// //                 child: Container(
// //                   margin: EdgeInsets.only(bottom: 12.h),
// //                   padding: EdgeInsets.all(16.r),
// //                   decoration: BoxDecoration(
// //                     color: isSelected
// //                         ? AppColors.darkRed.withOpacity(0.1)
// //                         : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
// //                     borderRadius: BorderRadius.circular(16.r),
// //                     border: Border.all(
// //                       color: isSelected
// //                           ? AppColors.darkRed
// //                           : (isDark
// //                               ? Colors.grey.shade800
// //                               : Colors.grey.shade200),
// //                       width: isSelected ? 2 : 1,
// //                     ),
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       CircleAvatar(
// //                         radius: 30.r,
// //                         backgroundColor: Colors.grey.shade300,
// //                         backgroundImage: employee.profileImageUrl != null &&
// //                                 employee.profileImageUrl!.isNotEmpty
// //                             ? NetworkImage(employee.profileImageUrl!)
// //                             : null,
// //                         child: employee.profileImageUrl == null ||
// //                                 employee.profileImageUrl!.isEmpty
// //                             ? Icon(Icons.person, size: 30.sp)
// //                             : null,
// //                       ),
// //                       SizedBox(width: 16.w),
// //                       Expanded(
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               employee.fullName,
// //                               style: TextStyle(
// //                                 fontSize: 16.sp,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: isDark ? Colors.white : AppColors.black,
// //                               ),
// //                             ),
// //                             if (employee.specialties != null &&
// //                                 employee.specialties!.isNotEmpty) ...[
// //                               SizedBox(height: 4.h),
// //                               Text(
// //                                 employee.specialties!.join(' • '),
// //                                 style: TextStyle(
// //                                     fontSize: 12.sp,
// //                                     color: Colors.grey.shade500),
// //                               ),
// //                             ],
// //                           ],
// //                         ),
// //                       ),
// //                       if (isSelected)
// //                         Icon(Icons.check_circle_rounded,
// //                             color: AppColors.darkRed, size: 28.sp),
// //                     ],
// //                   ),
// //                 )
// //                     .animate(delay: Duration(milliseconds: 100 * (index + 1)))
// //                     .fadeIn()
// //                     .slideX(begin: 0.2),
// //               );
// //             },
// //           )
// //         else
// //           Padding(
// //             padding: EdgeInsets.all(20.r),
// //             child: Center(
// //               child: Text(
// //                 'لا يوجد موظفون متاحون حالياً',
// //                 style: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
// //               ),
// //             ),
// //           ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildNotesAndSummary(bool isDark) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'ملاحظات إضافية',
// //           style: TextStyle(
// //             fontSize: 18.sp,
// //             fontWeight: FontWeight.bold,
// //             color: isDark ? Colors.white : AppColors.black,
// //           ),
// //         ),
// //         SizedBox(height: 16.h),
// //         TextField(
// //           controller: _notesController,
// //           maxLines: 4,
// //           style: TextStyle(color: isDark ? Colors.white : AppColors.black),
// //           decoration: InputDecoration(
// //             hintText: 'أضف أي ملاحظات خاصة بموعدك...',
// //             hintStyle: TextStyle(color: Colors.grey.shade500),
// //             filled: true,
// //             fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
// //             border: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(12.r),
// //               borderSide: BorderSide(
// //                   color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
// //             ),
// //           ),
// //         ),
// //         SizedBox(height: 24.h),
// //
// //         // ✅ إخفاء Coupon إذا كان هناك عرض
// //         if (_appliedOffer == null)
// //           CouponInputWidget(
// //             amount: widget.service.price,
// //             onCouponApplied: (discount) {
// //               setState(() {});
// //             },
// //           ),
// //
// //         if (_appliedOffer == null) SizedBox(height: 24.h),
// //
// //         Text(
// //           'ملخص الحجز',
// //           style: TextStyle(
// //             fontSize: 18.sp,
// //             fontWeight: FontWeight.bold,
// //             color: isDark ? Colors.white : AppColors.black,
// //           ),
// //         ),
// //         SizedBox(height: 16.h),
// //         _buildSummaryCard(isDark),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildSummaryCard(bool isDark) {
// //     return Consumer2<CouponProvider, LoyaltyTransactionProvider>(
// //       builder: (context, couponProvider, loyaltyProvider, _) {
// //         final originalPrice = widget.service.price;
// //
// //         // ✅ الأولوية للعرض، ثم الكوبون
// //         double totalDiscount = 0;
// //         String discountSource = '';
// //
// //         if (_discountAmount > 0) {
// //           totalDiscount = _discountAmount;
// //           discountSource = _appliedOffer!['title_ar'] as String;
// //         } else {
// //           totalDiscount = couponProvider.discountAmount ?? 0;
// //           if (couponProvider.appliedCoupon != null) {
// //             discountSource = couponProvider.appliedCoupon!.code;
// //           }
// //         }
// //
// //         final finalPrice = originalPrice - totalDiscount;
// //         final pointsToEarn = loyaltyProvider.calculateLoyaltyPoints(finalPrice);
// //
// //         return Container(
// //           padding: EdgeInsets.all(20.r),
// //           decoration: BoxDecoration(
// //             color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
// //             borderRadius: BorderRadius.circular(16.r),
// //             border: Border.all(
// //                 color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
// //           ),
// //           child: Column(
// //             children: [
// //               _buildSummaryRow(
// //                   Icons.design_services_rounded,
// //                   'الخدمة',
// //                   widget.service.serviceNameAr ??
// //                       widget.service.serviceName ??
// //                       '',
// //                   isDark),
// //               Divider(height: 24.h),
// //               _buildSummaryRow(
// //                   Icons.calendar_today_rounded,
// //                   'التاريخ',
// //                   _selectedDate != null
// //                       ? DateFormat('EEEE, d MMMM', 'ar').format(_selectedDate!)
// //                       : '-',
// //                   isDark),
// //               Divider(height: 24.h),
// //               _buildSummaryRow(
// //                   Icons.access_time_rounded,
// //                   'الوقت',
// //                   _selectedTime != null ? _formatTime(_selectedTime!) : '-',
// //                   isDark),
// //               Divider(height: 24.h),
// //               _buildSummaryRow(Icons.person_rounded, 'الموظف',
// //                   _selectedEmployee?.fullName ?? 'اختيار تلقائي', isDark),
// //               Divider(height: 24.h),
// //               _buildSummaryRow(Icons.access_time, 'المدة',
// //                   '${widget.service.durationMinutes} دقيقة', isDark),
// //               Divider(height: 24.h),
// //               _buildSummaryRow(
// //                 Icons.payments_rounded,
// //                 'السعر الأصلي',
// //                 '${originalPrice.toStringAsFixed(0)} ريال',
// //                 isDark,
// //                 isStrikethrough: totalDiscount > 0,
// //               ),
// //               if (totalDiscount > 0) ...[
// //                 Divider(height: 24.h),
// //                 Row(
// //                   children: [
// //                     Icon(
// //                       _discountAmount > 0
// //                           ? Icons.local_offer_rounded
// //                           : Icons.discount_rounded,
// //                       color: Colors.green,
// //                       size: 22.sp,
// //                     ),
// //                     SizedBox(width: 12.w),
// //                     Expanded(
// //                       child: Text(
// //                         'الخصم ($discountSource)',
// //                         style: TextStyle(
// //                             fontSize: 14.sp,
// //                             color: Colors.green,
// //                             fontWeight: FontWeight.bold),
// //                       ),
// //                     ),
// //                     Text(
// //                       '- ${totalDiscount.toStringAsFixed(0)} ريال',
// //                       style: TextStyle(
// //                         fontSize: 15.sp,
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.green,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //               Divider(height: 24.h),
// //               Row(
// //                 children: [
// //                   Icon(Icons.payment_rounded,
// //                       color: AppColors.gold, size: 22.sp),
// //                   SizedBox(width: 12.w),
// //                   Expanded(
// //                     child: Text(
// //                       'الإجمالي',
// //                       style: TextStyle(
// //                         fontSize: 16.sp,
// //                         fontWeight: FontWeight.bold,
// //                         color: isDark ? Colors.white : AppColors.black,
// //                       ),
// //                     ),
// //                   ),
// //                   Text(
// //                     '${finalPrice.toStringAsFixed(0)} ريال',
// //                     style: TextStyle(
// //                       fontSize: 18.sp,
// //                       fontWeight: FontWeight.bold,
// //                       color: AppColors.gold,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               if (totalDiscount > 0)
// //                 Padding(
// //                   padding: EdgeInsets.only(top: 12.h),
// //                   child: Container(
// //                     padding:
// //                         EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
// //                     decoration: BoxDecoration(
// //                       color: Colors.green.withOpacity(0.1),
// //                       borderRadius: BorderRadius.circular(20.r),
// //                     ),
// //                     child: Text(
// //                       '🎉 وفرت ${totalDiscount.toStringAsFixed(0)} ريال',
// //                       style: TextStyle(
// //                         fontSize: 13.sp,
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.green,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               if (pointsToEarn > 0) ...[
// //                 SizedBox(height: 12.h),
// //                 Container(
// //                   padding:
// //                       EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
// //                   decoration: BoxDecoration(
// //                     color: AppColors.gold.withOpacity(0.1),
// //                     borderRadius: BorderRadius.circular(20.r),
// //                     border: Border.all(color: AppColors.gold.withOpacity(0.3)),
// //                   ),
// //                   child: Row(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       Icon(Icons.stars_rounded,
// //                           color: AppColors.gold, size: 18.sp),
// //                       SizedBox(width: 6.w),
// //                       Text(
// //                         'سوف تكسب $pointsToEarn نقطة ولاء',
// //                         style: TextStyle(
// //                           fontSize: 13.sp,
// //                           fontWeight: FontWeight.bold,
// //                           color: AppColors.gold,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ],
// //           ),
// //         ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
// //       },
// //     );
// //   }
// //
// //   Widget _buildSummaryRow(
// //       IconData icon, String label, String value, bool isDark,
// //       {bool isPrice = false, bool isStrikethrough = false}) {
// //     return Row(
// //       children: [
// //         Icon(icon, color: AppColors.darkRed, size: 22.sp),
// //         SizedBox(width: 12.w),
// //         Expanded(
// //           child: Text(
// //             label,
// //             style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
// //           ),
// //         ),
// //         Text(
// //           value,
// //           style: TextStyle(
// //             fontSize: 15.sp,
// //             fontWeight: FontWeight.bold,
// //             color: isPrice
// //                 ? AppColors.gold
// //                 : (isDark ? Colors.white : AppColors.black),
// //             decoration: isStrikethrough ? TextDecoration.lineThrough : null,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildBottomButtons(bool isDark) {
// //     return Container(
// //       padding: EdgeInsets.all(20.r),
// //       decoration: BoxDecoration(
// //         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.1),
// //             blurRadius: 10,
// //             offset: const Offset(0, -2),
// //           ),
// //         ],
// //       ),
// //       child: SafeArea(
// //         child: Row(
// //           children: [
// //             if (_currentStep > 0 && !_isConfirming)
// //               Expanded(
// //                 child: OutlinedButton(
// //                   onPressed: () => setState(() => _currentStep--),
// //                   style: OutlinedButton.styleFrom(
// //                     padding: EdgeInsets.symmetric(vertical: 16.h),
// //                     side: const BorderSide(color: AppColors.darkRed),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(12.r),
// //                     ),
// //                     foregroundColor: AppColors.darkRed,
// //                   ),
// //                   child: Text(
// //                     'السابق',
// //                     style: TextStyle(
// //                       fontSize: 16.sp,
// //                       fontWeight: FontWeight.bold,
// //                       color: AppColors.darkRed,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             if (_currentStep > 0 && !_isConfirming) SizedBox(width: 12.w),
// //             Expanded(
// //               flex: 2,
// //               child: ElevatedButton(
// //                 onPressed: (_canProceed() && !_isConfirming)
// //                     ? _handleNextOrConfirm
// //                     : null,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: AppColors.darkRed,
// //                   foregroundColor: Colors.white,
// //                   disabledBackgroundColor: Colors.grey.shade300,
// //                   disabledForegroundColor: Colors.grey.shade500,
// //                   padding: EdgeInsets.symmetric(vertical: 16.h),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(12.r),
// //                   ),
// //                 ),
// //                 child: _isConfirming
// //                     ? SizedBox(
// //                         height: 20.h,
// //                         width: 20.w,
// //                         child: const CircularProgressIndicator(
// //                           strokeWidth: 2,
// //                           valueColor:
// //                               AlwaysStoppedAnimation<Color>(Colors.white),
// //                         ),
// //                       )
// //                     : Text(
// //                         _currentStep == 3 ? 'تأكيد الحجز' : 'التالي',
// //                         style: TextStyle(
// //                           fontSize: 16.sp,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.white,
// //                         ),
// //                       ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   bool _canProceed() {
// //     switch (_currentStep) {
// //       case 0:
// //         return _selectedDate != null;
// //       case 1:
// //         return _selectedTime != null;
// //       case 2:
// //         return true;
// //       case 3:
// //         return true;
// //       default:
// //         return false;
// //     }
// //   }
// //
// //   void _handleNextOrConfirm() {
// //     if (_currentStep < 3) {
// //       setState(() => _currentStep++);
// //     } else {
// //       _confirmBooking();
// //     }
// //   }
// //
// //   Future<void> _confirmBooking() async {
// //     final userProvider = Provider.of<UserProvider>(context, listen: false);
// //     final notificationProvider =
// //     Provider.of<NotificationProvider>(context, listen: false);
// //     final couponProvider = Provider.of<CouponProvider>(context, listen: false);
// //     // ملاحظة: لا نستخدم LoyaltyTransactionProvider هنا أبداً للإدراج.
// //
// //     if (userProvider.user == null) {
// //       CustomSnackbar.showError(context, 'يجب تسجيل الدخول أولاً');
// //       return;
// //     }
// //
// //     if (_isConfirming) return;
// //     setState(() => _isConfirming = true);
// //
// //     final originalPrice = widget.service.price;
// //
// //     double totalDiscount = 0;
// //     double couponDiscount = couponProvider.discountAmount ?? 0;
// //     double offerDiscount = _discountAmount;
// //
// //     if (_appliedOffer != null && offerDiscount > 0) {
// //       totalDiscount = offerDiscount;
// //     } else if (couponDiscount > 0) {
// //       totalDiscount = couponDiscount;
// //     }
// //
// //     final finalPrice = originalPrice - totalDiscount;
// //
// //     // حساب النقاط (فقط للعرض - لا ترسلها للداتابيز أبداً هنا)
// //     final pointsEarned = LoyaltyEngine.calculatePoints(finalPrice); // استخدم الدالة الموحدة
// //
// //     final appointmentData = {
// //       'user_id': userProvider.user!.id,
// //       'employee_id': _selectedEmployee?.id,
// //       'appointment_date': _selectedDate!.toIso8601String().split('T')[0],
// //       'appointment_time': _selectedTime,
// //       'duration_minutes': widget.service.durationMinutes,
// //       'total_price': originalPrice,
// //       'discount_amount': totalDiscount,
// //       'coupon_id': couponProvider.appliedCoupon?.id,
// //       'client_name': userProvider.user!.fullName,
// //       'client_phone': userProvider.user!.phone,
// //       'notes': _notesController.text.trim().isEmpty
// //           ? null
// //           : _notesController.text.trim(),
// //       'payment_status': 'unpaid',
// //       'status': 'pending',
// //       // يمكنك إضافة 'loyalty_points_earned': pointsEarned فقط للعرض، ليس للاحتساب!
// //     };
// //
// //     try {
// //       final appointmentResponse = await Supabase.instance.client
// //           .from('appointments')
// //           .insert(appointmentData)
// //           .select()
// //           .single();
// //
// //       final appointmentId = appointmentResponse['id'] as int;
// //
// //       await Supabase.instance.client.from('appointment_services').insert({
// //         'appointment_id': appointmentId,
// //         'service_id': widget.service.id,
// //         'service_price': widget.service.price,
// //         'service_duration': widget.service.durationMinutes,
// //         'employee_id': _selectedEmployee?.id,
// //         'status': 'pending',
// //       });
// //
// //       if (couponProvider.appliedCoupon != null && couponDiscount > 0) {
// //         await couponProvider.useCoupon(
// //           appointmentId: appointmentId,
// //           userId: userProvider.user!.id!,
// //         );
// //       }
// //
// //       if (_appliedOfferId != null && offerDiscount > 0) {
// //         await Supabase.instance.client.from('offer_usage').insert({
// //           'offer_id': _appliedOfferId,
// //           'user_id': userProvider.user!.id,
// //           'appointment_id': appointmentId,
// //           'discount_applied': offerDiscount,
// //           'usage_date': DateTime.now().toUtc().toIso8601String(),
// //         });
// //
// //         await Supabase.instance.client.from('offers').update({
// //           'current_usage': (_appliedOffer!['current_usage'] as int? ?? 0) + 1
// //         }).eq('id', _appliedOfferId!);
// //       }
// //
// //       // ❌ لا تضف نقاط يدوياً هنا!
// //       // ✅ النقاط تخصم وتمنح أوتوماتيكياً في قاعدة البيانات عند تحديث حالة الحجز (عبر Trigger).
// //
// //       await notificationProvider.createBookingNotification(
// //         userId: userProvider.user!.id!,
// //         appointmentId: appointmentId,
// //         serviceName: widget.service.serviceNameAr ??
// //             widget.service.serviceName ??
// //             'الخدمة',
// //         appointmentDate: _selectedDate!,
// //         appointmentTime: _selectedTime!,
// //       );
// //
// //       if (mounted) {
// //         // شاشة النجاح وعرض ملخص الحجز والخصم
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(
// //             builder: (_) => BookingSuccessScreen(
// //               bookingData: {
// //                 'service_name':
// //                 widget.service.serviceNameAr ?? widget.service.serviceName,
// //                 'date': _selectedDate,
// //                 'time': _selectedTime,
// //                 'final_price': finalPrice,
// //                 'discount': totalDiscount > 0 ? totalDiscount : null,
// //                 'points_earned': pointsEarned > 0 ? pointsEarned : null, // للعرض فقط
// //               },
// //             ),
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         CustomSnackbar.showError(
// //             context, 'فشل إنشاء الحجز. يرجى المحاولة مرة أخرى');
// //       }
// //     } finally {
// //       setState(() => _isConfirming = false);
// //     }
// //   }
// //
// // }
// //
// // class LoyaltyEngine {
// //   /// احسب النقاط بناءً على السعر النهائي
// //   static int calculatePoints(double finalPrice) {
// //     // افتراض نقطة واحدة لكل 10 ريال
// //     return finalPrice ~/ 1000;
// //   }
// // }
//
//
//
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:intl/intl.dart';
// import 'package:millionaire_barber/features/appointments/domain/models/electronic_wallet_model.dart';
// import 'package:millionaire_barber/features/appointments/domain/models/employee_model.dart';
// import 'package:millionaire_barber/features/appointments/presentation/pages/appointment_success_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'dart:ui' as ui;
// import '../../../../core/constants/app_colors.dart';
// import '../../../../shared/widgets/custom_snackbar.dart';
// import '../../../profile/presentation/providers/user_provider.dart';
// import '../../../services/domain/models/service_model.dart';
// import '../../../coupons/presentation/providers/coupon_provider.dart';
// import '../../../coupons/presentation/widgets/coupon_input_widget.dart';
// import '../../../loyalty/presentation/providers/loyalty_transaction_provider.dart';
// import '../../../notifications/presentation/providers/notification_provider.dart';
// import '../providers/appointment_provider.dart';
// import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
//
// import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
//
// class BookAppointmentScreen extends StatefulWidget {
//   final ServiceModel service;
//
//   const BookAppointmentScreen({Key? key, required this.service})
//       : super(key: key);
//
//   @override
//   State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
// }
//
// class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
//   DateTime? _selectedDate;
//   String? _selectedTime;
//   EmployeeModel? _selectedEmployee;
//   final _notesController = TextEditingController();
//   int _currentStep = 0;
//
//   // ✅ متغير Loader
//   bool _isConfirming = false;
//
//   // ✅ متغيرات العروض
//   Map<String, dynamic>? _appliedOffer;
//   String? _appliedPromoCode;
//   int? _appliedOfferId;
//   double _discountAmount = 0.0;
//
//   // ── أضفها مع باقي المتغيرات في الأعلى ──────────────────────────
//   String _paymentMethod = 'cash';                      // 'cash' | 'electronic'
//   ElectronicWalletModel? _selectedWallet;              // المحفظة المختارة
//   File? _receiptFile;                                  // ملف الإيصال
//   List<ElectronicWalletModel> _wallets = [];           // قائمة المحافظ
//   bool _loadingWallets = false;                        // loading state
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _initializeScreen();
//     });
//   }
//
//   Future<void> _initializeScreen() async {
//
//
//     final appointmentProvider =
//     Provider.of<AppointmentProvider>(context, listen: false);
//     appointmentProvider.fetchAvailableEmployees();
//
//     // ✅ جلب وقت السيرفر أولاً (مهم جداً!)
//     await appointmentProvider.fetchServerTime();
//
//
//     final couponProvider = Provider.of<CouponProvider>(context, listen: false);
//     couponProvider.removeCoupon();
//
//     final loyaltyProvider =
//     Provider.of<LoyaltyTransactionProvider>(context, listen: false);
//     loyaltyProvider.fetchLoyaltySettings();
//     _fetchWallets();                                   // ← أضف هذا السطر
//
//     // ✅ استقبال العرض من arguments
//     final args =
//     ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
//
//     if (args != null) {
//       final offer = args['applied_offer'] as Map<String, dynamic>?;
//       final offerId = args['offer_id'] as int?;
//       final promoCode = args['promo_code'] as String?;
//
//       if (offer != null) {
//         setState(() {
//           _appliedOffer = offer;
//           _appliedOfferId = offerId;
//           _appliedPromoCode = promoCode;
//         });
//
//
//         _calculateOfferDiscount();
//
//         Future.delayed(const Duration(milliseconds: 500), () {
//           if (mounted) {
//             CustomSnackbar.showSuccess(
//               context,
//               '🎉 تم تطبيق عرض: ${offer['title_ar']}',
//             );
//           }
//         });
//       }
//     }
//   }
//
//   Future<void> _fetchWallets() async {
//     if (!mounted) return;
//     setState(() => _loadingWallets = true);
//
//     try {
//       final response = await Supabase.instance.client
//           .from('electronic_wallets')
//           .select()
//           .eq('is_active', true)
//           .order('display_order');
//
//       if (mounted) {
//         setState(() {
//           _wallets = (response as List)
//               .map((w) => ElectronicWalletModel.fromJson(w as Map<String, dynamic>))
//               .toList();
//         });
//       }
//     } catch (_) {
//       // wallets تبقى فارغة — لا تؤثر على باقي الشاشة
//     } finally {
//       if (mounted) setState(() => _loadingWallets = false);
//     }
//   }
//
//   Future<void> _pickAndCompressReceipt() async {
//     final picker = ImagePicker();
//     final picked = await picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 100, // نضغطها يدوياً لاحقاً
//     );
//     if (picked == null) return;
//
//     final originalFile = File(picked.path);
//
//     // ── ضغط الصورة بقوة: max 800px، جودة 50 ──────────────────
//     final compressedBytes = await FlutterImageCompress.compressWithFile(
//       originalFile.absolute.path,
//       minWidth:  800,
//       minHeight: 800,
//       quality:   50,
//       format:    CompressFormat.jpeg,
//     );
//
//     if (compressedBytes == null) return;
//
//     // حفظ الصورة المضغوطة في temp directory
//     final tempDir  = Directory.systemTemp;
//     final tempFile = File(
//       '${tempDir.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.jpg',
//     );
//     await tempFile.writeAsBytes(compressedBytes);
//
//     if (mounted) {
//       setState(() => _receiptFile = tempFile);
//     }
//   }
//
//   Widget _buildPaymentSection(bool isDark) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(height: 24.h),
//
//         // ── العنوان ────────────────────────────────────────────
//         Text(
//           'طريقة الدفع',
//           style: TextStyle(
//             fontSize: 18.sp,
//             fontWeight: FontWeight.bold,
//             color: isDark ? Colors.white : AppColors.black,
//           ),
//         ),
//         SizedBox(height: 16.h),
//
//         // ── خيار كاش ───────────────────────────────────────────
//         _buildPaymentOption(
//           isDark:   isDark,
//           value:    'cash',
//           icon:     Icons.payments_rounded,
//           iconColor: Colors.green,
//           title:    'الدفع نقداً',
//           subtitle: 'ادفع عند وصولك للصالون',
//         ),
//
//         SizedBox(height: 10.h),
//
//         // ── خيار إلكتروني ───────────────────────────────────────
//         _buildPaymentOption(
//           isDark:   isDark,
//           value:    'electronic',
//           icon:     Icons.account_balance_wallet_rounded,
//           iconColor: const Color(0xFFB8860B),
//           title:    'الدفع الإلكتروني',
//           subtitle: 'تحويل عبر المحفظة الإلكترونية',
//         ),
//
//         // ── قسم المحفظة والإيصال (يظهر فقط عند الإلكتروني) ──────
//         if (_paymentMethod == 'electronic') ...[
//           SizedBox(height: 16.h),
//           _buildWalletSelector(isDark),
//           SizedBox(height: 16.h),
//           _buildReceiptUploader(isDark),
//         ],
//       ],
//     );
//   }
//
//   Widget _buildPaymentOption({
//     required bool isDark,
//     required String value,
//     required IconData icon,
//     required Color iconColor,
//     required String title,
//     required String subtitle,
//   }) {
//     final isSelected = _paymentMethod == value;
//
//     return GestureDetector(
//       onTap: () => setState(() {
//         _paymentMethod    = value;
//         _selectedWallet   = null;
//         _receiptFile      = null;
//       }),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: EdgeInsets.all(16.r),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? (value == 'cash'
//               ? Colors.green.withValues(alpha: 0.08)
//               : const Color(0xFFB8860B).withValues(alpha: 0.08))
//               : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
//           borderRadius: BorderRadius.circular(16.r),
//           border: Border.all(
//             color: isSelected
//                 ? (value == 'cash' ? Colors.green : const Color(0xFFB8860B))
//                 : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
//             width: isSelected ? 2 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(10.r),
//               decoration: BoxDecoration(
//                 color: iconColor.withValues(alpha: 0.12),
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: Icon(icon, color: iconColor, size: 24.sp),
//             ),
//             SizedBox(width: 14.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title,
//                       style: TextStyle(
//                         fontSize: 15.sp,
//                         fontWeight: FontWeight.bold,
//                         color: isDark ? Colors.white : AppColors.black,
//                       )),
//                   SizedBox(height: 3.h),
//                   Text(subtitle,
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         color: isDark
//                             ? Colors.grey.shade400
//                             : Colors.grey.shade600,
//                       )),
//                 ],
//               ),
//             ),
//             AnimatedSwitcher(
//               duration: const Duration(milliseconds: 200),
//               child: isSelected
//                   ? Icon(Icons.check_circle_rounded,
//                   key: const ValueKey('checked'),
//                   color: value == 'cash'
//                       ? Colors.green
//                       : const Color(0xFFB8860B),
//                   size: 26.sp)
//                   : Icon(Icons.radio_button_unchecked_rounded,
//                   key: const ValueKey('unchecked'),
//                   color: isDark
//                       ? Colors.grey.shade600
//                       : Colors.grey.shade400,
//                   size: 26.sp),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
// // ── اختيار المحفظة ──────────────────────────────────────────────
//   Widget _buildWalletSelector(bool isDark) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('اختر المحفظة',
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w600,
//               color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
//             )),
//         SizedBox(height: 10.h),
//
//         if (_loadingWallets)
//           Center(child: SizedBox(
//             width: 24.w, height: 24.h,
//             child: const CircularProgressIndicator(strokeWidth: 2),
//           ))
//         else if (_wallets.isEmpty)
//           Container(
//             padding: EdgeInsets.all(14.r),
//             decoration: BoxDecoration(
//               color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(
//                   color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
//             ),
//             child: Row(children: [
//               Icon(Icons.info_outline_rounded,
//                   color: Colors.orange, size: 18.sp),
//               SizedBox(width: 8.w),
//               Text('لا توجد محافظ متاحة حالياً',
//                   style: TextStyle(
//                       fontSize: 13.sp, color: Colors.grey.shade500)),
//             ]),
//           )
//         else
//           Column(
//             children: _wallets.map((wallet) {
//               final isSelected = _selectedWallet?.id == wallet.id;
//               return GestureDetector(
//                 onTap: () => setState(() => _selectedWallet = wallet),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 180),
//                   margin: EdgeInsets.only(bottom: 8.h),
//                   padding: EdgeInsets.symmetric(
//                       horizontal: 14.w, vertical: 12.h),
//                   decoration: BoxDecoration(
//                     color: isSelected
//                         ? const Color(0xFFB8860B).withValues(alpha: 0.08)
//                         : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
//                     borderRadius: BorderRadius.circular(12.r),
//                     border: Border.all(
//                       color: isSelected
//                           ? const Color(0xFFB8860B)
//                           : (isDark
//                           ? Colors.grey.shade800
//                           : Colors.grey.shade200),
//                       width: isSelected ? 1.8 : 1,
//                     ),
//                   ),
//                   child: Row(children: [
//                     // أيقونة المحفظة
//                     Container(
//                       width: 40.w, height: 40.h,
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFB8860B).withValues(alpha: 0.1),
//                         borderRadius: BorderRadius.circular(10.r),
//                       ),
//                       child: Center(
//                         child: wallet.iconUrl != null &&
//                             wallet.iconUrl!.isNotEmpty
//                             ? Image.network(wallet.iconUrl!,
//                             width: 26.w, height: 26.h,
//                             errorBuilder: (_, __, ___) => Icon(
//                                 Icons.account_balance_wallet_rounded,
//                                 color: const Color(0xFFB8860B),
//                                 size: 22.sp))
//                             : Icon(Icons.account_balance_wallet_rounded,
//                             color: const Color(0xFFB8860B), size: 22.sp),
//                       ),
//                     ),
//                     SizedBox(width: 12.w),
//
//                     // الاسم ورقم الهاتف
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             wallet.walletNameAr.isNotEmpty
//                                 ? wallet.walletNameAr
//                                 : wallet.walletName,
//                             style: TextStyle(
//                               fontSize: 14.sp,
//                               fontWeight: FontWeight.bold,
//                               color: isDark ? Colors.white : AppColors.black,
//                             ),
//                           ),
//                           SizedBox(height: 2.h),
//                           Text(wallet.phoneNumber,
//                               style: TextStyle(
//                                   fontSize: 12.sp,
//                                   color: Colors.grey.shade500)),
//                         ],
//                       ),
//                     ),
//
//                     if (isSelected)
//                       Icon(Icons.check_circle_rounded,
//                           color: const Color(0xFFB8860B), size: 22.sp),
//                   ]),
//                 ),
//               );
//             }).toList(),
//           ),
//       ],
//     ).animate().fadeIn().slideY(begin: 0.1);
//   }
//
// // ── رفع الإيصال ────────────────────────────────────────────────
//   Widget _buildReceiptUploader(bool isDark) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(children: [
//           Text('إيصال الدفع',
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 fontWeight: FontWeight.w600,
//                 color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
//               )),
//           SizedBox(width: 6.w),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
//             decoration: BoxDecoration(
//               color: Colors.red.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(6.r),
//             ),
//             child: Text('مطلوب',
//                 style: TextStyle(
//                     fontSize: 10.sp,
//                     color: Colors.red,
//                     fontWeight: FontWeight.bold)),
//           ),
//         ]),
//         SizedBox(height: 10.h),
//
//         GestureDetector(
//           onTap: _pickAndCompressReceipt,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             width: double.infinity,
//             constraints: BoxConstraints(minHeight: 120.h),
//             decoration: BoxDecoration(
//               color: _receiptFile != null
//                   ? Colors.green.withValues(alpha: 0.05)
//                   : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
//               borderRadius: BorderRadius.circular(16.r),
//               border: Border.all(
//                 color: _receiptFile != null
//                     ? Colors.green
//                     : const Color(0xFFB8860B).withValues(alpha: 0.4),
//                 width: 1.5,
//                 style: _receiptFile != null
//                     ? BorderStyle.solid
//                     : BorderStyle.solid,
//               ),
//             ),
//             child: _receiptFile != null
//                 ? Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(14.r),
//                   child: Image.file(
//                     _receiptFile!,
//                     width: double.infinity,
//                     height: 160.h,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 // زر حذف
//                 Positioned(
//                   top: 8, left: 8,
//                   child: GestureDetector(
//                     onTap: () => setState(() => _receiptFile = null),
//                     child: Container(
//                       padding: EdgeInsets.all(6.r),
//                       decoration: const BoxDecoration(
//                         color: Colors.red,
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(Icons.close_rounded,
//                           color: Colors.white, size: 16.sp),
//                     ),
//                   ),
//                 ),
//                 // شارة نجاح
//                 Positioned(
//                   bottom: 8, right: 8,
//                   child: Container(
//                     padding: EdgeInsets.symmetric(
//                         horizontal: 10.w, vertical: 5.h),
//                     decoration: BoxDecoration(
//                       color: Colors.green,
//                       borderRadius: BorderRadius.circular(20.r),
//                     ),
//                     child: Row(mainAxisSize: MainAxisSize.min, children: [
//                       Icon(Icons.check_rounded,
//                           color: Colors.white, size: 13.sp),
//                       SizedBox(width: 4.w),
//                       Text('تم الرفع',
//                           style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 11.sp,
//                               fontWeight: FontWeight.bold)),
//                     ]),
//                   ),
//                 ),
//               ],
//             )
//                 : Padding(
//               padding: EdgeInsets.all(20.r),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(14.r),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFB8860B).withValues(alpha: 0.1),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(Icons.upload_file_rounded,
//                         color: const Color(0xFFB8860B), size: 30.sp),
//                   ),
//                   SizedBox(height: 12.h),
//                   Text('اضغط لرفع إيصال الدفع',
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w600,
//                         color: isDark
//                             ? Colors.grey.shade300
//                             : Colors.grey.shade700,
//                       )),
//                   SizedBox(height: 4.h),
//                   Text('سيتم ضغط الصورة تلقائياً',
//                       style: TextStyle(
//                           fontSize: 11.sp,
//                           color: Colors.grey.shade500)),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     ).animate().fadeIn().slideY(begin: 0.1);
//   }
//
//   void _calculateOfferDiscount() {
//     if (_appliedOffer == null) {
//       setState(() {
//         _discountAmount = 0;
//       });
//       return;
//     }
//
//     final discountType = _appliedOffer!['discount_type'] as String;
//     final discountValue = (_appliedOffer!['discount_value'] as num).toDouble();
//     final minPurchase =
//         (_appliedOffer!['min_purchase_amount'] as num?)?.toDouble() ?? 0;
//     final maxDiscount =
//     (_appliedOffer!['max_discount_amount'] as num?)?.toDouble();
//     final originalPrice = widget.service.price;
//
//     if (originalPrice < minPurchase) {
//       CustomSnackbar.showError(
//         context,
//         'الحد الأدنى للشراء ${minPurchase.toInt()} ر.س',
//       );
//       setState(() {
//         _appliedOffer = null;
//         _discountAmount = 0;
//       });
//       return;
//     }
//
//     double discount = 0;
//
//     if (discountType == 'percentage') {
//       discount = originalPrice * (discountValue / 100);
//     } else if (discountType == 'fixed_amount') {
//       discount = discountValue;
//     }
//
//     if (maxDiscount != null && discount > maxDiscount) {
//       discount = maxDiscount;
//     }
//
//     if (discount > originalPrice) {
//       discount = originalPrice;
//     }
//
//     setState(() {
//       _discountAmount = discount;
//     });
//   }
//
//   @override
//   void dispose() {
//     _notesController.dispose();
//     super.dispose();
//   }
//
//   String _formatDate(DateTime date) {
//     final days = [
//       'الأحد',
//       'الاثنين',
//       'الثلاثاء',
//       'الأربعاء',
//       'الخميس',
//       'الجمعة',
//       'السبت'
//     ];
//     final months = [
//       'يناير',
//       'فبراير',
//       'مارس',
//       'أبريل',
//       'مايو',
//       'يونيو',
//       'يوليو',
//       'أغسطس',
//       'سبتمبر',
//       'أكتوبر',
//       'نوفمبر',
//       'ديسمبر'
//     ];
//
//     final dayName = days[date.weekday % 7];
//     final monthName = months[date.month - 1];
//
//     return '$dayName، ${date.day} $monthName ${date.year}';
//   }
//
//   /// ✅ تنسيق الوقت - hh:mm ص/م
//   String _formatTime(String time) {
//     try {
//       final parts = time.split(':');
//       final hour = int.parse(parts[0]);
//       final minute = parts.length > 1 ? parts[1] : '00';
//
//       if (hour == 0) {
//         return '12:$minute ص';
//       } else if (hour < 12) {
//         return '$hour:$minute ص';
//       } else if (hour == 12) {
//         return '12:$minute م';
//       } else {
//         return '${hour - 12}:$minute م';
//       }
//     } catch (e) {
//       return time;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Directionality(
//       textDirection: ui.TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor:
//         isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
//         appBar: AppBar(
//           backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//           elevation: 0,
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back_ios,
//                 color: isDark ? Colors.white : AppColors.black),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: Text(
//             'حجز موعد',
//             style: TextStyle(
//               fontSize: 20.sp,
//               fontWeight: FontWeight.bold,
//               color: isDark ? Colors.white : AppColors.black,
//             ),
//           ),
//           centerTitle: true,
//         ),
//         body: Column(
//           children: [
//             _buildStepIndicator(isDark),
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.all(20.w),
//                 child: Column(
//                   children: [
//                     _buildServiceCard(isDark),
//                     SizedBox(height: 24.h),
//
//                     // ✅ بطاقة العرض - تظهر في جميع الخطوات
//                     if (_appliedOffer != null) ...[
//                       _buildAppliedOfferCard(isDark),
//                       SizedBox(height: 24.h),
//                     ],
//
//                     // ✅ بطاقة العرض المطبق
//
//                     if (_currentStep == 0) _buildDateSelection(isDark),
//                     if (_currentStep == 1) _buildTimeSelection(isDark),
//                     if (_currentStep == 2) _buildEmployeeSelection(isDark),
//                     if (_currentStep == 3) _buildNotesAndSummary(isDark),
//                   ],
//                 ),
//               ),
//             ),
//             _buildBottomButtons(isDark),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildStepIndicator(bool isDark) {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           _buildStepItem(0, 'التاريخ', Icons.calendar_today_rounded, isDark),
//           _buildStepLine(0, isDark),
//           _buildStepItem(1, 'الوقت', Icons.access_time_rounded, isDark),
//           _buildStepLine(1, isDark),
//           _buildStepItem(2, 'الموظف', Icons.person_rounded, isDark),
//           _buildStepLine(2, isDark),
//           _buildStepItem(3, 'التأكيد', Icons.check_circle_rounded, isDark),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStepItem(int step, String label, IconData icon, bool isDark) {
//     final isActive = _currentStep == step;
//     final isCompleted = _currentStep > step;
//
//     return Expanded(
//       child: Column(
//         children: [
//           Container(
//             width: 40.w,
//             height: 40.h,
//             decoration: BoxDecoration(
//               color: isCompleted || isActive
//                   ? AppColors.darkRed
//                   : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               isCompleted ? Icons.check_rounded : icon,
//               color:
//               isCompleted || isActive ? Colors.white : Colors.grey.shade500,
//               size: 20.sp,
//             ),
//           ),
//           SizedBox(height: 6.h),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 11.sp,
//               fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//               color: isActive
//                   ? AppColors.darkRed
//                   : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStepLine(int step, bool isDark) {
//     final isCompleted = _currentStep > step;
//     return Expanded(
//       child: Container(
//         height: 2,
//         margin: EdgeInsets.only(bottom: 30.h),
//         color: isCompleted
//             ? AppColors.darkRed
//             : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade300),
//       ),
//     );
//   }
//
//   Widget _buildServiceCard(bool isDark) {
//     return Container(
//       padding: EdgeInsets.all(16.r),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(
//             color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12.r),
//             child: widget.service.imageUrl != null &&
//                 widget.service.imageUrl!.isNotEmpty
//                 ? Image.network(
//               widget.service.imageUrl!,
//               width: 70.w,
//               height: 70.h,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) => _buildPlaceholder(isDark),
//             )
//                 : _buildPlaceholder(isDark),
//           ),
//           SizedBox(width: 16.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.service.serviceNameAr ??
//                       widget.service.serviceName ??
//                       '',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                     color: isDark ? Colors.white : AppColors.black,
//                   ),
//                 ),
//                 SizedBox(height: 6.h),
//                 Row(
//                   children: [
//                     Icon(Icons.access_time,
//                         size: 16.sp, color: Colors.grey.shade500),
//                     SizedBox(width: 4.w),
//                     Text(
//                       '${widget.service.durationMinutes} دقيقة',
//                       style: TextStyle(
//                           fontSize: 13.sp, color: Colors.grey.shade500),
//                     ),
//                     SizedBox(width: 16.w),
//                     Icon(Icons.payments_rounded,
//                         size: 16.sp, color: AppColors.gold),
//                     SizedBox(width: 4.w),
//                     Text(
//                       '${widget.service.price.toStringAsFixed(0)} ريال',
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.gold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     ).animate().fadeIn().slideY(begin: 0.2);
//   }
//
//   Widget _buildPlaceholder(bool isDark) {
//     return Container(
//       width: 70.w,
//       height: 70.h,
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200,
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child:
//       Icon(Icons.content_cut_rounded, color: AppColors.gold, size: 30.sp),
//     );
//   }
//
//   /// ✅ بطاقة العرض المطبق
//   Widget _buildAppliedOfferCard(bool isDark) {
//     final title = _appliedOffer!['title_ar'] as String;
//     final discountType = _appliedOffer!['discount_type'] as String;
//     final discountValue = (_appliedOffer!['discount_value'] as num).toDouble();
//
//     String discountText = '';
//     if (discountType == 'percentage') {
//       discountText = '${discountValue.toInt()}%';
//     } else {
//       discountText = '${discountValue.toInt()} ر.س';
//     }
//
//     return Container(
//       margin: EdgeInsets.only(bottom: 24.h),
//       padding: EdgeInsets.all(16.r),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [AppColors.gold, AppColors.goldDark],
//         ),
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.gold.withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(12.r),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.3),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.local_offer_rounded,
//               color: Colors.white,
//               size: 24.sp,
//             ),
//           ),
//           SizedBox(width: 16.w),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'عرض مطبق 🎉',
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     color: Colors.white.withOpacity(0.9),
//                   ),
//                 ),
//                 SizedBox(height: 4.h),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12.r),
//             ),
//             child: Text(
//               discountText,
//               style: TextStyle(
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.darkRed,
//               ),
//             ),
//           ),
//           SizedBox(width: 8.w),
//           IconButton(
//             onPressed: _removeOffer,
//             icon: Icon(
//               Icons.close_rounded,
//               color: Colors.white,
//               size: 20.sp,
//             ),
//             tooltip: 'إزالة العرض',
//           ),
//         ],
//       ),
//     ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.3);
//   }
//
//   void _removeOffer() {
//     setState(() {
//       _appliedOffer = null;
//       _appliedOfferId = null;
//       _appliedPromoCode = null;
//       _discountAmount = 0;
//     });
//
//     CustomSnackbar.showSuccess(context, 'تم إزالة العرض');
//   }
//
//   Widget _buildDateSelection(bool isDark) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'اختر التاريخ',
//           style: TextStyle(
//             fontSize: 18.sp,
//             fontWeight: FontWeight.bold,
//             color: isDark ? Colors.white : AppColors.black,
//           ),
//         ),
//         SizedBox(height: 16.h),
//         PlatformWidget(
//           material: (_, __) => Container(
//             padding: EdgeInsets.all(16.r),
//             decoration: BoxDecoration(
//               color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//               borderRadius: BorderRadius.circular(16.r),
//               border: Border.all(
//                   color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
//             ),
//             child: CalendarDatePicker(
//               initialDate: _selectedDate ?? DateTime.now(),
//               firstDate: DateTime.now(),
//               lastDate: DateTime.now().add(const Duration(days: 60)),
//               onDateChanged: (DateTime newDate) {
//                 setState(() {
//                   _selectedDate = newDate;
//                   _selectedTime = null;
//                 });
//
//                 final appointmentProvider =
//                 Provider.of<AppointmentProvider>(context, listen: false);
//                 appointmentProvider.fetchAvailableTimeSlots(
//                   newDate,
//                   widget.service.durationMinutes ?? 30,
//                 );
//               },
//             ),
//           ),
//           cupertino: (_, __) => GestureDetector(
//             onTap: () => _showCupertinoDatePicker(context),
//             child: Container(
//               padding: EdgeInsets.all(20.r),
//               decoration: BoxDecoration(
//                 color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//                 borderRadius: BorderRadius.circular(16.r),
//                 border: Border.all(
//                     color:
//                     isDark ? Colors.grey.shade800 : Colors.grey.shade200),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.calendar_month_rounded,
//                       color: AppColors.darkRed, size: 28.sp),
//                   SizedBox(width: 16.w),
//                   Expanded(
//                     child: Text(
//                       _selectedDate != null
//                           ? _formatDate(_selectedDate!)
//                           : 'اضغط لاختيار التاريخ',
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w600,
//                         color: isDark ? Colors.white : AppColors.black,
//                       ),
//                     ),
//                   ),
//                   Icon(Icons.arrow_forward_ios,
//                       size: 16.sp, color: Colors.grey),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         if (_selectedDate != null) ...[
//           SizedBox(height: 16.h),
//           Container(
//             padding: EdgeInsets.all(16.r),
//             decoration: BoxDecoration(
//               color: AppColors.darkRed.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(color: AppColors.darkRed.withOpacity(0.3)),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.event_available,
//                     color: AppColors.darkRed, size: 24.sp),
//                 SizedBox(width: 12.w),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'التاريخ المحدد',
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: isDark
//                               ? Colors.grey.shade400
//                               : AppColors.greyDark,
//                         ),
//                       ),
//                       SizedBox(height: 4.h),
//                       Text(
//                         _formatDate(_selectedDate!),
//                         style: TextStyle(
//                           fontSize: 15.sp,
//                           fontWeight: FontWeight.bold,
//                           color: isDark ? Colors.white : AppColors.black,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ).animate().fadeIn().slideY(begin: 0.2),
//         ],
//       ],
//     );
//   }
//
//   void _showCupertinoDatePicker(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext builder) {
//         return Container(
//           height: 250.h,
//           child: CupertinoDatePicker(
//             mode: CupertinoDatePickerMode.date,
//             initialDateTime: _selectedDate ?? DateTime.now(),
//             minimumDate: DateTime.now(),
//             maximumDate: DateTime.now().add(const Duration(days: 60)),
//             onDateTimeChanged: (DateTime newDate) {
//               setState(() {
//                 _selectedDate = newDate;
//                 _selectedTime = null;
//               });
//
//               final appointmentProvider =
//               Provider.of<AppointmentProvider>(context, listen: false);
//               appointmentProvider.fetchAvailableTimeSlots(
//                 newDate,
//                 widget.service.durationMinutes ?? 30,
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
//
//
//   Widget _buildTimeSelection(bool isDark) {
//     final appointmentProvider = Provider.of<AppointmentProvider>(context);
//
//     if (_selectedDate == null) {
//       return Center(
//         child: Text('الرجاء اختيار التاريخ أولاً',
//             style: TextStyle(color: Colors.grey.shade500)),
//       );
//     }
//
//     if (appointmentProvider.isLoading) {
//       return _buildTimeSelectionShimmer(isDark);
//     }
//
//     if (appointmentProvider.availableTimeSlots.isEmpty) {
//       return Center(
//         child: Column(
//           children: [
//             Icon(Icons.event_busy_rounded,
//                 size: 60.sp, color: Colors.grey.shade400),
//             SizedBox(height: 16.h),
//             Text(
//               'لا توجد أوقات متاحة في هذا اليوم',
//               style: TextStyle(color: Colors.grey.shade500),
//             ),
//           ],
//         ),
//       );
//     }
//
//     // ✅ التحقق: هل التاريخ المختار هو اليوم؟
//     // final now = DateTime.now();
//     // final isToday = _selectedDate!.year == now.year &&
//     //     _selectedDate!.month == now.month &&
//     //     _selectedDate!.day == now.day;
//     //
//     // final currentTime = TimeOfDay.now();
//
//     // ✅ الحصول على وقت السيرفر (أو وقت الهاتف كاحتياطي)
//     final serverTime = appointmentProvider.serverTime ?? DateTime.now();
//
//     // ✅ التحقق: هل التاريخ المختار = اليوم؟
//     final isToday = _selectedDate!.year == serverTime.year &&
//         _selectedDate!.month == serverTime.month &&
//         _selectedDate!.day == serverTime.day;
//
//     // ✅ الوقت الحالي من السيرفر
//     final currentTime = TimeOfDay.fromDateTime(serverTime);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'اختر الوقت',
//           style: TextStyle(
//             fontSize: 18.sp,
//             fontWeight: FontWeight.bold,
//             color: isDark ? Colors.white : AppColors.black,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Text(
//           DateFormat('EEEE, d MMMM', 'ar').format(_selectedDate!),
//           style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
//         ),
//         SizedBox(height: 16.h),
//         GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 3,
//             crossAxisSpacing: 10.w,
//             mainAxisSpacing: 10.h,
//             childAspectRatio: 2.0,
//           ),
//           itemCount: appointmentProvider.availableTimeSlots.length,
//           itemBuilder: (context, index) {
//             final time = appointmentProvider.availableTimeSlots[index];
//             final isSelected = _selectedTime == time;
//
//             // ✅ تحليل الوقت من String (format: "HH:mm")
//             final timeParts = time.split(':');
//             final timeHour = int.tryParse(timeParts[0]) ?? 0;
//             final timeMinute = timeParts.length > 1
//                 ? int.tryParse(timeParts[1]) ?? 0
//                 : 0;
//
//             // ✅ التحقق: هل الوقت في الماضي؟
//             bool isPastTime = false;
//             if (isToday) {
//               if (timeHour < currentTime.hour ||
//                   (timeHour == currentTime.hour && timeMinute <= currentTime.minute)) {
//                 isPastTime = true;
//               }
//             }
//
//             return GestureDetector(
//               onTap: isPastTime
//                   ? null // ✅ تعطيل الضغط للأوقات الماضية
//                   : () => setState(() => _selectedTime = time),
//               child: Opacity(
//                 opacity: isPastTime ? 0.4 : 1.0, // ✅ شفافية للأوقات الماضية
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: isPastTime
//                         ? (isDark ? const Color(0xFF0A0A0A) : Colors.grey.shade100)
//                         : (isSelected
//                         ? AppColors.darkRed
//                         : (isDark ? const Color(0xFF1E1E1E) : Colors.white)),
//                     borderRadius: BorderRadius.circular(12.r),
//                     border: Border.all(
//                       color: isPastTime
//                           ? (isDark ? Colors.grey.shade900 : Colors.grey.shade300)
//                           : (isSelected
//                           ? AppColors.darkRed
//                           : (isDark
//                           ? Colors.grey.shade800
//                           : Colors.grey.shade300)),
//                     ),
//                   ),
//                   child: Stack(
//                     children: [
//                       Center(
//                         child: Text(
//                           _formatTime(time),
//                           style: TextStyle(
//                             fontSize: 12.sp,
//                             fontWeight:
//                             isSelected ? FontWeight.bold : FontWeight.normal,
//                             color: isPastTime
//                                 ? Colors.grey.shade600
//                                 : (isSelected
//                                 ? Colors.white
//                                 : (isDark ? Colors.white : AppColors.black)),
//                             decoration: isPastTime
//                                 ? TextDecoration.lineThrough
//                                 : null,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                       if (isPastTime)
//                         Positioned(
//                           top: 4,
//                           right: 4,
//                           child: Icon(
//                             Icons.block_rounded,
//                             size: 12.sp,
//                             color: Colors.red.shade300,
//                           ),
//                         ),
//                     ],
//                   ),
//                 )
//                     .animate(delay: Duration(milliseconds: 50 * index))
//                     .fadeIn()
//                     .scale(),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }
//
//
//   /// ✅ Shimmer للأوقات
//   Widget _buildTimeSelectionShimmer(bool isDark) {
//     return Shimmer.fromColors(
//       baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
//       highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 150.w,
//             height: 20.h,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8.r),
//             ),
//           ),
//           SizedBox(height: 16.h),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 3,
//               crossAxisSpacing: 10.w,
//               mainAxisSpacing: 10.h,
//               childAspectRatio: 2.0,
//             ),
//             itemCount: 9,
//             itemBuilder: (_, i) => Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEmployeeSelection(bool isDark) {
//     final appointmentProvider = Provider.of<AppointmentProvider>(context);
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'اختر الموظف',
//           style: TextStyle(
//             fontSize: 18.sp,
//             fontWeight: FontWeight.bold,
//             color: isDark ? Colors.white : AppColors.black,
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Text(
//           'يمكنك اختيار أي موظف متاح أو ترك النظام يختار تلقائياً',
//           style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
//         ),
//         SizedBox(height: 16.h),
//         GestureDetector(
//           onTap: () => setState(() => _selectedEmployee = null),
//           child: Container(
//             margin: EdgeInsets.only(bottom: 12.h),
//             padding: EdgeInsets.all(16.r),
//             decoration: BoxDecoration(
//               color: _selectedEmployee == null
//                   ? AppColors.gold.withOpacity(0.1)
//                   : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
//               borderRadius: BorderRadius.circular(16.r),
//               border: Border.all(
//                 color: _selectedEmployee == null
//                     ? AppColors.gold
//                     : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
//                 width: _selectedEmployee == null ? 2 : 1,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 60.w,
//                   height: 60.h,
//                   decoration: BoxDecoration(
//                     color: AppColors.gold.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(Icons.auto_awesome_rounded,
//                       color: AppColors.gold, size: 30.sp),
//                 ),
//                 SizedBox(width: 16.w),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'اختيار تلقائي',
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.bold,
//                           color: isDark ? Colors.white : AppColors.black,
//                         ),
//                       ),
//                       SizedBox(height: 4.h),
//                       Text(
//                         'سيتم اختيار أفضل موظف متاح تلقائياً',
//                         style: TextStyle(
//                             fontSize: 12.sp, color: Colors.grey.shade500),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (_selectedEmployee == null)
//                   Icon(Icons.check_circle_rounded,
//                       color: AppColors.gold, size: 28.sp),
//               ],
//             ),
//           ).animate().fadeIn().slideX(begin: 0.2),
//         ),
//         if (appointmentProvider.isLoading)
//           Center(
//             child: Padding(
//               padding: EdgeInsets.all(40.r),
//               child: Column(
//                 children: [
//                   const CircularProgressIndicator(),
//                   SizedBox(height: 16.h),
//                   Text('جارٍ تحميل الموظفين...',
//                       style: TextStyle(color: Colors.grey.shade500)),
//                 ],
//               ),
//             ),
//           )
//         else if (appointmentProvider.employees.isNotEmpty)
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: appointmentProvider.employees.length,
//             itemBuilder: (context, index) {
//               final employee = appointmentProvider.employees[index];
//               final isSelected = _selectedEmployee?.id == employee.id;
//
//               return GestureDetector(
//                 onTap: () => setState(() => _selectedEmployee = employee),
//                 child: Container(
//                   margin: EdgeInsets.only(bottom: 12.h),
//                   padding: EdgeInsets.all(16.r),
//                   decoration: BoxDecoration(
//                     color: isSelected
//                         ? AppColors.darkRed.withOpacity(0.1)
//                         : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
//                     borderRadius: BorderRadius.circular(16.r),
//                     border: Border.all(
//                       color: isSelected
//                           ? AppColors.darkRed
//                           : (isDark
//                           ? Colors.grey.shade800
//                           : Colors.grey.shade200),
//                       width: isSelected ? 2 : 1,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 30.r,
//                         backgroundColor: Colors.grey.shade300,
//                         backgroundImage: employee.profileImageUrl != null &&
//                             employee.profileImageUrl!.isNotEmpty
//                             ? NetworkImage(employee.profileImageUrl!)
//                             : null,
//                         child: employee.profileImageUrl == null ||
//                             employee.profileImageUrl!.isEmpty
//                             ? Icon(Icons.person, size: 30.sp)
//                             : null,
//                       ),
//                       SizedBox(width: 16.w),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               employee.fullName,
//                               style: TextStyle(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.bold,
//                                 color: isDark ? Colors.white : AppColors.black,
//                               ),
//                             ),
//                             if (employee.specialties != null &&
//                                 employee.specialties!.isNotEmpty) ...[
//                               SizedBox(height: 4.h),
//                               Text(
//                                 employee.specialties!.join(' • '),
//                                 style: TextStyle(
//                                     fontSize: 12.sp,
//                                     color: Colors.grey.shade500),
//                               ),
//                             ],
//                           ],
//                         ),
//                       ),
//                       if (isSelected)
//                         Icon(Icons.check_circle_rounded,
//                             color: AppColors.darkRed, size: 28.sp),
//                     ],
//                   ),
//                 )
//                     .animate(delay: Duration(milliseconds: 100 * (index + 1)))
//                     .fadeIn()
//                     .slideX(begin: 0.2),
//               );
//             },
//           )
//         else
//           Padding(
//             padding: EdgeInsets.all(20.r),
//             child: Center(
//               child: Text(
//                 'لا يوجد موظفون متاحون حالياً',
//                 style: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp),
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   // Widget _buildNotesAndSummary(bool isDark) {
//   //   return Column(
//   //     crossAxisAlignment: CrossAxisAlignment.start,
//   //     children: [
//   //       Text(
//   //         'ملاحظات إضافية',
//   //         style: TextStyle(
//   //           fontSize: 18.sp,
//   //           fontWeight: FontWeight.bold,
//   //           color: isDark ? Colors.white : AppColors.black,
//   //         ),
//   //       ),
//   //       SizedBox(height: 16.h),
//   //       TextField(
//   //         controller: _notesController,
//   //         maxLines: 4,
//   //         style: TextStyle(color: isDark ? Colors.white : AppColors.black),
//   //         decoration: InputDecoration(
//   //           hintText: 'أضف أي ملاحظات خاصة بموعدك...',
//   //           hintStyle: TextStyle(color: Colors.grey.shade500),
//   //           filled: true,
//   //           fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//   //           border: OutlineInputBorder(
//   //             borderRadius: BorderRadius.circular(12.r),
//   //             borderSide: BorderSide(
//   //                 color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
//   //           ),
//   //         ),
//   //       ),
//   //       SizedBox(height: 24.h),
//   //
//   //       // ✅ إخفاء Coupon إذا كان هناك عرض
//   //       if (_appliedOffer == null)
//   //         CouponInputWidget(
//   //           amount: widget.service.price,
//   //           onCouponApplied: (discount) {
//   //             setState(() {});
//   //           },
//   //         ),
//   //
//   //       if (_appliedOffer == null) SizedBox(height: 24.h),
//   //
//   //       Text(
//   //         'ملخص الحجز',
//   //         style: TextStyle(
//   //           fontSize: 18.sp,
//   //           fontWeight: FontWeight.bold,
//   //           color: isDark ? Colors.white : AppColors.black,
//   //         ),
//   //       ),
//   //       SizedBox(height: 16.h),
//   //       _buildSummaryCard(isDark),
//   //     ],
//   //   );
//   // }
//
//   Widget _buildNotesAndSummary(bool isDark) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('ملاحظات إضافية',
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.bold,
//               color: isDark ? Colors.white : AppColors.black,
//             )),
//         SizedBox(height: 16.h),
//         TextField(
//           controller: _notesController,
//           maxLines: 4,
//           style: TextStyle(color: isDark ? Colors.white : AppColors.black),
//           decoration: InputDecoration(
//             hintText: 'أضف أي ملاحظات خاصة بموعدك...',
//             hintStyle: TextStyle(color: Colors.grey.shade500),
//             filled: true,
//             fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.r),
//               borderSide: BorderSide(
//                   color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
//             ),
//           ),
//         ),
//         SizedBox(height: 24.h),
//
//         // ✅ قسم طريقة الدفع الجديد
//         _buildPaymentSection(isDark),
//
//         SizedBox(height: 24.h),
//
//         if (_appliedOffer == null)
//           CouponInputWidget(
//             amount: widget.service.price,
//             onCouponApplied: (discount) => setState(() {}),
//           ),
//
//         if (_appliedOffer == null) SizedBox(height: 24.h),
//
//         Text('ملخص الحجز',
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.bold,
//               color: isDark ? Colors.white : AppColors.black,
//             )),
//         SizedBox(height: 16.h),
//         _buildSummaryCard(isDark),
//       ],
//     );
//   }
//
//   Widget _buildSummaryCard(bool isDark) {
//     return Consumer2<CouponProvider, LoyaltyTransactionProvider>(
//       builder: (context, couponProvider, loyaltyProvider, _) {
//         final originalPrice = widget.service.price;
//
//         // ✅ الأولوية للعرض، ثم الكوبون
//         double totalDiscount = 0;
//         String discountSource = '';
//
//         if (_discountAmount > 0) {
//           totalDiscount = _discountAmount;
//           discountSource = _appliedOffer!['title_ar'] as String;
//         } else {
//           totalDiscount = couponProvider.discountAmount ?? 0;
//           if (couponProvider.appliedCoupon != null) {
//             discountSource = couponProvider.appliedCoupon!.code;
//           }
//         }
//
//         final finalPrice = originalPrice - totalDiscount;
//         final pointsToEarn = loyaltyProvider.calculateLoyaltyPoints(finalPrice);
//
//         return Container(
//           padding: EdgeInsets.all(20.r),
//           decoration: BoxDecoration(
//             color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//             borderRadius: BorderRadius.circular(16.r),
//             border: Border.all(
//                 color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
//           ),
//           child: Column(
//             children: [
//               _buildSummaryRow(
//                   Icons.design_services_rounded,
//                   'الخدمة',
//                   widget.service.serviceNameAr ??
//                       widget.service.serviceName ??
//                       '',
//                   isDark),
//               Divider(height: 24.h),
//               _buildSummaryRow(
//                   Icons.calendar_today_rounded,
//                   'التاريخ',
//                   _selectedDate != null
//                       ? DateFormat('EEEE, d MMMM', 'ar').format(_selectedDate!)
//                       : '-',
//                   isDark),
//               Divider(height: 24.h),
//               _buildSummaryRow(
//                   Icons.access_time_rounded,
//                   'الوقت',
//                   _selectedTime != null ? _formatTime(_selectedTime!) : '-',
//                   isDark),
//               Divider(height: 24.h),
//               _buildSummaryRow(Icons.person_rounded, 'الموظف',
//                   _selectedEmployee?.fullName ?? 'اختيار تلقائي', isDark),
//               Divider(height: 24.h),
//               _buildSummaryRow(Icons.access_time, 'المدة',
//                   '${widget.service.durationMinutes} دقيقة', isDark),
//               Divider(height: 24.h),
//               _buildSummaryRow(
//                 Icons.payments_rounded,
//                 'السعر الأصلي',
//                 '${originalPrice.toStringAsFixed(0)} ريال',
//                 isDark,
//                 isStrikethrough: totalDiscount > 0,
//               ),
//               if (totalDiscount > 0) ...[
//                 Divider(height: 24.h),
//                 Row(
//                   children: [
//                     Icon(
//                       _discountAmount > 0
//                           ? Icons.local_offer_rounded
//                           : Icons.discount_rounded,
//                       color: Colors.green,
//                       size: 22.sp,
//                     ),
//                     SizedBox(width: 12.w),
//                     Expanded(
//                       child: Text(
//                         'الخصم ($discountSource)',
//                         style: TextStyle(
//                             fontSize: 14.sp,
//                             color: Colors.green,
//                             fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     Text(
//                       '- ${totalDiscount.toStringAsFixed(0)} ريال',
//                       style: TextStyle(
//                         fontSize: 15.sp,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//               Divider(height: 24.h),
//               Row(
//                 children: [
//                   Icon(Icons.payment_rounded,
//                       color: AppColors.gold, size: 22.sp),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     child: Text(
//                       'الإجمالي',
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.bold,
//                         color: isDark ? Colors.white : AppColors.black,
//                       ),
//                     ),
//                   ),
//                   Text(
//                     '${finalPrice.toStringAsFixed(0)} ريال',
//                     style: TextStyle(
//                       fontSize: 18.sp,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.gold,
//                     ),
//                   ),
//                 ],
//               ),
//               if (totalDiscount > 0)
//                 Padding(
//                   padding: EdgeInsets.only(top: 12.h),
//                   child: Container(
//                     padding:
//                     EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//                     decoration: BoxDecoration(
//                       color: Colors.green.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20.r),
//                     ),
//                     child: Text(
//                       '🎉 وفرت ${totalDiscount.toStringAsFixed(0)} ريال',
//                       style: TextStyle(
//                         fontSize: 13.sp,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                   ),
//                 ),
//               if (pointsToEarn > 0) ...[
//                 SizedBox(height: 12.h),
//                 Container(
//                   padding:
//                   EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//                   decoration: BoxDecoration(
//                     color: AppColors.gold.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(20.r),
//                     border: Border.all(color: AppColors.gold.withOpacity(0.3)),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.stars_rounded,
//                           color: AppColors.gold, size: 18.sp),
//                       SizedBox(width: 6.w),
//                       Text(
//                         'سوف تكسب $pointsToEarn نقطة ولاء',
//                         style: TextStyle(
//                           fontSize: 13.sp,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.gold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
//       },
//     );
//   }
//
//   Widget _buildSummaryRow(
//       IconData icon, String label, String value, bool isDark,
//       {bool isPrice = false, bool isStrikethrough = false}) {
//     return Row(
//       children: [
//         Icon(icon, color: AppColors.darkRed, size: 22.sp),
//         SizedBox(width: 12.w),
//         Expanded(
//           child: Text(
//             label,
//             style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 15.sp,
//             fontWeight: FontWeight.bold,
//             color: isPrice
//                 ? AppColors.gold
//                 : (isDark ? Colors.white : AppColors.black),
//             decoration: isStrikethrough ? TextDecoration.lineThrough : null,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildBottomButtons(bool isDark) {
//     return Container(
//       padding: EdgeInsets.all(20.r),
//       decoration: BoxDecoration(
//         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             if (_currentStep > 0 && !_isConfirming)
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () => setState(() => _currentStep--),
//                   style: OutlinedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(vertical: 16.h),
//                     side: const BorderSide(color: AppColors.darkRed),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     foregroundColor: AppColors.darkRed,
//                   ),
//                   child: Text(
//                     'السابق',
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.darkRed,
//                     ),
//                   ),
//                 ),
//               ),
//             if (_currentStep > 0 && !_isConfirming) SizedBox(width: 12.w),
//             Expanded(
//               flex: 2,
//               child: ElevatedButton(
//                 onPressed: (_canProceed() && !_isConfirming)
//                     ? _handleNextOrConfirm
//                     : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.darkRed,
//                   foregroundColor: Colors.white,
//                   disabledBackgroundColor: Colors.grey.shade300,
//                   disabledForegroundColor: Colors.grey.shade500,
//                   padding: EdgeInsets.symmetric(vertical: 16.h),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                 ),
//                 child: _isConfirming
//                     ? SizedBox(
//                   height: 20.h,
//                   width: 20.w,
//                   child: const CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor:
//                     AlwaysStoppedAnimation<Color>(Colors.white),
//                   ),
//                 )
//                     : Text(
//                   _currentStep == 3 ? 'تأكيد الحجز' : 'التالي',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
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
//   // bool _canProceed() {
//   //   switch (_currentStep) {
//   //     case 0:
//   //       return _selectedDate != null;
//   //     case 1:
//   //       return _selectedTime != null;
//   //     case 2:
//   //       return true;
//   //     case 3:
//   //       return true;
//   //     default:
//   //       return false;
//   //   }
//   // }
//
//   bool _canProceed() {
//     switch (_currentStep) {
//       case 0: return _selectedDate != null;
//       case 1: return _selectedTime != null;
//       case 2: return true;
//       case 3:
//       // ✅ إذا إلكتروني: يجب اختيار محفظة ورفع إيصال
//         if (_paymentMethod == 'electronic') {
//           return _selectedWallet != null && _receiptFile != null;
//         }
//         return true;
//       default: return false;
//     }
//   }
//
//   void _handleNextOrConfirm() {
//     if (_currentStep < 3) {
//       setState(() => _currentStep++);
//     } else {
//       _confirmBooking();
//     }
//   }
//
//   // Future<void> _confirmBooking() async {
//   //   final userProvider = Provider.of<UserProvider>(context, listen: false);
//   //   final notificationProvider =
//   //   Provider.of<NotificationProvider>(context, listen: false);
//   //   final couponProvider = Provider.of<CouponProvider>(context, listen: false);
//   //   // ملاحظة: لا نستخدم LoyaltyTransactionProvider هنا أبداً للإدراج.
//   //
//   //   if (userProvider.user == null) {
//   //     CustomSnackbar.showError(context, 'يجب تسجيل الدخول أولاً');
//   //     return;
//   //   }
//   //
//   //   if (_isConfirming) return;
//   //   setState(() => _isConfirming = true);
//   //
//   //   final originalPrice = widget.service.price;
//   //
//   //   double totalDiscount = 0;
//   //   double couponDiscount = couponProvider.discountAmount ?? 0;
//   //   double offerDiscount = _discountAmount;
//   //
//   //   if (_appliedOffer != null && offerDiscount > 0) {
//   //     totalDiscount = offerDiscount;
//   //   } else if (couponDiscount > 0) {
//   //     totalDiscount = couponDiscount;
//   //   }
//   //
//   //   final finalPrice = originalPrice - totalDiscount;
//   //
//   //   // حساب النقاط (فقط للعرض - لا ترسلها للداتابيز أبداً هنا)
//   //   final pointsEarned = LoyaltyEngine.calculatePoints(finalPrice); // استخدم الدالة الموحدة
//   //
//   //   // final appointmentData = {
//   //   //   'user_id': userProvider.user!.id,
//   //   //   'employee_id': _selectedEmployee?.id,
//   //   //   'appointment_date': _selectedDate!.toIso8601String().split('T')[0],
//   //   //   'appointment_time': _selectedTime,
//   //   //   'duration_minutes': widget.service.durationMinutes,
//   //   //   'total_price': originalPrice,
//   //   //   'discount_amount': totalDiscount,
//   //   //   'coupon_id': couponProvider.appliedCoupon?.id,
//   //   //   'client_name': userProvider.user!.fullName,
//   //   //   'client_phone': userProvider.user!.phone,
//   //   //   'notes': _notesController.text.trim().isEmpty
//   //   //       ? null
//   //   //       : _notesController.text.trim(),
//   //   //   'payment_status': 'unpaid',
//   //   //   'status': 'pending',
//   //   //   // يمكنك إضافة 'loyalty_points_earned': pointsEarned فقط للعرض، ليس للاحتساب!
//   //   // };
//   //
//   //   // استبدل appointmentData بهذا:
//   //   final appointmentData = {
//   //     'user_id':          userProvider.user!.id,
//   //     'employee_id':      _selectedEmployee?.id,
//   //     'appointment_date': _selectedDate!.toIso8601String().split('T')[0],
//   //     'appointment_time': _selectedTime,
//   //     'duration_minutes': widget.service.durationMinutes,
//   //     'total_price':      originalPrice,
//   //     'discount_amount':  totalDiscount,
//   //     'coupon_id':        couponProvider.appliedCoupon?.id,
//   //     'client_name':      userProvider.user!.fullName,
//   //     'client_phone':     userProvider.user!.phone,
//   //     'notes':            _notesController.text.trim().isEmpty
//   //         ? null
//   //         : _notesController.text.trim(),
//   //     'payment_status':   'unpaid',
//   //     'status':           'pending',
//   //     // ✅ جديد
//   //     'payment_method':        _paymentMethod,
//   //     'electronic_wallet_id':  _selectedWallet?.id,
//   //     'persons_count':         1,
//   //   };
//   //
//   //   try {
//   //     final appointmentResponse = await Supabase.instance.client
//   //         .from('appointments')
//   //         .insert(appointmentData)
//   //         .select()
//   //         .single();
//   //
//   //     final appointmentId = appointmentResponse['id'] as int;
//   //
//   //     await Supabase.instance.client.from('appointment_services').insert({
//   //       'appointment_id': appointmentId,
//   //       'service_id': widget.service.id,
//   //       'service_price': widget.service.price,
//   //       'service_duration': widget.service.durationMinutes,
//   //       'employee_id': _selectedEmployee?.id,
//   //       'status': 'pending',
//   //     });
//   //
//   //     if (couponProvider.appliedCoupon != null && couponDiscount > 0) {
//   //       await couponProvider.useCoupon(
//   //         appointmentId: appointmentId,
//   //         userId: userProvider.user!.id!,
//   //       );
//   //     }
//   //
//   //     if (_appliedOfferId != null && offerDiscount > 0) {
//   //       await Supabase.instance.client.from('offer_usage').insert({
//   //         'offer_id': _appliedOfferId,
//   //         'user_id': userProvider.user!.id,
//   //         'appointment_id': appointmentId,
//   //         'discount_applied': offerDiscount,
//   //         'usage_date': DateTime.now().toUtc().toIso8601String(),
//   //       });
//   //
//   //       await Supabase.instance.client.from('offers').update({
//   //         'current_usage': (_appliedOffer!['current_usage'] as int? ?? 0) + 1
//   //       }).eq('id', _appliedOfferId!);
//   //     }
//   //
//   //     // ❌ لا تضف نقاط يدوياً هنا!
//   //     // ✅ النقاط تخصم وتمنح أوتوماتيكياً في قاعدة البيانات عند تحديث حالة الحجز (عبر Trigger).
//   //
//   //     await notificationProvider.createBookingNotification(
//   //       userId: userProvider.user!.id!,
//   //       appointmentId: appointmentId,
//   //       serviceName: widget.service.serviceNameAr ??
//   //           widget.service.serviceName ??
//   //           'الخدمة',
//   //       appointmentDate: _selectedDate!,
//   //       appointmentTime: _selectedTime!,
//   //     );
//   //
//   //     if (mounted) {
//   //       // شاشة النجاح وعرض ملخص الحجز والخصم
//   //       Navigator.pushReplacement(
//   //         context,
//   //         MaterialPageRoute(
//   //           builder: (_) => BookingSuccessScreen(
//   //             bookingData: {
//   //               'service_name':
//   //               widget.service.serviceNameAr ?? widget.service.serviceName,
//   //               'date': _selectedDate,
//   //               'time': _selectedTime,
//   //               'final_price': finalPrice,
//   //               'discount': totalDiscount > 0 ? totalDiscount : null,
//   //               'points_earned': pointsEarned > 0 ? pointsEarned : null, // للعرض فقط
//   //             },
//   //           ),
//   //         ),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     if (mounted) {
//   //       CustomSnackbar.showError(
//   //           context, 'فشل إنشاء الحجز. يرجى المحاولة مرة أخرى');
//   //     }
//   //   } finally {
//   //     setState(() => _isConfirming = false);
//   //   }
//   // }
//
//   Future<void> _confirmBooking() async {
//     final userProvider =
//     Provider.of<UserProvider>(context, listen: false);
//     final notificationProvider =
//     Provider.of<NotificationProvider>(context, listen: false);
//     final couponProvider =
//     Provider.of<CouponProvider>(context, listen: false);
//
//     if (userProvider.user == null) {
//       CustomSnackbar.showError(context, 'يجب تسجيل الدخول أولاً');
//       return;
//     }
//
//     // ✅ التحقق من المحفظة والإيصال قبل المتابعة
//     if (_paymentMethod == 'electronic') {
//       if (_selectedWallet == null) {
//         CustomSnackbar.showError(context, 'يرجى اختيار المحفظة الإلكترونية');
//         return;
//       }
//       if (_receiptFile == null) {
//         CustomSnackbar.showError(context, 'يرجى رفع إيصال الدفع');
//         return;
//       }
//     }
//
//     if (_isConfirming) return;
//     setState(() => _isConfirming = true);
//
//     final originalPrice = widget.service.price;
//
//     double totalDiscount  = 0;
//     double couponDiscount = couponProvider.discountAmount ?? 0;
//     double offerDiscount  = _discountAmount;
//
//     if (_appliedOffer != null && offerDiscount > 0) {
//       totalDiscount = offerDiscount;
//     } else if (couponDiscount > 0) {
//       totalDiscount = couponDiscount;
//     }
//
//     final finalPrice    = originalPrice - totalDiscount;
//     final pointsEarned  = LoyaltyEngine.calculatePoints(finalPrice);
//
//     final appointmentData = {
//       'user_id':              userProvider.user!.id,
//       'employee_id':          _selectedEmployee?.id,
//       'appointment_date':     _selectedDate!.toIso8601String().split('T')[0],
//       'appointment_time':     _selectedTime,
//       'duration_minutes':     widget.service.durationMinutes,
//       'total_price':          originalPrice,
//       'discount_amount':      totalDiscount,
//       'coupon_id':            couponProvider.appliedCoupon?.id,
//       'client_name':          userProvider.user!.fullName,
//       'client_phone':         userProvider.user!.phone,
//       'notes':                _notesController.text.trim().isEmpty
//           ? null
//           : _notesController.text.trim(),
//       'payment_status':       'unpaid',
//       'status':               'pending',
//       'payment_method':       _paymentMethod,
//       'electronic_wallet_id': _selectedWallet?.id,
//       'persons_count':        1,
//     };
//
//     try {
//       // ── 1. إنشاء الموعد ──────────────────────────────────────────
//       final appointmentResponse = await Supabase.instance.client
//           .from('appointments')
//           .insert(appointmentData)
//           .select()
//           .single();
//
//       final appointmentId = appointmentResponse['id'] as int;
//
//       // ── 2. رفع الإيصال إذا كان الدفع إلكتروني ───────────────────
//       if (_paymentMethod == 'electronic' && _receiptFile != null) {
//         try {
//           // ضغط الصورة: max 800px، جودة 50
//           final compressedBytes = await FlutterImageCompress.compressWithFile(
//             _receiptFile!.absolute.path,
//             minWidth:  800,
//             minHeight: 800,
//             quality:   50,
//             format:    CompressFormat.jpeg,
//           );
//
//           if (compressedBytes != null) {
//             // حفظ مؤقت للصورة المضغوطة
//             final tempFile = File(
//               '${Directory.systemTemp.path}'
//                   '/receipt_${appointmentId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
//             );
//             await tempFile.writeAsBytes(compressedBytes);
//
//             // رفع إلى Supabase Storage
//             final fileName =
//                 'receipts/receipt_${appointmentId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
//
//             await Supabase.instance.client.storage
//                 .from('payment-receipts')
//                 .upload(
//               fileName,
//               tempFile,
//               fileOptions: const FileOptions(
//                 cacheControl: '3600',
//                 upsert: true,
//               ),
//             );
//
//             final receiptUrl = Supabase.instance.client.storage
//                 .from('payment-receipts')
//                 .getPublicUrl(fileName);
//
//             // تحديث رابط الإيصال في جدول appointments
//             await Supabase.instance.client
//                 .from('appointments')
//                 .update({'payment_receipt_url': receiptUrl})
//                 .eq('id', appointmentId);
//
//             // حذف الملف المؤقت بعد الرفع
//             await tempFile.delete().catchError((_) {});
//           }
//         } catch (e) {
//           // ✅ فشل رفع الإيصال لا يوقف إنشاء الحجز
//           debugPrint('⚠️ فشل رفع الإيصال: $e');
//         }
//       }
//
//       // ── 3. إضافة الخدمة ──────────────────────────────────────────
//       await Supabase.instance.client.from('appointment_services').insert({
//         'appointment_id':   appointmentId,
//         'service_id':       widget.service.id,
//         'service_price':    widget.service.price,
//         'service_duration': widget.service.durationMinutes,
//         'employee_id':      _selectedEmployee?.id,
//         'status':           'pending',
//       });
//
//       // ── 4. استخدام الكوبون ───────────────────────────────────────
//       if (couponProvider.appliedCoupon != null && couponDiscount > 0) {
//         await couponProvider.useCoupon(
//           appointmentId: appointmentId,
//           userId:        userProvider.user!.id!,
//         );
//       }
//
//       // ── 5. تسجيل استخدام العرض ──────────────────────────────────
//       if (_appliedOfferId != null && offerDiscount > 0) {
//         await Supabase.instance.client.from('offer_usage').insert({
//           'offer_id':         _appliedOfferId,
//           'user_id':          userProvider.user!.id,
//           'appointment_id':   appointmentId,
//           'discount_applied': offerDiscount,
//           'usage_date':       DateTime.now().toUtc().toIso8601String(),
//         });
//
//         await Supabase.instance.client
//             .from('offers')
//             .update({
//           'current_usage':
//           (_appliedOffer!['current_usage'] as int? ?? 0) + 1
//         })
//             .eq('id', _appliedOfferId!);
//       }
//
//       // ── 6. إرسال الإشعار ────────────────────────────────────────
//       // ❌ لا تضف نقاط يدوياً — يتولّى ذلك الـ Trigger تلقائياً
//       await notificationProvider.createBookingNotification(
//         userId:          userProvider.user!.id!,
//         appointmentId:   appointmentId,
//         serviceName:     widget.service.serviceNameAr ??
//             widget.service.serviceName ??
//             'الخدمة',
//         appointmentDate: _selectedDate!,
//         appointmentTime: _selectedTime!,
//       );
//
//       // ── 7. الانتقال لشاشة النجاح ─────────────────────────────────
//       if (mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => BookingSuccessScreen(
//               bookingData: {
//                 'service_name':   widget.service.serviceNameAr ??
//                     widget.service.serviceName,
//                 'date':           _selectedDate,
//                 'time':           _selectedTime,
//                 'final_price':    finalPrice,
//                 'discount':       totalDiscount > 0 ? totalDiscount : null,
//                 'points_earned':  pointsEarned > 0 ? pointsEarned : null,
//                 'payment_method': _paymentMethod,               // ✅ جديد
//                 'has_receipt':    _receiptFile != null,          // ✅ جديد
//               },
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         CustomSnackbar.showError(
//             context, 'فشل إنشاء الحجز. يرجى المحاولة مرة أخرى');
//       }
//       debugPrint('❌ خطأ في _confirmBooking: $e');
//     } finally {
//       if (mounted) setState(() => _isConfirming = false);
//     }
//   }
//
// }
//
// class LoyaltyEngine {
//   /// احسب النقاط بناءً على السعر النهائي
//   static int calculatePoints(double finalPrice) {
//     // افتراض نقطة واحدة لكل 10 ريال
//     return finalPrice ~/ 1000;
//   }
// }




import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:ui' as ui;

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_snackbar.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../../services/domain/models/service_model.dart';
import '../../../coupons/presentation/providers/coupon_provider.dart';
import '../../../coupons/presentation/widgets/coupon_input_widget.dart';
import '../../../loyalty/presentation/providers/loyalty_transaction_provider.dart';
import '../../../notifications/presentation/providers/notification_provider.dart';
import '../providers/appointment_provider.dart';
import '../../domain/models/employee_model.dart';
import '../../domain/models/electronic_wallet_model.dart';
import 'appointment_success_screen.dart';

// ══════════════════════════════════════════════════════════════════
// BookAppointmentScreen - يدعم خدمة واحدة أو متعددة
// ══════════════════════════════════════════════════════════════════

class BookAppointmentScreen extends StatefulWidget {
  /// ✅ قائمة الخدمات (خدمة واحدة أو أكثر)
  final List<ServiceModel> services;

  const BookAppointmentScreen({
    Key? key,
    required this.services,
  }) : super(key: key);

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {

  // ✅ قائمة الخدمات المحددة (قابلة للتعديل)
  late List<ServiceModel> _selectedServices;

  // الخطوات والتنقل
  int currentStep = 0;
  bool isConfirming = false;

  // التاريخ والوقت والموظف
  DateTime? selectedDate;
  String? selectedTime;
  EmployeeModel? selectedEmployee;
  final notesController = TextEditingController();

  // الدفع
  String paymentMethod = 'cash';
  ElectronicWalletModel? selectedWallet;
  File? receiptFile;
  List<ElectronicWalletModel> wallets = [];
  bool loadingWallets = false;

  // العروض والكوبونات
  Map<String, dynamic>? appliedOffer;
  String? appliedPromoCode;
  int? appliedOfferId;
  double discountAmount = 0.0;

  // ✅ فحص توفر الموظف
  bool _isCheckingAvailability = false;
  bool? _isEmployeeAvailable; // null=لم يُفحص, true=متاح, false=تعارض

  // ══ Computed ══
  int    get totalDuration => _selectedServices.fold(0, (s, srv) => s + srv.durationMinutes);
  double get basePrice     => _selectedServices.fold(0.0, (s, srv) => s + srv.price);

  // ══════════════════════════════════════════════════════════════════
  // INIT
  // ══════════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _selectedServices = List.from(widget.services);
    WidgetsBinding.instance.addPostFrameCallback(_initializeScreen);
  }

  Future<void> _initializeScreen(_) async {
    final provider = context.read<AppointmentProvider>();
    provider.fetchAvailableEmployees();
    await provider.fetchServerTime();

    context.read<CouponProvider>().removeCoupon();
    context.read<LoyaltyTransactionProvider>().fetchLoyaltySettings();
    _fetchWallets();

    // استقبال بيانات العرض من التنقل
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      final offer    = args['appliedoffer'] as Map<String, dynamic>?;
      final offerId  = args['offerid'] as int?;
      final promoCode = args['promocode'] as String?;
      if (offer != null) {
        setState(() {
          appliedOffer    = offer;
          appliedOfferId  = offerId;
          appliedPromoCode = promoCode;
        });
        calculateOfferDiscount();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) CustomSnackbar.showSuccess(context, offer['title_ar'].toString());
        });
      }
    }
  }

  Future<void> _fetchWallets() async {
    if (!mounted) return;
    setState(() => loadingWallets = true);
    try {
      final res = await Supabase.instance.client
          .from('electronic_wallets')
          .select()
          .eq('is_active', true)
          .order('display_order');
      if (mounted) {
        setState(() {
          wallets = (res as List)
              .map((w) => ElectronicWalletModel.fromJson(w as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => loadingWallets = false);
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════
  // OFFER LOGIC
  // ══════════════════════════════════════════════════════════════════

  void calculateOfferDiscount() {
    if (appliedOffer == null) { setState(() => discountAmount = 0); return; }

    final discountType  = appliedOffer!['discount_type'] as String;
    final discountValue = (appliedOffer!['discount_value'] as num).toDouble();
    final minPurchase   = (appliedOffer!['min_purchase_amount'] as num?)?.toDouble() ?? 0;
    final maxDiscount   = (appliedOffer!['max_discount_amount'] as num?)?.toDouble();

    if (basePrice < minPurchase) {
      CustomSnackbar.showError(context, 'الحد الأدنى للشراء هو ${minPurchase.toInt()} ر.ي');
      setState(() { appliedOffer = null; discountAmount = 0; });
      return;
    }

    double discount = discountType == 'percentage'
        ? basePrice * discountValue / 100
        : discountValue;

    if (maxDiscount != null && discount > maxDiscount) discount = maxDiscount;
    if (discount > basePrice) discount = basePrice;
    setState(() => discountAmount = discount);
  }

  void _removeOffer() {
    setState(() { appliedOffer = null; appliedOfferId = null; appliedPromoCode = null; discountAmount = 0; });
    CustomSnackbar.showSuccess(context, 'تم إلغاء العرض');
  }

  // ══════════════════════════════════════════════════════════════════
  // ✅ AVAILABILITY CHECK
  // ══════════════════════════════════════════════════════════════════

  Future<void> _checkEmployeeAvailability(EmployeeModel employee) async {
    if (employee.id == null || selectedDate == null || selectedTime == null) return;

    setState(() { _isCheckingAvailability = true; _isEmployeeAvailable = null; });

    try {
      final available = await context.read<AppointmentProvider>().checkEmployeeAvailability(
        employeeId:      employee.id!,
        date:            selectedDate!,
        time:            selectedTime!,
        durationMinutes: totalDuration,
      );

      if (mounted) {
        setState(() { _isEmployeeAvailable = available; _isCheckingAvailability = false; });
        if (!available) _showConflictDialog(employee);
      }
    } catch (_) {
      if (mounted) setState(() { _isEmployeeAvailable = true; _isCheckingAvailability = false; });
    }
  }

  void _showConflictDialog(EmployeeModel employee) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Text('تعارض في الموعد', style: TextStyle(
                fontSize: 18.sp, fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.black, fontFamily: 'Cairo',
              )),
            ],
          ),
          content: Text(
            '${employee.fullName} لديه موعد آخر في هذا الوقت.\nهل تريد الاستمرار أو اختيار حلاق آخر؟',
            style: TextStyle(
              fontSize: 14.sp, height: 1.6, fontFamily: 'Cairo',
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() { selectedEmployee = null; _isEmployeeAvailable = null; });
              },
              child: Text('اختيار آخر', style: TextStyle(
                color: AppColors.darkRed, fontFamily: 'Cairo',
                fontWeight: FontWeight.bold, fontSize: 14.sp,
              )),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _isEmployeeAvailable = true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: Text('الاستمرار على أي حال',
                  style: TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 14.sp)),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════

  String _formatDate(DateTime date) {
    final days   = ['الأحد','الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت'];
    final months = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    return '${days[date.weekday % 7]} ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(String time) {
    try {
      final parts  = time.split(':');
      final hour   = int.parse(parts[0]);
      final minute = parts.length > 1 ? parts[1] : '00';
      if (hour == 0) return '12:$minute ص';
      if (hour < 12) return '$hour:$minute ص';
      if (hour == 12) return '$hour:$minute م';
      return '${hour - 12}:$minute م';
    } catch (_) { return time; }
  }

  bool get canProceed {
    switch (currentStep) {
      case 0: return selectedDate != null;
      case 1: return selectedTime != null;
      case 2: return true;
      case 3:
        if (paymentMethod == 'electronic') return selectedWallet != null && receiptFile != null;
        return true;
      default: return false;
    }
  }

  void _handleNextOrConfirm() {
    if (currentStep < 3) {
      if (currentStep == 1) {
        // Reset availability when moving to employee step
        setState(() { selectedEmployee = null; _isEmployeeAvailable = null; });
      }
      setState(() => currentStep++);
    } else {
      _confirmBooking();
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // RECEIPT
  // ══════════════════════════════════════════════════════════════════

  Future<void> _pickAndCompressReceipt() async {
    final picker  = ImagePicker();
    final picked  = await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (picked == null) return;

    final bytes = await FlutterImageCompress.compressWithFile(
      File(picked.path).absolute.path,
      minWidth: 800, minHeight: 800, quality: 50, format: CompressFormat.jpeg,
    );
    if (bytes == null) return;

    final tempFile = File('${Directory.systemTemp.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(bytes);
    if (mounted) setState(() => receiptFile = tempFile);
  }

  // ══════════════════════════════════════════════════════════════════
  // CONFIRM BOOKING
  // ══════════════════════════════════════════════════════════════════

  Future<void> _confirmBooking() async {
    final userProvider         = context.read<UserProvider>();
    final notificationProvider = context.read<NotificationProvider>();
    final couponProvider       = context.read<CouponProvider>();

    if (userProvider.user == null) { CustomSnackbar.showError(context, 'يرجى تسجيل الدخول أولاً'); return; }
    if (paymentMethod == 'electronic') {
      if (selectedWallet == null) { CustomSnackbar.showError(context, 'يرجى اختيار المحفظة الإلكترونية'); return; }
      if (receiptFile == null)    { CustomSnackbar.showError(context, 'يرجى رفع إيصال الدفع'); return; }
    }
    if (isConfirming) return;
    setState(() => isConfirming = true);

    final double couponDiscount = couponProvider.discountAmount ?? 0;
    final double offerDiscount  = discountAmount;
    final double totalDiscount  = appliedOffer != null ? offerDiscount : couponDiscount;
    final double finalPrice     = basePrice - totalDiscount;
    final int    pointsEarned   = LoyaltyEngine.calculatePoints(finalPrice);

    final appointmentData = {
      'user_id':               userProvider.user!.id,
      'employee_id':           selectedEmployee?.id,
      'appointment_date':      selectedDate!.toIso8601String().split('T')[0],
      'appointment_time':      selectedTime,
      'duration_minutes':      totalDuration, // ✅ مجموع مدة جميع الخدمات
      'total_price':           basePrice,
      'discount_amount':       totalDiscount,
      'coupon_id':             couponProvider.appliedCoupon?.id,
      'client_name':           userProvider.user!.fullName,
      'client_phone':          userProvider.user!.phone,
      'notes':                 notesController.text.trim().isEmpty ? null : notesController.text.trim(),
      'payment_status':        'unpaid',
      'status':                'pending',
      'payment_method':        paymentMethod,
      'electronic_wallet_id':  selectedWallet?.id,
      'persons_count':         1,
      'loyalty_points_earned': pointsEarned,
    };

    try {
      // ── 1. إنشاء الحجز ──
      final response = await Supabase.instance.client
          .from('appointments')
          .insert(appointmentData)
          .select()
          .single();
      final int appointmentId = response['id'] as int;

      // ── 2. رفع الإيصال ──
      if (paymentMethod == 'electronic' && receiptFile != null) {
        try {
          final bytes = await FlutterImageCompress.compressWithFile(
            receiptFile!.absolute.path,
            minWidth: 800, minHeight: 800, quality: 50, format: CompressFormat.jpeg,
          );
          if (bytes != null) {
            final tempFile = File('${Directory.systemTemp.path}/receipt_${appointmentId}_${DateTime.now().millisecondsSinceEpoch}.jpg');
            await tempFile.writeAsBytes(bytes);
            final fileName = 'receipts/receipt_${appointmentId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
            await Supabase.instance.client.storage
                .from('payment-receipts')
                .upload(fileName, tempFile, fileOptions: const FileOptions(cacheControl: '3600', upsert: true));
            final url = Supabase.instance.client.storage.from('payment-receipts').getPublicUrl(fileName);
            await Supabase.instance.client.from('appointments').update({'payment_receipt_url': url}).eq('id', appointmentId);
            await tempFile.delete().catchError((_) {});
          }
        } catch (e) { debugPrint('Receipt upload error: $e'); }
      }

      // ── 3. ✅ إدراج جميع الخدمات المحددة ──
      final servicesData = _selectedServices.map((service) => {
        'appointment_id':   appointmentId,
        'service_id':       service.id,
        'service_price':    service.price,
        'service_duration': service.durationMinutes,
        'employee_id':      selectedEmployee?.id,
        'status':           'pending',
      }).toList();
      await Supabase.instance.client.from('appointment_services').insert(servicesData);

      // ── 4. استخدام الكوبون ──
      if (couponProvider.appliedCoupon != null && couponDiscount > 0) {
        await couponProvider.useCoupon(appointmentId: appointmentId, userId: userProvider.user!.id!);
      }

      // ── 5. استخدام العرض ──
      if (appliedOfferId != null && offerDiscount > 0) {
        await Supabase.instance.client.from('offer_usage').insert({
          'offer_id': appliedOfferId, 'user_id': userProvider.user!.id,
          'appointment_id': appointmentId, 'discount_applied': offerDiscount,
          'usage_date': DateTime.now().toUtc().toIso8601String(),
        });
        await Supabase.instance.client
            .from('offers')
            .update({'current_usage': (appliedOffer!['current_usage'] as int? ?? 0) + 1})
            .eq('id', appliedOfferId!);
      }

      // ── 6. إشعار ──
      // await notificationProvider.createBookingNotification(
      //   userId:          userProvider.user!.id!,
      //   appointmentId:   appointmentId,
      //   serviceName:     _selectedServices.map((s) => s.serviceNameAr).join('، '),
      //   appointmentDate: selectedDate!,
      //   appointmentTime: selectedTime!,
      // );
// ✅ بعد - إضافة toString() وضمان النوع الصحيح
      await notificationProvider.createBookingNotification(
        userId:          userProvider.user!.id!,
        appointmentId:   appointmentId,
        serviceName:     _selectedServices
            .map((s) => s.serviceNameAr.isNotEmpty ? s.serviceNameAr : s.serviceName)
            .join('، ')
            .toString(),
        appointmentDate: selectedDate!,
        appointmentTime: selectedTime!.toString(),
      );

      // ── 7. الانتقال لشاشة النجاح ──
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => BookingSuccessScreen(
              bookingData: {
                'service_name':   _selectedServices.length == 1
                    ? _selectedServices.first.serviceNameAr
                    : '${_selectedServices.length} خدمات',
                'services_count': _selectedServices.length,
                'date':           selectedDate,
                'time':           selectedTime,
                'final_price':    finalPrice,
                'discount':       totalDiscount > 0 ? totalDiscount : null,
                'points_earned':  pointsEarned > 0 ? pointsEarned : null,
                'payment_method': paymentMethod,
                'has_receipt':    receiptFile != null,
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.showError(context, 'حدث خطأ أثناء الحجز. يرجى المحاولة مرة أخرى.');
        debugPrint('confirmBooking error: $e');
      }
    } finally {
      if (mounted) setState(() => isConfirming = false);
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : AppColors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'حجز موعد',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.black, fontFamily: 'Cairo'),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildStepIndicator(isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    // ✅ بطاقة الخدمات المحددة
                    _buildServicesCard(isDark),
                    SizedBox(height: 24.h),

                    if (appliedOffer != null) ...[
                      _buildAppliedOfferCard(isDark),
                      SizedBox(height: 24.h),
                    ],

                    if (currentStep == 0) _buildDateSelection(isDark),
                    if (currentStep == 1) _buildTimeSelection(isDark),
                    if (currentStep == 2) _buildEmployeeSelection(isDark),
                    if (currentStep == 3) _buildNotesAndSummary(isDark),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(isDark),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // STEP INDICATOR
  // ══════════════════════════════════════════════════════════════════

  Widget _buildStepIndicator(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          _buildStepItem(0, 'التاريخ',  Icons.calendar_today_rounded,  isDark),
          _buildStepLine(0, isDark),
          _buildStepItem(1, 'الوقت',    Icons.access_time_rounded,     isDark),
          _buildStepLine(1, isDark),
          _buildStepItem(2, 'الحلاق',   Icons.person_rounded,          isDark),
          _buildStepLine(2, isDark),
          _buildStepItem(3, 'التأكيد',  Icons.check_circle_rounded,    isDark),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String label, IconData icon, bool isDark) {
    final isActive    = currentStep == step;
    final isCompleted = currentStep >  step;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40.w, height: 40.h,
            decoration: BoxDecoration(
              color: isCompleted || isActive ? AppColors.darkRed : isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(isCompleted ? Icons.check_rounded : icon,
                color: isCompleted || isActive ? Colors.white : Colors.grey.shade500, size: 20.sp),
          ),
          SizedBox(height: 6.h),
          Text(label, style: TextStyle(
            fontSize: 11.sp,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.darkRed : isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            fontFamily: 'Cairo',
          )),
        ],
      ),
    );
  }

  Widget _buildStepLine(int step, bool isDark) {
    final isCompleted = currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: EdgeInsets.only(bottom: 30.h),
        color: isCompleted ? AppColors.darkRed : isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade300,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // ✅ SERVICES CARD - يعرض جميع الخدمات المحددة
  // ══════════════════════════════════════════════════════════════════

  Widget _buildServicesCard(bool isDark) {
    return Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        // Header
        Row(
        children: [
          Icon(Icons.design_services_rounded, color: AppColors.darkRed, size: 20.sp),
          SizedBox(width: 8.w),
          Text(
            _selectedServices.length == 1 ? 'الخدمة المحجوزة' : 'الخدمات المحجوزة (${_selectedServices.length})',
            style: TextStyle(
              fontSize: 15.sp, fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.black, fontFamily: 'Cairo',
            ),
          ),
          const Spacer(),
          // ✅ مجموع السعر
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '${basePrice.toStringAsFixed(0)} ر.ي',
              style: TextStyle(
                fontSize: 14.sp, fontWeight: FontWeight.bold,
                color: AppColors.gold, fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
        ),
              SizedBox(height: 12.h),
              // ✅ قائمة الخدمات
              ..._selectedServices.asMap().entries.map((entry) {
                final index   = entry.key;
                final service = entry.value;
                return Container(
                  margin: EdgeInsets.only(bottom: index < _selectedServices.length - 1 ? 8.h : 0),
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      // صورة الخدمة أو placeholder
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: service.imageUrl != null && service.imageUrl!.isNotEmpty
                            ? Image.network(service.imageUrl!, width: 50.w, height: 50.h,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildServicePlaceholder(isDark))
                            : _buildServicePlaceholder(isDark),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.serviceNameAr.isNotEmpty ? service.serviceNameAr : service.serviceName,
                              style: TextStyle(
                                fontSize: 14.sp, fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.black, fontFamily: 'Cairo',
                              ),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 13.sp, color: Colors.grey.shade500),
                                SizedBox(width: 3.w),
                                Text('${service.durationMinutes} دقيقة',
                                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500, fontFamily: 'Cairo')),
                                SizedBox(width: 12.w),
                                Icon(Icons.payments_rounded, size: 13.sp, color: AppColors.gold),
                                SizedBox(width: 3.w),
                                Text('${service.price.toStringAsFixed(0)} ر.ي',
                                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold,
                                        color: AppColors.gold, fontFamily: 'Cairo')),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // ✅ زر إزالة الخدمة (إذا كان هناك أكثر من خدمة واحدة)
                      if (_selectedServices.length > 1)
                        GestureDetector(
                          onTap: () => setState(() => _selectedServices.removeAt(index)),
                          child: Container(
                            padding: EdgeInsets.all(6.r),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close_rounded, color: Colors.red, size: 16.sp),
                          ),
                        ),
                    ],
                  ),
                );
              }),
              // ✅ مجموع المدة
              if (_selectedServices.length > 1) ...[
                Divider(height: 16.h, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timer_rounded, size: 16.sp, color: Colors.grey.shade500),
                        SizedBox(width: 6.w),
                        Text('إجمالي المدة',
                            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500, fontFamily: 'Cairo')),
                      ],
                    ),
                    Text('$totalDuration دقيقة',
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.black, fontFamily: 'Cairo')),
                  ],
                ),
              ],
            ],
        ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildServicePlaceholder(bool isDark) {
    return Container(
      width: 50.w, height: 50.h,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A3A3A) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(Icons.content_cut_rounded, color: AppColors.gold, size: 22.sp),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // OFFER CARD
  // ══════════════════════════════════════════════════════════════════

  Widget _buildAppliedOfferCard(bool isDark) {
    final title         = appliedOffer!['title_ar'] as String;
    final discountType  = appliedOffer!['discount_type'] as String;
    final discountValue = (appliedOffer!['discount_value'] as num).toDouble();
    final discountText  = discountType == 'percentage'
        ? '${discountValue.toInt()}%'
        : '${discountValue.toInt()} ر.ي';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.gold, AppColors.goldDark]),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
            child: Icon(Icons.local_offer_rounded, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('عرض مُفعَّل',
                    style: TextStyle(fontSize: 12.sp, color: Colors.white.withOpacity(0.9), fontFamily: 'Cairo')),
                SizedBox(height: 4.h),
                Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold,
                    color: Colors.white, fontFamily: 'Cairo'), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r)),
            child: Text(discountText, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold,
                color: AppColors.darkRed, fontFamily: 'Cairo')),
          ),
          SizedBox(width: 8.w),
          IconButton(onPressed: _removeOffer, icon: Icon(Icons.close_rounded, color: Colors.white, size: 20.sp)),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn().slideY(begin: -0.3);
  }

  // ══════════════════════════════════════════════════════════════════
  // STEP 0: DATE SELECTION
  // ══════════════════════════════════════════════════════════════════

  Widget _buildDateSelection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('اختر التاريخ', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.black, fontFamily: 'Cairo')),
        SizedBox(height: 16.h),
        PlatformWidget(
          material: (_, __) => Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            ),
            child: CalendarDatePicker(
              initialDate: selectedDate ?? DateTime.now(),
              firstDate:   DateTime.now(),
              lastDate:    DateTime.now().add(const Duration(days: 60)),
              onDateChanged: (newDate) {
                setState(() { selectedDate = newDate; selectedTime = null; _isEmployeeAvailable = null; });
                context.read<AppointmentProvider>()
                    .fetchAvailableTimeSlots(newDate, totalDuration);
              },
            ),
          ),
          cupertino: (_, __) => GestureDetector(
            onTap: () => _showCupertinoDatePicker(context),
            child: Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: AppColors.darkRed, size: 28.sp),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      selectedDate != null ? _formatDate(selectedDate!) : 'اضغط لاختيار التاريخ',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.black, fontFamily: 'Cairo'),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
        if (selectedDate != null) ...[
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.darkRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.darkRed.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.event_available, color: AppColors.darkRed, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('التاريخ المختار',
                          style: TextStyle(fontSize: 12.sp, color: isDark ? Colors.grey.shade400 : AppColors.greyDark, fontFamily: 'Cairo')),
                      SizedBox(height: 4.h),
                      Text(_formatDate(selectedDate!),
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.black, fontFamily: 'Cairo')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  void _showCupertinoDatePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        height: 250.h,
        child: CupertinoDatePicker(
          mode:            CupertinoDatePickerMode.date,
          initialDateTime: selectedDate ?? DateTime.now(),
          minimumDate:     DateTime.now(),
          maximumDate:     DateTime.now().add(const Duration(days: 60)),
          onDateTimeChanged: (newDate) {
            setState(() { selectedDate = newDate; selectedTime = null; _isEmployeeAvailable = null; });
            context.read<AppointmentProvider>().fetchAvailableTimeSlots(newDate, totalDuration);
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // STEP 1: TIME SELECTION
  // ══════════════════════════════════════════════════════════════════

  Widget _buildTimeSelection(bool isDark) {
    final provider = context.watch<AppointmentProvider>();

    if (selectedDate == null) {
      return Center(child: Text('يرجى اختيار التاريخ أولاً',
          style: TextStyle(color: Colors.grey.shade500, fontFamily: 'Cairo')));
    }
    if (provider.isLoading) return _buildTimeSelectionShimmer(isDark);
    if (provider.availableTimeSlots.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.event_busy_rounded, size: 60.sp, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text('لا توجد أوقات متاحة في هذا اليوم',
                style: TextStyle(color: Colors.grey.shade500, fontFamily: 'Cairo')),
          ],
        ),
      );
    }

    final serverTime  = provider.serverTime ?? DateTime.now();
    final isToday     = selectedDate!.year == serverTime.year &&
        selectedDate!.month == serverTime.month &&
        selectedDate!.day == serverTime.day;
    final currentTime = TimeOfDay.fromDateTime(serverTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('اختر الوقت', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.black, fontFamily: 'Cairo')),
        SizedBox(height: 8.h),
        Text(DateFormat('EEEE، d MMMM', 'ar').format(selectedDate!),
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500, fontFamily: 'Cairo')),
        SizedBox(height: 16.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h, childAspectRatio: 2.0,
          ),
          itemCount: provider.availableTimeSlots.length,
          itemBuilder: (_, index) {
            final time       = provider.availableTimeSlots[index];
            final isSelected = selectedTime == time;
            final parts      = time.split(':');
            final timeHour   = int.tryParse(parts[0]) ?? 0;
            final timeMinute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
            final isPast     = isToday &&
                (timeHour < currentTime.hour ||
                    (timeHour == currentTime.hour && timeMinute <= currentTime.minute));

            return GestureDetector(
              onTap: isPast ? null : () => setState(() { selectedTime = time; _isEmployeeAvailable = null; }),
              child: Opacity(
                opacity: isPast ? 0.4 : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: isPast
                        ? (isDark ? const Color(0xFF0A0A0A) : Colors.grey.shade100)
                        : isSelected ? AppColors.darkRed
                        : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isPast
                          ? (isDark ? Colors.grey.shade900 : Colors.grey.shade300)
                          : isSelected ? AppColors.darkRed
                          : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          _formatTime(time),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isPast ? Colors.grey.shade600
                                : isSelected ? Colors.white
                                : (isDark ? Colors.white : AppColors.black),
                            decoration: isPast ? TextDecoration.lineThrough : null,
                            fontFamily: 'Cairo',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (isPast)
                        Positioned(top: 4, right: 4,
                            child: Icon(Icons.block_rounded, size: 12.sp, color: Colors.red.shade300)),
                    ],
                  ),
                ),
              ),
            ).animate(delay: Duration(milliseconds: 50 * index)).fadeIn().scale();
          },
        ),
      ],
    );
  }

  Widget _buildTimeSelectionShimmer(bool isDark) {
    return Shimmer.fromColors(
      baseColor:      isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 150.w, height: 20.h,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r))),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 10.w, mainAxisSpacing: 10.h, childAspectRatio: 2.0),
            itemCount: 9,
            itemBuilder: (_, __) => Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r))),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // STEP 2: EMPLOYEE SELECTION
  // ══════════════════════════════════════════════════════════════════

  Widget _buildEmployeeSelection(bool isDark) {
    final provider = context.watch<AppointmentProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('اختر الحلاق', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.black, fontFamily: 'Cairo')),
        SizedBox(height: 8.h),
        Text('اختياري - يمكنك ترك الاختيار لنا',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500, fontFamily: 'Cairo')),
        SizedBox(height: 16.h),

        // ✅ خيار "أي حلاق"
        GestureDetector(
          onTap: () => setState(() { selectedEmployee = null; _isEmployeeAvailable = null; }),
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: selectedEmployee == null ? AppColors.gold.withOpacity(0.1) : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: selectedEmployee == null ? AppColors.gold : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                width: selectedEmployee == null ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60.w, height: 60.h,
                  decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 30.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('أفضل حلاق متاح', style: TextStyle(fontSize: 16.sp,
                          fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.black, fontFamily: 'Cairo')),
                      SizedBox(height: 4.h),
                      Text('سيتم تعيين أفضل حلاق متاح لك',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500, fontFamily: 'Cairo')),
                    ],
                  ),
                ),
                if (selectedEmployee == null)
                  Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 28.sp),
              ],
            ),
          ),
        ).animate().fadeIn().slideX(begin: 0.2),

        // ✅ قائمة الموظفين
        if (provider.isLoading)
          Center(
            child: Padding(
              padding: EdgeInsets.all(40.r),
              child: Column(
                children: [
                  const CircularProgressIndicator(color: AppColors.darkRed),
                  SizedBox(height: 16.h),
                  Text('جارٍ تحميل الحلاقين...',
                      style: TextStyle(color: Colors.grey.shade500, fontFamily: 'Cairo')),
                ],
              ),
            ),
          )
        else if (provider.employees.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.employees.length,
            itemBuilder: (_, index) {
              final emp        = provider.employees[index];
              final isSelected = selectedEmployee?.id == emp.id;

              return GestureDetector(
                onTap: () async {
                  setState(() { selectedEmployee = emp; _isEmployeeAvailable = null; });
                  // ✅ فحص التوفر تلقائياً عند الاختيار (إذا كان التاريخ والوقت محددَين)
                  if (selectedDate != null && selectedTime != null) {
                    await _checkEmployeeAvailability(emp);
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.darkRed.withOpacity(0.1) : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isSelected ? AppColors.darkRed : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // صورة الموظف
                      CircleAvatar(
                        radius: 30.r,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: emp.profileImageUrl != null && emp.profileImageUrl!.isNotEmpty
                            ? NetworkImage(emp.profileImageUrl!) : null,
                        child: emp.profileImageUrl == null || emp.profileImageUrl!.isEmpty
                            ? Icon(Icons.person, size: 30.sp) : null,
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(emp.fullName, style: TextStyle(fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.black, fontFamily: 'Cairo')),
                            SizedBox(height: 2.h),
                            if (emp.jobTitle != null && emp.jobTitle!.isNotEmpty)
                              Text(emp.jobTitle!, style: TextStyle(fontSize: 12.sp,
                                  color: Colors.grey.shade500, fontFamily: 'Cairo')),
                            SizedBox(height: 4.h),
                            // Rating
                            Row(
                              children: [
                                Icon(Icons.star_rounded, size: 14.sp, color: AppColors.gold),
                                SizedBox(width: 3.w),
                                Text(
                                  (emp.averageRating ?? 0) > 0
                                      ? (emp.averageRating ?? 0).toStringAsFixed(1)
                                      : 'جديد',
                                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold,
                                      color: AppColors.gold, fontFamily: 'Cairo'),
                                ),
                                if ((emp.totalReviews ?? 0) > 0) ...[
                                  SizedBox(width: 4.w),
                                  Text('(${emp.totalReviews})',
                                      style: TextStyle(fontSize: 11.sp,
                                          color: Colors.grey, fontFamily: 'Cairo')),
                                ],
                                if (emp.specialties != null && emp.specialties!.isNotEmpty) ...[
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(emp.specialties!.take(2).join('، '),
                                        style: TextStyle(fontSize: 11.sp,
                                            color: Colors.grey.shade500, fontFamily: 'Cairo'),
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      // ✅ حالة التوفر
                      Column(
                        children: [
                          if (isSelected) ...[
                            if (_isCheckingAvailability)
                              SizedBox(width: 20.w, height: 20.h,
                                  child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.darkRed))
                            else if (_isEmployeeAvailable == true)
                              Column(children: [
                                Icon(Icons.check_circle_rounded, color: AppColors.darkRed, size: 28.sp),
                                SizedBox(height: 4.h),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text('متاح', style: TextStyle(fontSize: 10.sp,
                                      color: Colors.green, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                                ),
                              ])
                            else if (_isEmployeeAvailable == false)
                                Column(children: [
                                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28.sp),
                                  SizedBox(height: 4.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text('تعارض', style: TextStyle(fontSize: 10.sp,
                                        color: Colors.orange, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                                  ),
                                ])
                              else
                                Icon(Icons.check_circle_rounded, color: AppColors.darkRed, size: 28.sp),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate(delay: Duration(milliseconds: 100 * (index + 1))).fadeIn().slideX(begin: 0.2);
            },
          )
        else
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Center(child: Text('لا يوجد حلاقون متاحون حالياً',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp, fontFamily: 'Cairo'))),
          ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // STEP 3: NOTES + SUMMARY
  // ══════════════════════════════════════════════════════════════════

  Widget _buildNotesAndSummary(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ملاحظات إضافية', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.black, fontFamily: 'Cairo')),
        SizedBox(height: 16.h),
        TextField(
          controller: notesController,
          maxLines: 4,
          textDirection: ui.TextDirection.rtl,
          style: TextStyle(color: isDark ? Colors.white : AppColors.black, fontFamily: 'Cairo'),
          decoration: InputDecoration(
            hintText: 'أي تعليمات أو طلبات خاصة...',
            hintStyle: TextStyle(color: Colors.grey.shade500, fontFamily: 'Cairo'),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
            ),
          ),
        ),
        SizedBox(height: 24.h),

        // قسم الدفع
        _buildPaymentSection(isDark),
        SizedBox(height: 24.h),

        // كوبون (إذا لم يكن هناك عرض)
        if (appliedOffer == null) ...[
          CouponInputWidget(
            amount: basePrice,
            onCouponApplied: (discount) => setState(() {}),
          ),
          SizedBox(height: 24.h),
        ],

        // ملخص الحجز
        Text('ملخص الحجز', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.black, fontFamily: 'Cairo')),
        SizedBox(height: 16.h),
        _buildSummaryCard(isDark),
      ],
    );
  }

  Widget _buildPaymentSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('طريقة الدفع', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.black, fontFamily: 'Cairo')),
        SizedBox(height: 16.h),
        _buildPaymentOption(isDark: isDark, value: 'cash',
            icon: Icons.payments_rounded, iconColor: Colors.green,
            title: 'دفع نقدي', subtitle: 'ادفع عند وصولك'),
        SizedBox(height: 10.h),
        _buildPaymentOption(isDark: isDark, value: 'electronic',
            icon: Icons.account_balance_wallet_rounded, iconColor: const Color(0xFFB8860B),
            title: 'دفع إلكتروني', subtitle: 'عبر المحافظ الإلكترونية'),
        if (paymentMethod == 'electronic') ...[
          SizedBox(height: 16.h),
          _buildWalletSelector(isDark),
          SizedBox(height: 16.h),
          _buildReceiptUploader(isDark),
        ],
      ],
    );
  }

  Widget _buildPaymentOption({
    required bool isDark, required String value, required IconData icon,
    required Color iconColor, required String title, required String subtitle,
  }) {
    final isSelected = paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() { paymentMethod = value; selectedWallet = null; receiptFile = null; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isSelected
              ? (value == 'cash' ? Colors.green.withOpacity(0.08) : const Color(0xFFB8860B).withOpacity(0.08))
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? (value == 'cash' ? Colors.green : const Color(0xFFB8860B))
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12.r)),
              child: Icon(icon, color: iconColor, size: 24.sp),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.black, fontFamily: 'Cairo')),
                  SizedBox(height: 3.h),
                  Text(subtitle, style: TextStyle(fontSize: 12.sp,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontFamily: 'Cairo')),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? Icon(Icons.check_circle_rounded, key: const ValueKey('checked'),
                  color: value == 'cash' ? Colors.green : const Color(0xFFB8860B), size: 26.sp)
                  : Icon(Icons.radio_button_unchecked_rounded, key: const ValueKey('unchecked'),
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, size: 26.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('اختر المحفظة', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, fontFamily: 'Cairo')),
        SizedBox(height: 10.h),
        if (loadingWallets)
          const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
        else if (wallets.isEmpty)
          Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            ),
            child: Row(children: [
              Icon(Icons.info_outline_rounded, color: Colors.orange, size: 18.sp),
              SizedBox(width: 8.w),
              Text('لا توجد محافظ إلكترونية متاحة',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500, fontFamily: 'Cairo')),
            ]),
          )
        else
          Column(
            children: wallets.map((wallet) {
              final isSelected = selectedWallet?.id == wallet.id;
              return GestureDetector(
                onTap: () => setState(() => selectedWallet = wallet),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFB8860B).withOpacity(0.08) : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFB8860B) : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40.w, height: 40.h,
                        decoration: BoxDecoration(
                            color: const Color(0xFFB8860B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10.r)),
                        child: Center(
                          child: wallet.iconUrl != null && wallet.iconUrl!.isNotEmpty
                              ? Image.network(wallet.iconUrl!, width: 26.w, height: 26.h,
                              errorBuilder: (_, __, ___) => Icon(Icons.account_balance_wallet_rounded,
                                  color: const Color(0xFFB8860B), size: 22.sp))
                              : Icon(Icons.account_balance_wallet_rounded,
                              color: const Color(0xFFB8860B), size: 22.sp),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(wallet.walletNameAr.isNotEmpty ? wallet.walletNameAr : wallet.walletName,
                                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.black, fontFamily: 'Cairo')),
                            SizedBox(height: 2.h),
                            Text(wallet.phoneNumber,
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500, fontFamily: 'Cairo')),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded, color: const Color(0xFFB8860B), size: 22.sp),
                    ],
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn().slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildReceiptUploader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('إيصال الدفع', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, fontFamily: 'Cairo')),
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(6.r)),
              child: Text('مطلوب', style: TextStyle(fontSize: 10.sp, color: Colors.red,
                  fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        GestureDetector(
          onTap: _pickAndCompressReceipt,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 120.h),
            decoration: BoxDecoration(
              color: receiptFile != null
                  ? Colors.green.withOpacity(0.05)
                  : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: receiptFile != null ? Colors.green : const Color(0xFFB8860B).withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: receiptFile != null
                ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: Image.file(receiptFile!, width: double.infinity, height: 160.h, fit: BoxFit.cover),
                ),
                Positioned(top: 8, left: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => receiptFile = null),
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Icon(Icons.close_rounded, color: Colors.white, size: 16.sp),
                    ),
                  ),
                ),
                Positioned(bottom: 8, right: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                    decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20.r)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.check_rounded, color: Colors.white, size: 13.sp),
                      SizedBox(width: 4.w),
                      Text('تم الرفع', style: TextStyle(color: Colors.white, fontSize: 11.sp,
                          fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                    ]),
                  ),
                ),
              ],
            )
                : Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                      color: const Color(0xFFB8860B).withOpacity(0.1), shape: BoxShape.circle),
                  child: Icon(Icons.upload_file_rounded, color: const Color(0xFFB8860B), size: 30.sp),
                ),
                SizedBox(height: 12.h),
                Text('رفع إيصال الدفع', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, fontFamily: 'Cairo')),
                SizedBox(height: 4.h),
                Text('اضغط لاختيار صورة من معرض الصور',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500, fontFamily: 'Cairo')),
              ]),
            ),
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  // ══════════════════════════════════════════════════════════════════
  // SUMMARY CARD
  // ══════════════════════════════════════════════════════════════════

  Widget _buildSummaryCard(bool isDark) {
    return Consumer2<CouponProvider, LoyaltyTransactionProvider>(
      builder: (_, couponProvider, loyaltyProvider, __) {
        final double couponDiscount = couponProvider.discountAmount ?? 0;
        final double totalDiscount  = discountAmount > 0 ? discountAmount : couponDiscount;
        final String discountSource = discountAmount > 0
            ? (appliedOffer?['title_ar'] as String? ?? 'خصم العرض')
            : (couponProvider.appliedCoupon?.code ?? '');
        final double finalPrice   = basePrice - totalDiscount;
        final int    pointsToEarn = loyaltyProvider.calculateLoyaltyPoints(finalPrice);

        return Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          ),
          child: Column(
            children: [
              // ✅ الخدمات المحددة
              ..._selectedServices.map((service) => Column(
                children: [
                  _buildSummaryRow(Icons.design_services_rounded, service.serviceNameAr,
                      '${service.price.toStringAsFixed(0)} ر.ي', isDark),
                  Divider(height: 16.h),
                ],
              )),

              _buildSummaryRow(Icons.calendar_today_rounded, 'التاريخ',
                  selectedDate != null ? _formatDate(selectedDate!) : '-', isDark),
              Divider(height: 24.h),
              _buildSummaryRow(Icons.access_time_rounded, 'الوقت',
                  selectedTime != null ? _formatTime(selectedTime!) : '-', isDark),
              Divider(height: 24.h),
              _buildSummaryRow(Icons.person_rounded, 'الحلاق',
                  selectedEmployee?.fullName ?? 'أفضل حلاق متاح', isDark),
              Divider(height: 24.h),
              _buildSummaryRow(Icons.timer_rounded, 'إجمالي المدة',
                  '$totalDuration دقيقة', isDark),
              Divider(height: 24.h),
              _buildSummaryRow(Icons.payments_rounded, 'السعر الإجمالي',
                  '${basePrice.toStringAsFixed(0)} ر.ي', isDark,
                  isStrikethrough: totalDiscount > 0),

              // الخصم
              if (totalDiscount > 0) ...[
                Divider(height: 24.h),
                Row(
                  children: [
                    Icon(discountAmount > 0 ? Icons.local_offer_rounded : Icons.discount_rounded,
                        color: Colors.green, size: 22.sp),
                    SizedBox(width: 12.w),
                    Expanded(child: Text(discountSource,
                        style: TextStyle(fontSize: 14.sp, color: Colors.green,
                            fontWeight: FontWeight.bold, fontFamily: 'Cairo'))),
                    Text('- ${totalDiscount.toStringAsFixed(0)} ر.ي',
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold,
                            color: Colors.green, fontFamily: 'Cairo')),
                  ],
                ),
              ],

              Divider(height: 24.h),
              // المبلغ النهائي
              Row(
                children: [
                  Icon(Icons.payment_rounded, color: AppColors.gold, size: 22.sp),
                  SizedBox(width: 12.w),
                  Expanded(child: Text('المبلغ النهائي',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.black, fontFamily: 'Cairo'))),
                  Text('${finalPrice.toStringAsFixed(0)} ر.ي',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold,
                          color: AppColors.gold, fontFamily: 'Cairo')),
                ],
              ),

              if (totalDiscount > 0) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20.r)),
                  child: Text('وفّرت ${totalDiscount.toStringAsFixed(0)} ر.ي 🎉',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold,
                          color: Colors.green, fontFamily: 'Cairo')),
                ),
              ],

              if (pointsToEarn > 0) ...[
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.stars_rounded, color: AppColors.gold, size: 18.sp),
                    SizedBox(width: 6.w),
                    Text('ستكسب $pointsToEarn نقطة ولاء',
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold,
                            color: AppColors.gold, fontFamily: 'Cairo')),
                  ]),
                ),
              ],
            ],
          ),
        ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2);
      },
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value, bool isDark,
      {bool isStrikethrough = false}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.darkRed, size: 22.sp),
        SizedBox(width: 12.w),
        Expanded(child: Text(label,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500, fontFamily: 'Cairo'))),
        Text(value, style: TextStyle(
          fontSize: 15.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo',
          color: isDark ? Colors.white : AppColors.black,
          decoration: isStrikethrough ? TextDecoration.lineThrough : null,
        )),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // BOTTOM BUTTONS
  // ══════════════════════════════════════════════════════════════════

  Widget _buildBottomButtons(bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (currentStep > 0 && !isConfirming)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() { currentStep--; _isEmployeeAvailable = null; }),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    side: const BorderSide(color: AppColors.darkRed),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    foregroundColor: AppColors.darkRed,
                  ),
                  child: Text('السابق', style: TextStyle(fontSize: 16.sp,
                      fontWeight: FontWeight.bold, color: AppColors.darkRed, fontFamily: 'Cairo')),
                ),
              ),
            if (currentStep > 0 && !isConfirming) SizedBox(width: 12.w),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: canProceed && !isConfirming ? _handleNextOrConfirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkRed,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade500,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: isConfirming
                    ? SizedBox(height: 20.h, width: 20.w,
                    child: const CircularProgressIndicator(strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white)))
                    : Text(
                  currentStep == 3 ? 'تأكيد الحجز' : 'التالي',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold,
                      color: Colors.white, fontFamily: 'Cairo'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ══════════════════════════════════════════════════════════════════
// LoyaltyEngine - حساب نقاط الولاء
// ══════════════════════════════════════════════════════════════════
class LoyaltyEngine {
  /// احسب نقاط الولاء: كل 1000 ريال = 10 نقاط
  static int calculatePoints(double finalPrice) {
    return (finalPrice / 1000 * 10).floor();
  }
}
