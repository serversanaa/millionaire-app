//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:millionaire_barber/features/appointments/presentation/pages/appointment_success_screen.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:provider/provider.dart';
//
// import 'package:millionaire_barber/features/appointments/domain/models/electronic_wallet_model.dart';
// import 'package:millionaire_barber/features/appointments/presentation/providers/appointment_provider.dart';
// import 'package:millionaire_barber/features/appointments/presentation/providers/multi_appointment_provider.dart';
// import 'package:millionaire_barber/features/profile/presentation/providers/user_provider.dart';
// import 'package:millionaire_barber/features/services/presentation/providers/services_provider.dart';
// import 'package:millionaire_barber/features/services/domain/models/service_model.dart';
//
// // ══════════════════════════════════════════════════════════════════════
// // CONSTANTS
// // ══════════════════════════════════════════════════════════════════════
//
// const _kGold = Color(0xFFB8860B);
// const _kGoldDark = Color(0xFF8B6914);
// const _kBg = Color(0xFF0A0A0A);
// const _kCard = Color(0xFF1E1E1E);
//
// // أسماء الخطوات مع أيقوناتها
// const _kStepLabels = ['الأشخاص', 'الموعد', 'الدفع'];
// const _kStepIcons = [
//   Icons.people_outline_rounded,
//   Icons.calendar_today_outlined,
//   Icons.payment_outlined,
// ];
// const _kStepHints = [
//   'أضف الأشخاص واختر خدماتهم',
//   'حدد التاريخ والوقت المناسب',
//   'اختر طريقة الدفع وأكمل الحجز',
// ];
//
// // ══════════════════════════════════════════════════════════════════════
// // MAIN SCREEN
// // ══════════════════════════════════════════════════════════════════════
//
// class MultiAppointmentScreen extends StatefulWidget {
//   const MultiAppointmentScreen({Key? key}) : super(key: key);
//
//   @override
//   State<MultiAppointmentScreen> createState() => _MultiAppointmentScreenState();
// }
//
// class _MultiAppointmentScreenState extends State<MultiAppointmentScreen>
//     with TickerProviderStateMixin {
//   late final TabController _tabCtrl;
//   late final AnimationController _progressAnim;
//   final _picker = ImagePicker();
//   int _activeTab = 0;
//
//   // ── Lifecycle ─────────────────────────────────────────────────────────
//
//   @override
//   void initState() {
//     super.initState();
//     _progressAnim = AnimationController(
//       vsync:    this,
//       duration: const Duration(milliseconds: 500),
//       value:    0.0,
//     );
//     _tabCtrl = TabController(length: 3, vsync: this)
//       ..addListener(() {
//         if (!_tabCtrl.indexIsChanging && mounted) {
//           setState(() => _activeTab = _tabCtrl.index);
//           _progressAnim.animateTo(
//             _tabCtrl.index / 2.0,
//             curve: Curves.easeInOut,
//           );
//         }
//       });
//
//     // ✅ صحيح — كل provider calls داخل addPostFrameCallback
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;                    // ← أضف هذا السطر فقط كحماية
//
//       final appt = context.read<MultiAppointmentProvider>();
//       appt.reset();
//       appt.addPerson();
//       appt.loadWallets();
//
//       final svc = context.read<ServicesProvider>();
//       svc.resetFilter();
//       if (svc.categories.isEmpty) svc.fetchCategories();
//       if (svc.services.isEmpty)   svc.fetchServices();
//     });
//   }
//
//
//
// // ── يُنفَّذ فوراً — خفيف ─────────────────────────────────
//   void _initImmediate() {
//     final appt = context.read<MultiAppointmentProvider>();
//     appt.reset();
//     appt.addPerson();
//
//     // ✅ تحميل الباقي بعد أول frame بدون تعليق الـ UI
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       _loadDataInBackground();
//     });
//   }
//
// // ── يُنفَّذ في الخلفية — ثقيل ─────────────────────────────
//   Future<void> _loadDataInBackground() async {
//     final appt = context.read<MultiAppointmentProvider>();
//     final svc = context.read<ServicesProvider>();
//
//     // تحميل المحافظ والخدمات بالتوازي
//     await Future.wait([
//       appt.loadWallets(),
//       Future(() {
//         svc.resetFilter();
//         // لا تُحمِّل إذا البيانات موجودة مسبقاً (cache)
//         if (svc.categories.isEmpty) svc.fetchCategories();
//         if (svc.services.isEmpty) svc.fetchServices();
//       }),
//     ]);
//   }
//
//   @override
//   void dispose() {
//     _tabCtrl.dispose();
//     _progressAnim.dispose();
//     super.dispose();
//   }
//
//   // ── Build ──────────────────────────────────────────────────────────────
//
//   @override
//   Widget build(BuildContext context) {
//     final dark = Theme.of(context).brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor: dark ? _kBg : const Color(0xFFF5F7FA),
//       body: SafeArea(
//         child: Consumer<MultiAppointmentProvider>(
//           builder: (_, prov, __) => Column(
//             children: [
//               _buildHeader(dark, prov),
//               _buildProgressBar(),
//               AnimatedSize(
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//                 child: prov.totalPrice > 0
//                     ? _buildSummaryChip(prov, dark)
//                     : const SizedBox.shrink(),
//               ),
//               Expanded(
//                 child: IndexedStack(
//                   index: _activeTab,
//                   children: [
//                     _PersonsTab(
//                       provider: prov,
//                       isDark: dark,
//                       gold: _kGold,
//                       picker: _picker,
//                       onShowServices: _openServicesSheet,
//                     ),
//                     _DateTimeTab(provider: prov, isDark: dark, gold: _kGold),
//                     _PaymentTab(
//                       provider: prov,
//                       isDark: dark,
//                       gold: _kGold,
//                       picker: _picker,
//                     ),
//                   ],
//                 ),
//               ),
//               _buildBottomNav(prov, dark),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── Header + Stepper ──────────────────────────────────────────────────
//
//   Widget _buildHeader(bool dark, MultiAppointmentProvider prov) {
//     return Container(
//       padding: EdgeInsets.only(
//         top: MediaQuery.of(context).padding.top + 8.h,
//         bottom: 16.h,
//         right: 16.w,
//         left: 16.w,
//       ),
//       decoration: BoxDecoration(
//         color: dark ? const Color(0xFF1A1A1A) : Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.07),
//             blurRadius: 16,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // ── صف العنوان ───────────────────────────────────
//           Row(
//             children: [
//               _backButton(),
//               SizedBox(width: 12.w),
//               Expanded(child: _titleSection(dark)),
//               _personsCounter(prov),
//             ],
//           ),
//           SizedBox(height: 20.h),
//
//           // ── Stepper ──────────────────────────────────────
//           _buildStepper(dark),
//
//           // ── تلميح الخطوة الحالية ─────────────────────────
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 300),
//             transitionBuilder: (child, anim) => FadeTransition(
//               opacity: anim,
//               child: SlideTransition(
//                 position: Tween<Offset>(
//                   begin: const Offset(0, -0.3),
//                   end: Offset.zero,
//                 ).animate(anim),
//                 child: child,
//               ),
//             ),
//             child: Container(
//               key: ValueKey(_activeTab),
//               margin: EdgeInsets.only(top: 12.h),
//               padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
//               decoration: BoxDecoration(
//                 color: _kGold.withValues(alpha: 0.08),
//                 borderRadius: BorderRadius.circular(20.r),
//                 border: Border.all(color: _kGold.withValues(alpha: 0.2)),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.lightbulb_outline, color: _kGold, size: 14.sp),
//                   SizedBox(width: 6.w),
//                   Text(
//                     _kStepHints[_activeTab],
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       color: _kGold,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _backButton() => GestureDetector(
//         onTap: () => Navigator.pop(context),
//         child: Container(
//           padding: EdgeInsets.all(10.r),
//           decoration: BoxDecoration(
//             color: _kGold.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(color: _kGold.withValues(alpha: 0.25)),
//           ),
//           child: Icon(Icons.arrow_back_ios_new, size: 18.sp, color: _kGold),
//         ),
//       );
//
//   Widget _titleSection(bool dark) => Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'حجز موعد جماعي',
//             style: TextStyle(
//               fontSize: 20.sp,
//               fontWeight: FontWeight.bold,
//               color: dark ? Colors.white : const Color(0xFF1A1A1A),
//             ),
//           ),
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 300),
//             child: Text(
//               'الخطوة ${_activeTab + 1} من 3 — ${_kStepLabels[_activeTab]}',
//               key: ValueKey(_activeTab),
//               style: TextStyle(fontSize: 12.sp, color: _kGold),
//             ),
//           ),
//         ],
//       );
//
//   Widget _personsCounter(MultiAppointmentProvider prov) => Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//               colors: [_kGold, _kGoldDark],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight),
//           borderRadius: BorderRadius.circular(20.r),
//           boxShadow: [
//             BoxShadow(
//               color: _kGold.withValues(alpha: 0.35),
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.people_rounded, color: Colors.white, size: 15.sp),
//             SizedBox(width: 5.w),
//             Text(
//               '${prov.persons.length}',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14.sp,
//               ),
//             ),
//           ],
//         ),
//       );
//
//   // ✅ Stepper — boxShadow بقيم صفرية بدلاً من null لتفادي crash
//   Widget _buildStepper(bool dark) {
//     return Row(
//       children: List.generate(_kStepLabels.length * 2 - 1, (i) {
//         if (i.isOdd) {
//           final prevStep = i ~/ 2;
//           return Expanded(
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 400),
//               height: 2.5,
//               decoration: BoxDecoration(
//                 gradient: _activeTab > prevStep
//                     ? const LinearGradient(colors: [_kGold, _kGoldDark])
//                     : null,
//                 color: _activeTab <= prevStep
//                     ? (dark ? const Color(0xFF2C2C2C) : Colors.grey.shade200)
//                     : null,
//                 borderRadius: BorderRadius.circular(2.r),
//               ),
//             ),
//           );
//         }
//
//         final idx = i ~/ 2;
//         final isActive = _activeTab == idx;
//         final isCompleted = _activeTab > idx;
//
//         return GestureDetector(
//           onTap: () {
//             if (idx < _activeTab) _goToTab(idx);
//           },
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // ✅ الإصلاح الجوهري: boxShadow دائماً موجودة بقيم صفرية
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 350),
// // ✅ لا overshoot أبداً
//                 curve: Curves.easeOut,
//                 width: isActive ? 46.w : 36.w,
//                 height: isActive ? 46.h : 36.h,
//                 decoration: BoxDecoration(
//                   gradient: (isActive || isCompleted)
//                       ? const LinearGradient(
//                           colors: [_kGold, _kGoldDark],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         )
//                       : null,
//                   color: !(isActive || isCompleted)
//                       ? (dark ? const Color(0xFF2C2C2C) : Colors.grey.shade100)
//                       : null,
//                   shape: BoxShape.circle,
//                   // ✅ FIX: لا تستخدم null - دائماً مرر قيم صفرية
//                   boxShadow: [
//                     BoxShadow(
//                       color: isActive
//                           ? _kGold.withValues(alpha: 0.45)
//                           : Colors.transparent,
//                       blurRadius: isActive ? 14.0 : 0.0,
//                       spreadRadius: isActive ? 2.0 : 0.0,
//                       offset: Offset.zero,
//                     ),
//                   ],
//                 ),
//                 child: Icon(
//                   isCompleted ? Icons.check_rounded : _kStepIcons[idx],
//                   color: (isActive || isCompleted)
//                       ? Colors.white
//                       : Colors.grey.shade400,
//                   size: isActive ? 22.sp : 17.sp,
//                 ),
//               ),
//               SizedBox(height: 5.h),
//               AnimatedDefaultTextStyle(
//                 duration: const Duration(milliseconds: 250),
//                 style: TextStyle(
//                   fontSize: 10.sp,
//                   fontFamily: 'Cairo',
//                   fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//                   color: isActive
//                       ? _kGold
//                       : (dark ? Colors.grey.shade600 : Colors.grey.shade500),
//                 ),
//                 child: Text(_kStepLabels[idx]),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }
//
//   // ── Progress Bar ──────────────────────────────────────────────────────
//
//   Widget _buildProgressBar() {
//     return AnimatedBuilder(
//       animation: _progressAnim,
//       builder: (_, __) => SizedBox(
//         height: 3,
//         child: Stack(
//           children: [
//             Container(color: Colors.grey.withValues(alpha: 0.1)),
//             FractionallySizedBox(
//               widthFactor:
//                   _progressAnim.value < 0.01 ? 0.02 : _progressAnim.value,
//               child: Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(colors: [_kGold, _kGoldDark]),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Summary Chip ──────────────────────────────────────────────────────
//
//   Widget _buildSummaryChip(MultiAppointmentProvider p, bool dark) {
//     return Container(
//       margin: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
//       padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
//       decoration: BoxDecoration(
//         color: _kGold.withValues(alpha: 0.07),
//         borderRadius: BorderRadius.circular(14.r),
//         border: Border.all(color: _kGold.withValues(alpha: 0.2)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.receipt_long_outlined, color: _kGold, size: 16.sp),
//           SizedBox(width: 8.w),
//           Expanded(
//             child: Text(
//               '${p.persons.length} ${p.persons.length == 1 ? 'شخص' : 'أشخاص'}'
//               '${p.selectedDate != null ? '  •  ${p.selectedDate!.day}/${p.selectedDate!.month}/${p.selectedDate!.year}' : ''}'
//               '${p.selectedTimeSlot != null ? '  •  ${p.selectedTimeSlot}' : ''}',
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 color: dark ? Colors.grey.shade300 : Colors.grey.shade600,
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(colors: [_kGold, _kGoldDark]),
//               borderRadius: BorderRadius.circular(20.r),
//             ),
//             child: Text(
//               '${p.totalPrice.toStringAsFixed(0)} ر.ي',
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Bottom Navigation ─────────────────────────────────────────────────
//
//   Widget _buildBottomNav(MultiAppointmentProvider p, bool dark) {
//     final isLast = _activeTab == 2;
//
//     return Container(
//       padding: EdgeInsets.fromLTRB(
//         16.w,
//         14.h,
//         16.w,
//         MediaQuery.of(context).padding.bottom + 14.h,
//       ),
//       decoration: BoxDecoration(
//         color: dark ? const Color(0xFF1A1A1A) : Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.1),
//             blurRadius: 20,
//             offset: const Offset(0, -4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // زر السابق
//           if (_activeTab > 0) ...[
//             Tooltip(
//               message: 'الخطوة السابقة: ${_kStepLabels[_activeTab - 1]}',
//               child: GestureDetector(
//                 onTap: p.isLoading
//                     ? null
//                     : () {
//                         HapticFeedback.lightImpact();
//                         _goToTab(_activeTab - 1);
//                       },
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   padding: EdgeInsets.all(16.r),
//                   decoration: BoxDecoration(
//                     color: _kGold.withValues(alpha: p.isLoading ? 0.04 : 0.1),
//                     borderRadius: BorderRadius.circular(16.r),
//                     border: Border.all(
//                       color: _kGold.withValues(alpha: p.isLoading ? 0.1 : 0.35),
//                       width: 1.5,
//                     ),
//                   ),
//                   child: Icon(
//                     Icons.arrow_forward_ios_rounded,
//                     color: p.isLoading ? Colors.grey : _kGold,
//                     size: 20.sp,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(width: 12.w),
//           ],
//
//           // زر التالي/التأكيد
//           Expanded(
//             child: SizedBox(
//               height: 56.h,
//               child: ElevatedButton(
//                 onPressed: p.isLoading
//                     ? null
//                     : () {
//                         HapticFeedback.mediumImpact();
//                         _handleNext(p);
//                       },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.transparent,
//                   shadowColor: Colors.transparent,
//                   padding: EdgeInsets.zero,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16.r)),
//                 ),
//                 child: Ink(
//                   decoration: BoxDecoration(
//                     gradient: p.isLoading
//                         ? null
//                         : LinearGradient(
//                             colors: isLast
//                                 ? [Colors.green.shade500, Colors.green.shade700]
//                                 : [_kGold, _kGoldDark],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                     color: p.isLoading ? Colors.grey.shade200 : null,
//                     borderRadius: BorderRadius.circular(16.r),
//                     boxShadow: [
//                       BoxShadow(
//                         color: p.isLoading
//                             ? Colors.transparent
//                             : (isLast ? Colors.green : _kGold)
//                                 .withValues(alpha: 0.35),
//                         blurRadius: p.isLoading ? 0 : 16,
//                         offset: const Offset(0, 5),
//                       ),
//                     ],
//                   ),
//                   child: Container(
//                     alignment: Alignment.center,
//                     child: p.isLoading
//                         ? Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               SizedBox(
//                                 width: 22.w,
//                                 height: 22.h,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.grey.shade600,
//                                   strokeWidth: 2.5,
//                                 ),
//                               ),
//                               SizedBox(width: 12.w),
//                               Text(
//                                 'جارٍ تأكيد الحجز...',
//                                 style: TextStyle(
//                                   fontSize: 15.sp,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.grey.shade600,
//                                 ),
//                               ),
//                             ],
//                           )
//                         : Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(
//                                 isLast
//                                     ? 'تأكيد الحجز (${p.persons.length} ${p.persons.length == 1 ? 'شخص' : 'أشخاص'})'
//                                     : 'التالي — ${_kStepLabels[_activeTab + 1]}',
//                                 style: TextStyle(
//                                   fontSize: 15.sp,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               SizedBox(width: 8.w),
//                               Icon(
//                                 isLast
//                                     ? Icons.check_circle_outline_rounded
//                                     : Icons.arrow_back_ios_rounded,
//                                 color: Colors.white,
//                                 size: 18.sp,
//                               ),
//                             ],
//                           ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Navigation Logic ──────────────────────────────────────────────────
//
//   void _handleNext(MultiAppointmentProvider p) {
//     switch (_activeTab) {
//       case 0:
//         if (p.persons.isEmpty) {
//           _showSnack('أضف شخصاً واحداً على الأقل', isError: true);
//           return;
//         }
//         if (p.persons.any((x) => x.name.trim().isEmpty)) {
//           _showSnack('أدخل الاسم لكل شخص', isError: true);
//           return;
//         }
//         if (p.persons.any((x) => x.services.isEmpty)) {
//           _showSnack('اختر خدمة واحدة على الأقل لكل شخص', isError: true);
//           return;
//         }
//         _goToTab(1);
//         break;
//
//       case 1:
//         if (p.selectedDate == null) {
//           _showSnack('اختر تاريخ الموعد أولاً', isError: true);
//           return;
//         }
//         if (p.selectedTimeSlot == null) {
//           _showSnack('اختر وقت الموعد', isError: true);
//           return;
//         }
//         _goToTab(2);
//         break;
//
//       case 2:
//         _submit(p);
//         break;
//     }
//   }
//
//   void _goToTab(int index) {
//     _tabCtrl.animateTo(index);
//     setState(() => _activeTab = index);
//     _progressAnim.animateTo(index / 2.0, curve: Curves.easeInOut);
//   }
//
//   // ── Submit ────────────────────────────────────────────────────────────
//
//   Future<void> _submit(MultiAppointmentProvider provider) async {
//     if (provider.paymentMethod == 'electronic') {
//       if (provider.selectedWallet == null) {
//         _showSnack('اختر المحفظة الإلكترونية', isError: true);
//         return;
//       }
//       if (provider.receiptFile == null) {
//         _showSnack('ارفع صورة إيصال التحويل', isError: true);
//         return;
//       }
//     }
//
//     final user = context.read<UserProvider>().user;
//     if (user == null || user.id == null) {
//       _showSnack('يجب تسجيل الدخول أولاً', isError: true);
//       return;
//     }
//
//     final ok = await provider.submitAppointment(
//       userId: user.id!,
//       clientName: user.fullName,
//       clientPhone: user.phone,
//     );
//
//     if (ok && mounted) {
//       final allServices = provider.persons
//           .expand((p) => p.services)
//           .map((s) =>
//               s.serviceNameAr.isNotEmpty ? s.serviceNameAr : s.serviceName)
//           .toList();
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => BookingSuccessScreen(
//             bookingData: {
//               'appointment_id': provider.createdAppointment?.id,
//               'service_name': allServices.isEmpty
//                   ? 'خدمات متعددة'
//                   : allServices.join(' • '),
//               'date': provider.selectedDate!,
//               'time': provider.selectedTimeSlot ?? '',
//               'final_price': provider.totalPrice,
//               'discount': null,
//               'points_earned': null,
//               'employee_name': null,
//               'status': 'pending',
//               'persons_count': provider.persons.length,
//               'payment_method': provider.paymentMethod,
//               'is_multi': true,
//             },
//           ),
//         ),
//       );
//     } else if (mounted) {
//       _showSnack(provider.errorMessage ?? 'فشل الحجز، حاول مرة أخرى',
//           isError: true);
//     }
//   }
//
//   // ── Services Sheet ────────────────────────────────────────────────────
//
//   void _openServicesSheet(
//     AppointmentPersonItem person,
//     MultiAppointmentProvider provider,
//     bool dark,
//   ) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _ServicesSheet(
//         person: person,
//         provider: provider,
//         isDark: dark,
//         gold: _kGold,
//       ),
//     );
//   }
//
//   // ── SnackBar ──────────────────────────────────────────────────────────
//
//   void _showSnack(String msg, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(SnackBar(
//         content: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(6.r),
//               decoration: BoxDecoration(
//                 color: Colors.white.withValues(alpha: 0.2),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 isError
//                     ? Icons.error_outline_rounded
//                     : Icons.check_circle_outline_rounded,
//                 color: Colors.white,
//                 size: 18.sp,
//               ),
//             ),
//             SizedBox(width: 10.w),
//             Expanded(
//               child: Text(
//                 msg,
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor:
//             isError ? const Color(0xFFE53E3E) : const Color(0xFF38A169),
//         behavior: SnackBarBehavior.floating,
//         margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
//         duration: const Duration(seconds: 3),
//         elevation: 8,
//       ));
//   }
// }
//
// // ══════════════════════════════════════════════════════════════════════
// // TAB 1 — الأشخاص
// // ══════════════════════════════════════════════════════════════════════
//
// class _PersonsTab extends StatelessWidget {
//   final MultiAppointmentProvider provider;
//   final bool isDark;
//   final Color gold;
//   final ImagePicker picker;
//   final void Function(AppointmentPersonItem, MultiAppointmentProvider, bool)
//       onShowServices;
//
//   const _PersonsTab({
//     required this.provider,
//     required this.isDark,
//     required this.gold,
//     required this.picker,
//     required this.onShowServices,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final svc = context.watch<ServicesProvider>();
//
//     return ListView(
//       padding: EdgeInsets.all(16.w),
//       children: [
//         // ── شرح سريع ──────────────────────────────────────
//         // شريط تحميل الخدمات
//         if (svc.isLoading)
//           Container(
//             margin: EdgeInsets.only(bottom: 12.h),
//             padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
//             decoration: BoxDecoration(
//               color: gold.withValues(alpha: 0.06),
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(color: gold.withValues(alpha: 0.2)),
//             ),
//             child: Row(
//               children: [
//                 SizedBox(
//                   width: 16.w,
//                   height: 16.h,
//                   child: CircularProgressIndicator(
//                     color: gold,
//                     strokeWidth: 2,
//                   ),
//                 ),
//                 SizedBox(width: 10.w),
//                 Text(
//                   'جارٍ تحميل الخدمات المتاحة...',
//                   style: TextStyle(
//                     fontSize: 13.sp,
//                     color: gold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//         Container(
//           padding: EdgeInsets.all(14.w),
//           margin: EdgeInsets.only(bottom: 16.h),
//           decoration: BoxDecoration(
//             color: gold.withValues(alpha: 0.06),
//             borderRadius: BorderRadius.circular(14.r),
//             border: Border.all(color: gold.withValues(alpha: 0.2)),
//           ),
//           child: Row(
//             children: [
//               Icon(Icons.info_outline_rounded, color: gold, size: 18.sp),
//               SizedBox(width: 10.w),
//               Expanded(
//                 child: Text(
//                   'أضف كل شخص باسمه واختر الخدمات المطلوبة له',
//                   style: TextStyle(
//                     fontSize: 13.sp,
//                     color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         // ── قائمة الأشخاص ─────────────────────────────────
//         ...List.generate(
//           provider.persons.length,
//           (i) => _PersonCard(
//             key: ValueKey(provider.persons[i].tempId),
//             person: provider.persons[i],
//             index: i,
//             totalPersons: provider.persons.length,
//             provider: provider,
//             isDark: isDark,
//             gold: gold,
//             onShowServices: onShowServices,
//           ),
//         ),
//
//         // ── زر إضافة شخص ──────────────────────────────────
//         SizedBox(height: 4.h),
//         Tooltip(
//           message: 'إضافة شخص جديد للحجز',
//           child: GestureDetector(
//             onTap: () {
//               HapticFeedback.lightImpact();
//               provider.addPerson();
//             },
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               padding: EdgeInsets.symmetric(vertical: 16.h),
//               decoration: BoxDecoration(
//                 color: gold.withValues(alpha: 0.05),
//                 borderRadius: BorderRadius.circular(16.r),
//                 border: Border.all(
//                   color: gold.withValues(alpha: 0.4),
//                   width: 1.5,
//                   style: BorderStyle.solid,
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(6.r),
//                     decoration: BoxDecoration(
//                       gradient:
//                           const LinearGradient(colors: [_kGold, _kGoldDark]),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(Icons.add, color: Colors.white, size: 18.sp),
//                   ),
//                   SizedBox(width: 10.w),
//                   Text(
//                     'إضافة شخص آخر',
//                     style: TextStyle(
//                       fontSize: 15.sp,
//                       color: gold,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         SizedBox(height: 16.h),
//       ],
//     );
//   }
// }
//
// // ══════════════════════════════════════════════════════════════════════
// // بطاقة شخص — محسّنة مع label واضح وTooltip
// // ══════════════════════════════════════════════════════════════════════
//
// class _PersonCard extends StatefulWidget {
//   final AppointmentPersonItem person;
//   final int index;
//   final int totalPersons;
//   final MultiAppointmentProvider provider;
//   final bool isDark;
//   final Color gold;
//   final void Function(AppointmentPersonItem, MultiAppointmentProvider, bool)
//       onShowServices;
//
//   const _PersonCard({
//     Key? key,
//     required this.person,
//     required this.index,
//     required this.totalPersons,
//     required this.provider,
//     required this.isDark,
//     required this.gold,
//     required this.onShowServices,
//   }) : super(key: key);
//
//   @override
//   State<_PersonCard> createState() => _PersonCardState();
// }
//
// class _PersonCardState extends State<_PersonCard>
//     with SingleTickerProviderStateMixin {
//   late final TextEditingController _ctrl;
//   late final AnimationController _shakeCtrl;
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = TextEditingController(text: widget.person.name);
//     _shakeCtrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     _shakeCtrl.dispose();
//     super.dispose();
//   }
//
//   // أسماء افتراضية للتلميح
//   static const _hints = [
//     'أنت (الشخص الأول)',
//     'الشخص الثاني',
//     'الشخص الثالث',
//     'الشخص الرابع',
//     'الشخص الخامس',
//   ];
//
//   String get _personLabel {
//     final idx = widget.index;
//     if (idx == 0) return 'شخص 1 (أنت)';
//     return 'شخص ${idx + 1}';
//   }
//
//   String get _hintText {
//     final idx = widget.index;
//     return idx < _hints.length ? _hints[idx] : 'اسم الشخص ${idx + 1}';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final p = widget.person;
//     final prov = widget.provider;
//     final dark = widget.isDark;
//     final gold = widget.gold;
//     final isValid = p.name.trim().isNotEmpty && p.services.isNotEmpty;
//
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       margin: EdgeInsets.only(bottom: 16.h),
//       decoration: BoxDecoration(
//         color: dark ? _kCard : Colors.white,
//         borderRadius: BorderRadius.circular(20.r),
//         border: Border.all(
//           color: isValid
//               ? gold.withValues(alpha: 0.5)
//               : (p.name.isEmpty && p.services.isEmpty)
//                   ? gold.withValues(alpha: 0.2)
//                   : Colors.orange.withValues(alpha: 0.5),
//           width: 1.5,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.06),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── رأس البطاقة ──────────────────────────────────
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   gold.withValues(alpha: 0.12),
//                   gold.withValues(alpha: 0.04),
//                 ],
//                 begin: Alignment.centerRight,
//                 end: Alignment.centerLeft,
//               ),
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//             ),
//             child: Row(
//               children: [
//                 // أيقونة الترقيم
//                 Tooltip(
//                   message: _personLabel,
//                   child: Container(
//                     width: 38.w,
//                     height: 38.h,
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [_kGold, _kGoldDark],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: _kGold.withValues(alpha: 0.35),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(
//                           widget.index == 0
//                               ? Icons.person_rounded
//                               : Icons.person_outline_rounded,
//                           color: Colors.white,
//                           size: widget.index == 0 ? 18.sp : 16.sp,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 10.w),
//
//                 // عمود label + حقل الاسم
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // label "شخص 1" / "شخص 2"
//                       Row(
//                         children: [
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 8.w, vertical: 2.h),
//                             decoration: BoxDecoration(
//                               color: gold.withValues(alpha: 0.15),
//                               borderRadius: BorderRadius.circular(20.r),
//                             ),
//                             child: Text(
//                               _personLabel,
//                               style: TextStyle(
//                                 fontSize: 10.sp,
//                                 fontWeight: FontWeight.bold,
//                                 color: gold,
//                               ),
//                             ),
//                           ),
//                           if (widget.index == 0) ...[
//                             SizedBox(width: 6.w),
//                             Container(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 6.w, vertical: 2.h),
//                               decoration: BoxDecoration(
//                                 color: Colors.green.withValues(alpha: 0.15),
//                                 borderRadius: BorderRadius.circular(20.r),
//                               ),
//                               child: Text(
//                                 'أنت',
//                                 style: TextStyle(
//                                   fontSize: 9.sp,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                       SizedBox(height: 4.h),
//
//                       // حقل الاسم
//                       Tooltip(
//                         message: 'اكتب الاسم الكامل للشخص',
//                         child: TextField(
//                           controller: _ctrl,
//                           textDirection: TextDirection.rtl,
//                           style: TextStyle(
//                             fontSize: 15.sp,
//                             fontWeight: FontWeight.w600,
//                             color:
//                                 dark ? Colors.white : const Color(0xFF1A1A1A),
//                           ),
//                           decoration: InputDecoration(
//                             hintText: _hintText,
//                             hintStyle: TextStyle(
//                               color: Colors.grey.shade400,
//                               fontSize: 14.sp,
//                             ),
//                             border: InputBorder.none,
//                             isDense: true,
//                             contentPadding: EdgeInsets.zero,
//                           ),
//                           onChanged: (v) => prov.updatePersonName(p.tempId, v),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // حالة الصحة
//                 Tooltip(
//                   message: isValid ? 'البيانات مكتملة ✓' : 'يتطلب: اسم + خدمة',
//                   child: Container(
//                     padding: EdgeInsets.all(6.r),
//                     decoration: BoxDecoration(
//                       color: isValid
//                           ? Colors.green.withValues(alpha: 0.1)
//                           : Colors.orange.withValues(alpha: 0.1),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       isValid
//                           ? Icons.check_circle_rounded
//                           : Icons.pending_rounded,
//                       color: isValid ? Colors.green : Colors.orange,
//                       size: 18.sp,
//                     ),
//                   ),
//                 ),
//
//                 // زر الحذف
//                 if (prov.persons.length > 1) ...[
//                   SizedBox(width: 6.w),
//                   Tooltip(
//                     message: 'حذف هذا الشخص من الحجز',
//                     child: GestureDetector(
//                       onTap: () => _confirmDelete(context),
//                       child: Container(
//                         padding: EdgeInsets.all(6.r),
//                         decoration: BoxDecoration(
//                           color: Colors.red.withValues(alpha: 0.1),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(Icons.delete_outline_rounded,
//                             color: Colors.red.shade400, size: 18.sp),
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//
//           // ── قسم الخدمات ───────────────────────────────────
//           Padding(
//             padding: EdgeInsets.all(14.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // عنوان القسم
//                 Row(
//                   children: [
//                     Icon(Icons.content_cut_rounded, color: gold, size: 15.sp),
//                     SizedBox(width: 6.w),
//                     Text(
//                       'الخدمات المختارة',
//                       style: TextStyle(
//                         fontSize: 13.sp,
//                         fontWeight: FontWeight.bold,
//                         color: gold,
//                       ),
//                     ),
//                     const Spacer(),
//                     if (p.services.isNotEmpty)
//                       Container(
//                         padding: EdgeInsets.symmetric(
//                             horizontal: 8.w, vertical: 3.h),
//                         decoration: BoxDecoration(
//                           color: gold.withValues(alpha: 0.12),
//                           borderRadius: BorderRadius.circular(20.r),
//                         ),
//                         child: Text(
//                           '${p.services.length} خدمة',
//                           style: TextStyle(
//                             fontSize: 11.sp,
//                             color: gold,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 SizedBox(height: 10.h),
//
//                 // قائمة الخدمات أو تحذير
//                 if (p.services.isNotEmpty)
//                   ...p.services.map((s) => _ServiceChip(
//                         service: s,
//                         personId: p.tempId,
//                         provider: prov,
//                         gold: gold,
//                       ))
//                 else
//                   Container(
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.withValues(alpha: 0.07),
//                       borderRadius: BorderRadius.circular(10.r),
//                       border: Border.all(
//                           color: Colors.orange.withValues(alpha: 0.3)),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.warning_amber_rounded,
//                             color: Colors.orange, size: 16.sp),
//                         SizedBox(width: 8.w),
//                         Text(
//                           'لم تُختر أي خدمة بعد',
//                           style: TextStyle(
//                             fontSize: 13.sp,
//                             color: Colors.orange.shade700,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                 SizedBox(height: 12.h),
//
//                 // زر اختيار الخدمات
//                 Tooltip(
//                   message: 'اضغط لاختيار أو تعديل الخدمات',
//                   child: GestureDetector(
//                     onTap: () {
//                       HapticFeedback.lightImpact();
//                       widget.onShowServices(p, prov, dark);
//                     },
//                     child: Container(
//                       width: double.infinity,
//                       padding: EdgeInsets.symmetric(
//                           horizontal: 14.w, vertical: 11.h),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             gold.withValues(alpha: 0.08),
//                             gold.withValues(alpha: 0.04),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(12.r),
//                         border: Border.all(color: gold.withValues(alpha: 0.35)),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                               p.services.isEmpty
//                                   ? Icons.add_circle_outline_rounded
//                                   : Icons.edit_outlined,
//                               color: gold,
//                               size: 18.sp),
//                           SizedBox(width: 8.w),
//                           Text(
//                             p.services.isEmpty
//                                 ? 'اختر الخدمات لهذا الشخص'
//                                 : 'تعديل الخدمات',
//                             style: TextStyle(
//                               fontSize: 13.sp,
//                               color: gold,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 // ملخص المجموع
//                 if (p.services.isNotEmpty) ...[
//                   SizedBox(height: 10.h),
//                   Container(
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//                     decoration: BoxDecoration(
//                       color: gold.withValues(alpha: 0.06),
//                       borderRadius: BorderRadius.circular(10.r),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(Icons.timer_outlined,
//                                 color: Colors.grey, size: 14.sp),
//                             SizedBox(width: 4.w),
//                             Text(
//                               '${p.totalDuration} دقيقة',
//                               style: TextStyle(
//                                   fontSize: 12.sp, color: Colors.grey),
//                             ),
//                           ],
//                         ),
//                         Text(
//                           '${p.totalPrice.toStringAsFixed(0)} ر.ي',
//                           style: TextStyle(
//                             fontSize: 14.sp,
//                             fontWeight: FontWeight.bold,
//                             color: gold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _confirmDelete(BuildContext ctx) {
//     showDialog(
//       context: ctx,
//       builder: (_) => AlertDialog(
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
//         title: Row(
//           children: [
//             Icon(Icons.delete_outline_rounded, color: Colors.red, size: 24.sp),
//             SizedBox(width: 10.w),
//             const Text('حذف شخص'),
//           ],
//         ),
//         content: Text(
//           'هل تريد حذف ${_personLabel} "${widget.person.name.isEmpty ? '(بدون اسم)' : widget.person.name}" من الحجز؟',
//           style: TextStyle(fontSize: 14.sp, height: 1.5),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: Text('إلغاء',
//                 style: TextStyle(color: Colors.grey, fontSize: 15.sp)),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               widget.provider.removePerson(widget.person.tempId);
//               Navigator.pop(ctx);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.r)),
//             ),
//             child: const Text('حذف', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Service Chip ──────────────────────────────────────────────────────
//
// class _ServiceChip extends StatelessWidget {
//   final AppointmentServiceItem service;
//   final String personId;
//   final MultiAppointmentProvider provider;
//   final Color gold;
//
//   const _ServiceChip({
//     required this.service,
//     required this.personId,
//     required this.provider,
//     required this.gold,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 6.h),
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//       decoration: BoxDecoration(
//         color: gold.withValues(alpha: 0.07),
//         borderRadius: BorderRadius.circular(10.r),
//         border: Border.all(color: gold.withValues(alpha: 0.2)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.check_circle_rounded, color: gold, size: 16.sp),
//           SizedBox(width: 8.w),
//           Expanded(
//             child: Text(
//               service.serviceNameAr.isNotEmpty
//                   ? service.serviceNameAr
//                   : service.serviceName,
//               style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
//             ),
//           ),
//           Text(
//             '${service.price.toStringAsFixed(0)} ر.ي',
//             style: TextStyle(
//                 fontSize: 13.sp, fontWeight: FontWeight.bold, color: gold),
//           ),
//           SizedBox(width: 8.w),
//           Tooltip(
//             message: 'إزالة هذه الخدمة',
//             child: GestureDetector(
//               onTap: () =>
//                   provider.removeServiceFromPerson(personId, service.serviceId),
//               child: Container(
//                 padding: EdgeInsets.all(3.r),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withValues(alpha: 0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child:
//                     Icon(Icons.close_rounded, size: 14.sp, color: Colors.red),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ══════════════════════════════════════════════════════════════════════
// // TAB 2 — التاريخ والوقت
// // ══════════════════════════════════════════════════════════════════════
//
// class _DateTimeTab extends StatelessWidget {
//   final MultiAppointmentProvider provider;
//   final bool isDark;
//   final Color gold;
//
//   const _DateTimeTab({
//     required this.provider,
//     required this.isDark,
//     required this.gold,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionTitle('اختر التاريخ', Icons.calendar_today_outlined, gold),
//           SizedBox(height: 12.h),
//           Container(
//             decoration: BoxDecoration(
//               color: isDark ? _kCard : Colors.white,
//               borderRadius: BorderRadius.circular(20.r),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.05),
//                   blurRadius: 12,
//                 ),
//               ],
//             ),
//             child: CalendarDatePicker(
//               initialDate: provider.selectedDate ??
//                   DateTime.now().add(const Duration(days: 1)),
//               firstDate: DateTime.now().add(const Duration(days: 1)),
//               lastDate: DateTime.now().add(const Duration(days: 60)),
//               onDateChanged: (date) {
//                 provider.setDate(date);
//                 context
//                     .read<AppointmentProvider>()
//                     .fetchAvailableTimeSlots(date, provider.totalDuration);
//               },
//             ),
//           ),
//           if (provider.selectedDate != null) ...[
//             SizedBox(height: 24.h),
//             _sectionTitle('اختر الوقت', Icons.access_time_outlined, gold),
//             SizedBox(height: 4.h),
//             Text(
//               'المدة الإجمالية المطلوبة: ${provider.totalDuration} دقيقة',
//               style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//             ),
//             SizedBox(height: 12.h),
//             _TimeSlots(provider: provider, isDark: isDark, gold: gold),
//           ],
//           SizedBox(height: 20.h),
//         ],
//       ),
//     );
//   }
// }
//
// class _TimeSlots extends StatelessWidget {
//   final MultiAppointmentProvider provider;
//   final bool isDark;
//   final Color gold;
//
//   const _TimeSlots({
//     required this.provider,
//     required this.isDark,
//     required this.gold,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AppointmentProvider>(
//       builder: (_, ap, __) {
//         if (ap.isLoading) {
//           return Center(
//             child: Column(
//               children: [
//                 CircularProgressIndicator(color: gold),
//                 SizedBox(height: 12.h),
//                 Text('جارٍ تحميل الأوقات المتاحة...',
//                     style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
//               ],
//             ),
//           );
//         }
//
//         if (ap.availableTimeSlots.isEmpty) {
//           return Container(
//             padding: EdgeInsets.all(20.w),
//             decoration: BoxDecoration(
//               color: isDark ? _kCard : Colors.white,
//               borderRadius: BorderRadius.circular(16.r),
//             ),
//             child: Column(
//               children: [
//                 Icon(Icons.event_busy_rounded, size: 48.sp, color: Colors.grey),
//                 SizedBox(height: 12.h),
//                 Text(
//                   'لا توجد أوقات متاحة في هذا اليوم',
//                   style: TextStyle(fontSize: 14.sp, color: Colors.grey),
//                 ),
//                 SizedBox(height: 6.h),
//                 Text(
//                   'جرّب اختيار يوم آخر',
//                   style:
//                       TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
//                 ),
//               ],
//             ),
//           );
//         }
//
//         return Wrap(
//           spacing: 10.w,
//           runSpacing: 10.h,
//           children: ap.availableTimeSlots.map((slot) {
//             final sel = provider.selectedTimeSlot == slot;
//             // ✅ FIX: boxShadow بقيم صفرية بدلاً من null
//             return Tooltip(
//               message: sel ? 'الوقت المختار' : 'اختر هذا الوقت',
//               child: GestureDetector(
//                 onTap: () {
//                   HapticFeedback.selectionClick();
//                   provider.setTimeSlot(slot);
//                 },
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 250),
//                   padding:
//                       EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
//                   decoration: BoxDecoration(
//                     gradient: sel
//                         ? const LinearGradient(colors: [_kGold, _kGoldDark])
//                         : null,
//                     color: sel
//                         ? null
//                         : (isDark
//                             ? const Color(0xFF2A2A2A)
//                             : Colors.grey.shade100),
//                     borderRadius: BorderRadius.circular(12.r),
//                     boxShadow: [
//                       BoxShadow(
//                         color: sel
//                             ? gold.withValues(alpha: 0.4)
//                             : Colors.transparent,
//                         blurRadius: sel ? 8.0 : 0.0,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Text(
//                     slot,
//                     style: TextStyle(
//                       fontSize: 14.sp,
//                       fontWeight: sel ? FontWeight.bold : FontWeight.normal,
//                       color:
//                           sel ? Colors.white : (isDark ? Colors.white70 : null),
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
// }
//
// // ══════════════════════════════════════════════════════════════════════
// // TAB 3 — الدفع
// // ══════════════════════════════════════════════════════════════════════
//
// class _PaymentTab extends StatelessWidget {
//   final MultiAppointmentProvider provider;
//   final bool isDark;
//   final Color gold;
//   final ImagePicker picker;
//
//   const _PaymentTab({
//     required this.provider,
//     required this.isDark,
//     required this.gold,
//     required this.picker,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(16.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _sectionTitle('طريقة الدفع', Icons.payment_outlined, gold),
//           SizedBox(height: 14.h),
//           _PaymentOption(
//             provider: provider,
//             method: 'cash',
//             title: 'دفع عند الحضور',
//             subtitle: 'ادفع نقداً عند وصولك للصالون',
//             icon: Icons.money_rounded,
//             isDark: isDark,
//             gold: gold,
//           ),
//           SizedBox(height: 12.h),
//           _PaymentOption(
//             provider: provider,
//             method: 'electronic',
//             title: 'تحويل إلكتروني',
//             subtitle: 'حوّل المبلغ وارفع صورة الإيصال',
//             icon: Icons.phone_android_rounded,
//             isDark: isDark,
//             gold: gold,
//           ),
//           if (provider.isElectronic) ...[
//             SizedBox(height: 24.h),
//             _ElectronicSection(
//               provider: provider,
//               isDark: isDark,
//               gold: gold,
//               picker: picker,
//             ),
//           ],
//           SizedBox(height: 32.h),
//         ],
//       ),
//     );
//   }
// }
//
// class _PaymentOption extends StatelessWidget {
//   final MultiAppointmentProvider provider;
//   final String method, title, subtitle;
//   final IconData icon;
//   final bool isDark;
//   final Color gold;
//
//   const _PaymentOption({
//     required this.provider,
//     required this.method,
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.isDark,
//     required this.gold,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final sel = provider.paymentMethod == method;
//     // ✅ FIX: boxShadow بقيم صفرية بدلاً من null
//     return GestureDetector(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         provider.setPaymentMethod(method);
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         padding: EdgeInsets.all(16.w),
//         decoration: BoxDecoration(
//           color: isDark ? _kCard : Colors.white,
//           borderRadius: BorderRadius.circular(16.r),
//           border: Border.all(
//             color: sel ? gold : Colors.grey.withValues(alpha: 0.3),
//             width: sel ? 2 : 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: sel ? gold.withValues(alpha: 0.18) : Colors.transparent,
//               blurRadius: sel ? 14.0 : 0.0,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(10.w),
//               decoration: BoxDecoration(
//                 gradient: sel
//                     ? const LinearGradient(colors: [_kGold, _kGoldDark])
//                     : null,
//                 color: sel ? null : Colors.grey.shade100,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon,
//                   color: sel ? Colors.white : Colors.grey, size: 22.sp),
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
//                         color: sel ? gold : null,
//                       )),
//                   Text(subtitle,
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         color: Colors.grey.shade600,
//                       )),
//                 ],
//               ),
//             ),
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 250),
//               width: 22.w,
//               height: 22.h,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: sel ? gold : Colors.grey, width: 2),
//                 color: sel ? gold : Colors.transparent,
//               ),
//               child: sel
//                   ? Icon(Icons.check, color: Colors.white, size: 13.sp)
//                   : null,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _ElectronicSection extends StatelessWidget {
//   final MultiAppointmentProvider provider;
//   final bool isDark;
//   final Color gold;
//   final ImagePicker picker;
//
//   const _ElectronicSection({
//     required this.provider,
//     required this.isDark,
//     required this.gold,
//     required this.picker,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _sectionTitle(
//             'اختر المحفظة', Icons.account_balance_wallet_outlined, gold),
//         SizedBox(height: 12.h),
//         if (provider.wallets.isEmpty)
//           Center(child: CircularProgressIndicator(color: gold))
//         else
//           ...provider.wallets.map(
//             (w) => _WalletCard(
//               wallet: w,
//               provider: provider,
//               isDark: isDark,
//               gold: gold,
//             ),
//           ),
//         if (provider.selectedWallet != null) ...[
//           SizedBox(height: 20.h),
//           _TransferInfo(
//             wallet: provider.selectedWallet!,
//             totalPrice: provider.totalPrice,
//             gold: gold,
//           ),
//         ],
//         SizedBox(height: 24.h),
//         _sectionTitle('ارفع صورة الإيصال', Icons.receipt_long_outlined, gold),
//         SizedBox(height: 12.h),
//         _ReceiptUploader(
//           provider: provider,
//           isDark: isDark,
//           gold: gold,
//           picker: picker,
//         ),
//       ],
//     );
//   }
// }
//
// class _WalletCard extends StatelessWidget {
//   final ElectronicWalletModel wallet;
//   final MultiAppointmentProvider provider;
//   final bool isDark;
//   final Color gold;
//
//   const _WalletCard({
//     required this.wallet,
//     required this.provider,
//     required this.isDark,
//     required this.gold,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final sel = provider.selectedWalletId == wallet.id;
//     return GestureDetector(
//       onTap: () {
//         HapticFeedback.lightImpact();
//         provider.selectWallet(wallet.id);
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         margin: EdgeInsets.only(bottom: 10.h),
//         padding: EdgeInsets.all(14.w),
//         decoration: BoxDecoration(
//           color: isDark ? _kCard : Colors.white,
//           borderRadius: BorderRadius.circular(14.r),
//           border: Border.all(
//             color: sel ? gold : Colors.grey.withValues(alpha: 0.2),
//             width: sel ? 2 : 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: sel ? gold.withValues(alpha: 0.15) : Colors.transparent,
//               blurRadius: sel ? 10.0 : 0.0,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 46.w,
//               height: 46.h,
//               decoration: BoxDecoration(
//                 color: gold.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: Center(
//                 child: Text(
//                   wallet.walletNameAr.isNotEmpty ? wallet.walletNameAr[0] : '؟',
//                   style: TextStyle(
//                     fontSize: 20.sp,
//                     fontWeight: FontWeight.bold,
//                     color: gold,
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(width: 14.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(wallet.walletNameAr,
//                       style: TextStyle(
//                         fontSize: 15.sp,
//                         fontWeight: FontWeight.bold,
//                         color: sel ? gold : null,
//                       )),
//                   Text(wallet.phoneNumber,
//                       style: TextStyle(
//                         fontSize: 13.sp,
//                         color: Colors.grey.shade600,
//                       )),
//                 ],
//               ),
//             ),
//             if (sel)
//               Container(
//                 padding: EdgeInsets.all(4.w),
//                 decoration: BoxDecoration(color: gold, shape: BoxShape.circle),
//                 child: Icon(Icons.check, color: Colors.white, size: 14.sp),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _TransferInfo extends StatelessWidget {
//   final ElectronicWalletModel wallet;
//   final double totalPrice;
//   final Color gold;
//
//   const _TransferInfo({
//     required this.wallet,
//     required this.totalPrice,
//     required this.gold,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: const Color(0xFF3B82F6).withValues(alpha: 0.07),
//         borderRadius: BorderRadius.circular(14.r),
//         border:
//             Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.25)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(children: [
//             const Icon(Icons.info_outline_rounded, color: Color(0xFF3B82F6)),
//             SizedBox(width: 8.w),
//             Text('معلومات التحويل',
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFF3B82F6),
//                 )),
//           ]),
//           SizedBox(height: 12.h),
//           _infoRow('المحفظة', wallet.walletNameAr),
//           _infoRow('الرقم', wallet.phoneNumber),
//           if (wallet.accountName?.isNotEmpty == true)
//             _infoRow('الاسم', wallet.accountName!),
//           _infoRow('المبلغ', '${totalPrice.toStringAsFixed(0)} ر.ي'),
//         ],
//       ),
//     );
//   }
//
//   Widget _infoRow(String label, String value) => Padding(
//         padding: EdgeInsets.only(bottom: 6.h),
//         child: Row(children: [
//           Text('$label: ',
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 color: Colors.grey.shade600,
//                 fontWeight: FontWeight.w500,
//               )),
//           Text(value,
//               style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
//         ]),
//       );
// }
//
// class _ReceiptUploader extends StatefulWidget {
//   final MultiAppointmentProvider provider;
//   final bool isDark;
//   final Color gold;
//   final ImagePicker picker;
//
//   const _ReceiptUploader({
//     required this.provider,
//     required this.isDark,
//     required this.gold,
//     required this.picker,
//   });
//
//   @override
//   State<_ReceiptUploader> createState() => _ReceiptUploaderState();
// }
//
// class _ReceiptUploaderState extends State<_ReceiptUploader> {
//   bool _isCompressing = false;
//
//   // ── ضغط الصورة قبل الرفع ─────────────────────────────────
//   Future<File?> _compressImage(File file) async {
//     try {
//       final dir = await getTemporaryDirectory();
//       final path =
//           '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_receipt.jpg';
//
//       final result = await FlutterImageCompress.compressAndGetFile(
//         file.absolute.path,
//         path,
//         quality: 72, // جودة 72% — توازن مثالي
//         minWidth: 1024,
//         minHeight: 1024,
//         format: CompressFormat.jpeg,
//       );
//
//       return result != null ? File(result.path) : file;
//     } catch (_) {
//       return file; // fallback للملف الأصلي عند الخطأ
//     }
//   }
//
//   Future<void> _pickAndCompress(ImageSource source) async {
//     Navigator.pop(context);
//
//     final picked = await widget.picker.pickImage(
//       source: source,
//       imageQuality: 100, // نضغط يدوياً بعدها
//     );
//     if (picked == null) return;
//
//     setState(() => _isCompressing = true);
//
//     try {
//       final original = File(picked.path);
//       final compressed = await _compressImage(original);
//       if (compressed != null) {
//         widget.provider.setReceiptFile(compressed);
//
//         // عرض نتيجة الضغط
//         if (mounted) {
//           final origSize = (original.lengthSync() / 1024).toStringAsFixed(0);
//           final newSize = (compressed.lengthSync() / 1024).toStringAsFixed(0);
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Row(
//                 children: [
//                   Icon(Icons.compress_rounded,
//                       color: Colors.white, size: 18.sp),
//                   SizedBox(width: 8.w),
//                   Text(
//                     'تم ضغط الصورة: ${origSize}KB → ${newSize}KB',
//                     style: TextStyle(fontSize: 13.sp),
//                   ),
//                 ],
//               ),
//               backgroundColor: const Color(0xFF38A169),
//               behavior: SnackBarBehavior.floating,
//               margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.r)),
//               duration: const Duration(seconds: 3),
//             ),
//           );
//         }
//       }
//     } finally {
//       if (mounted) setState(() => _isCompressing = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final prov = widget.provider;
//     final gold = widget.gold;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── منطقة الرفع ──────────────────────────────────────
//         GestureDetector(
//           onTap: _isCompressing ? null : () => _showPicker(context),
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             width: double.infinity,
//             height: prov.receiptFile != null ? 200.h : 130.h,
//             decoration: BoxDecoration(
//               color: widget.isDark ? _kCard : Colors.white,
//               borderRadius: BorderRadius.circular(16.r),
//               border: Border.all(
//                 color: _isCompressing
//                     ? gold.withValues(alpha: 0.4)
//                     : prov.receiptFile != null
//                         ? Colors.green
//                         : gold.withValues(alpha: 0.5),
//                 width: 2,
//               ),
//               // ✅ FIX: لا تستخدم null
//               boxShadow: [
//                 BoxShadow(
//                   color: prov.receiptFile != null
//                       ? Colors.green.withValues(alpha: 0.15)
//                       : Colors.transparent,
//                   blurRadius: prov.receiptFile != null ? 12.0 : 0.0,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: _isCompressing
//                 ? _buildCompressing()
//                 : prov.receiptFile != null
//                     ? _buildPreview(context)
//                     : _buildEmpty(),
//           ),
//         ),
//
//         // ── معلومات الحجم ─────────────────────────────────────
//         if (prov.receiptFile != null) ...[
//           SizedBox(height: 8.h),
//           _buildFileSizeInfo(prov.receiptFile!),
//         ],
//       ],
//     );
//   }
//
//   // ── واجهة الضغط ──────────────────────────────────────────
//
//   Widget _buildCompressing() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         SizedBox(
//           width: 40.w,
//           height: 40.h,
//           child: CircularProgressIndicator(
//             color: widget.gold,
//             strokeWidth: 3,
//           ),
//         ),
//         SizedBox(height: 12.h),
//         Text(
//           'جارٍ ضغط الصورة...',
//           style: TextStyle(
//             fontSize: 14.sp,
//             fontWeight: FontWeight.w600,
//             color: widget.gold,
//           ),
//         ),
//         SizedBox(height: 4.h),
//         Text(
//           'يُرجى الانتظار',
//           style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//         ),
//       ],
//     );
//   }
//
//   // ── واجهة فارغة ──────────────────────────────────────────
//
//   // Widget _buildEmpty() {
//   //   return Column(
//   //     mainAxisAlignment: MainAxisAlignment.center,
//   //     children: [
//   //       Container(
//   //         padding: EdgeInsets.all(14.r),
//   //         decoration: BoxDecoration(
//   //           gradient: LinearGradient(
//   //             colors: [
//   //               widget.gold.withValues(alpha:0.15),
//   //               widget.gold.withValues(alpha:0.05),
//   //             ],
//   //           ),
//   //           shape: BoxShape.circle,
//   //         ),
//   //         child: Icon(Icons.cloud_upload_outlined,
//   //             size: 32.sp, color: widget.gold),
//   //       ),
//   //       SizedBox(height: 12.h),
//   //       Text(
//   //         'اضغط لرفع صورة الإيصال',
//   //         style: TextStyle(
//   //           fontSize:   14.sp,
//   //           fontWeight: FontWeight.w600,
//   //           color:      widget.gold,
//   //         ),
//   //       ),
//   //       SizedBox(height: 4.h),
//   //       Text(
//   //         'سيتم ضغط الصورة تلقائياً قبل الرفع',
//   //         style: TextStyle(fontSize: 11.sp, color: Colors.grey),
//   //       ),
//   //       SizedBox(height: 4.h),
//   //       Row(
//   //         mainAxisAlignment: MainAxisAlignment.center,
//   //         children: [
//   //           _formatBadge('JPG'),
//   //           SizedBox(width: 6.w),
//   //           _formatBadge('PNG'),
//   //           SizedBox(width: 6.w),
//   //           _formatBadge('≤ 5MB'),
//   //         ],
//   //       ),
//   //     ],
//   //   );
//   // }
//
//   Widget _buildEmpty() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//       child: FittedBox(
//         // ✅ يضغط المحتوى ليناسب الحجم
//         fit: BoxFit.scaleDown,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: EdgeInsets.all(10.r),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     widget.gold.withValues(alpha: 0.15),
//                     widget.gold.withValues(alpha: 0.05),
//                   ],
//                 ),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(Icons.cloud_upload_outlined,
//                   size: 26.sp, color: widget.gold),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               'اضغط لرفع صورة الإيصال',
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 fontWeight: FontWeight.w600,
//                 color: widget.gold,
//               ),
//             ),
//             SizedBox(height: 3.h),
//             Text(
//               'سيتم ضغط الصورة تلقائياً',
//               style: TextStyle(fontSize: 10.sp, color: Colors.grey),
//             ),
//             SizedBox(height: 6.h),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 _formatBadge('JPG'),
//                 SizedBox(width: 5.w),
//                 _formatBadge('PNG'),
//                 SizedBox(width: 5.w),
//                 _formatBadge('≤ 5MB'),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _formatBadge(String label) => Container(
//         padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
//         decoration: BoxDecoration(
//           color: widget.gold.withValues(alpha: 0.08),
//           borderRadius: BorderRadius.circular(6.r),
//           border: Border.all(color: widget.gold.withValues(alpha: 0.25)),
//         ),
//         child:
//             Text(label, style: TextStyle(fontSize: 11.sp, color: widget.gold)),
//       );
//
//   // ── معاينة الصورة ─────────────────────────────────────────
//
//   Widget _buildPreview(BuildContext context) {
//     return Stack(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(14.r),
//           child: Image.file(
//             widget.provider.receiptFile!,
//             width: double.infinity,
//             height: double.infinity,
//             fit: BoxFit.cover,
//           ),
//         ),
//         // طبقة شفافة
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(14.r),
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [
//                 Colors.transparent,
//                 Colors.black.withValues(alpha: 0.45),
//               ],
//             ),
//           ),
//         ),
//         // شارة النجاح
//         Positioned(
//           bottom: 10.h,
//           right: 10.w,
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
//             decoration: BoxDecoration(
//               color: Colors.green,
//               borderRadius: BorderRadius.circular(20.r),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.green.withValues(alpha: 0.35),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(Icons.check_circle_rounded,
//                     color: Colors.white, size: 13.sp),
//                 SizedBox(width: 5.w),
//                 Text('تم رفع الإيصال',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 11.sp,
//                       fontWeight: FontWeight.bold,
//                     )),
//               ],
//             ),
//           ),
//         ),
//         // زر التغيير
//         Positioned(
//           top: 8.h,
//           left: 8.w,
//           child: GestureDetector(
//             onTap: () => _showPicker(context),
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
//               decoration: BoxDecoration(
//                 color: _kGold,
//                 borderRadius: BorderRadius.circular(20.r),
//                 boxShadow: [
//                   BoxShadow(
//                     color: _kGold.withValues(alpha: 0.4),
//                     blurRadius: 8,
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.edit_rounded, color: Colors.white, size: 13.sp),
//                   SizedBox(width: 4.w),
//                   Text('تغيير',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 11.sp,
//                         fontWeight: FontWeight.bold,
//                       )),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ── معلومات حجم الملف ──────────────────────────────────────
//
//   Widget _buildFileSizeInfo(File file) {
//     final sizeKB = file.lengthSync() / 1024;
//     final sizeStr = sizeKB >= 1024
//         ? '${(sizeKB / 1024).toStringAsFixed(1)} MB'
//         : '${sizeKB.toStringAsFixed(0)} KB';
//
//     return Row(
//       children: [
//         Icon(Icons.insert_drive_file_outlined, size: 14.sp, color: Colors.grey),
//         SizedBox(width: 6.w),
//         Text(
//           'حجم الملف: $sizeStr',
//           style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//         ),
//         SizedBox(width: 8.w),
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
//           decoration: BoxDecoration(
//             color: Colors.green.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(10.r),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.compress_rounded, size: 11.sp, color: Colors.green),
//               SizedBox(width: 3.w),
//               Text('مضغوطة',
//                   style: TextStyle(
//                     fontSize: 11.sp,
//                     color: Colors.green,
//                     fontWeight: FontWeight.bold,
//                   )),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   // ── اختيار المصدر ─────────────────────────────────────────
//
//   void _showPicker(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
//       backgroundColor: widget.isDark ? const Color(0xFF1A1A1A) : Colors.white,
//       builder: (_) => Padding(
//         padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 30.h),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 36.w,
//               height: 4.h,
//               margin: EdgeInsets.only(bottom: 16.h),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(2.r),
//               ),
//             ),
//             Text(
//               'اختر مصدر الصورة',
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               'ستُضغط الصورة تلقائياً للحصول على أفضل جودة',
//               style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 20.h),
//             Row(children: [
//               Expanded(
//                 child: _pickerBtn(
//                   icon: Icons.camera_alt_rounded,
//                   label: 'الكاميرا',
//                   source: ImageSource.camera,
//                 ),
//               ),
//               SizedBox(width: 16.w),
//               Expanded(
//                 child: _pickerBtn(
//                   icon: Icons.photo_library_rounded,
//                   label: 'المعرض',
//                   source: ImageSource.gallery,
//                 ),
//               ),
//             ]),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _pickerBtn({
//     required IconData icon,
//     required String label,
//     required ImageSource source,
//   }) {
//     return GestureDetector(
//       onTap: () => _pickAndCompress(source),
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 18.h),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               _kGold.withValues(alpha: 0.1),
//               _kGold.withValues(alpha: 0.05),
//             ],
//           ),
//           borderRadius: BorderRadius.circular(16.r),
//           border: Border.all(color: _kGold.withValues(alpha: 0.35)),
//         ),
//         child: Column(
//           children: [
//             Container(
//               padding: EdgeInsets.all(12.r),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(colors: [_kGold, _kGoldDark]),
//                 shape: BoxShape.circle,
//                 boxShadow: [
//                   BoxShadow(
//                     color: _kGold.withValues(alpha: 0.35),
//                     blurRadius: 8,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Icon(icon, color: Colors.white, size: 26.sp),
//             ),
//             SizedBox(height: 10.h),
//             Text(label,
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w600,
//                   color: _kGold,
//                 )),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ══════════════════════════════════════════════════════════════════════
// // SERVICES BOTTOM SHEET
// // ══════════════════════════════════════════════════════════════════════
//
// class _ServicesSheet extends StatelessWidget {
//   final AppointmentPersonItem person;
//   final MultiAppointmentProvider provider;
//   final bool isDark;
//   final Color gold;
//
//   const _ServicesSheet({
//     required this.person,
//     required this.provider,
//     required this.isDark,
//     required this.gold,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       initialChildSize: 0.7,
//       maxChildSize: 0.95,
//       minChildSize: 0.5,
//       builder: (_, scroll) => Container(
//         decoration: BoxDecoration(
//           color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//         ),
//         child: Column(
//           children: [
//             Container(
//               margin: EdgeInsets.only(top: 10.h),
//               width: 36.w,
//               height: 4.h,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade400,
//                 borderRadius: BorderRadius.circular(2.r),
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.all(16.w),
//               child: Row(children: [
//                 Container(
//                   padding: EdgeInsets.all(8.r),
//                   decoration: BoxDecoration(
//                     gradient:
//                         const LinearGradient(colors: [_kGold, _kGoldDark]),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(Icons.person_rounded,
//                       color: Colors.white, size: 18.sp),
//                 ),
//                 SizedBox(width: 10.w),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'خدمات لـ ${person.name.isEmpty ? 'الشخص' : person.name}',
//                         style: TextStyle(
//                             fontSize: 17.sp, fontWeight: FontWeight.bold),
//                       ),
//                       Text(
//                         'اختر الخدمات المطلوبة',
//                         style: TextStyle(fontSize: 12.sp, color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (person.services.isNotEmpty)
//                   Container(
//                     padding:
//                         EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
//                     decoration: BoxDecoration(
//                       gradient:
//                           const LinearGradient(colors: [_kGold, _kGoldDark]),
//                       borderRadius: BorderRadius.circular(20.r),
//                     ),
//                     child: Text(
//                       '${person.services.length} مختار',
//                       style: TextStyle(
//                         fontSize: 12.sp,
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//               ]),
//             ),
//             Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
//             Expanded(
//               child: Consumer<ServicesProvider>(
//                 builder: (_, svc, __) {
//                   if (svc.isLoading) {
//                     return Center(
//                         child: CircularProgressIndicator(color: gold));
//                   }
//                   if (svc.categories.isEmpty) {
//                     return Center(
//                       child: Text('لا توجد خدمات متاحة',
//                           style:
//                               TextStyle(fontSize: 14.sp, color: Colors.grey)),
//                     );
//                   }
//                   return _ServicesList(
//                     svcProvider: svc,
//                     person: person,
//                     provider: provider,
//                     scroll: scroll,
//                     isDark: isDark,
//                     gold: gold,
//                   );
//                 },
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 50.h,
//                 child: ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.transparent,
//                     shadowColor: Colors.transparent,
//                     padding: EdgeInsets.zero,
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14.r)),
//                   ),
//                   child: Ink(
//                     decoration: BoxDecoration(
//                       gradient:
//                           const LinearGradient(colors: [_kGold, _kGoldDark]),
//                       borderRadius: BorderRadius.circular(14.r),
//                     ),
//                     child: Container(
//                       alignment: Alignment.center,
//                       child: Text(
//                         person.services.isEmpty
//                             ? 'إغلاق'
//                             : 'تأكيد (${person.services.length} ${person.services.length == 1 ? 'خدمة' : 'خدمات'})',
//                         style: TextStyle(
//                           fontSize: 15.sp,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _ServicesList extends StatelessWidget {
//   final ServicesProvider svcProvider;
//   final AppointmentPersonItem person;
//   final MultiAppointmentProvider provider;
//   final ScrollController scroll;
//   final bool isDark;
//   final Color gold;
//
//   const _ServicesList({
//     required this.svcProvider,
//     required this.person,
//     required this.provider,
//     required this.scroll,
//     required this.isDark,
//     required this.gold,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final cats = svcProvider.categories;
//
//     return ListView.builder(
//       controller: scroll,
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//       itemCount: cats.length,
//       itemBuilder: (_, ci) {
//         final cat = cats[ci];
//         final catSvcs = svcProvider.services
//             .where((s) => s.categoryId == cat.id && s.requiresBooking)
//             .toList();
//
//         if (catSvcs.isEmpty) return const SizedBox.shrink();
//
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: 10.h),
//               child: Row(children: [
//                 Container(
//                   width: 4.w,
//                   height: 20.h,
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [_kGold, _kGoldDark],
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                     ),
//                     borderRadius: BorderRadius.circular(2.r),
//                   ),
//                 ),
//                 SizedBox(width: 8.w),
//                 Text(
//                   cat.categoryNameAr.isNotEmpty
//                       ? cat.categoryNameAr
//                       : cat.categoryName,
//                   style: TextStyle(
//                     fontSize: 15.sp,
//                     fontWeight: FontWeight.bold,
//                     color: gold,
//                   ),
//                 ),
//                 SizedBox(width: 6.w),
//                 Text('(${catSvcs.length})',
//                     style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
//               ]),
//             ),
//             ...catSvcs.map(
//               (svc) => _ServiceTile(
//                 key: ValueKey('${person.tempId}_${svc.id}'),
//                 service: svc,
//                 person: person,
//                 provider: provider,
//                 isDark: isDark,
//                 gold: gold,
//               ),
//             ),
//             if (ci < cats.length - 1)
//               Divider(height: 20.h, color: Colors.grey.withValues(alpha: 0.15)),
//           ],
//         );
//       },
//     );
//   }
// }
//
// class _ServiceTile extends StatefulWidget {
//   final ServiceModel service;
//   final AppointmentPersonItem person;
//   final MultiAppointmentProvider provider;
//   final bool isDark;
//   final Color gold;
//
//   const _ServiceTile({
//     Key? key,
//     required this.service,
//     required this.person,
//     required this.provider,
//     required this.isDark,
//     required this.gold,
//   }) : super(key: key);
//
//   @override
//   State<_ServiceTile> createState() => _ServiceTileState();
// }
//
// class _ServiceTileState extends State<_ServiceTile> {
//   @override
//   Widget build(BuildContext context) {
//     final svc = widget.service;
//     final sel = widget.provider
//         .isServiceSelectedForPerson(widget.person.tempId, svc.id);
//
//     return GestureDetector(
//       onTap: () {
//         HapticFeedback.selectionClick();
//         widget.provider.toggleServiceForPerson(
//           widget.person.tempId,
//           AppointmentServiceItem(
//             serviceId: svc.id,
//             serviceName: svc.serviceName,
//             serviceNameAr: svc.serviceNameAr,
//             price: svc.price,
//             duration: svc.durationMinutes,
//           ),
//         );
//         setState(() {});
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         margin: EdgeInsets.only(bottom: 10.h),
//         padding: EdgeInsets.all(14.w),
//         decoration: BoxDecoration(
//           color: sel ? widget.gold.withValues(alpha: 0.08) : null,
//           borderRadius: BorderRadius.circular(14.r),
//           border: Border.all(
//             color: sel ? widget.gold : Colors.grey.withValues(alpha: 0.2),
//             width: sel ? 1.5 : 1,
//           ),
//         ),
//         child: Row(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(10.r),
//               child: svc.getImageUrl() != null
//                   ? Image.network(
//                       svc.getImageUrl()!,
//                       width: 48.w,
//                       height: 48.h,
//                       fit: BoxFit.cover,
//                       errorBuilder: (_, __, ___) => _placeholder(),
//                     )
//                   : _placeholder(),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     svc.serviceNameAr.isNotEmpty
//                         ? svc.serviceNameAr
//                         : svc.serviceName,
//                     style: TextStyle(
//                       fontSize: 14.sp,
//                       fontWeight: FontWeight.w600,
//                       color: sel ? widget.gold : null,
//                     ),
//                   ),
//                   SizedBox(height: 4.h),
//                   Row(
//                     children: [
//                       Icon(Icons.access_time, size: 12.sp, color: Colors.grey),
//                       SizedBox(width: 3.w),
//                       Text('${svc.durationMinutes} دقيقة',
//                           style:
//                               TextStyle(fontSize: 12.sp, color: Colors.grey)),
//                       if (svc.loyaltyPoints > 0) ...[
//                         SizedBox(width: 8.w),
//                         Icon(Icons.star_rounded,
//                             size: 12.sp, color: widget.gold),
//                         SizedBox(width: 2.w),
//                         Text('${svc.loyaltyPoints} نقطة',
//                             style: TextStyle(
//                               fontSize: 11.sp,
//                               color: widget.gold,
//                             )),
//                       ],
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   '${svc.price.toStringAsFixed(0)} ر.ي',
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.bold,
//                     color: widget.gold,
//                   ),
//                 ),
//                 SizedBox(height: 6.h),
//                 AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 200),
//                   child: Icon(
//                     sel ? Icons.check_circle_rounded : Icons.circle_outlined,
//                     key: ValueKey(sel),
//                     color: sel ? widget.gold : Colors.grey,
//                     size: 24.sp,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _placeholder() => Container(
//         width: 48.w,
//         height: 48.h,
//         decoration: BoxDecoration(
//           color: widget.isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200,
//           borderRadius: BorderRadius.circular(10.r),
//         ),
//         child: Icon(Icons.content_cut_rounded, color: widget.gold, size: 22.sp),
//       );
// }
//
// // ══════════════════════════════════════════════════════════════════════
// // SHARED HELPERS
// // ══════════════════════════════════════════════════════════════════════
//
// Widget _sectionTitle(String title, IconData icon, Color gold) {
//   return Row(
//     children: [
//       Container(
//         padding: EdgeInsets.all(7.r),
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(colors: [_kGold, _kGoldDark]),
//           borderRadius: BorderRadius.circular(10.r),
//         ),
//         child: Icon(icon, color: Colors.white, size: 16.sp),
//       ),
//       SizedBox(width: 10.w),
//       Text(title,
//           style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold)),
//     ],
//   );
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:millionaire_barber/features/appointments/presentation/pages/appointment_success_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:millionaire_barber/features/appointments/domain/models/electronic_wallet_model.dart';
import 'package:millionaire_barber/features/appointments/presentation/providers/appointment_provider.dart';
import 'package:millionaire_barber/features/appointments/presentation/providers/multi_appointment_provider.dart';
import 'package:millionaire_barber/features/profile/presentation/providers/user_provider.dart';
import 'package:millionaire_barber/features/services/presentation/providers/services_provider.dart';
import 'package:millionaire_barber/features/services/domain/models/service_model.dart';

const _kGold     = Color(0xFFB8860B);
const _kGoldDark = Color(0xFF8B6914);
const _kBg       = Color(0xFF0A0A0A);
const _kCard     = Color(0xFF1E1E1E);

const _kStepLabels = ['الأشخاص', 'الموعد', 'الدفع'];
const _kStepIcons  = [
  Icons.people_outline_rounded,
  Icons.calendar_today_outlined,
  Icons.payment_outlined,
];
const _kStepHints = [
  'أضف الأشخاص واختر خدماتهم',
  'حدد التاريخ والوقت المناسب',
  'اختر طريقة الدفع وأكمل الحجز',
];

// ══════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ══════════════════════════════════════════════════════════════════════

class MultiAppointmentScreen extends StatefulWidget {
  const MultiAppointmentScreen({Key? key}) : super(key: key);

  @override
  State<MultiAppointmentScreen> createState() => _MultiAppointmentScreenState();
}

class _MultiAppointmentScreenState extends State<MultiAppointmentScreen>
    with TickerProviderStateMixin {
  late final TabController       _tabCtrl;
  late final AnimationController _progressAnim;
  final _picker   = ImagePicker();
  int  _activeTab = 0;

  @override
  void initState() {
    super.initState();
    _progressAnim = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500), value: 0.0,
    );
    _tabCtrl = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (!_tabCtrl.indexIsChanging && mounted) {
          setState(() => _activeTab = _tabCtrl.index);
          _progressAnim.animateTo(_tabCtrl.index / 2.0, curve: Curves.easeInOut);
        }
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final appt = context.read<MultiAppointmentProvider>();
      appt.reset();
      appt.addPerson();
      appt.loadWallets();
      final svc = context.read<ServicesProvider>();
      svc.resetFilter();
      if (svc.categories.isEmpty) svc.fetchCategories();
      if (svc.services.isEmpty)   svc.fetchServices();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _progressAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? _kBg : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Consumer<MultiAppointmentProvider>(
          builder: (_, prov, __) => Column(
            children: [
              _buildHeader(dark, prov),
              _buildProgressBar(),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: prov.totalPrice > 0
                    ? _buildSummaryChip(prov, dark)
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: IndexedStack(
                  index: _activeTab,
                  children: [
                    _PersonsTab(
                      provider:       prov,
                      isDark:         dark,
                      gold:           _kGold,
                      picker:         _picker,
                      onShowServices: _openServicesSheet,
                    ),
                    _DateTimeTab(provider: prov, isDark: dark, gold: _kGold),
                    _PaymentTab(
                      provider: prov, isDark: dark,
                      gold: _kGold,   picker: _picker,
                    ),
                  ],
                ),
              ),
              _buildBottomNav(prov, dark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool dark, MultiAppointmentProvider prov) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8.h,
        bottom: 16.h, right: 16.w, left: 16.w,
      ),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Row(children: [
            _backButton(),
            SizedBox(width: 12.w),
            Expanded(child: _titleSection(dark)),
            _personsCounter(prov),
          ]),
          SizedBox(height: 20.h),
          _buildStepper(dark),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(anim),
                child: child,
              ),
            ),
            child: Container(
              key:     ValueKey(_activeTab),
              margin:  EdgeInsets.only(top: 12.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
              decoration: BoxDecoration(
                color:        _kGold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20.r),
                border:       Border.all(color: _kGold.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lightbulb_outline, color: _kGold, size: 14.sp),
                  SizedBox(width: 6.w),
                  Text(_kStepHints[_activeTab],
                      style: TextStyle(fontSize: 12.sp, color: _kGold, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _backButton() => GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color:        _kGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border:       Border.all(color: _kGold.withValues(alpha: 0.25)),
      ),
      child: Icon(Icons.arrow_back_ios_new, size: 18.sp, color: _kGold),
    ),
  );

  Widget _titleSection(bool dark) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('حجز موعد جماعي',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold,
              color: dark ? Colors.white : const Color(0xFF1A1A1A))),
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Text('الخطوة ${_activeTab + 1} من 3 — ${_kStepLabels[_activeTab]}',
            key: ValueKey(_activeTab),
            style: TextStyle(fontSize: 12.sp, color: _kGold)),
      ),
    ],
  );

  Widget _personsCounter(MultiAppointmentProvider prov) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
    decoration: BoxDecoration(
      gradient:     const LinearGradient(colors: [_kGold, _kGoldDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(20.r),
      boxShadow:    [BoxShadow(color: _kGold.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.people_rounded, color: Colors.white, size: 15.sp),
      SizedBox(width: 5.w),
      Text('${prov.persons.length}',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
    ]),
  );

  Widget _buildStepper(bool dark) {
    return Row(
      children: List.generate(_kStepLabels.length * 2 - 1, (i) {
        if (i.isOdd) {
          final prevStep = i ~/ 2;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: 2.5,
              decoration: BoxDecoration(
                gradient: _activeTab > prevStep ? const LinearGradient(colors: [_kGold, _kGoldDark]) : null,
                color:    _activeTab <= prevStep ? (dark ? const Color(0xFF2C2C2C) : Colors.grey.shade200) : null,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          );
        }
        final idx         = i ~/ 2;
        final isActive    = _activeTab == idx;
        final isCompleted = _activeTab > idx;
        return GestureDetector(
          onTap: () { if (idx < _activeTab) _goToTab(idx); },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve:    Curves.easeOut,
                width:    isActive ? 46.w : 36.w,
                height:   isActive ? 46.h : 36.h,
                decoration: BoxDecoration(
                  gradient: (isActive || isCompleted)
                      ? const LinearGradient(colors: [_kGold, _kGoldDark], begin: Alignment.topLeft, end: Alignment.bottomRight)
                      : null,
                  color: !(isActive || isCompleted)
                      ? (dark ? const Color(0xFF2C2C2C) : Colors.grey.shade100)
                      : null,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color:        isActive ? _kGold.withValues(alpha: 0.45) : Colors.transparent,
                    blurRadius:   isActive ? 14.0 : 0.0,
                    spreadRadius: isActive ? 2.0  : 0.0,
                    offset:       Offset.zero,
                  )],
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded : _kStepIcons[idx],
                  color: (isActive || isCompleted) ? Colors.white : Colors.grey.shade400,
                  size:  isActive ? 22.sp : 17.sp,
                ),
              ),
              SizedBox(height: 5.h),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize:   10.sp,
                  fontFamily: 'Cairo',
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? _kGold : (dark ? Colors.grey.shade600 : Colors.grey.shade500),
                ),
                child: Text(_kStepLabels[idx]),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressAnim,
      builder: (_, __) => SizedBox(
        height: 3,
        child: Stack(children: [
          Container(color: Colors.grey.withValues(alpha: 0.1)),
          FractionallySizedBox(
            widthFactor: _progressAnim.value < 0.01 ? 0.02 : _progressAnim.value,
            child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [_kGold, _kGoldDark]))),
          ),
        ]),
      ),
    );
  }

  Widget _buildSummaryChip(MultiAppointmentProvider p, bool dark) {
    return Container(
      margin:  EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
      decoration: BoxDecoration(
        color:        _kGold.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14.r),
        border:       Border.all(color: _kGold.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Icon(Icons.receipt_long_outlined, color: _kGold, size: 16.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            '${p.persons.length} ${p.persons.length == 1 ? 'شخص' : 'أشخاص'}'
                '${p.selectedDate != null ? '  •  ${p.selectedDate!.day}/${p.selectedDate!.month}/${p.selectedDate!.year}' : ''}'
                '${p.selectedTimeSlot != null ? '  •  ${p.selectedTimeSlot}' : ''}',
            style:    TextStyle(fontSize: 12.sp, color: dark ? Colors.grey.shade300 : Colors.grey.shade600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            gradient:     const LinearGradient(colors: [_kGold, _kGoldDark]),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text('${p.totalPrice.toStringAsFixed(0)} ر.ي',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ]),
    );
  }

  Widget _buildBottomNav(MultiAppointmentProvider p, bool dark) {
    final isLast = _activeTab == 2;
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, MediaQuery.of(context).padding.bottom + 14.h),
      decoration: BoxDecoration(
        color:        dark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow:    [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: Row(children: [
        if (_activeTab > 0) ...[
          Tooltip(
            message: 'الخطوة السابقة: ${_kStepLabels[_activeTab - 1]}',
            child: GestureDetector(
              onTap: p.isLoading ? null : () { HapticFeedback.lightImpact(); _goToTab(_activeTab - 1); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color:        _kGold.withValues(alpha: p.isLoading ? 0.04 : 0.1),
                  borderRadius: BorderRadius.circular(16.r),
                  border:       Border.all(color: _kGold.withValues(alpha: p.isLoading ? 0.1 : 0.35), width: 1.5),
                ),
                child: Icon(Icons.arrow_forward_ios_rounded,
                    color: p.isLoading ? Colors.grey : _kGold, size: 20.sp),
              ),
            ),
          ),
          SizedBox(width: 12.w),
        ],
        Expanded(
          child: SizedBox(
            height: 56.h,
            child: ElevatedButton(
              onPressed: p.isLoading ? null : () { HapticFeedback.mediumImpact(); _handleNext(p); },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: p.isLoading ? null : LinearGradient(
                    colors: isLast ? [Colors.green.shade500, Colors.green.shade700] : [_kGold, _kGoldDark],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  color:        p.isLoading ? Colors.grey.shade200 : null,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [BoxShadow(
                    color:      p.isLoading ? Colors.transparent : (isLast ? Colors.green : _kGold).withValues(alpha: 0.35),
                    blurRadius: p.isLoading ? 0 : 16,
                    offset:     const Offset(0, 5),
                  )],
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: p.isLoading
                      ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    SizedBox(width: 22.w, height: 22.h,
                        child: CircularProgressIndicator(color: Colors.grey.shade600, strokeWidth: 2.5)),
                    SizedBox(width: 12.w),
                    Text('جارٍ تأكيد الحجز...',
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                  ])
                      : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(
                      isLast
                          ? 'تأكيد الحجز (${p.persons.length} ${p.persons.length == 1 ? 'شخص' : 'أشخاص'})'
                          : 'التالي — ${_kStepLabels[_activeTab + 1]}',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(width: 8.w),
                    Icon(isLast ? Icons.check_circle_outline_rounded : Icons.arrow_back_ios_rounded,
                        color: Colors.white, size: 18.sp),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  void _handleNext(MultiAppointmentProvider p) {
    switch (_activeTab) {
      case 0:
        if (p.persons.isEmpty) { _showSnack('أضف شخصاً واحداً على الأقل', isError: true); return; }
        if (p.persons.any((x) => x.name.trim().isEmpty)) { _showSnack('أدخل الاسم لكل شخص', isError: true); return; }
        if (p.persons.any((x) => x.services.isEmpty)) { _showSnack('اختر خدمة واحدة على الأقل لكل شخص', isError: true); return; }
        _goToTab(1);
        break;
      case 1:
        if (p.selectedDate == null) { _showSnack('اختر تاريخ الموعد أولاً', isError: true); return; }
        if (p.selectedTimeSlot == null) { _showSnack('اختر وقت الموعد', isError: true); return; }
        _goToTab(2);
        break;
      case 2:
        _submit(p);
        break;
    }
  }

  void _goToTab(int index) {
    _tabCtrl.animateTo(index);
    setState(() => _activeTab = index);
    _progressAnim.animateTo(index / 2.0, curve: Curves.easeInOut);
  }

  Future<void> _submit(MultiAppointmentProvider provider) async {
    if (provider.paymentMethod == 'electronic') {
      if (provider.selectedWallet == null) { _showSnack('اختر المحفظة الإلكترونية', isError: true); return; }
      if (provider.receiptFile == null)    { _showSnack('ارفع صورة إيصال التحويل', isError: true); return; }
    }
    final user = context.read<UserProvider>().user;
    if (user == null || user.id == null) { _showSnack('يجب تسجيل الدخول أولاً', isError: true); return; }

    final ok = await provider.submitAppointment(
      userId: user.id!, clientName: user.fullName, clientPhone: user.phone,
    );

    if (ok && mounted) {
      final allServices = provider.persons
          .expand((p) => p.services)
          .map((s) => s.serviceNameAr.isNotEmpty ? s.serviceNameAr : s.serviceName)
          .toList();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BookingSuccessScreen(
        bookingData: {
          'appointment_id': provider.createdAppointment?.id,
          'service_name':   allServices.isEmpty ? 'خدمات متعددة' : allServices.join(' • '),
          'date':           provider.selectedDate!,
          'time':           provider.selectedTimeSlot ?? '',
          'final_price':    provider.totalPrice,
          'discount':       null, 'points_earned': null, 'employee_name': null,
          'status':         'pending',
          'persons_count':  provider.persons.length,
          'payment_method': provider.paymentMethod,
          'is_multi':       true,
        },
      )));
    } else if (mounted) {
      _showSnack(provider.errorMessage ?? 'فشل الحجز، حاول مرة أخرى', isError: true);
    }
  }

  void _openServicesSheet(AppointmentPersonItem person, MultiAppointmentProvider provider, bool dark) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _ServicesSheet(person: person, provider: provider, isDark: dark, gold: _kGold),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Row(children: [
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                color: Colors.white, size: 18.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(child: Text(msg,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.white))),
        ]),
        backgroundColor: isError ? const Color(0xFFE53E3E) : const Color(0xFF38A169),
        behavior:        SnackBarBehavior.floating,
        margin:          EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        duration:        const Duration(seconds: 3),
        elevation:       8,
      ));
  }
}

// ══════════════════════════════════════════════════════════════════════
// TAB 1 — الأشخاص
// ══════════════════════════════════════════════════════════════════════

class _PersonsTab extends StatelessWidget {
  final MultiAppointmentProvider provider;
  final bool    isDark;
  final Color   gold;
  final ImagePicker picker;
  final void Function(AppointmentPersonItem, MultiAppointmentProvider, bool) onShowServices;

  const _PersonsTab({
    required this.provider, required this.isDark,
    required this.gold, required this.picker, required this.onShowServices,
  });

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<ServicesProvider>();
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        if (svc.isLoading)
          Container(
            margin:  EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color:        gold.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12.r),
              border:       Border.all(color: gold.withValues(alpha: 0.2)),
            ),
            child: Row(children: [
              SizedBox(width: 16.w, height: 16.h,
                  child: CircularProgressIndicator(color: gold, strokeWidth: 2)),
              SizedBox(width: 10.w),
              Text('جارٍ تحميل الخدمات المتاحة...', style: TextStyle(fontSize: 13.sp, color: gold)),
            ]),
          ),

        Container(
          padding: EdgeInsets.all(14.w),
          margin:  EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color:        gold.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14.r),
            border:       Border.all(color: gold.withValues(alpha: 0.2)),
          ),
          child: Row(children: [
            Icon(Icons.info_outline_rounded, color: gold, size: 18.sp),
            SizedBox(width: 10.w),
            Expanded(child: Text('أضف كل شخص باسمه واختر الخدمات المطلوبة له',
                style: TextStyle(fontSize: 13.sp,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700))),
          ]),
        ),

        ...List.generate(
          provider.persons.length,
              (i) => _PersonCard(
            key:           ValueKey(provider.persons[i].tempId),
            person:        provider.persons[i],
            index:         i,
            totalPersons:  provider.persons.length,
            provider:      provider,
            isDark:        isDark,
            gold:          gold,
            onShowServices: onShowServices,
          ),
        ),

        SizedBox(height: 4.h),
        Tooltip(
          message: 'إضافة شخص جديد للحجز',
          child: GestureDetector(
            onTap: () { HapticFeedback.lightImpact(); provider.addPerson(); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color:        gold.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16.r),
                border:       Border.all(color: gold.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [_kGold, _kGoldDark]),
                    shape:    BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: Colors.white, size: 18.sp),
                ),
                SizedBox(width: 10.w),
                Text('إضافة شخص آخر',
                    style: TextStyle(fontSize: 15.sp, color: gold, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// بطاقة الشخص
// ══════════════════════════════════════════════════════════════════════

class _PersonCard extends StatefulWidget {
  final AppointmentPersonItem    person;
  final int                      index;
  final int                      totalPersons;
  final MultiAppointmentProvider provider;
  final bool                     isDark;
  final Color                    gold;
  final void Function(AppointmentPersonItem, MultiAppointmentProvider, bool) onShowServices;

  const _PersonCard({
    Key? key,
    required this.person, required this.index, required this.totalPersons,
    required this.provider, required this.isDark, required this.gold,
    required this.onShowServices,
  }) : super(key: key);

  @override
  State<_PersonCard> createState() => _PersonCardState();
}

class _PersonCardState extends State<_PersonCard> with SingleTickerProviderStateMixin {
  late final TextEditingController _ctrl;
  late final AnimationController   _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl      = TextEditingController(text: widget.person.name);
    _shakeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  static const _hints = [
    'أنت (الشخص الأول)', 'الشخص الثاني', 'الشخص الثالث', 'الشخص الرابع', 'الشخص الخامس',
  ];

  String get _personLabel => widget.index == 0 ? 'شخص 1 (أنت)' : 'شخص ${widget.index + 1}';
  String get _hintText    => widget.index < _hints.length ? _hints[widget.index] : 'اسم الشخص ${widget.index + 1}';

  @override
  Widget build(BuildContext context) {
    final p       = widget.person;
    final prov    = widget.provider;
    final dark    = widget.isDark;
    final gold    = widget.gold;
    final isValid = p.name.trim().isNotEmpty && p.services.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color:        dark ? _kCard : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isValid
              ? gold.withValues(alpha: 0.5)
              : (p.name.isEmpty && p.services.isEmpty)
              ? gold.withValues(alpha: 0.2)
              : Colors.orange.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── رأس البطاقة ──────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gold.withValues(alpha: 0.12), gold.withValues(alpha: 0.04)],
                begin: Alignment.centerRight, end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Tooltip(
                  message: _personLabel,
                  child: Container(
                    width: 38.w, height: 38.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_kGold, _kGoldDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      shape:    BoxShape.circle,
                      boxShadow: [BoxShadow(color: _kGold.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Icon(
                      widget.index == 0 ? Icons.person_rounded : Icons.person_outline_rounded,
                      color: Colors.white,
                      size:  widget.index == 0 ? 18.sp : 16.sp,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),

                // ── حقل الاسم + زر "أنا" ──────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── شارة التسمية ──────────────────────────────────
                      Row(children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color:        gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            _personLabel,
                            style: TextStyle(
                              fontSize:   10.sp,
                              fontWeight: FontWeight.bold,
                              color:      gold,
                            ),
                          ),
                        ),
                        if (widget.index == 0) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color:        Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              'أنت',
                              style: TextStyle(
                                fontSize:   9.sp,
                                fontWeight: FontWeight.bold,
                                color:      Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ]),
                      SizedBox(height: 6.h),

                      // ── حقل الاسم ─────────────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: dark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: TextField(
                          controller:    _ctrl,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize:   14.sp,
                            fontWeight: FontWeight.w600,
                            color:      dark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                          decoration: InputDecoration(
                            hintText:       _hintText,
                            hintStyle:      TextStyle(
                                color: Colors.grey.shade400, fontSize: 13.sp),
                            border:         InputBorder.none,
                            isDense:        true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 10.h),
                          ),
                          onChanged: (v) => prov.updatePersonName(p.tempId, v),
                        ),
                      ),

                      // ✅ زر "أنا" — للشخص الأول (صاحب الحساب) فقط
                      // يُسهِّل الحجز مع الزوجة أو الأبناء
                      if (widget.index == 0) ...[
                        SizedBox(height: 6.h),
                        Consumer<UserProvider>(
                          builder: (context, userProv, _) {
                            final userName = userProv.user?.fullName ?? '';
                            if (userName.trim().isEmpty) return const SizedBox.shrink();

                            final alreadySet =
                                _ctrl.text.trim() == userName.trim();

                            return GestureDetector(
                              onTap: alreadySet
                                  ? null
                                  : () {
                                _ctrl.text = userName;
                                prov.updatePersonName(p.tempId, userName);
                                HapticFeedback.lightImpact();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 5.h),
                                decoration: BoxDecoration(
                                  color: alreadySet
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : gold.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: alreadySet
                                        ? Colors.green.withValues(alpha: 0.4)
                                        : gold.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      alreadySet
                                          ? Icons.check_circle_rounded
                                          : Icons.person_pin_rounded,
                                      size:  12.sp,
                                      color: alreadySet ? Colors.green : gold,
                                    ),
                                    SizedBox(width: 4.w),
                                    Flexible(
                                      child: Text(
                                        alreadySet
                                            ? 'تم تعيين اسمك ✓'
                                            : 'أنا ($userName)',
                                        style: TextStyle(
                                          fontSize:   11.sp,
                                          fontWeight: FontWeight.w600,
                                          color: alreadySet ? Colors.green : gold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                      // ملاحظة: الأشخاص من index 1 وما بعد (زوجة، أبناء، إلخ)
                      // يكتبون أسماءهم يدوياً بدون زر "أنا"
                    ],
                  ),
                ),


                SizedBox(width: 8.w),

                // أيقونة الحالة + زر الحذف
                Column(children: [
                  Tooltip(
                    message: isValid ? 'البيانات مكتملة ✓' : 'يتطلب: اسم + خدمة',
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color:  isValid ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                        shape:  BoxShape.circle,
                      ),
                      child: Icon(
                        isValid ? Icons.check_circle_rounded : Icons.pending_rounded,
                        color: isValid ? Colors.green : Colors.orange,
                        size:  18.sp,
                      ),
                    ),
                  ),
                  if (prov.persons.length > 1) ...[
                    SizedBox(height: 6.h),
                    Tooltip(
                      message: 'حذف هذا الشخص',
                      child: GestureDetector(
                        onTap: () => _confirmDelete(context),
                        child: Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 18.sp),
                        ),
                      ),
                    ),
                  ],
                ]),
              ],
            ),
          ),

          // ── قسم الخدمات ──────────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.content_cut_rounded, color: gold, size: 15.sp),
                  SizedBox(width: 6.w),
                  Text('الخدمات المختارة',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: gold)),
                  const Spacer(),
                  if (p.services.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color:        gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text('${p.services.length} خدمة',
                          style: TextStyle(fontSize: 11.sp, color: gold, fontWeight: FontWeight.bold)),
                    ),
                ]),
                SizedBox(height: 10.h),

                if (p.services.isNotEmpty)
                  ...p.services.map((s) => _ServiceChip(service: s, personId: p.tempId, provider: prov, gold: gold))
                else
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color:        Colors.orange.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(10.r),
                      border:       Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16.sp),
                      SizedBox(width: 8.w),
                      Text('لم تُختر أي خدمة بعد',
                          style: TextStyle(fontSize: 13.sp, color: Colors.orange.shade700)),
                    ]),
                  ),

                SizedBox(height: 12.h),

                GestureDetector(
                  onTap: () { HapticFeedback.lightImpact(); widget.onShowServices(p, prov, widget.isDark); },
                  child: Container(
                    width:   double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [gold.withValues(alpha: 0.08), gold.withValues(alpha: 0.04)]),
                      borderRadius: BorderRadius.circular(12.r),
                      border:       Border.all(color: gold.withValues(alpha: 0.35)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(p.services.isEmpty ? Icons.add_circle_outline_rounded : Icons.edit_outlined,
                          color: gold, size: 18.sp),
                      SizedBox(width: 8.w),
                      Text(p.services.isEmpty ? 'اختر الخدمات لهذا الشخص' : 'تعديل الخدمات',
                          style: TextStyle(fontSize: 13.sp, color: gold, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),

                if (p.services.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color:        gold.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [
                        Icon(Icons.timer_outlined, color: Colors.grey, size: 14.sp),
                        SizedBox(width: 4.w),
                        Text('${p.totalDuration} دقيقة',
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                      ]),
                      Text('${p.totalPrice.toStringAsFixed(0)} ر.ي',
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: gold)),
                    ]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape:   RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Row(children: [
          Icon(Icons.delete_outline_rounded, color: Colors.red, size: 24.sp),
          SizedBox(width: 10.w),
          const Text('حذف شخص'),
        ]),
        content: Text(
          'هل تريد حذف $_personLabel "${widget.person.name.isEmpty ? '(بدون اسم)' : widget.person.name}" من الحجز؟',
          style: TextStyle(fontSize: 14.sp, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: TextStyle(color: Colors.grey, fontSize: 15.sp)),
          ),
          ElevatedButton(
            onPressed: () { widget.provider.removePerson(widget.person.tempId); Navigator.pop(ctx); },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Service Chip ──────────────────────────────────────────────────────

class _ServiceChip extends StatelessWidget {
  final AppointmentServiceItem   service;
  final String                   personId;
  final MultiAppointmentProvider provider;
  final Color                    gold;

  const _ServiceChip({required this.service, required this.personId, required this.provider, required this.gold});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  EdgeInsets.only(bottom: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color:        gold.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10.r),
        border:       Border.all(color: gold.withValues(alpha: 0.2)),
      ),
      child: Row(children: [
        Icon(Icons.check_circle_rounded, color: gold, size: 16.sp),
        SizedBox(width: 8.w),
        Expanded(child: Text(
          service.serviceNameAr.isNotEmpty ? service.serviceNameAr : service.serviceName,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
        )),
        Text('${service.price.toStringAsFixed(0)} ر.ي',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: gold)),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: () => provider.removeServiceFromPerson(personId, service.serviceId),
          child: Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.close_rounded, size: 14.sp, color: Colors.red),
          ),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// TAB 2 — التاريخ والوقت  ✅ إصلاح لون التاريخ المحدد
// ══════════════════════════════════════════════════════════════════════

class _DateTimeTab extends StatelessWidget {
  final MultiAppointmentProvider provider;
  final bool  isDark;
  final Color gold;

  const _DateTimeTab({required this.provider, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('اختر التاريخ', Icons.calendar_today_outlined, gold),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color:        isDark ? _kCard : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow:    [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12)],
            ),
            // ✅ إصلاح: لف CalendarDatePicker بـ Theme لإصلاح لون التحديد
// ✅ لف CalendarDatePicker بـ Theme مخصص
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary:   _kGold,           // ← دائرة التاريخ المحدد
                  onPrimary: Colors.white,     // ← رقم التاريخ داخل الدائرة
                  onSurface: isDark ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              child: CalendarDatePicker(
                initialDate: provider.selectedDate ??
                    DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now().add(const Duration(days: 1)),
                lastDate:  DateTime.now().add(const Duration(days: 60)),
                onDateChanged: (date) {
                  provider.setDate(date);
                  context
                      .read<AppointmentProvider>()
                      .fetchAvailableTimeSlots(date, provider.totalDuration);
                },
              ),
            ),

          ),
          if (provider.selectedDate != null) ...[
            SizedBox(height: 24.h),
            _sectionTitle('اختر الوقت', Icons.access_time_outlined, gold),
            SizedBox(height: 4.h),
            Text('المدة الإجمالية المطلوبة: ${provider.totalDuration} دقيقة',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            SizedBox(height: 12.h),
            _TimeSlots(provider: provider, isDark: isDark, gold: gold),
          ],
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

class _TimeSlots extends StatelessWidget {
  final MultiAppointmentProvider provider;
  final bool  isDark;
  final Color gold;

  const _TimeSlots({required this.provider, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentProvider>(
      builder: (_, ap, __) {
        if (ap.isLoading) return Center(child: Column(children: [
          CircularProgressIndicator(color: gold),
          SizedBox(height: 12.h),
          Text('جارٍ تحميل الأوقات المتاحة...', style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
        ]));

        if (ap.availableTimeSlots.isEmpty) return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(color: isDark ? _kCard : Colors.white, borderRadius: BorderRadius.circular(16.r)),
          child: Column(children: [
            Icon(Icons.event_busy_rounded, size: 48.sp, color: Colors.grey),
            SizedBox(height: 12.h),
            Text('لا توجد أوقات متاحة في هذا اليوم', style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
            SizedBox(height: 6.h),
            Text('جرّب اختيار يوم آخر', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500)),
          ]),
        );

        return Wrap(
          spacing: 10.w, runSpacing: 10.h,
          children: ap.availableTimeSlots.map((slot) {
            final sel = provider.selectedTimeSlot == slot;
            return GestureDetector(
              onTap: () { HapticFeedback.selectionClick(); provider.setTimeSlot(slot); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
                decoration: BoxDecoration(
                  gradient:     sel ? const LinearGradient(colors: [_kGold, _kGoldDark]) : null,
                  color:        sel ? null : (isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [BoxShadow(
                    color:      sel ? gold.withValues(alpha: 0.4) : Colors.transparent,
                    blurRadius: sel ? 8.0 : 0.0,
                    offset:     const Offset(0, 3),
                  )],
                ),
                child: Text(slot, style: TextStyle(
                  fontSize:   14.sp,
                  fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                  color:      sel ? Colors.white : (isDark ? Colors.white70 : null),
                )),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// TAB 3 — الدفع
// ══════════════════════════════════════════════════════════════════════

class _PaymentTab extends StatelessWidget {
  final MultiAppointmentProvider provider;
  final bool        isDark;
  final Color       gold;
  final ImagePicker picker;

  const _PaymentTab({required this.provider, required this.isDark, required this.gold, required this.picker});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('طريقة الدفع', Icons.payment_outlined, gold),
          SizedBox(height: 14.h),
          _PaymentOption(provider: provider, method: 'cash',       title: 'دفع عند الحضور',   subtitle: 'ادفع نقداً عند وصولك للصالون', icon: Icons.money_rounded,          isDark: isDark, gold: gold),
          SizedBox(height: 12.h),
          _PaymentOption(provider: provider, method: 'electronic', title: 'تحويل إلكتروني',  subtitle: 'حوّل المبلغ وارفع صورة الإيصال', icon: Icons.phone_android_rounded, isDark: isDark, gold: gold),
          if (provider.isElectronic) ...[
            SizedBox(height: 24.h),
            _ElectronicSection(provider: provider, isDark: isDark, gold: gold, picker: picker),
          ],
          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final MultiAppointmentProvider provider;
  final String   method, title, subtitle;
  final IconData icon;
  final bool     isDark;
  final Color    gold;

  const _PaymentOption({
    required this.provider, required this.method,  required this.title,
    required this.subtitle, required this.icon,    required this.isDark, required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    final sel = provider.paymentMethod == method;
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); provider.setPaymentMethod(method); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color:        isDark ? _kCard : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border:       Border.all(color: sel ? gold : Colors.grey.withValues(alpha: 0.3), width: sel ? 2 : 1),
          boxShadow: [BoxShadow(
            color:      sel ? gold.withValues(alpha: 0.18) : Colors.transparent,
            blurRadius: sel ? 14.0 : 0.0,
            offset:     const Offset(0, 4),
          )],
        ),
        child: Row(children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              gradient: sel ? const LinearGradient(colors: [_kGold, _kGoldDark]) : null,
              color:    sel ? null : Colors.grey.shade100,
              shape:    BoxShape.circle,
            ),
            child: Icon(icon, color: sel ? Colors.white : Colors.grey, size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: sel ? gold : null)),
            Text(subtitle, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
          ])),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 22.w, height: 22.h,
            decoration: BoxDecoration(
              shape:  BoxShape.circle,
              border: Border.all(color: sel ? gold : Colors.grey, width: 2),
              color:  sel ? gold : Colors.transparent,
            ),
            child: sel ? Icon(Icons.check, color: Colors.white, size: 13.sp) : null,
          ),
        ]),
      ),
    );
  }
}

class _ElectronicSection extends StatelessWidget {
  final MultiAppointmentProvider provider;
  final bool isDark; final Color gold; final ImagePicker picker;

  const _ElectronicSection({required this.provider, required this.isDark, required this.gold, required this.picker});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('اختر المحفظة', Icons.account_balance_wallet_outlined, gold),
      SizedBox(height: 12.h),
      if (provider.wallets.isEmpty)
        Center(child: CircularProgressIndicator(color: gold))
      else
        ...provider.wallets.map((w) => _WalletCard(wallet: w, provider: provider, isDark: isDark, gold: gold)),
      if (provider.selectedWallet != null) ...[
        SizedBox(height: 20.h),
        _TransferInfo(wallet: provider.selectedWallet!, totalPrice: provider.totalPrice, gold: gold),
      ],
      SizedBox(height: 24.h),
      _sectionTitle('ارفع صورة الإيصال', Icons.receipt_long_outlined, gold),
      SizedBox(height: 12.h),
      _ReceiptUploader(provider: provider, isDark: isDark, gold: gold, picker: picker),
    ]);
  }
}

class _WalletCard extends StatelessWidget {
  final ElectronicWalletModel wallet; final MultiAppointmentProvider provider;
  final bool isDark; final Color gold;

  const _WalletCard({required this.wallet, required this.provider, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    final sel = provider.selectedWalletId == wallet.id;
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); provider.selectWallet(wallet.id); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin:   EdgeInsets.only(bottom: 10.h),
        padding:  EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color:        isDark ? _kCard : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border:       Border.all(color: sel ? gold : Colors.grey.withValues(alpha: 0.2), width: sel ? 2 : 1),
          boxShadow: [BoxShadow(
            color:      sel ? gold.withValues(alpha: 0.15) : Colors.transparent,
            blurRadius: sel ? 10.0 : 0.0,
            offset:     const Offset(0, 3),
          )],
        ),
        child: Row(children: [
          Container(
            width: 46.w, height: 46.h,
            decoration: BoxDecoration(color: gold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12.r)),
            child: Center(child: Text(
              wallet.walletNameAr.isNotEmpty ? wallet.walletNameAr[0] : '؟',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: gold),
            )),
          ),
          SizedBox(width: 14.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(wallet.walletNameAr, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: sel ? gold : null)),
            Text(wallet.phoneNumber,  style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
          ])),
          if (sel)
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(color: gold, shape: BoxShape.circle),
              child: Icon(Icons.check, color: Colors.white, size: 14.sp),
            ),
        ]),
      ),
    );
  }
}

class _TransferInfo extends StatelessWidget {
  final ElectronicWalletModel wallet; final double totalPrice; final Color gold;

  const _TransferInfo({required this.wallet, required this.totalPrice, required this.gold});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color:        const Color(0xFF3B82F6).withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14.r),
        border:       Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF3B82F6)),
          SizedBox(width: 8.w),
          Text('معلومات التحويل',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF3B82F6))),
        ]),
        SizedBox(height: 12.h),
        _row('المحفظة', wallet.walletNameAr),
        _row('الرقم',   wallet.phoneNumber),
        if (wallet.accountName?.isNotEmpty == true) _row('الاسم', wallet.accountName!),
        _row('المبلغ', '${totalPrice.toStringAsFixed(0)} ر.ي'),
      ]),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: EdgeInsets.only(bottom: 6.h),
    child: Row(children: [
      Text('$label: ', style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
      Text(value,      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════════
// Receipt Uploader
// ══════════════════════════════════════════════════════════════════════

class _ReceiptUploader extends StatefulWidget {
  final MultiAppointmentProvider provider;
  final bool isDark; final Color gold; final ImagePicker picker;

  const _ReceiptUploader({required this.provider, required this.isDark, required this.gold, required this.picker});

  @override
  State<_ReceiptUploader> createState() => _ReceiptUploaderState();
}

class _ReceiptUploaderState extends State<_ReceiptUploader> {
  bool _isCompressing = false;

  Future<File?> _compressImage(File file) async {
    try {
      final dir  = await getTemporaryDirectory();
      final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_receipt.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, path, quality: 72, minWidth: 1024, minHeight: 1024, format: CompressFormat.jpeg,
      );
      return result != null ? File(result.path) : file;
    } catch (_) { return file; }
  }

  Future<void> _pickAndCompress(ImageSource source) async {
    Navigator.pop(context);
    final picked = await widget.picker.pickImage(source: source, imageQuality: 100);
    if (picked == null) return;
    setState(() => _isCompressing = true);
    try {
      final original   = File(picked.path);
      final compressed = await _compressImage(original);
      if (compressed != null) {
        widget.provider.setReceiptFile(compressed);
        if (mounted) {
          final origSize = (original.lengthSync() / 1024).toStringAsFixed(0);
          final newSize  = (compressed.lengthSync() / 1024).toStringAsFixed(0);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(children: [
              Icon(Icons.compress_rounded, color: Colors.white, size: 18.sp),
              SizedBox(width: 8.w),
              Text('تم ضغط الصورة: ${origSize}KB → ${newSize}KB', style: TextStyle(fontSize: 13.sp)),
            ]),
            backgroundColor: const Color(0xFF38A169),
            behavior:        SnackBarBehavior.floating,
            margin:          EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            duration:        const Duration(seconds: 3),
          ));
        }
      }
    } finally {
      if (mounted) setState(() => _isCompressing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = widget.provider;
    final gold = widget.gold;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      GestureDetector(
        onTap: _isCompressing ? null : () => _showPicker(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width:    double.infinity,
          height:   prov.receiptFile != null ? 200.h : 130.h,
          decoration: BoxDecoration(
            color:        widget.isDark ? _kCard : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: _isCompressing ? gold.withValues(alpha: 0.4) : prov.receiptFile != null ? Colors.green : gold.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [BoxShadow(
              color:      prov.receiptFile != null ? Colors.green.withValues(alpha: 0.15) : Colors.transparent,
              blurRadius: prov.receiptFile != null ? 12.0 : 0.0,
              offset:     const Offset(0, 4),
            )],
          ),
          child: _isCompressing ? _buildCompressing() : prov.receiptFile != null ? _buildPreview(context) : _buildEmpty(),
        ),
      ),
      if (prov.receiptFile != null) ...[SizedBox(height: 8.h), _buildFileSizeInfo(prov.receiptFile!)],
    ]);
  }

  Widget _buildCompressing() => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    SizedBox(width: 40.w, height: 40.h, child: CircularProgressIndicator(color: widget.gold, strokeWidth: 3)),
    SizedBox(height: 12.h),
    Text('جارٍ ضغط الصورة...', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: widget.gold)),
    SizedBox(height: 4.h),
    Text('يُرجى الانتظار', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
  ]);

  Widget _buildEmpty() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [widget.gold.withValues(alpha: 0.15), widget.gold.withValues(alpha: 0.05)]),
            shape:    BoxShape.circle,
          ),
          child: Icon(Icons.cloud_upload_outlined, size: 26.sp, color: widget.gold),
        ),
        SizedBox(height: 8.h),
        Text('اضغط لرفع صورة الإيصال',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: widget.gold)),
        SizedBox(height: 3.h),
        Text('سيتم ضغط الصورة تلقائياً', style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
        SizedBox(height: 6.h),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _badge('JPG'), SizedBox(width: 5.w), _badge('PNG'), SizedBox(width: 5.w), _badge('≤ 5MB'),
        ]),
      ]),
    ),
  );

  Widget _badge(String label) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
      color:        widget.gold.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(6.r),
      border:       Border.all(color: widget.gold.withValues(alpha: 0.25)),
    ),
    child: Text(label, style: TextStyle(fontSize: 11.sp, color: widget.gold)),
  );

  Widget _buildPreview(BuildContext context) => Stack(children: [
    ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Image.file(widget.provider.receiptFile!, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
    ),
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.45)],
        ),
      ),
    ),
    Positioned(bottom: 10.h, right: 10.w, child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color:        Colors.green,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow:    [BoxShadow(color: Colors.green.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.check_circle_rounded, color: Colors.white, size: 13.sp),
        SizedBox(width: 5.w),
        Text('تم رفع الإيصال', style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold)),
      ]),
    )),
    Positioned(top: 8.h, left: 8.w, child: GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color:        _kGold,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow:    [BoxShadow(color: _kGold.withValues(alpha: 0.4), blurRadius: 8)],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.edit_rounded, color: Colors.white, size: 13.sp),
          SizedBox(width: 4.w),
          Text('تغيير', style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold)),
        ]),
      ),
    )),
  ]);

  Widget _buildFileSizeInfo(File file) {
    final sizeKB  = file.lengthSync() / 1024;
    final sizeStr = sizeKB >= 1024 ? '${(sizeKB / 1024).toStringAsFixed(1)} MB' : '${sizeKB.toStringAsFixed(0)} KB';
    return Row(children: [
      Icon(Icons.insert_drive_file_outlined, size: 14.sp, color: Colors.grey),
      SizedBox(width: 6.w),
      Text('حجم الملف: $sizeStr', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
      SizedBox(width: 8.w),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10.r)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.compress_rounded, size: 11.sp, color: Colors.green),
          SizedBox(width: 3.w),
          Text('مضغوطة', style: TextStyle(fontSize: 11.sp, color: Colors.green, fontWeight: FontWeight.bold)),
        ]),
      ),
    ]);
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape:           RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      backgroundColor: widget.isDark ? const Color(0xFF1A1A1A) : Colors.white,
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 30.h),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36.w, height: 4.h, margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2.r))),
          Text('اختر مصدر الصورة', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text('ستُضغط الصورة تلقائياً للحصول على أفضل جودة',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey), textAlign: TextAlign.center),
          SizedBox(height: 20.h),
          Row(children: [
            Expanded(child: _pickerBtn(icon: Icons.camera_alt_rounded,    label: 'الكاميرا', source: ImageSource.camera)),
            SizedBox(width: 16.w),
            Expanded(child: _pickerBtn(icon: Icons.photo_library_rounded, label: 'المعرض',  source: ImageSource.gallery)),
          ]),
        ]),
      ),
    );
  }

  Widget _pickerBtn({required IconData icon, required String label, required ImageSource source}) =>
      GestureDetector(
        onTap: () => _pickAndCompress(source),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 18.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_kGold.withValues(alpha: 0.1), _kGold.withValues(alpha: 0.05)]),
            borderRadius: BorderRadius.circular(16.r),
            border:       Border.all(color: _kGold.withValues(alpha: 0.35)),
          ),
          child: Column(children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                gradient:  const LinearGradient(colors: [_kGold, _kGoldDark]),
                shape:     BoxShape.circle,
                boxShadow: [BoxShadow(color: _kGold.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Icon(icon, color: Colors.white, size: 26.sp),
            ),
            SizedBox(height: 10.h),
            Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: _kGold)),
          ]),
        ),
      );
}

// ══════════════════════════════════════════════════════════════════════
// SERVICES BOTTOM SHEET  ✅ إصلاح التداخل عند التمرير
// ══════════════════════════════════════════════════════════════════════

class _ServicesSheet extends StatelessWidget {
  final AppointmentPersonItem    person;
  final MultiAppointmentProvider provider;
  final bool  isDark;
  final Color gold;

  const _ServicesSheet({required this.person, required this.provider, required this.isDark, required this.gold});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7, maxChildSize: 0.95, minChildSize: 0.5,
      builder: (_, scroll) => Container(
        decoration: BoxDecoration(
          color:        isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(children: [
          Container(
            margin: EdgeInsets.only(top: 10.h),
            width: 36.w, height: 4.h,
            decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2.r)),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [_kGold, _kGoldDark]), shape: BoxShape.circle),
                child: Icon(Icons.person_rounded, color: Colors.white, size: 18.sp),
              ),
              SizedBox(width: 10.w),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('خدمات لـ ${person.name.isEmpty ? 'الشخص' : person.name}',
                    style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold)),
                Text('اختر الخدمات المطلوبة', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              ])),
              if (person.services.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: const BoxDecoration(gradient: LinearGradient(colors: [_kGold, _kGoldDark]), borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Text('${person.services.length} مختار',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
            ]),
          ),
          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
          Expanded(
            child: Consumer<ServicesProvider>(
              builder: (_, svc, __) {
                if (svc.isLoading) return Center(child: CircularProgressIndicator(color: gold));
                if (svc.categories.isEmpty) return Center(
                  child: Text('لا توجد خدمات متاحة', style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
                );
                return _ServicesList(
                  svcProvider: svc, person: person, provider: provider,
                  scroll: scroll, isDark: isDark, gold: gold,
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
            child: SizedBox(
              width: double.infinity, height: 50.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient:     const LinearGradient(colors: [_kGold, _kGoldDark]),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      person.services.isEmpty ? 'إغلاق' : 'تأكيد (${person.services.length} ${person.services.length == 1 ? 'خدمة' : 'خدمات'})',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ServicesList extends StatelessWidget {
  final ServicesProvider svcProvider; final AppointmentPersonItem person;
  final MultiAppointmentProvider provider; final ScrollController scroll;
  final bool isDark; final Color gold;

  const _ServicesList({
    required this.svcProvider, required this.person, required this.provider,
    required this.scroll,      required this.isDark,  required this.gold,
  });

  @override
  Widget build(BuildContext context) {
    final cats = svcProvider.categories;
    return ListView.builder(
      controller: scroll,
      padding:    EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount:  cats.length,
      itemBuilder: (_, ci) {
        final cat     = cats[ci];
        final catSvcs = svcProvider.services.where((s) => s.categoryId == cat.id && s.requiresBooking).toList();
        if (catSvcs.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Row(children: [
                Container(
                  width: 4.w, height: 20.h,
                  decoration: BoxDecoration(
                    gradient:     const LinearGradient(colors: [_kGold, _kGoldDark], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(cat.categoryNameAr.isNotEmpty ? cat.categoryNameAr : cat.categoryName,
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: gold)),
                SizedBox(width: 6.w),
                Text('(${catSvcs.length})', style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              ]),
            ),
            ...catSvcs.map((svc) => _ServiceTile(
              key: ValueKey('${person.tempId}_${svc.id}'),
              service: svc, person: person, provider: provider, isDark: isDark, gold: gold,
            )),
            if (ci < cats.length - 1) Divider(height: 20.h, color: Colors.grey.withValues(alpha: 0.15)),
          ],
        );
      },
    );
  }
}

class _ServiceTile extends StatefulWidget {
  final ServiceModel service; final AppointmentPersonItem person;
  final MultiAppointmentProvider provider; final bool isDark; final Color gold;

  const _ServiceTile({Key? key, required this.service, required this.person, required this.provider, required this.isDark, required this.gold}) : super(key: key);

  @override
  State<_ServiceTile> createState() => _ServiceTileState();
}

class _ServiceTileState extends State<_ServiceTile> {
  @override
  Widget build(BuildContext context) {
    final svc = widget.service;
    final sel = widget.provider.isServiceSelectedForPerson(
        widget.person.tempId, svc.id);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Material(
        // ✅ Material يضمن القطع الصحيح لكل المحتوى داخل الحواف المستديرة
        color:        Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
        clipBehavior: Clip.antiAlias,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: sel
                ? widget.gold.withValues(alpha: 0.10)
                : (widget.isDark ? const Color(0xFF2A2A2A) : Colors.white),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: sel
                  ? widget.gold
                  : (widget.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.shade200),
              width: sel ? 1.5 : 1,
            ),
          ),
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              widget.provider.toggleServiceForPerson(
                widget.person.tempId,
                AppointmentServiceItem(
                  serviceId:     svc.id,
                  serviceName:   svc.serviceName,
                  serviceNameAr: svc.serviceNameAr,
                  price:         svc.price,
                  duration:      svc.durationMinutes,
                ),
              );
              setState(() {});
            },
            splashColor:      widget.gold.withValues(alpha: 0.15),
            highlightColor:   widget.gold.withValues(alpha: 0.08),
            borderRadius:     BorderRadius.circular(14.r),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                children: [
                  // ── صورة الخدمة ──────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: svc.getImageUrl() != null
                        ? Image.network(
                      svc.getImageUrl()!,
                      width:  48.w,
                      height: 48.h,
                      fit:    BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                        : _placeholder(),
                  ),
                  SizedBox(width: 12.w),

                  // ── اسم + تفاصيل ─────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          svc.serviceNameAr.isNotEmpty
                              ? svc.serviceNameAr
                              : svc.serviceName,
                          style: TextStyle(
                            fontSize:   14.sp,
                            fontWeight: FontWeight.w600,
                            color: sel
                                ? widget.gold
                                : (widget.isDark ? Colors.white : const Color(0xFF1A1A1A)),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 12.sp, color: Colors.grey),
                            SizedBox(width: 3.w),
                            Text(
                              '${svc.durationMinutes} دقيقة',
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.grey),
                            ),
                            if (svc.loyaltyPoints > 0) ...[
                              SizedBox(width: 8.w),
                              Icon(Icons.star_rounded,
                                  size: 12.sp, color: widget.gold),
                              SizedBox(width: 2.w),
                              Text(
                                '${svc.loyaltyPoints} نقطة',
                                style: TextStyle(
                                    fontSize: 11.sp, color: widget.gold),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── السعر + أيقونة التحديد ───────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${svc.price.toStringAsFixed(0)} ر.ي',
                        style: TextStyle(
                          fontSize:   14.sp,
                          fontWeight: FontWeight.bold,
                          color:      widget.gold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, anim) => ScaleTransition(
                          scale: anim,
                          child: child,
                        ),
                        child: Icon(
                          sel
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          key:   ValueKey(sel),
                          color: sel ? widget.gold : Colors.grey.shade400,
                          size:  24.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width:  48.w,
    height: 48.h,
    decoration: BoxDecoration(
      color: widget.isDark
          ? const Color(0xFF383838)
          : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Icon(
      Icons.content_cut_rounded,
      color: widget.gold,
      size:  22.sp,
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════
// SHARED HELPERS
// ══════════════════════════════════════════════════════════════════════

Widget _sectionTitle(String title, IconData icon, Color gold) {
  return Row(children: [
    Container(
      padding: EdgeInsets.all(7.r),
      decoration: BoxDecoration(
        gradient:     const LinearGradient(colors: [_kGold, _kGoldDark]),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(icon, color: Colors.white, size: 16.sp),
    ),
    SizedBox(width: 10.w),
    Text(title, style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold)),
  ]);
}
