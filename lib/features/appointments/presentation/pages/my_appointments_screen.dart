// // import 'dart:ui' as ui;
// // import 'package:flutter/material.dart';
// // import 'package:flutter_animate/flutter_animate.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:flutter_slidable/flutter_slidable.dart';
// // import 'package:millionaire_barber/core/constants/app_colors.dart';
// // import 'package:millionaire_barber/features/appointments/domain/models/appointment_model.dart';
// // import 'package:millionaire_barber/features/appointments/presentation/pages/appointment_details_screen.dart';
// // import 'package:millionaire_barber/features/appointments/presentation/providers/appointment_provider.dart';
// // import 'package:millionaire_barber/features/notifications/presentation/providers/notification_provider.dart';
// // import 'package:millionaire_barber/features/profile/presentation/providers/user_provider.dart';
// // import 'package:millionaire_barber/features/reviews/presentation/providers/review_provider.dart';
// // import 'package:shimmer/shimmer.dart';
// // import 'package:intl/intl.dart';
// // import 'package:provider/provider.dart';
// // import '../../../reviews/presentation/pages/add_review_screen.dart';
// //
// // class MyAppointmentsScreen extends StatefulWidget {
// //   const MyAppointmentsScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
// // }
// //
// // class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
// //     with SingleTickerProviderStateMixin {
// //   late TabController _tabController;
// //   final TextEditingController _searchController = TextEditingController();
// //   bool _isLoading = false;
// //   bool _isSearching = false;
// //   String _searchQuery = '';
// //   String _sortBy = 'date'; // 'date' or 'price'
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: 3, vsync: this);
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _loadAppointments();
// //     });
// //   }
// //
// //   Future<void> _loadAppointments() async {
// //     final userProvider = Provider.of<UserProvider>(context, listen: false);
// //     if (userProvider.user?.id == null) return;
// //
// //     setState(() => _isLoading = true);
// //
// //     final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
// //     await appointmentProvider.fetchUserAppointments(userProvider.user!.id!);
// //
// //     if (mounted) setState(() => _isLoading = false);
// //   }
// //
// //   @override
// //   void dispose() {
// //     _tabController.dispose();
// //     _searchController.dispose();
// //     super.dispose();
// //   }
// //
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
// //         backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
// //         body: NestedScrollView(
// //           headerSliverBuilder: (context, innerBoxIsScrolled) {
// //             return [
// //               _buildAppBar(isDark, innerBoxIsScrolled),
// //             ];
// //           },
// //           body: Column(
// //             children: [
// //               // ✅ Search Bar
// //               _buildSearchBar(isDark),
// //
// //               // ✅ Sort & Filter Row
// //               _buildSortFilterRow(isDark),
// //
// //               // ✅ Tabs
// //               _buildTabBar(isDark),
// //
// //               // ✅ Content
// //               Expanded(
// //                 child: _isLoading
// //                     ? _buildShimmerLoading(isDark)
// //                     : TabBarView(
// //                   controller: _tabController,
// //                   children: [
// //                     _buildUpcomingTab(isDark),
// //                     _buildCompletedTab(isDark),
// //                     _buildCancelledTab(isDark),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   /// ═══════════════════════════════════════════════════════════════
// //   /// APP BAR
// //   /// ═══════════════════════════════════════════════════════════════
// //
// //   Widget _buildAppBar(bool isDark, bool innerBoxIsScrolled) {
// //     return SliverAppBar(
// //       expandedHeight: 120.h,
// //       floating: false,
// //       pinned: true,
// //       elevation: 0,
// //       backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
// //       leading: IconButton(
// //         icon: Container(
// //           padding: EdgeInsets.all(8.r),
// //           decoration: BoxDecoration(
// //             color: AppColors.darkRed.withValues(alpha: 0.1),
// //             borderRadius: BorderRadius.circular(10.r),
// //           ),
// //           child: Icon(Icons.arrow_back_ios, size: 18.sp, color: AppColors.darkRed),
// //         ),
// //         onPressed: () => Navigator.pop(context),
// //       ),
// //       actions: [
// //         // ✅ Search Toggle
// //         IconButton(
// //           icon: Container(
// //             padding: EdgeInsets.all(8.r),
// //             decoration: BoxDecoration(
// //               color: _isSearching
// //                   ? AppColors.darkRed.withValues(alpha: 0.2)
// //                   : AppColors.darkRed.withValues(alpha: 0.1),
// //               borderRadius: BorderRadius.circular(10.r),
// //             ),
// //             child: Icon(
// //               _isSearching ? Icons.search_off_rounded : Icons.search_rounded,
// //               size: 20.sp,
// //               color: AppColors.darkRed,
// //             ),
// //           ),
// //           onPressed: () {
// //             setState(() {
// //               _isSearching = !_isSearching;
// //               if (!_isSearching) {
// //                 _searchController.clear();
// //                 _searchQuery = '';
// //               }
// //             });
// //           },
// //         ),
// //         SizedBox(width: 8.w),
// //       ],
// //       flexibleSpace: FlexibleSpaceBar(
// //         titlePadding: EdgeInsets.only(right: 16.w, bottom: 16.h),
// //         title: AnimatedOpacity(
// //           opacity: innerBoxIsScrolled ? 1.0 : 0.0,
// //           duration: const Duration(milliseconds: 200),
// //           child: Text(
// //             'حجوزاتي',
// //             style: TextStyle(
// //               fontSize: 20.sp,
// //               fontWeight: FontWeight.bold,
// //               color: isDark ? Colors.white : AppColors.black,
// //             ),
// //           ),
// //         ),
// //         background: Container(
// //           decoration: BoxDecoration(
// //             gradient: LinearGradient(
// //               begin: Alignment.topRight,
// //               end: Alignment.bottomLeft,
// //               colors: isDark
// //                   ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
// //                   : [Colors.white, Colors.grey.shade50],
// //             ),
// //           ),
// //           child: SafeArea(
// //             child: Padding(
// //               padding: EdgeInsets.symmetric(horizontal: 16.w),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 mainAxisAlignment: MainAxisAlignment.end,
// //                 children: [
// //                   Text(
// //                     'مواعيدي',
// //                     style: TextStyle(
// //                       fontSize: 32.sp,
// //                       fontWeight: FontWeight.bold,
// //                       color: isDark ? Colors.white : AppColors.black,
// //                     ),
// //                   ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
// //                   SizedBox(height: 4.h),
// //                   Text(
// //                     'إدارة مواعيدك بسهولة',
// //                     style: TextStyle(
// //                       fontSize: 14.sp,
// //                       color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
// //                     ),
// //                   ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
// //                   SizedBox(height: 16.h),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   /// ═══════════════════════════════════════════════════════════════
// //   /// SEARCH BAR
// //   /// ═══════════════════════════════════════════════════════════════
// //
// //   Widget _buildSearchBar(bool isDark) {
// //     if (!_isSearching) return const SizedBox.shrink();
// //
// //     return Container(
// //       margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
// //       child: TextField(
// //         controller: _searchController,
// //         onChanged: (value) {
// //           setState(() => _searchQuery = value.toLowerCase());
// //         },
// //         decoration: InputDecoration(
// //           hintText: 'ابحث عن موعد...',
// //           prefixIcon: const Icon(Icons.search_rounded, color: AppColors.darkRed),
// //           suffixIcon: _searchQuery.isNotEmpty
// //               ? IconButton(
// //             icon: Icon(Icons.clear_rounded, color: Colors.grey.shade500),
// //             onPressed: () {
// //               _searchController.clear();
// //               setState(() => _searchQuery = '');
// //             },
// //           )
// //               : null,
// //           filled: true,
// //           fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
// //           border: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12.r),
// //             borderSide: BorderSide(
// //               color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
// //             ),
// //           ),
// //           enabledBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12.r),
// //             borderSide: BorderSide(
// //               color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
// //             ),
// //           ),
// //           focusedBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12.r),
// //             borderSide: const BorderSide(color: AppColors.darkRed, width: 2),
// //           ),
// //         ),
// //       ),
// //     ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.3);
// //   }
// //
// //   /// ═══════════════════════════════════════════════════════════════
// //   /// SORT & FILTER ROW
// //   /// ═══════════════════════════════════════════════════════════════
// //
// //   Widget _buildSortFilterRow(bool isDark) {
// //     return Container(
// //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
// //       child: Row(
// //         children: [
// //           Text(
// //             'ترتيب حسب:',
// //             style: TextStyle(
// //               fontSize: 13.sp,
// //               color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
// //             ),
// //           ),
// //           SizedBox(width: 12.w),
// //           _buildSortChip('التاريخ', 'date', Icons.calendar_today_rounded, isDark),
// //           SizedBox(width: 8.w),
// //           _buildSortChip('السعر', 'price', Icons.attach_money_rounded, isDark),
// //         ],
// //       ),
// //     ).animate().fadeIn(delay: 100.ms);
// //   }
// //
// //   Widget _buildSortChip(String label, String value, IconData icon, bool isDark) {
// //     final isSelected = _sortBy == value;
// //
// //     return InkWell(
// //       onTap: () => setState(() => _sortBy = value),
// //       borderRadius: BorderRadius.circular(20.r),
// //       child: Container(
// //         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
// //         decoration: BoxDecoration(
// //           color: isSelected
// //               ? AppColors.darkRed
// //               : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
// //           borderRadius: BorderRadius.circular(20.r),
// //           border: Border.all(
// //             color: isSelected
// //                 ? AppColors.darkRed
// //                 : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
// //           ),
// //         ),
// //         child: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Icon(
// //               icon,
// //               size: 14.sp,
// //               color: isSelected ? Colors.white : AppColors.darkRed,
// //             ),
// //             SizedBox(width: 4.w),
// //             Text(
// //               label,
// //               style: TextStyle(
// //                 fontSize: 12.sp,
// //                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
// //                 color: isSelected
// //                     ? Colors.white
// //                     : (isDark ? Colors.grey.shade300 : AppColors.black),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   /// ═══════════════════════════════════════════════════════════════
// //   /// TAB BAR
// //   /// ═══════════════════════════════════════════════════════════════
// //
// //   Widget _buildTabBar(bool isDark) {
// //     return Container(
// //       margin: EdgeInsets.all(16.r),
// //       decoration: BoxDecoration(
// //         color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
// //         borderRadius: BorderRadius.circular(16.r),
// //         border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withValues(alpha: 0.05),
// //             blurRadius: 10,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: TabBar(
// //         controller: _tabController,
// //         indicator: BoxDecoration(
// //           color: AppColors.darkRed,
// //           borderRadius: BorderRadius.circular(12.r),
// //         ),
// //         indicatorSize: TabBarIndicatorSize.tab,
// //         dividerColor: Colors.transparent,
// //         labelColor: Colors.white,
// //         unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
// //         labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold,fontFamily:'Cairo'),
// //         padding: EdgeInsets.all(4.r),
// //         tabs: const [
// //           Tab(text: 'القادمة'),
// //           Tab(text: 'المكتملة'),
// //           Tab(text: 'الملغاة'),
// //         ],
// //       ),
// //     ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.2);
// //   }
// //
// //   /// ═══════════════════════════════════════════════════════════════
// //   /// SHIMMER LOADING
// //   /// ═══════════════════════════════════════════════════════════════
// //
// //   Widget _buildShimmerLoading(bool isDark) {
// //     return ListView.builder(
// //       padding: EdgeInsets.all(16.r),
// //       itemCount: 5,
// //       itemBuilder: (context, index) {
// //         return Shimmer.fromColors(
// //           baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
// //           highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
// //           child: Container(
// //             margin: EdgeInsets.only(bottom: 16.h),
// //             padding: EdgeInsets.all(16.r),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(16.r),
// //             ),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   children: [
// //                     Container(
// //                       width: 60.w,
// //                       height: 60.h,
// //                       decoration: BoxDecoration(
// //                         color: Colors.white,
// //                         borderRadius: BorderRadius.circular(12.r),
// //                       ),
// //                     ),
// //                     SizedBox(width: 16.w),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Container(
// //                             width: double.infinity,
// //                             height: 16.h,
// //                             decoration: BoxDecoration(
// //                               color: Colors.white,
// //                               borderRadius: BorderRadius.circular(8.r),
// //                             ),
// //                           ),
// //                           SizedBox(height: 8.h),
// //                           Container(
// //                             width: 150.w,
// //                             height: 12.h,
// //                             decoration: BoxDecoration(
// //                               color: Colors.white,
// //                               borderRadius: BorderRadius.circular(6.r),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   /// ═══════════════════════════════════════════════════════════════
// //   /// TABS CONTENT
// //   /// ═══════════════════════════════════════════════════════════════
// //
// //   Widget _buildUpcomingTab(bool isDark) {
// //     return Consumer<AppointmentProvider>(
// //       builder: (context, provider, _) {
// //         var upcoming = provider.appointments
// //             .where((a) =>
// //         a.status == 'pending' ||
// //             a.status == 'confirmed' ||
// //             a.status == 'in_progress')
// //             .toList();
// //
// //         // ✅ Apply Search Filter
// //         if (_searchQuery.isNotEmpty) {
// //           upcoming = upcoming.where((a) {
// //             final serviceName = (a.services?.first.serviceNameAr ?? '').toLowerCase();
// //             final date = DateFormat('d MMMM yyyy', 'ar').format(a.appointmentDate).toLowerCase();
// //             final id = a.id?.toString() ?? '';
// //             return serviceName.contains(_searchQuery) ||
// //                 date.contains(_searchQuery) ||
// //                 id.contains(_searchQuery);
// //           }).toList();
// //         }
// //
// //         // ✅ Apply Sort
// //         if (_sortBy == 'date') {
// //           upcoming.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
// //         } else if (_sortBy == 'price') {
// //           upcoming.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
// //         }
// //
// //         if (upcoming.isEmpty) {
// //           return _buildEmptyState(
// //             icon: Icons.calendar_today_rounded,
// //             title: _searchQuery.isNotEmpty
// //                 ? 'لا توجد نتائج'
// //                 : 'لا توجد حجوزات قادمة',
// //             subtitle: _searchQuery.isNotEmpty
// //                 ? 'جرّب البحث بكلمات مختلفة'
// //                 : 'احجز موعداً جديداً الآن',
// //             isDark: isDark,
// //             iconColor: Colors.orange,
// //           );
// //         }
// //
// //         return RefreshIndicator(
// //           onRefresh: _loadAppointments,
// //           color: AppColors.darkRed,
// //           child: ListView.builder(
// //             padding: EdgeInsets.all(16.r),
// //             itemCount: upcoming.length,
// //             itemBuilder: (context, index) {
// //               return _buildAppointmentCard(upcoming[index], isDark, index);
// //             },
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   Widget _buildCompletedTab(bool isDark) {
// //     return Consumer<AppointmentProvider>(
// //       builder: (context, provider, _) {
// //         var completed = provider.appointments.where((a) => a.status == 'completed').toList();
// //
// //         if (_searchQuery.isNotEmpty) {
// //           completed = completed.where((a) {
// //             final serviceName = (a.services?.first.serviceNameAr ?? '').toLowerCase();
// //             final date = DateFormat('d MMMM yyyy', 'ar').format(a.appointmentDate).toLowerCase();
// //             return serviceName.contains(_searchQuery) || date.contains(_searchQuery);
// //           }).toList();
// //         }
// //
// //         if (_sortBy == 'date') {
// //           completed.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
// //         } else if (_sortBy == 'price') {
// //           completed.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
// //         }
// //
// //         if (completed.isEmpty) {
// //           return _buildEmptyState(
// //             icon: Icons.check_circle_outline_rounded,
// //             title: _searchQuery.isNotEmpty ? 'لا توجد نتائج' : 'لا توجد حجوزات مكتملة',
// //             subtitle: _searchQuery.isNotEmpty
// //                 ? 'جرّب البحث بكلمات مختلفة'
// //                 : 'سيظهر هنا سجل حجوزاتك المكتملة',
// //             isDark: isDark,
// //             iconColor: Colors.green,
// //           );
// //         }
// //
// //         return ListView.builder(
// //           padding: EdgeInsets.all(16.r),
// //           itemCount: completed.length,
// //           itemBuilder: (context, index) {
// //             return _buildAppointmentCard(completed[index], isDark, index);
// //           },
// //         );
// //       },
// //     );
// //   }
// //
// //   Widget _buildCancelledTab(bool isDark) {
// //     return Consumer<AppointmentProvider>(
// //       builder: (context, provider, _) {
// //         var cancelled = provider.appointments
// //             .where((a) => a.status == 'cancelled' || a.status == 'no_show')
// //             .toList();
// //
// //         if (_searchQuery.isNotEmpty) {
// //           cancelled = cancelled.where((a) {
// //             final serviceName = (a.services?.first.serviceNameAr ?? '').toLowerCase();
// //             final date = DateFormat('d MMMM yyyy', 'ar').format(a.appointmentDate).toLowerCase();
// //             return serviceName.contains(_searchQuery) || date.contains(_searchQuery);
// //           }).toList();
// //         }
// //
// //         if (_sortBy == 'date') {
// //           cancelled.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
// //         } else if (_sortBy == 'price') {
// //           cancelled.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
// //         }
// //
// //         if (cancelled.isEmpty) {
// //           return _buildEmptyState(
// //             icon: Icons.cancel_outlined,
// //             title: _searchQuery.isNotEmpty ? 'لا توجد نتائج' : 'لا توجد حجوزات ملغاة',
// //             subtitle: _searchQuery.isNotEmpty
// //                 ? 'جرّب البحث بكلمات مختلفة'
// //                 : 'لم تقم بإلغاء أي حجز بعد',
// //             isDark: isDark,
// //             iconColor: Colors.red,
// //           );
// //         }
// //
// //         return ListView.builder(
// //           padding: EdgeInsets.all(16.r),
// //           itemCount: cancelled.length,
// //           itemBuilder: (context, index) {
// //             return _buildAppointmentCard(cancelled[index], isDark, index);
// //           },
// //         );
// //       },
// //     );
// //   }
// //
// //   /// ═══════════════════════════════════════════════════════════════
// //   /// APPOINTMENT CARD (مع Swipe to Cancel)
// //   /// ═══════════════════════════════════════════════════════════════
// //
// //   Widget _buildAppointmentCard(AppointmentModel appointment, bool isDark, int index) {
// //     final canCancel = appointment.canBeCancelled;
// //     final canReview = appointment.canBeReviewed;
// //
// //     return Slidable(
// //       key: ValueKey(appointment.id),
// //       enabled: canCancel,
// //       endActionPane: canCancel
// //           ? ActionPane(
// //         motion: const ScrollMotion(),
// //         children: [
// //           SlidableAction(
// //             onPressed: (_) => _cancelAppointment(appointment),
// //             backgroundColor: Colors.red,
// //             foregroundColor: Colors.white,
// //             icon: Icons.cancel_rounded,
// //             label: 'إلغاء',
// //             borderRadius: BorderRadius.circular(16.r),
// //           ),
// //         ],
// //       )
// //           : null,
// //       child: GestureDetector(
// //         onTap: () {
// //           Navigator.push(
// //             context,
// //             MaterialPageRoute(
// //               builder: (context) => AppointmentDetailsScreen(appointment: appointment),
// //             ),
// //           );
// //         },
// //         child: Container(
// //           margin: EdgeInsets.only(bottom: 16.h),
// //           padding: EdgeInsets.all(16.r),
// //           decoration: BoxDecoration(
// //             color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
// //             borderRadius: BorderRadius.circular(16.r),
// //             border: Border.all(
// //               color: _getStatusColor(appointment.status).withValues(alpha: 0.3),
// //               width: 1.5,
// //             ),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: Colors.black.withValues(alpha: 0.05),
// //                 blurRadius: 10,
// //                 offset: const Offset(0, 4),
// //               ),
// //             ],
// //           ),
// //           child: Column(
// //             children: [
// //               Row(
// //                 children: [
// //                   Container(
// //                     width: 60.w,
// //                     height: 60.h,
// //                     decoration: BoxDecoration(
// //                       color: _getStatusColor(appointment.status).withValues(alpha: 0.1),
// //                       borderRadius: BorderRadius.circular(12.r),
// //                     ),
// //                     child: Icon(
// //                       _getStatusIcon(appointment.status),
// //                       color: _getStatusColor(appointment.status),
// //                       size: 28.sp,
// //                     )
// //                         .animate(onPlay: (controller) => controller.repeat())
// //                         .then(delay: 2000.ms)
// //                         .shimmer(
// //                       duration: 1500.ms,
// //                       color: _getStatusColor(appointment.status).withValues(alpha: 0.5),
// //                     ),
// //                   ),
// //                   SizedBox(width: 16.w),
// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Row(
// //                           children: [
// //                             Expanded(
// //                               child: Text(
// //                                 appointment.services?.first.serviceNameAr ?? 'خدمة',
// //                                 style: TextStyle(
// //                                   fontSize: 16.sp,
// //                                   fontWeight: FontWeight.bold,
// //                                   color: isDark ? Colors.white : AppColors.black,
// //                                 ),
// //                               ),
// //                             ),
// //                             _buildStatusBadge(appointment.status, isDark),
// //                           ],
// //                         ),
// //                         SizedBox(height: 6.h),
// //                         Row(
// //                           children: [
// //                             Icon(Icons.calendar_today, size: 14.sp, color: Colors.grey.shade500),
// //                             SizedBox(width: 4.w),
// //                             Text(
// //                               DateFormat('d MMMM yyyy', 'ar').format(appointment.appointmentDate),
// //                               style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
// //                             ),
// //                             SizedBox(width: 12.w),
// //                             Icon(Icons.access_time, size: 14.sp, color: Colors.grey.shade500),
// //                             SizedBox(width: 4.w),
// //                             Text(
// //                               _formatTime(appointment.appointmentTime),
// //                               style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
// //                             ),
// //                           ],
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               Divider(height: 24.h),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Row(
// //                     children: [
// //                       CircleAvatar(
// //                         radius: 16.r,
// //                         backgroundColor: Colors.grey.shade300,
// //                         backgroundImage: appointment.employeeImageUrl != null &&
// //                             appointment.employeeImageUrl!.isNotEmpty
// //                             ? NetworkImage(appointment.employeeImageUrl!)
// //                             : null,
// //                         child: appointment.employeeImageUrl == null ||
// //                             appointment.employeeImageUrl!.isEmpty
// //                             ? Icon(Icons.person, size: 16.sp)
// //                             : null,
// //                       ),
// //                       SizedBox(width: 8.w),
// //                       Text(
// //                         appointment.employeeName ?? 'تلقائي',
// //                         style: TextStyle(
// //                           fontSize: 13.sp,
// //                           color: isDark ? Colors.grey.shade300 : AppColors.greyDark,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   Text(
// //                     '${appointment.totalPrice.toStringAsFixed(0)} ريال',
// //                     style: TextStyle(
// //                       fontSize: 16.sp,
// //                       fontWeight: FontWeight.bold,
// //                       color: AppColors.gold,
// //                     ),
// //                   )
// //                       .animate(onPlay: (controller) => controller.repeat())
// //                       .then(delay: 3000.ms)
// //                       .shimmer(duration: 1000.ms, color: AppColors.goldDark),
// //                 ],
// //               ),
// //               if (canCancel || canReview) ...[
// //                 SizedBox(height: 12.h),
// //                 if (canCancel)
// //                   Row(
// //                     children: [
// //                       Expanded(
// //                         child: OutlinedButton.icon(
// //                           onPressed: () => _cancelAppointment(appointment),
// //                           icon: Icon(Icons.close_rounded, size: 18.sp, color: AppColors.error),
// //                           label: Text(
// //                             'إلغاء',
// //                             style: TextStyle(
// //                               color: AppColors.error,
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: 14.sp,
// //                             ),
// //                           ),
// //                           style: OutlinedButton.styleFrom(
// //                             side: const BorderSide(color: AppColors.error),
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(10.r),
// //                             ),
// //                             padding: EdgeInsets.symmetric(vertical: 12.h),
// //                           ),
// //                         ),
// //                       ),
// //                       SizedBox(width: 12.w),
// //                       Expanded(
// //                         child: ElevatedButton.icon(
// //                           onPressed: () {
// //                             Navigator.push(
// //                               context,
// //                               MaterialPageRoute(
// //                                 builder: (context) =>
// //                                     AppointmentDetailsScreen(appointment: appointment),
// //                               ),
// //                             );
// //                           },
// //                           icon: Icon(Icons.info_outline_rounded, size: 18.sp, color: Colors.white),
// //                           label: Text(
// //                             'التفاصيل',
// //                             style: TextStyle(
// //                               color: Colors.white,
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: 14.sp,
// //                             ),
// //                           ),
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: AppColors.darkRed,
// //                             foregroundColor: Colors.white,
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(10.r),
// //                             ),
// //                             padding: EdgeInsets.symmetric(vertical: 12.h),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 if (canReview)
// //                   SizedBox(
// //                     width: double.infinity,
// //                     child: ElevatedButton.icon(
// //                       onPressed: () => _navigateToReview(appointment),
// //                       icon: Icon(Icons.star_rounded, size: 18.sp, color: Colors.white)
// //                           .animate(onPlay: (controller) => controller.repeat())
// //                           .then(delay: 1000.ms)
// //                           .rotate(duration: 500.ms, begin: 0, end: 0.1)
// //                           .then()
// //                           .rotate(duration: 500.ms, begin: 0.1, end: 0),
// //                       label: Text(
// //                         'قيّم الخدمة',
// //                         style: TextStyle(
// //                           color: Colors.white,
// //                           fontWeight: FontWeight.bold,
// //                           fontSize: 14.sp,
// //                         ),
// //                       ),
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: AppColors.gold,
// //                         foregroundColor: Colors.white,
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(10.r),
// //                         ),
// //                         padding: EdgeInsets.symmetric(vertical: 12.h),
// //                       ),
// //                     ),
// //                   ),
// //               ],
// //             ],
// //           ),
// //         ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn().slideY(begin: 0.2),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildStatusBadge(String status, bool isDark) {
// //     return Container(
// //       padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
// //       decoration: BoxDecoration(
// //         color: _getStatusColor(status).withValues(alpha: 0.1),
// //         borderRadius: BorderRadius.circular(12.r),
// //         border: Border.all(
// //           color: _getStatusColor(status).withValues(alpha: 0.3),
// //         ),
// //       ),
// //       child: Text(
// //         _getStatusText(status),
// //         style: TextStyle(
// //           fontSize: 11.sp,
// //           fontWeight: FontWeight.bold,
// //           color: _getStatusColor(status),
// //         ),
// //       ),
// //     )
// //         .animate(onPlay: (controller) => controller.repeat())
// //         .then(delay: 2000.ms)
// //         .shimmer(duration: 1000.ms, color: _getStatusColor(status).withValues(alpha: 0.3));
// //   }
// //
// //   /// ═══════════════════════════════════════════════════════════════
// //   /// EMPTY STATE
// //   /// ═══════════════════════════════════════════════════════════════
// //
// //   Widget _buildEmptyState({
// //     required IconData icon,
// //     required String title,
// //     required String subtitle,
// //     required bool isDark,
// //     required Color iconColor,
// //   }) {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Container(
// //             padding: EdgeInsets.all(40.r),
// //             decoration: BoxDecoration(
// //               color: iconColor.withValues(alpha: 0.1),
// //               shape: BoxShape.circle,
// //             ),
// //             child: Icon(
// //               icon,
// //               size: 80.sp,
// //               color: iconColor,
// //             ),
// //           )
// //               .animate(onPlay: (controller) => controller.repeat())
// //               .scale(
// //             duration: 2000.ms,
// //             begin: const Offset(1, 1),
// //             end: const Offset(1.1, 1.1),
// //           )
// //               .then()
// //               .scale(
// //             duration: 2000.ms,
// //             begin: const Offset(1.1, 1.1),
// //             end: const Offset(1, 1),
// //           ),
// //           SizedBox(height: 32.h),
// //           Text(
// //             title,
// //             style: TextStyle(
// //               fontSize: 20.sp,
// //               fontWeight: FontWeight.bold,
// //               color: isDark ? Colors.white : AppColors.black,
// //             ),
// //           ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
// //           SizedBox(height: 8.h),
// //           Text(
// //             subtitle,
// //             textAlign: TextAlign.center,
// //             style: TextStyle(
// //               fontSize: 14.sp,
// //               color: isDark ? Colors.grey.shade500 : AppColors.greyDark,
// //             ),
// //           ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   /// ═══════════════════════════════════════════════════════════════
// //   /// HELPER METHODS
// //   /// ═══════════════════════════════════════════════════════════════
// //
// //   Future<void> _navigateToReview(AppointmentModel appointment) async {
// //     final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
// //
// //     final existingReview = await reviewProvider.checkAppointmentReview(appointment.id!);
// //
// //     if (existingReview != null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: const Text('لقد قمت بتقييم هذه الخدمة مسبقاً'),
// //           backgroundColor: Colors.orange,
// //           behavior: SnackBarBehavior.floating,
// //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
// //         ),
// //       );
// //       return;
// //     }
// //
// //     final result = await Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) => AddReviewScreen(appointment: appointment),
// //       ),
// //     );
// //
// //     if (result == true && mounted) {
// //       final userProvider = Provider.of<UserProvider>(context, listen: false);
// //       final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
// //       await appointmentProvider.fetchUserAppointments(userProvider.user!.id!);
// //     }
// //   }
// //
// //   Color _getStatusColor(String status) {
// //     switch (status) {
// //       case 'pending':
// //         return Colors.orange;
// //       case 'confirmed':
// //         return Colors.blue;
// //       case 'in_progress':
// //         return Colors.purple;
// //       case 'completed':
// //         return Colors.green;
// //       case 'cancelled':
// //         return Colors.red;
// //       case 'no_show':
// //         return Colors.grey;
// //       default:
// //         return Colors.grey;
// //     }
// //   }
// //
// //   IconData _getStatusIcon(String status) {
// //     switch (status) {
// //       case 'pending':
// //         return Icons.hourglass_empty_rounded;
// //       case 'confirmed':
// //         return Icons.check_circle_outline_rounded;
// //       case 'in_progress':
// //         return Icons.pending_rounded;
// //       case 'completed':
// //         return Icons.check_circle_rounded;
// //       case 'cancelled':
// //         return Icons.cancel_rounded;
// //       case 'no_show':
// //         return Icons.event_busy_rounded;
// //       default:
// //         return Icons.help_outline_rounded;
// //     }
// //   }
// //
// //   String _getStatusText(String status) {
// //     switch (status) {
// //       case 'pending':
// //         return 'قيد الانتظار';
// //       case 'confirmed':
// //         return 'مؤكد';
// //       case 'in_progress':
// //         return 'جارٍ التنفيذ';
// //       case 'completed':
// //         return 'مكتمل';
// //       case 'cancelled':
// //         return 'ملغى';
// //       case 'no_show':
// //         return 'لم يحضر';
// //       default:
// //         return status;
// //     }
// //   }
// //
// //   Future<void> _cancelAppointment(AppointmentModel appointment) async {
// //     final confirmed = await showDialog<bool>(
// //       context: context,
// //       builder: (context) => Directionality(
// //         textDirection: ui.TextDirection.rtl,
// //         child: AlertDialog(
// //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
// //           backgroundColor: Theme.of(context).brightness == Brightness.dark
// //               ? const Color(0xFF1E1E1E)
// //               : Colors.white,
// //           title: Row(
// //             children: [
// //               Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28.sp)
// //                   .animate(onPlay: (controller) => controller.repeat())
// //                   .shake(duration: 500.ms, hz: 4)
// //                   .then(delay: 500.ms),
// //               SizedBox(width: 12.w),
// //               const Text('إلغاء الموعد'),
// //             ],
// //           ),
// //           content: Text(
// //             'هل أنت متأكد من إلغاء هذا الموعد؟\n'
// //                 'لن يتم إضافة نقاط الولاء المعلقة لهذا الحجز.',
// //             style: TextStyle(fontSize: 14.sp, height: 1.5),
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(context, false),
// //               child: Text('لا', style: TextStyle(color: Colors.grey.shade600, fontSize: 15.sp)),
// //             ),
// //             ElevatedButton(
// //               onPressed: () => Navigator.pop(context, true),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: AppColors.error,
// //                 foregroundColor: Colors.white,
// //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
// //                 padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
// //               ),
// //               child: Text('نعم، إلغاء', style: TextStyle(fontSize: 15.sp)),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //
// //     if (confirmed != true || !mounted) return;
// //
// //     final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
// //     final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
// //     final userProvider = Provider.of<UserProvider>(context, listen: false);
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (context) => Center(
// //         child: Material(
// //           color: Colors.transparent,
// //           child: Container(
// //             width: 200.w,
// //             padding: EdgeInsets.all(24.r),
// //             decoration: BoxDecoration(
// //               color: Theme.of(context).brightness == Brightness.dark
// //                   ? const Color(0xFF262626)
// //                   : Colors.white,
// //               borderRadius: BorderRadius.circular(20.r),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withValues(alpha: 0.1),
// //                   blurRadius: 12,
// //                   offset: const Offset(0, 4),
// //                 ),
// //               ],
// //             ),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 // دائرة تحميل أنيقة بحركة خفيفة
// //                 Container(
// //                   width: 56.w,
// //                   height: 56.w,
// //                   decoration: BoxDecoration(
// //                     shape: BoxShape.circle,
// //                     color: AppColors.darkRed.withValues(alpha: 0.1),
// //                   ),
// //                   child: Padding(
// //                     padding: EdgeInsets.all(10.w),
// //                     child: const CircularProgressIndicator(
// //                       strokeWidth: 3,
// //                       valueColor: AlwaysStoppedAnimation(AppColors.darkRed),
// //                     )
// //                         .animate(onPlay: (c) => c.repeat())
// //                         .scale(duration: 600.ms, curve: Curves.easeInOut),
// //                   ),
// //                 ),
// //                 SizedBox(height: 20.h),
// //
// //                 // نص متدرج وأنيق
// //                 Text(
// //                   'جارٍ الإلغاء...',
// //                   style: TextStyle(
// //                     fontSize: 16.sp,
// //                     fontWeight: FontWeight.w600,
// //                     color: Theme.of(context).brightness == Brightness.dark
// //                         ? Colors.white
// //                         : AppColors.black,
// //                   ),
// //                 ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3, end: 0),
// //
// //                 SizedBox(height: 6.h),
// //                 Text(
// //                   'يرجى الانتظار قليلاً',
// //                   style: TextStyle(
// //                     fontSize: 13.sp,
// //                     color: Theme.of(context).brightness == Brightness.dark
// //                         ? Colors.white70
// //                         : Colors.black54,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ).animate()
// //               .fadeIn(duration: 300.ms)
// //               .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1))
// //         ),
// //       ),
// //     );
// //     try {
// //       final success = await appointmentProvider.cancelAppointment(appointment.id!);
// //
// //       if (mounted) Navigator.pop(context);
// //
// //       if (success && mounted) {
// //         await notificationProvider.createCancellationNotification(
// //           userId: userProvider.user!.id!,
// //           appointmentId: appointment.id!,
// //           serviceName: appointment.services?.first.serviceNameAr ??
// //               appointment.services?.first.serviceName ??
// //               'الخدمة',
// //         );
// //
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: const Text('✅ تم إلغاء الموعد بنجاح'),
// //             backgroundColor: Colors.orange,
// //             behavior: SnackBarBehavior.floating,
// //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
// //           ),
// //         );
// //
// //         await appointmentProvider.fetchUserAppointments(userProvider.user!.id!);
// //       } else if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: const Text('❌ فشل إلغاء الموعد'),
// //             backgroundColor: Colors.red,
// //             behavior: SnackBarBehavior.floating,
// //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         Navigator.pop(context);
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('❌ خطأ: ${e.toString()}'),
// //             backgroundColor: Colors.red,
// //             behavior: SnackBarBehavior.floating,
// //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
// //           ),
// //         );
// //       }
// //     }
// //   }
// // }
//
//
//
// /**------------------------------------------------------**/
// // import 'dart:ui' as ui;
// // import 'package:cached_network_image/cached_network_image.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_animate/flutter_animate.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:flutter_slidable/flutter_slidable.dart';
// // import 'package:millionaire_barber/core/constants/app_colors.dart';
// // import 'package:millionaire_barber/features/appointments/domain/models/appointment_model.dart';
// // import 'package:millionaire_barber/features/appointments/presentation/pages/appointment_details_screen.dart';
// // import 'package:millionaire_barber/features/appointments/presentation/providers/appointment_provider.dart';
// // import 'package:millionaire_barber/features/notifications/presentation/providers/notification_provider.dart';
// // import 'package:millionaire_barber/features/profile/presentation/providers/user_provider.dart';
// // import 'package:millionaire_barber/features/reviews/presentation/providers/review_provider.dart';
// // import 'package:shimmer/shimmer.dart';
// // import 'package:intl/intl.dart';
// // import 'package:provider/provider.dart';
// // import '../../../reviews/presentation/pages/add_review_screen.dart';
// //
// // // ── ثوابت الألوان ─────────────────────────────────────────────────
// // const _kGold     = Color(0xFFB8860B);
// // const _kGoldDark = Color(0xFF8B6914);
// //
// // class MyAppointmentsScreen extends StatefulWidget {
// //   const MyAppointmentsScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
// // }
// //
// // class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
// //     with SingleTickerProviderStateMixin {
// //   late TabController _tabController;
// //   final TextEditingController _searchController = TextEditingController();
// //   bool _isLoading  = false;
// //   bool _isSearching = false;
// //   String _searchQuery = '';
// //   String _sortBy   = 'date';
// //
// //   // ── فلتر النوع: الكل / فردي / جماعي ─────────────────────────────
// //   String _typeFilter = 'all'; // 'all' | 'single' | 'group'
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: 3, vsync: this);
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _loadAppointments();
// //     });
// //   }
// //
// //   Future<void> _loadAppointments() async {
// //     final userProvider = Provider.of<UserProvider>(context, listen: false);
// //     if (userProvider.user?.id == null) return;
// //     setState(() => _isLoading = true);
// //     final apptProv = Provider.of<AppointmentProvider>(context, listen: false);
// //     await apptProv.fetchUserAppointments(userProvider.user!.id!);
// //     if (mounted) setState(() => _isLoading = false);
// //   }
// //
// //   @override
// //   void dispose() {
// //     _tabController.dispose();
// //     _searchController.dispose();
// //     super.dispose();
// //   }
// //
// //   // ── تنسيق الوقت ──────────────────────────────────────────────────
// //   String _formatTime(String time) {
// //     try {
// //       final parts  = time.split(':');
// //       final hour   = int.parse(parts[0]);
// //       final minute = parts.length > 1 ? parts[1] : '00';
// //       if (hour == 0)        return '12:$minute ص';
// //       if (hour < 12)        return '$hour:$minute ص';
// //       if (hour == 12)       return '12:$minute م';
// //       return '${hour - 12}:$minute م';
// //     } catch (_) { return time; }
// //   }
// //
// //   // ── فلترة قائمة المواعيد ─────────────────────────────────────────
// //   List<AppointmentModel> _applyFilters(List<AppointmentModel> list) {
// //     var result = list;
// //
// //     // فلتر النوع
// //     if (_typeFilter == 'group') {
// //       result = result.where((a) => _isGroup(a)).toList();
// //     } else if (_typeFilter == 'single') {
// //       result = result.where((a) => !_isGroup(a)).toList();
// //     }
// //
// //     // فلتر البحث
// //     if (_searchQuery.isNotEmpty) {
// //       result = result.where((a) {
// //         final svc  = (a.services?.isNotEmpty == true
// //             ? a.services!.first.serviceNameAr
// //             : '') ?? '';
// //         final date = DateFormat('d MMMM yyyy', 'ar').format(a.appointmentDate);
// //         final id   = a.id?.toString() ?? '';
// //         return svc.toLowerCase().contains(_searchQuery)  ||
// //             date.toLowerCase().contains(_searchQuery) ||
// //             id.contains(_searchQuery);
// //       }).toList();
// //     }
// //
// //     // ترتيب
// //     if (_sortBy == 'date') {
// //       result.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
// //     } else {
// //       result.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
// //     }
// //     return result;
// //   }
// //
// //   bool _isGroup(AppointmentModel a) => a.personsCount > 1;
// //
// //   // ══════════════════════════════════════════════════════════════════
// //   // BUILD
// //   // ══════════════════════════════════════════════════════════════════
// //   @override
// //   Widget build(BuildContext context) {
// //     final isDark = Theme.of(context).brightness == Brightness.dark;
// //
// //     return Directionality(
// //       textDirection: ui.TextDirection.rtl,
// //       child: Scaffold(
// //         backgroundColor:
// //         isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
// //         body: NestedScrollView(
// //           headerSliverBuilder: (_, innerScrolled) =>
// //           [_buildAppBar(isDark, innerScrolled)],
// //           body: Column(children: [
// //             _buildSearchBar(isDark),
// //             _buildFilterRow(isDark),
// //             _buildTabBar(isDark),
// //             Expanded(
// //               child: _isLoading
// //                   ? _buildShimmerLoading(isDark)
// //                   : TabBarView(
// //                 controller: _tabController,
// //                 children: [
// //                   _buildTab(isDark, ['pending','confirmed','in_progress']),
// //                   _buildTab(isDark, ['completed']),
// //                   _buildTab(isDark, ['cancelled','no_show']),
// //                 ],
// //               ),
// //             ),
// //           ]),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ══════════════════════════════════════════════════════════════════
// //   // APP BAR
// //   // ══════════════════════════════════════════════════════════════════
// //   Widget _buildAppBar(bool isDark, bool innerScrolled) {
// //     return SliverAppBar(
// //       expandedHeight: 120.h,
// //       floating: false,
// //       pinned:   true,
// //       elevation: 0,
// //       backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
// //       leading: IconButton(
// //         icon: Container(
// //           padding:    EdgeInsets.all(8.r),
// //           decoration: BoxDecoration(
// //             color:        AppColors.darkRed.withValues(alpha: 0.1),
// //             borderRadius: BorderRadius.circular(10.r),
// //           ),
// //           child: Icon(Icons.arrow_back_ios,
// //               size: 18.sp, color: AppColors.darkRed),
// //         ),
// //         onPressed: () => Navigator.pop(context),
// //       ),
// //       actions: [
// //         IconButton(
// //           icon: Container(
// //             padding: EdgeInsets.all(8.r),
// //             decoration: BoxDecoration(
// //               color: _isSearching
// //                   ? AppColors.darkRed.withValues(alpha: 0.2)
// //                   : AppColors.darkRed.withValues(alpha: 0.1),
// //               borderRadius: BorderRadius.circular(10.r),
// //             ),
// //             child: Icon(
// //               _isSearching
// //                   ? Icons.search_off_rounded
// //                   : Icons.search_rounded,
// //               size: 20.sp,
// //               color: AppColors.darkRed,
// //             ),
// //           ),
// //           onPressed: () => setState(() {
// //             _isSearching = !_isSearching;
// //             if (!_isSearching) {
// //               _searchController.clear();
// //               _searchQuery = '';
// //             }
// //           }),
// //         ),
// //         SizedBox(width: 8.w),
// //       ],
// //       flexibleSpace: FlexibleSpaceBar(
// //         titlePadding: EdgeInsets.only(right: 16.w, bottom: 16.h),
// //         title: AnimatedOpacity(
// //           opacity:  innerScrolled ? 1.0 : 0.0,
// //           duration: const Duration(milliseconds: 200),
// //           child: Text('حجوزاتي',
// //               style: TextStyle(
// //                 fontSize:   20.sp,
// //                 fontWeight: FontWeight.bold,
// //                 color: isDark ? Colors.white : AppColors.black,
// //               )),
// //         ),
// //         background: Container(
// //           decoration: BoxDecoration(
// //             gradient: LinearGradient(
// //               begin: Alignment.topRight,
// //               end:   Alignment.bottomLeft,
// //               colors: isDark
// //                   ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
// //                   : [Colors.white, Colors.grey.shade50],
// //             ),
// //           ),
// //           child: SafeArea(
// //             child: Padding(
// //               padding: EdgeInsets.symmetric(horizontal: 16.w),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 mainAxisAlignment:  MainAxisAlignment.end,
// //                 children: [
// //                   Text('مواعيدي',
// //                       style: TextStyle(
// //                         fontSize:   32.sp,
// //                         fontWeight: FontWeight.bold,
// //                         color: isDark ? Colors.white : AppColors.black,
// //                       ))
// //                       .animate()
// //                       .fadeIn(duration: 600.ms)
// //                       .slideX(begin: -0.2),
// //                   SizedBox(height: 4.h),
// //                   Text('إدارة مواعيدك بسهولة',
// //                       style: TextStyle(
// //                         fontSize: 14.sp,
// //                         color: isDark
// //                             ? Colors.grey.shade400
// //                             : AppColors.greyDark,
// //                       ))
// //                       .animate()
// //                       .fadeIn(delay: 200.ms)
// //                       .slideX(begin: -0.2),
// //                   SizedBox(height: 16.h),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ══════════════════════════════════════════════════════════════════
// //   // SEARCH BAR
// //   // ══════════════════════════════════════════════════════════════════
// //   Widget _buildSearchBar(bool isDark) {
// //     if (!_isSearching) return const SizedBox.shrink();
// //     return Container(
// //       margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
// //       child: TextField(
// //         controller: _searchController,
// //         onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
// //         decoration: InputDecoration(
// //           hintText:   'ابحث عن موعد...',
// //           prefixIcon: const Icon(Icons.search_rounded, color: AppColors.darkRed),
// //           suffixIcon: _searchQuery.isNotEmpty
// //               ? IconButton(
// //             icon: Icon(Icons.clear_rounded,
// //                 color: Colors.grey.shade500),
// //             onPressed: () {
// //               _searchController.clear();
// //               setState(() => _searchQuery = '');
// //             },
// //           )
// //               : null,
// //           filled:    true,
// //           fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
// //           border: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12.r),
// //             borderSide: BorderSide(
// //                 color: isDark
// //                     ? Colors.grey.shade800
// //                     : Colors.grey.shade300),
// //           ),
// //           enabledBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12.r),
// //             borderSide: BorderSide(
// //                 color: isDark
// //                     ? Colors.grey.shade800
// //                     : Colors.grey.shade300),
// //           ),
// //           focusedBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12.r),
// //             borderSide:
// //             const BorderSide(color: AppColors.darkRed, width: 2),
// //           ),
// //         ),
// //       ),
// //     ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.3);
// //   }
// //
// //   // ══════════════════════════════════════════════════════════════════
// //   // FILTER ROW  — الترتيب + فلتر النوع
// //   // ══════════════════════════════════════════════════════════════════
// //   // Widget _buildFilterRow(bool isDark) {
// //   //   return Container(
// //   //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
// //   //     child: Row(
// //   //       children: [
// //   //         // ── ترتيب ─────────────────────────────────────────────
// //   //         Text('ترتيب:',
// //   //             style: TextStyle(
// //   //               fontSize: 12.sp,
// //   //               color: isDark
// //   //                   ? Colors.grey.shade400
// //   //                   : AppColors.greyDark,
// //   //             )),
// //   //         SizedBox(width: 8.w),
// //   //         _chip('التاريخ', 'date',  Icons.calendar_today_rounded,
// //   //             isDark, isSort: true),
// //   //         SizedBox(width: 6.w),
// //   //         _chip('السعر',   'price', Icons.attach_money_rounded,
// //   //             isDark, isSort: true),
// //   //
// //   //         const Spacer(),
// //   //
// //   //         // ── نوع الحجز ─────────────────────────────────────────
// //   //         _typeChip('الكل',     'all',    null,              isDark),
// //   //         SizedBox(width: 5.w),
// //   //         _typeChip('فردي',     'single', Icons.person_rounded, isDark),
// //   //         SizedBox(width: 5.w),
// //   //         _typeChip('جماعي',    'group',  Icons.people_rounded, isDark),
// //   //       ],
// //   //     ),
// //   //   ).animate().fadeIn(delay: 100.ms);
// //   // }
// //
// //   // Widget _buildFilterRow(bool isDark) {
// //   //   return Container(
// //   //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
// //   //     child: Column(
// //   //       crossAxisAlignment: CrossAxisAlignment.start,
// //   //       children: [
// //   //         // ── الصف الأول: ترتيب ─────────────────────────────────
// //   //         Row(children: [
// //   //           Text('ترتيب:',
// //   //               style: TextStyle(
// //   //                 fontSize: 12.sp,
// //   //                 color: isDark
// //   //                     ? Colors.grey.shade400
// //   //                     : AppColors.greyDark,
// //   //               )),
// //   //           SizedBox(width: 6.w),
// //   //           _chip('التاريخ', 'date',  Icons.calendar_today_rounded,
// //   //               isDark, isSort: true),
// //   //           SizedBox(width: 5.w),
// //   //           _chip('السعر',   'price', Icons.attach_money_rounded,
// //   //               isDark, isSort: true),
// //   //         ]),
// //   //
// //   //         SizedBox(height: 6.h),
// //   //
// //   //         // ── الصف الثاني: نوع الحجز ────────────────────────────
// //   //         Row(children: [
// //   //           Text('النوع:',
// //   //               style: TextStyle(
// //   //                 fontSize: 12.sp,
// //   //                 color: isDark
// //   //                     ? Colors.grey.shade400
// //   //                     : AppColors.greyDark,
// //   //               )),
// //   //           SizedBox(width: 6.w),
// //   //           _typeChip('الكل',  'all',    null,                 isDark),
// //   //           SizedBox(width: 4.w),
// //   //           _typeChip('فردي',  'single', Icons.person_rounded,  isDark),
// //   //           SizedBox(width: 4.w),
// //   //           _typeChip('جماعي', 'group',  Icons.people_rounded,  isDark),
// //   //         ]),
// //   //       ],
// //   //     ),
// //   //   ).animate().fadeIn(delay: 100.ms);
// //   // }
// //
// //   Widget _buildFilterRow(bool isDark) {
// //     return Padding(
// //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
// //       child: Wrap(                          // ✅ ينزل للسطر التالي تلقائياً
// //         spacing:   6.w,                    // مسافة أفقية بين العناصر
// //         runSpacing: 6.h,                   // مسافة عمودية عند الانتقال لسطر جديد
// //         crossAxisAlignment: WrapCrossAlignment.center,
// //         children: [
// //           // ── ترتيب ───────────────────────────────────────────
// //           _filterLabel('ترتيب:', isDark),
// //           _chip('التاريخ', 'date',  Icons.calendar_today_rounded, isDark),
// //           _chip('السعر',   'price', Icons.attach_money_rounded,   isDark),
// //
// //           // فاصل مرئي
// //           _divider(isDark),
// //
// //           // ── نوع الحجز ──────────────────────────────────────
// //           _filterLabel('النوع:', isDark),
// //           _typeChip('الكل',  'all',    null,                isDark),
// //           _typeChip('فردي',  'single', Icons.person_rounded, isDark),
// //           _typeChip('جماعي', 'group',  Icons.people_rounded, isDark),
// //         ],
// //       ),
// //     ).animate().fadeIn(delay: 100.ms);
// //   }
// //
// // // ── widget مساعد للتسمية ──────────────────────────────────
// //   Widget _filterLabel(String text, bool isDark) {
// //     return Padding(
// //       padding: EdgeInsets.only(left: 2.w),
// //       child: Text(text,
// //           style: TextStyle(
// //             fontSize: 11.sp,
// //             color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
// //           )),
// //     );
// //   }
// //
// // // ── فاصل رأسي ────────────────────────────────────────────
// //   Widget _divider(bool isDark) {
// //     return Container(
// //       width:  1,
// //       height: 18.h,
// //       margin: EdgeInsets.symmetric(horizontal: 4.w),
// //       color:  isDark ? Colors.grey.shade700 : Colors.grey.shade300,
// //     );
// //   }
// //
// //   Widget _chip(String label, String value, IconData icon, bool isDark) {
// //     final selected = _sortBy == value;
// //     return InkWell(
// //       onTap: () => setState(() => _sortBy = value),
// //       borderRadius: BorderRadius.circular(20.r),
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 200),
// //         padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
// //         decoration: BoxDecoration(
// //           color: selected
// //               ? AppColors.darkRed
// //               : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
// //           borderRadius: BorderRadius.circular(20.r),
// //           border: Border.all(
// //             color: selected
// //                 ? AppColors.darkRed
// //                 : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
// //           ),
// //         ),
// //         child: Row(mainAxisSize: MainAxisSize.min, children: [
// //           Icon(icon, size: 11.sp,
// //               color: selected ? Colors.white : AppColors.darkRed),
// //           SizedBox(width: 3.w),
// //           Text(label,
// //               style: TextStyle(
// //                 fontSize:   11.sp,
// //                 fontWeight: selected ? FontWeight.bold : FontWeight.normal,
// //                 color: selected
// //                     ? Colors.white
// //                     : (isDark ? Colors.grey.shade300 : AppColors.black),
// //               )),
// //         ]),
// //       ),
// //     );
// //   }
// //
// //   Widget _typeChip(String label, String value, IconData? icon,
// //       bool isDark) {
// //     final selected = _typeFilter == value;
// //     return InkWell(
// //       onTap: () => setState(() => _typeFilter = value),
// //       borderRadius: BorderRadius.circular(20.r),
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 200),
// //         padding: EdgeInsets.symmetric(
// //             horizontal: 8.w, vertical: 4.h),     // ✅ أصغر
// //         decoration: BoxDecoration(
// //           color: selected
// //               ? _kGold
// //               : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
// //           borderRadius: BorderRadius.circular(20.r),
// //           border: Border.all(
// //             color: selected
// //                 ? _kGold
// //                 : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
// //           ),
// //         ),
// //         child: Row(mainAxisSize: MainAxisSize.min, children: [
// //           if (icon != null) ...[
// //             Icon(icon,
// //                 size:  11.sp,                    // ✅ أصغر
// //                 color: selected ? Colors.white : _kGold),
// //             SizedBox(width: 3.w),
// //           ],
// //           Text(label,
// //               style: TextStyle(
// //                 fontSize:   11.sp,               // ✅ أصغر
// //                 fontWeight:
// //                 selected ? FontWeight.bold : FontWeight.normal,
// //                 color: selected
// //                     ? Colors.white
// //                     : (isDark ? Colors.grey.shade300 : AppColors.black),
// //               )),
// //         ]),
// //       ),
// //     );
// //   }
// //
// //   // Widget _chip(String label, String value, IconData icon, bool isDark,
// //   //     {required bool isSort}) {
// //   //   final selected = _sortBy == value;
// //   //   return InkWell(
// //   //     onTap: () => setState(() => _sortBy = value),
// //   //     borderRadius: BorderRadius.circular(20.r),
// //   //     child: Container(
// //   //       padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
// //   //       decoration: BoxDecoration(
// //   //         color: selected
// //   //             ? AppColors.darkRed
// //   //             : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
// //   //         borderRadius: BorderRadius.circular(20.r),
// //   //         border: Border.all(
// //   //           color: selected
// //   //               ? AppColors.darkRed
// //   //               : (isDark
// //   //               ? Colors.grey.shade800
// //   //               : Colors.grey.shade300),
// //   //         ),
// //   //       ),
// //   //       child: Row(mainAxisSize: MainAxisSize.min, children: [
// //   //         Icon(icon,
// //   //             size:  12.sp,
// //   //             color: selected ? Colors.white : AppColors.darkRed),
// //   //         SizedBox(width: 3.w),
// //   //         Text(label,
// //   //             style: TextStyle(
// //   //               fontSize:   11.sp,
// //   //               fontWeight: selected
// //   //                   ? FontWeight.bold
// //   //                   : FontWeight.normal,
// //   //               color: selected
// //   //                   ? Colors.white
// //   //                   : (isDark
// //   //                   ? Colors.grey.shade300
// //   //                   : AppColors.black),
// //   //             )),
// //   //       ]),
// //   //     ),
// //   //   );
// //   // }
// //
// //   // Widget _typeChip(String label, String value, IconData? icon, bool isDark) {
// //   //   final selected = _typeFilter == value;
// //   //   return InkWell(
// //   //     onTap: () => setState(() => _typeFilter = value),
// //   //     borderRadius: BorderRadius.circular(20.r),
// //   //     child: AnimatedContainer(
// //   //       duration: const Duration(milliseconds: 200),
// //   //       padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
// //   //       decoration: BoxDecoration(
// //   //         color: selected
// //   //             ? _kGold
// //   //             : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
// //   //         borderRadius: BorderRadius.circular(20.r),
// //   //         border: Border.all(
// //   //           color: selected
// //   //               ? _kGold
// //   //               : (isDark
// //   //               ? Colors.grey.shade800
// //   //               : Colors.grey.shade300),
// //   //         ),
// //   //       ),
// //   //       child: Row(mainAxisSize: MainAxisSize.min, children: [
// //   //         if (icon != null) ...[
// //   //           Icon(icon,
// //   //               size:  11.sp,
// //   //               color: selected ? Colors.white : _kGold),
// //   //           SizedBox(width: 3.w),
// //   //         ],
// //   //         Text(label,
// //   //             style: TextStyle(
// //   //               fontSize:   11.sp,
// //   //               fontWeight: selected
// //   //                   ? FontWeight.bold
// //   //                   : FontWeight.normal,
// //   //               color: selected
// //   //                   ? Colors.white
// //   //                   : (isDark
// //   //                   ? Colors.grey.shade300
// //   //                   : AppColors.black),
// //   //             )),
// //   //       ]),
// //   //     ),
// //   //   );
// //   // }
// //
// //   // ══════════════════════════════════════════════════════════════════
// //   // TAB BAR
// //   // ══════════════════════════════════════════════════════════════════
// //   Widget _buildTabBar(bool isDark) {
// //     return Container(
// //       margin: EdgeInsets.all(16.r),
// //       decoration: BoxDecoration(
// //         color:        isDark ? const Color(0xFF1E1E1E) : Colors.white,
// //         borderRadius: BorderRadius.circular(16.r),
// //         border: Border.all(
// //             color: isDark
// //                 ? Colors.grey.shade800
// //                 : Colors.grey.shade200),
// //         boxShadow: [
// //           BoxShadow(
// //             color:      Colors.black.withValues(alpha: 0.05),
// //             blurRadius: 10,
// //             offset:     const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: TabBar(
// //         controller:         _tabController,
// //         indicator: BoxDecoration(
// //           color:        AppColors.darkRed,
// //           borderRadius: BorderRadius.circular(12.r),
// //         ),
// //         indicatorSize:        TabBarIndicatorSize.tab,
// //         dividerColor:         Colors.transparent,
// //         labelColor:           Colors.white,
// //         unselectedLabelColor: isDark
// //             ? Colors.grey.shade400
// //             : Colors.grey.shade600,
// //         labelStyle: TextStyle(
// //             fontSize:   14.sp,
// //             fontWeight: FontWeight.bold,
// //             fontFamily: 'Cairo'),
// //         padding: EdgeInsets.all(4.r),
// //         tabs: const [
// //           Tab(text: 'القادمة'),
// //           Tab(text: 'المكتملة'),
// //           Tab(text: 'الملغاة'),
// //         ],
// //       ),
// //     ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.2);
// //   }
// //
// //   // ══════════════════════════════════════════════════════════════════
// //   // TAB CONTENT
// //   // ══════════════════════════════════════════════════════════════════
// //   Widget _buildTab(bool isDark, List<String> statuses) {
// //     return Consumer<AppointmentProvider>(
// //       builder: (_, prov, __) {
// //         final list = _applyFilters(
// //           prov.appointments
// //               .where((a) => statuses.contains(a.status))
// //               .toList(),
// //         );
// //
// //         if (list.isEmpty) {
// //           final isUpcoming = statuses.contains('pending');
// //           final isCompleted = statuses.contains('completed');
// //           return _buildEmptyState(
// //             icon: isUpcoming
// //                 ? Icons.calendar_today_rounded
// //                 : isCompleted
// //                 ? Icons.check_circle_outline_rounded
// //                 : Icons.cancel_outlined,
// //             title: _searchQuery.isNotEmpty
// //                 ? 'لا توجد نتائج'
// //                 : isUpcoming
// //                 ? 'لا توجد حجوزات قادمة'
// //                 : isCompleted
// //                 ? 'لا توجد حجوزات مكتملة'
// //                 : 'لا توجد حجوزات ملغاة',
// //             subtitle: _searchQuery.isNotEmpty
// //                 ? 'جرّب البحث بكلمات مختلفة'
// //                 : isUpcoming
// //                 ? 'احجز موعداً جديداً الآن'
// //                 : isCompleted
// //                 ? 'سيظهر هنا سجل حجوزاتك المكتملة'
// //                 : 'لم تقم بإلغاء أي حجز بعد',
// //             isDark:    isDark,
// //             iconColor: isUpcoming
// //                 ? Colors.orange
// //                 : isCompleted
// //                 ? Colors.green
// //                 : Colors.red,
// //           );
// //         }
// //
// //         return RefreshIndicator(
// //           onRefresh: _loadAppointments,
// //           color:     AppColors.darkRed,
// //           child: ListView.builder(
// //             padding:   EdgeInsets.all(16.r),
// //             itemCount: list.length,
// //             itemBuilder: (_, i) =>
// //                 _buildAppointmentCard(list[i], isDark, i),
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   // ══════════════════════════════════════════════════════════════════
// //   // APPOINTMENT CARD
// //   // ══════════════════════════════════════════════════════════════════
// //   Widget _buildAppointmentCard(
// //       AppointmentModel appt, bool isDark, int index) {
// //     final canCancel = appt.canBeCancelled;
// //     final canReview = appt.canBeReviewed;
// //     final isGroup   = _isGroup(appt);
// //     final persons   = appt.personsCount ?? 1;
// //     // final hasReceipt = appt.receiptUrl != null &&
// //     //     appt.receiptUrl!.isNotEmpty;
// //     // final isPaidElec = appt.paymentMethod == 'electronic' ||
// //     //     appt.paymentMethod == 'wallet';
// //     final hasReceipt  = appt.hasReceipt;             // getter جاهز
// //     final isPaidElec  = appt.isElectronicPayment;    // getter جاهز
// //
// //     return Slidable(
// //       key:     ValueKey(appt.id),
// //       enabled: canCancel,
// //       endActionPane: canCancel
// //           ? ActionPane(
// //         motion: const ScrollMotion(),
// //         children: [
// //           SlidableAction(
// //             onPressed:       (_) => _cancelAppointment(appt),
// //             backgroundColor: Colors.red,
// //             foregroundColor: Colors.white,
// //             icon:            Icons.cancel_rounded,
// //             label:           'إلغاء',
// //             borderRadius:    BorderRadius.circular(16.r),
// //           ),
// //         ],
// //       )
// //           : null,
// //       child: GestureDetector(
// //         onTap: () => Navigator.push(context,
// //             MaterialPageRoute(
// //                 builder: (_) =>
// //                     AppointmentDetailsScreen(appointment: appt))),
// //         child: Container(
// //           margin: EdgeInsets.only(bottom: 16.h),
// //           decoration: BoxDecoration(
// //             color:        isDark ? const Color(0xFF1E1E1E) : Colors.white,
// //             borderRadius: BorderRadius.circular(16.r),
// //             border: Border.all(
// //               color: isGroup
// //                   ? _kGold.withValues(alpha: 0.4)
// //                   : _getStatusColor(appt.status).withValues(alpha: 0.3),
// //               width: isGroup ? 1.8 : 1.5,
// //             ),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: isGroup
// //                     ? _kGold.withValues(alpha: 0.08)
// //                     : Colors.black.withValues(alpha: 0.05),
// //                 blurRadius: 10,
// //                 offset:     const Offset(0, 4),
// //               ),
// //             ],
// //           ),
// //           child: Column(children: [
// //             // ── شريط علوي للحجز الجماعي ──────────────────────────
// //             if (isGroup)
// //               Container(
// //                 width:  double.infinity,
// //                 padding: EdgeInsets.symmetric(
// //                     horizontal: 14.w, vertical: 6.h),
// //                 decoration: BoxDecoration(
// //                   gradient: const LinearGradient(
// //                     colors: [_kGold, _kGoldDark],
// //                   ),
// //                   borderRadius: BorderRadius.only(
// //                     topRight: Radius.circular(14.r),
// //                     topLeft:  Radius.circular(14.r),
// //                   ),
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     Icon(Icons.people_rounded,
// //                         color: Colors.white, size: 14.sp),
// //                     SizedBox(width: 6.w),
// //                     Text(
// //                       'حجز جماعي — $persons أشخاص',
// //                       style: TextStyle(
// //                         color:      Colors.white,
// //                         fontSize:   12.sp,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                     const Spacer(),
// //                     Container(
// //                       padding: EdgeInsets.symmetric(
// //                           horizontal: 8.w, vertical: 2.h),
// //                       decoration: BoxDecoration(
// //                         color:        Colors.white.withValues(alpha: 0.25),
// //                         borderRadius: BorderRadius.circular(8.r),
// //                       ),
// //                       child: Text(
// //                         '${appt.totalPrice.toStringAsFixed(0)} ريال',
// //                         style: TextStyle(
// //                           color:      Colors.white,
// //                           fontSize:   11.sp,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //
// //             // ── المحتوى الرئيسي ───────────────────────────────────
// //             Padding(
// //               padding: EdgeInsets.all(14.r),
// //               child: Column(children: [
// //
// //                 // ── الصف الأول: أيقونة + معلومات + الحالة ───────
// //                 Row(children: [
// //                   // أيقونة الحالة
// //                   Container(
// //                     width:  54.w,
// //                     height: 54.h,
// //                     decoration: BoxDecoration(
// //                       color: _getStatusColor(appt.status)
// //                           .withValues(alpha: 0.1),
// //                       borderRadius: BorderRadius.circular(12.r),
// //                     ),
// //                     child: Icon(
// //                       _getStatusIcon(appt.status),
// //                       color: _getStatusColor(appt.status),
// //                       size:  26.sp,
// //                     )
// //                         .animate(
// //                         onPlay: (c) => c.repeat())
// //                         .then(delay: 2000.ms)
// //                         .shimmer(
// //                       duration: 1500.ms,
// //                       color: _getStatusColor(appt.status)
// //                           .withValues(alpha: 0.5),
// //                     ),
// //                   ),
// //                   SizedBox(width: 12.w),
// //
// //                   // معلومات الموعد
// //                   Expanded(
// //                     child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Row(children: [
// //                             Expanded(
// //                               child: Text(
// //                                 _getServiceTitle(appt),
// //                                 style: TextStyle(
// //                                   fontSize:   15.sp,
// //                                   fontWeight: FontWeight.bold,
// //                                   color: isDark
// //                                       ? Colors.white
// //                                       : AppColors.black,
// //                                 ),
// //                                 maxLines:  1,
// //                                 overflow: TextOverflow.ellipsis,
// //                               ),
// //                             ),
// //                             SizedBox(width: 6.w),
// //                             _buildStatusBadge(appt.status, isDark),
// //                           ]),
// //                           SizedBox(height: 5.h),
// //                           Row(children: [
// //                             Icon(Icons.calendar_today,
// //                                 size:  13.sp,
// //                                 color: Colors.grey.shade500),
// //                             SizedBox(width: 3.w),
// //                             Text(
// //                               DateFormat('d MMMM yyyy', 'ar')
// //                                   .format(appt.appointmentDate),
// //                               style: TextStyle(
// //                                   fontSize: 12.sp,
// //                                   color:    Colors.grey.shade500),
// //                             ),
// //                             SizedBox(width: 10.w),
// //                             Icon(Icons.access_time,
// //                                 size:  13.sp,
// //                                 color: Colors.grey.shade500),
// //                             SizedBox(width: 3.w),
// //                             Text(
// //                               _formatTime(appt.appointmentTime),
// //                               style: TextStyle(
// //                                   fontSize: 12.sp,
// //                                   color:    Colors.grey.shade500),
// //                             ),
// //                           ]),
// //                         ]),
// //                   ),
// //                 ]),
// //
// //                 // ── صف الأشخاص (للحجز الجماعي فقط) ─────────────
// //                 if (isGroup && appt.persons != null &&
// //                     appt.persons!.isNotEmpty) ...[
// //                   SizedBox(height: 10.h),
// //                   _buildPersonsRow(appt, isDark),
// //                 ],
// //
// //                 Divider(height: 18.h),
// //
// //                 // ── الصف السفلي: الحلاق + السعر + الإيصال ───────
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     // الحلاق
// //                     Row(children: [
// //                       CircleAvatar(
// //                         radius: 14.r,
// //                         backgroundColor: Colors.grey.shade300,
// //                         backgroundImage: appt.employeeImageUrl
// //                             ?.isNotEmpty ==
// //                             true
// //                             ? NetworkImage(appt.employeeImageUrl!)
// //                             : null,
// //                         child:
// //                         appt.employeeImageUrl?.isEmpty != false
// //                             ? Icon(Icons.person, size: 14.sp)
// //                             : null,
// //                       ),
// //                       SizedBox(width: 6.w),
// //                       Text(
// //                         appt.employeeName ?? 'تلقائي',
// //                         style: TextStyle(
// //                           fontSize: 12.sp,
// //                           color: isDark
// //                               ? Colors.grey.shade300
// //                               : AppColors.greyDark,
// //                         ),
// //                       ),
// //                     ]),
// //
// //                     // السعر + شارة الدفع
// //                     Row(children: [
// //                       if (isPaidElec)
// //                         Container(
// //                           margin: EdgeInsets.only(left: 6.w),
// //                           padding: EdgeInsets.symmetric(
// //                               horizontal: 7.w, vertical: 3.h),
// //                           decoration: BoxDecoration(
// //                             color:        hasReceipt
// //                                 ? Colors.green.withValues(alpha: 0.1)
// //                                 : Colors.orange.withValues(alpha: 0.1),
// //                             borderRadius: BorderRadius.circular(8.r),
// //                             border: Border.all(
// //                               color: hasReceipt
// //                                   ? Colors.green.withValues(alpha: 0.4)
// //                                   : Colors.orange.withValues(alpha: 0.4),
// //                             ),
// //                           ),
// //                           child: Row(
// //                               mainAxisSize: MainAxisSize.min,
// //                               children: [
// //                                 Icon(
// //                                   hasReceipt
// //                                       ? Icons.receipt_long_rounded
// //                                       : Icons.pending_rounded,
// //                                   size:  11.sp,
// //                                   color: hasReceipt
// //                                       ? Colors.green
// //                                       : Colors.orange,
// //                                 ),
// //                                 SizedBox(width: 3.w),
// //                                 Text(
// //                                   hasReceipt ? 'إيصال' : 'انتظار',
// //                                   style: TextStyle(
// //                                     fontSize: 10.sp,
// //                                     color: hasReceipt
// //                                         ? Colors.green
// //                                         : Colors.orange,
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                               ]),
// //                         ),
// //
// //                       if (!isGroup)
// //                         Text(
// //                           '${appt.totalPrice.toStringAsFixed(0)} ريال',
// //                           style: TextStyle(
// //                             fontSize:   15.sp,
// //                             fontWeight: FontWeight.bold,
// //                             color:      _kGold,
// //                           ),
// //                         )
// //                             .animate(
// //                             onPlay: (c) => c.repeat())
// //                             .then(delay: 3000.ms)
// //                             .shimmer(
// //                           duration: 1000.ms,
// //                           color: _kGoldDark,
// //                         ),
// //                     ]),
// //                   ],
// //                 ),
// //
// //                 // ── معاينة الإيصال (إن وجد) ───────────────────────
// //                 if (hasReceipt) ...[
// //                   SizedBox(height: 10.h),
// //                   _buildReceiptPreview(appt.paymentReceiptUrl!, isDark),
// //                 ],
// //
// //                 // ── أزرار الإجراءات ───────────────────────────────
// //                 if (canCancel || canReview) ...[
// //                   SizedBox(height: 10.h),
// //                   if (canCancel)
// //                     Row(children: [
// //                       Expanded(
// //                         child: OutlinedButton.icon(
// //                           onPressed: () => _cancelAppointment(appt),
// //                           icon: Icon(Icons.close_rounded,
// //                               size: 16.sp, color: AppColors.error),
// //                           label: Text('إلغاء',
// //                               style: TextStyle(
// //                                 color:      AppColors.error,
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize:   13.sp,
// //                               )),
// //                           style: OutlinedButton.styleFrom(
// //                             side: const BorderSide(
// //                                 color: AppColors.error),
// //                             shape: RoundedRectangleBorder(
// //                                 borderRadius:
// //                                 BorderRadius.circular(10.r)),
// //                             padding: EdgeInsets.symmetric(
// //                                 vertical: 10.h),
// //                           ),
// //                         ),
// //                       ),
// //                       SizedBox(width: 10.w),
// //                       Expanded(
// //                         child: ElevatedButton.icon(
// //                           onPressed: () => Navigator.push(context,
// //                               MaterialPageRoute(
// //                                   builder: (_) =>
// //                                       AppointmentDetailsScreen(
// //                                           appointment: appt))),
// //                           icon: Icon(Icons.info_outline_rounded,
// //                               size: 16.sp, color: Colors.white),
// //                           label: Text('التفاصيل',
// //                               style: TextStyle(
// //                                 color:      Colors.white,
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize:   13.sp,
// //                               )),
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: AppColors.darkRed,
// //                             shape: RoundedRectangleBorder(
// //                                 borderRadius:
// //                                 BorderRadius.circular(10.r)),
// //                             padding: EdgeInsets.symmetric(
// //                                 vertical: 10.h),
// //                           ),
// //                         ),
// //                       ),
// //                     ]),
// //                   if (canReview)
// //                     SizedBox(
// //                       width: double.infinity,
// //                       child: ElevatedButton.icon(
// //                         onPressed: () => _navigateToReview(appt),
// //                         icon: Icon(Icons.star_rounded,
// //                             size: 16.sp, color: Colors.white)
// //                             .animate(onPlay: (c) => c.repeat())
// //                             .then(delay: 1000.ms)
// //                             .rotate(
// //                             duration: 500.ms, begin: 0, end: 0.1)
// //                             .then()
// //                             .rotate(
// //                             duration: 500.ms,
// //                             begin: 0.1,
// //                             end: 0),
// //                         label: Text('قيّم الخدمة',
// //                             style: TextStyle(
// //                               color:      Colors.white,
// //                               fontWeight: FontWeight.bold,
// //                               fontSize:   13.sp,
// //                             )),
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: _kGold,
// //                           shape: RoundedRectangleBorder(
// //                               borderRadius:
// //                               BorderRadius.circular(10.r)),
// //                           padding:
// //                           EdgeInsets.symmetric(vertical: 10.h),
// //                         ),
// //                       ),
// //                     ),
// //                 ],
// //               ]),
// //             ),
// //           ]),
// //         )
// //             .animate(
// //             delay: Duration(milliseconds: 80 * index))
// //             .fadeIn()
// //             .slideY(begin: 0.15),
// //       ),
// //     );
// //   }
// //
// //   // ── عنوان الخدمة للحجز الفردي / الجماعي ──────────────────────────
// //   String _getServiceTitle(AppointmentModel appt) {
// //     if (_isGroup(appt)) {
// //       final count = appt.personsCount ?? 1;
// //       return 'حجز جماعي ($count أشخاص)';
// //     }
// //     return appt.services?.isNotEmpty == true
// //         ? (appt.services!.first.serviceNameAr ?? 'خدمة')
// //         : 'خدمة';
// //   }
// //
// //
// //   // ── معاينة الإيصال ───────────────────────────────────────────────
// //   Widget _buildReceiptPreview(String url, bool isDark) {
// //     return GestureDetector(
// //       onTap: () => _showReceiptFullScreen(url),
// //       child: Container(
// //         height:     70.h,
// //         decoration: BoxDecoration(
// //           color:        isDark
// //               ? const Color(0xFF262626)
// //               : Colors.grey.shade50,
// //           borderRadius: BorderRadius.circular(10.r),
// //           border: Border.all(
// //               color: Colors.green.withValues(alpha: 0.3)),
// //         ),
// //         child: Row(children: [
// //           // صورة مصغرة
// //           ClipRRect(
// //             borderRadius: BorderRadius.only(
// //               topRight:    Radius.circular(9.r),
// //               bottomRight: Radius.circular(9.r),
// //             ),
// //             child: CachedNetworkImage(
// //               imageUrl: url,
// //               width:    70.w,
// //               height:   70.h,
// //               fit:      BoxFit.cover,
// //               placeholder: (_, __) => Container(
// //                 color: Colors.grey.shade200,
// //                 child: Icon(Icons.image_outlined,
// //                     color: Colors.grey, size: 24.sp),
// //               ),
// //               errorWidget: (_, __, ___) => Container(
// //                 color: Colors.grey.shade200,
// //                 child: Icon(Icons.broken_image_outlined,
// //                     color: Colors.grey, size: 24.sp),
// //               ),
// //             ),
// //           ),
// //           SizedBox(width: 10.w),
// //           Expanded(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(children: [
// //                   Icon(Icons.receipt_long_rounded,
// //                       size: 14.sp, color: Colors.green),
// //                   SizedBox(width: 5.w),
// //                   Text('إيصال الدفع',
// //                       style: TextStyle(
// //                         fontSize:   12.sp,
// //                         fontWeight: FontWeight.bold,
// //                         color:      Colors.green,
// //                       )),
// //                 ]),
// //                 SizedBox(height: 3.h),
// //                 Text('اضغط للعرض الكامل',
// //                     style: TextStyle(
// //                       fontSize: 11.sp,
// //                       color:    Colors.grey.shade500,
// //                     )),
// //               ],
// //             ),
// //           ),
// //           Icon(Icons.arrow_forward_ios_rounded,
// //               size: 14.sp, color: Colors.grey.shade400),
// //           SizedBox(width: 10.w),
// //         ]),
// //       ),
// //     );
// //   }
// //
// //   // ── عرض الإيصال بالشاشة الكاملة ──────────────────────────────────
// //   void _showReceiptFullScreen(String url) {
// //     showDialog(
// //       context: context,
// //       builder: (_) => Dialog(
// //         backgroundColor: Colors.transparent,
// //         insetPadding:    EdgeInsets.all(16.r),
// //         child: Stack(children: [
// //           ClipRRect(
// //             borderRadius: BorderRadius.circular(16.r),
// //             child: CachedNetworkImage(imageUrl: url),
// //           ),
// //           Positioned(
// //             top:   8.h,
// //             left:  8.w,
// //             child: GestureDetector(
// //               onTap: () => Navigator.pop(context),
// //               child: Container(
// //                 padding:    EdgeInsets.all(8.r),
// //                 decoration: const BoxDecoration(
// //                   color:  Colors.black54,
// //                   shape:  BoxShape.circle,
// //                 ),
// //                 child: Icon(Icons.close_rounded,
// //                     color: Colors.white, size: 20.sp),
// //               ),
// //             ),
// //           ),
// //         ]),
// //       ),
// //     );
// //   }
// //
// //   // ══════════════════════════════════════════════════════════════════
// //   // STATUS BADGE
// //   // ══════════════════════════════════════════════════════════════════
// //   Widget _buildStatusBadge(String status, bool isDark) {
// //     return Container(
// //       padding: EdgeInsets.symmetric(
// //           horizontal: 9.w, vertical: 3.h),
// //       decoration: BoxDecoration(
// //         color:        _getStatusColor(status).withValues(alpha: 0.1),
// //         borderRadius: BorderRadius.circular(10.r),
// //         border: Border.all(
// //             color:
// //             _getStatusColor(status).withValues(alpha: 0.3)),
// //       ),
// //       child: Text(
// //         _getStatusText(status),
// //         style: TextStyle(
// //           fontSize:   10.sp,
// //           fontWeight: FontWeight.bold,
// //           color:      _getStatusColor(status),
// //         ),
// //       ),
// //     )
// //         .animate(onPlay: (c) => c.repeat())
// //         .then(delay: 2000.ms)
// //         .shimmer(
// //       duration: 1000.ms,
// //       color: _getStatusColor(status).withValues(alpha: 0.3),
// //     );
// //   }
// //
// //   // ══════════════════════════════════════════════════════════════════
// //   // SHIMMER
// //   // ══════════════════════════════════════════════════════════════════
// //   Widget _buildShimmerLoading(bool isDark) {
// //     return ListView.builder(
// //       padding:   EdgeInsets.all(16.r),
// //       itemCount: 5,
// //       itemBuilder: (_, i) => Shimmer.fromColors(
// //         baseColor:      isDark ? Colors.grey.shade800 : Colors.grey.shade300,
// //         highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
// //         child: Container(
// //           margin:     EdgeInsets.only(bottom: 16.h),
// //           height:     100.h,
// //           decoration: BoxDecoration(
// //             color:        Colors.white,
// //             borderRadius: BorderRadius.circular(16.r),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ── صف الأشخاص في الحجز الجماعي ─────────────────────────────────
// //   Widget _buildPersonsRow(AppointmentModel appt, bool isDark) {
// //     final persons = appt.persons ?? [];
// //     return Container(
// //       padding:    EdgeInsets.all(10.r),
// //       decoration: BoxDecoration(
// //         color:        _kGold.withValues(alpha: 0.05),
// //         borderRadius: BorderRadius.circular(10.r),
// //         border:       Border.all(color: _kGold.withValues(alpha: 0.2)),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(children: [
// //             Icon(Icons.group_rounded, size: 13.sp, color: _kGold),
// //             SizedBox(width: 5.w),
// //             Text('الأشخاص والخدمات',
// //                 style: TextStyle(
// //                   fontSize:   12.sp,
// //                   fontWeight: FontWeight.bold,
// //                   color:      _kGold,
// //                 )),
// //           ]),
// //           SizedBox(height: 6.h),
// //           ...persons.asMap().entries.map((e) {
// //             final i    = e.key;
// //             final p    = e.value; // AppointmentPersonModel
// //
// //             // ✅ استخدم الحقول الفعلية للـ model
// //             final name = p.personName.isNotEmpty
// //                 ? p.personName
// //                 : 'شخص ${i + 1}';
// //
// //             // اسم الخدمة من services المرتبطة بهذا الشخص
// //             final relatedSvc = appt.services
// //                 ?.where((s) => s.personId == p.id)
// //                 .map((s) => s.getDisplayName())
// //                 .join(', ') ?? '';
// //
// //             return Padding(
// //               padding: EdgeInsets.only(bottom: 4.h),
// //               child: Row(children: [
// //                 Container(
// //                   width:  20.w,
// //                   height: 20.h,
// //                   decoration: BoxDecoration(
// //                     color: _kGold.withValues(alpha: 0.15),
// //                     shape: BoxShape.circle,
// //                   ),
// //                   child: Center(
// //                     child: Text('${i + 1}',
// //                         style: TextStyle(
// //                           fontSize:   10.sp,
// //                           fontWeight: FontWeight.bold,
// //                           color:      _kGold,
// //                         )),
// //                   ),
// //                 ),
// //                 SizedBox(width: 6.w),
// //                 Text(name,
// //                     style: TextStyle(
// //                       fontSize:   12.sp,
// //                       fontWeight: FontWeight.w600,
// //                       color: isDark ? Colors.white : AppColors.black,
// //                     )),
// //                 if (relatedSvc.isNotEmpty) ...[
// //                   Text(' — ',
// //                       style: TextStyle(
// //                           fontSize: 11.sp,
// //                           color:    Colors.grey.shade500)),
// //                   Expanded(
// //                     child: Text(relatedSvc,
// //                         style: TextStyle(
// //                           fontSize: 11.sp,
// //                           color:    Colors.grey.shade500,
// //                         ),
// //                         overflow: TextOverflow.ellipsis),
// //                   ),
// //                 ],
// //               ]),
// //             );
// //           }),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ══════════════════════════════════════════════════════════════════
// //   // EMPTY STATE
// //   // ══════════════════════════════════════════════════════════════════
// //   Widget _buildEmptyState({
// //     required IconData icon,
// //     required String title,
// //     required String subtitle,
// //     required bool isDark,
// //     required Color iconColor,
// //   }) {
// //     return Center(
// //       child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
// //         Container(
// //           padding:    EdgeInsets.all(36.r),
// //           decoration: BoxDecoration(
// //             color: iconColor.withValues(alpha: 0.1),
// //             shape: BoxShape.circle,
// //           ),
// //           child: Icon(icon, size: 72.sp, color: iconColor),
// //         )
// //             .animate(onPlay: (c) => c.repeat())
// //             .scale(
// //           duration: 2000.ms,
// //           begin: const Offset(1, 1),
// //           end:   const Offset(1.08, 1.08),
// //         )
// //             .then()
// //             .scale(
// //           duration: 2000.ms,
// //           begin: const Offset(1.08, 1.08),
// //           end:   const Offset(1, 1),
// //         ),
// //         SizedBox(height: 28.h),
// //         Text(title,
// //             style: TextStyle(
// //               fontSize:   19.sp,
// //               fontWeight: FontWeight.bold,
// //               color: isDark ? Colors.white : AppColors.black,
// //             ))
// //             .animate()
// //             .fadeIn(delay: 200.ms)
// //             .slideY(begin: 0.2),
// //         SizedBox(height: 8.h),
// //         Text(subtitle,
// //             textAlign: TextAlign.center,
// //             style: TextStyle(
// //               fontSize: 13.sp,
// //               color: isDark
// //                   ? Colors.grey.shade500
// //                   : AppColors.greyDark,
// //             ))
// //             .animate()
// //             .fadeIn(delay: 400.ms)
// //             .slideY(begin: 0.2),
// //       ]),
// //     );
// //   }
// //
// //   // ══════════════════════════════════════════════════════════════════
// //   // HELPERS
// //   // ══════════════════════════════════════════════════════════════════
// //   Color _getStatusColor(String s) {
// //     switch (s) {
// //       case 'pending':     return Colors.orange;
// //       case 'confirmed':   return Colors.blue;
// //       case 'in_progress': return Colors.purple;
// //       case 'completed':   return Colors.green;
// //       case 'cancelled':   return Colors.red;
// //       case 'no_show':     return Colors.grey;
// //       default:            return Colors.grey;
// //     }
// //   }
// //
// //   IconData _getStatusIcon(String s) {
// //     switch (s) {
// //       case 'pending':     return Icons.hourglass_empty_rounded;
// //       case 'confirmed':   return Icons.check_circle_outline_rounded;
// //       case 'in_progress': return Icons.pending_rounded;
// //       case 'completed':   return Icons.check_circle_rounded;
// //       case 'cancelled':   return Icons.cancel_rounded;
// //       case 'no_show':     return Icons.event_busy_rounded;
// //       default:            return Icons.help_outline_rounded;
// //     }
// //   }
// //
// //   String _getStatusText(String s) {
// //     switch (s) {
// //       case 'pending':     return 'قيد الانتظار';
// //       case 'confirmed':   return 'مؤكد';
// //       case 'in_progress': return 'جارٍ التنفيذ';
// //       case 'completed':   return 'مكتمل';
// //       case 'cancelled':   return 'ملغى';
// //       case 'no_show':     return 'لم يحضر';
// //       default:            return s;
// //     }
// //   }
// //
// //   Future<void> _navigateToReview(AppointmentModel appt) async {
// //     final rev = Provider.of<ReviewProvider>(context, listen: false);
// //     final existing = await rev.checkAppointmentReview(appt.id!);
// //     if (existing != null) {
// //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
// //         content:          const Text('لقد قمت بتقييم هذه الخدمة مسبقاً'),
// //         backgroundColor:  Colors.orange,
// //         behavior:         SnackBarBehavior.floating,
// //         shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(10.r)),
// //       ));
// //       return;
// //     }
// //     final result = await Navigator.push(context,
// //         MaterialPageRoute(
// //             builder: (_) => AddReviewScreen(appointment: appt)));
// //     if (result == true && mounted) {
// //       final user = Provider.of<UserProvider>(context, listen: false);
// //       await Provider.of<AppointmentProvider>(context, listen: false)
// //           .fetchUserAppointments(user.user!.id!);
// //     }
// //   }
// //
// //   Future<void> _cancelAppointment(AppointmentModel appt) async {
// //     final confirmed = await showDialog<bool>(
// //       context: context,
// //       builder: (_) => Directionality(
// //         textDirection: ui.TextDirection.rtl,
// //         child: AlertDialog(
// //           shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(20.r)),
// //           backgroundColor: Theme.of(context).brightness == Brightness.dark
// //               ? const Color(0xFF1E1E1E)
// //               : Colors.white,
// //           title: Row(children: [
// //             Icon(Icons.warning_amber_rounded,
// //                 color: AppColors.error, size: 26.sp)
// //                 .animate(onPlay: (c) => c.repeat())
// //                 .shake(duration: 500.ms, hz: 4)
// //                 .then(delay: 500.ms),
// //             SizedBox(width: 10.w),
// //             const Text('إلغاء الموعد'),
// //           ]),
// //           content: Text(
// //             'هل أنت متأكد من إلغاء هذا الموعد؟\n'
// //                 'لن يتم إضافة نقاط الولاء المعلقة.',
// //             style: TextStyle(fontSize: 14.sp, height: 1.5),
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(context, false),
// //               child: Text('لا',
// //                   style: TextStyle(
// //                       color: Colors.grey.shade600,
// //                       fontSize: 15.sp)),
// //             ),
// //             ElevatedButton(
// //               onPressed: () => Navigator.pop(context, true),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: AppColors.error,
// //                 foregroundColor: Colors.white,
// //                 shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(10.r)),
// //               ),
// //               child:
// //               Text('نعم، إلغاء', style: TextStyle(fontSize: 15.sp)),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //     if (confirmed != true || !mounted) return;
// //
// //     final apptProv  = Provider.of<AppointmentProvider>(context, listen: false);
// //     final notifProv = Provider.of<NotificationProvider>(context, listen: false);
// //     final userProv  = Provider.of<UserProvider>(context, listen: false);
// //
// //     showDialog(
// //       context:           context,
// //       barrierDismissible: false,
// //       builder: (_) => Center(
// //         child: Material(
// //           color: Colors.transparent,
// //           child: Container(
// //             width:   180.w,
// //             padding: EdgeInsets.all(24.r),
// //             decoration: BoxDecoration(
// //               color: Theme.of(context).brightness == Brightness.dark
// //                   ? const Color(0xFF262626)
// //                   : Colors.white,
// //               borderRadius: BorderRadius.circular(20.r),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color:      Colors.black.withValues(alpha: 0.1),
// //                   blurRadius: 12,
// //                 ),
// //               ],
// //             ),
// //             child: Column(mainAxisSize: MainAxisSize.min, children: [
// //               Container(
// //                 width:  50.w,
// //                 height: 50.h,
// //                 decoration: BoxDecoration(
// //                   shape: BoxShape.circle,
// //                   color: AppColors.darkRed.withValues(alpha: 0.1),
// //                 ),
// //                 child: Padding(
// //                   padding: EdgeInsets.all(10.w),
// //                   child: const CircularProgressIndicator(
// //                     strokeWidth:  3,
// //                     valueColor: AlwaysStoppedAnimation(AppColors.darkRed),
// //                   ),
// //                 ),
// //               ),
// //               SizedBox(height: 16.h),
// //               Text('جارٍ الإلغاء...',
// //                   style: TextStyle(
// //                     fontSize:   15.sp,
// //                     fontWeight: FontWeight.w600,
// //                   )),
// //             ]),
// //           )
// //               .animate()
// //               .fadeIn(duration: 300.ms)
// //               .scale(
// //               begin: const Offset(0.9, 0.9),
// //               end:   const Offset(1, 1)),
// //         ),
// //       ),
// //     );
// //
// //     try {
// //       final ok = await apptProv.cancelAppointment(appt.id!);
// //       if (mounted) Navigator.pop(context);
// //       if (ok && mounted) {
// //         await notifProv.createCancellationNotification(
// //           userId:        userProv.user!.id!,
// //           appointmentId: appt.id!,
// //           serviceName: appt.services?.isNotEmpty == true
// //               ? (appt.services!.first.serviceNameAr ??
// //               appt.services!.first.serviceName ?? 'الخدمة')
// //               : 'الخدمة',
// //         );
// //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
// //           content:         const Text('✅ تم إلغاء الموعد بنجاح'),
// //           backgroundColor: Colors.orange,
// //           behavior:        SnackBarBehavior.floating,
// //           shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(10.r)),
// //         ));
// //         await apptProv
// //             .fetchUserAppointments(userProv.user!.id!);
// //       } else if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
// //           content:         const Text('❌ فشل إلغاء الموعد'),
// //           backgroundColor: Colors.red,
// //           behavior:        SnackBarBehavior.floating,
// //           shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(10.r)),
// //         ));
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         Navigator.pop(context);
// //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
// //           content:         Text('❌ خطأ: $e'),
// //           backgroundColor: Colors.red,
// //           behavior:        SnackBarBehavior.floating,
// //           shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(10.r)),
// //         ));
// //       }
// //     }
// //   }
// // }
//
// /**------------------------------------------------------**/
//
//
//
// import 'dart:convert';
// import 'dart:io';
// import 'dart:ui' as ui;
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:millionaire_barber/core/constants/app_colors.dart';
// import 'package:millionaire_barber/features/appointments/domain/models/appointment_model.dart';
// import 'package:millionaire_barber/features/appointments/presentation/pages/appointment_details_screen.dart';
// import 'package:millionaire_barber/features/appointments/presentation/providers/appointment_provider.dart';
// import 'package:millionaire_barber/features/notifications/presentation/providers/notification_provider.dart';
// import 'package:millionaire_barber/features/profile/presentation/providers/user_provider.dart';
// import 'package:millionaire_barber/features/reviews/presentation/providers/review_provider.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import '../../../reviews/presentation/pages/add_review_screen.dart';
//
// // ── ثوابت الألوان ─────────────────────────────────────────────────
// const _kGold     = Color(0xFFB8860B);
// const _kGoldDark = Color(0xFF8B6914);
//
// class MyAppointmentsScreen extends StatefulWidget {
//   const MyAppointmentsScreen({Key? key}) : super(key: key);
//
//   @override
//   State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
// }
//
// class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final TextEditingController _searchController = TextEditingController();
//   bool _isLoading   = false;
//   bool _isSearching = false;
//   bool _isExporting = false;
//   String _searchQuery = '';
//   String _sortBy      = 'date';
//
//   // ── فلتر النوع ────────────────────────────────────────────────────
//   String _typeFilter = 'all'; // 'all' | 'single' | 'group'
//
//   // ── فلتر نطاق التاريخ ─────────────────────────────────────────────
//   DateTime? _filterFromDate;
//   DateTime? _filterToDate;
//
//   // ── فحص وجود فلتر نشط ────────────────────────────────────────────
//   bool get _hasActiveFilter =>
//       _filterFromDate != null ||
//           _filterToDate   != null ||
//           _typeFilter     != 'all' ||
//           _sortBy         != 'date' ||
//           _searchQuery.isNotEmpty;
//
//   // ══════════════════════════════════════════════════════════════════
//   // INIT / DISPOSE
//   // ══════════════════════════════════════════════════════════════════
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     WidgetsBinding.instance.addPostFrameCallback((_) => _loadAppointments());
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadAppointments() async {
//     final userProvider = Provider.of<UserProvider>(context, listen: false);
//     if (userProvider.user?.id == null) return;
//     setState(() => _isLoading = true);
//     final apptProv = Provider.of<AppointmentProvider>(context, listen: false);
//     await apptProv.fetchUserAppointments(userProvider.user!.id!);
//     if (mounted) setState(() => _isLoading = false);
//   }
//
//   // ── تنسيق الوقت ──────────────────────────────────────────────────
//   String _formatTime(String time) {
//     try {
//       final parts  = time.split(':');
//       final hour   = int.parse(parts[0]);
//       final minute = parts.length > 1 ? parts[1] : '00';
//       if (hour == 0)  return '12:$minute ص';
//       if (hour < 12)  return '$hour:$minute ص';
//       if (hour == 12) return '12:$minute م';
//       return '${hour - 12}:$minute م';
//     } catch (_) { return time; }
//   }
//
//   // ══════════════════════════════════════════════════════════════════
//   // FILTER LOGIC
//   // ══════════════════════════════════════════════════════════════════
//   List<AppointmentModel> _applyFilters(List<AppointmentModel> list) {
//     var result = list;
//
//     // 1. فلتر النوع
//     if (_typeFilter == 'group') {
//       result = result.where((a) => _isGroup(a)).toList();
//     } else if (_typeFilter == 'single') {
//       result = result.where((a) => !_isGroup(a)).toList();
//     }
//
//     // 2. فلتر نطاق التاريخ
//     if (_filterFromDate != null) {
//       result = result.where((a) =>
//       !a.appointmentDate.isBefore(
//         DateTime(_filterFromDate!.year, _filterFromDate!.month, _filterFromDate!.day),
//       ),
//       ).toList();
//     }
//     if (_filterToDate != null) {
//       result = result.where((a) =>
//       !a.appointmentDate.isAfter(
//         DateTime(_filterToDate!.year, _filterToDate!.month, _filterToDate!.day, 23, 59, 59),
//       ),
//       ).toList();
//     }
//
//     // 3. فلتر البحث
//     if (_searchQuery.isNotEmpty) {
//       result = result.where((a) {
//         final svc  = (a.services?.isNotEmpty == true
//             ? a.services!.first.serviceNameAr : '') ?? '';
//         final date = DateFormat('d MMMM yyyy', 'ar').format(a.appointmentDate);
//         final id   = a.id?.toString() ?? '';
//         final emp  = a.employeeName ?? '';
//         return svc.toLowerCase().contains(_searchQuery) ||
//             date.toLowerCase().contains(_searchQuery)   ||
//             id.contains(_searchQuery)                   ||
//             emp.toLowerCase().contains(_searchQuery);
//       }).toList();
//     }
//
//     // 4. ترتيب
//     if (_sortBy == 'date') {
//       result.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
//     } else {
//       result.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
//     }
//     return result;
//   }
//
//   bool _isGroup(AppointmentModel a) => a.personsCount > 1;
//
//   void _resetAllFilters() {
//     setState(() {
//       _filterFromDate = null;
//       _filterToDate   = null;
//       _typeFilter     = 'all';
//       _sortBy         = 'date';
//       _searchQuery    = '';
//       _searchController.clear();
//       _isSearching    = false;
//     });
//   }
//
//   // ══════════════════════════════════════════════════════════════════
//   // BUILD
//   // ══════════════════════════════════════════════════════════════════
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//
//     return Directionality(
//       textDirection: ui.TextDirection.rtl,
//       child: Scaffold(
//         backgroundColor:
//         isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
//         body: NestedScrollView(
//           headerSliverBuilder: (_, innerScrolled) =>
//           [_buildAppBar(isDark, innerScrolled)],
//           body: Column(children: [
//             _buildSearchBar(isDark),
//             _buildFilterRow(isDark),
//             _buildTabBar(isDark),
//             Expanded(
//               child: _isLoading
//                   ? _buildShimmerLoading(isDark)
//                   : TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _buildTab(isDark, ['pending', 'confirmed', 'in_progress']),
//                   _buildTab(isDark, ['completed']),
//                   _buildTab(isDark, ['cancelled', 'no_show']),
//                 ],
//               ),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════════════
//   // APP BAR
//   // ══════════════════════════════════════════════════════════════════
//   Widget _buildAppBar(bool isDark, bool innerScrolled) {
//     return SliverAppBar(
//       expandedHeight: 120.h,
//       floating: false,
//       pinned:   true,
//       elevation: 0,
//       backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//       leading: IconButton(
//         icon: Container(
//           padding:    EdgeInsets.all(8.r),
//           decoration: BoxDecoration(
//             color:        AppColors.darkRed.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(10.r),
//           ),
//           child: Icon(Icons.arrow_back_ios,
//               size: 18.sp, color: AppColors.darkRed),
//         ),
//         onPressed: () => Navigator.pop(context),
//       ),
//       actions: [
//         // ── زر إعادة تعيين الفلاتر (يظهر فقط عند وجود فلتر نشط) ──
//         if (_hasActiveFilter)
//           IconButton(
//             tooltip: 'إعادة تعيين الفلاتر',
//             icon: Container(
//               padding: EdgeInsets.all(8.r),
//               decoration: BoxDecoration(
//                 color: Colors.orange.withValues(alpha: 0.15),
//                 borderRadius: BorderRadius.circular(10.r),
//               ),
//               child: Icon(Icons.filter_alt_off_rounded,
//                   size: 18.sp, color: Colors.orange),
//             ),
//             onPressed: _resetAllFilters,
//           ),
//
//         // ── زر التصدير ────────────────────────────────────────────
//         IconButton(
//           tooltip: 'تصدير كشف الحجوزات',
//           icon: _isExporting
//               ? SizedBox(
//             width: 20.w, height: 20.h,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               color: AppColors.darkRed,
//             ),
//           )
//               : Container(
//             padding: EdgeInsets.all(8.r),
//             decoration: BoxDecoration(
//               color: AppColors.darkRed.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(10.r),
//             ),
//             child: Icon(Icons.file_download_rounded,
//                 size: 20.sp, color: AppColors.darkRed),
//           ),
//           onPressed: _isExporting ? null : () => _showExportSheet(isDark),
//         ),
//
//         // ── زر البحث ──────────────────────────────────────────────
//         IconButton(
//           icon: Container(
//             padding: EdgeInsets.all(8.r),
//             decoration: BoxDecoration(
//               color: _isSearching
//                   ? AppColors.darkRed.withValues(alpha: 0.2)
//                   : AppColors.darkRed.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(10.r),
//             ),
//             child: Icon(
//               _isSearching ? Icons.search_off_rounded : Icons.search_rounded,
//               size: 20.sp,
//               color: AppColors.darkRed,
//             ),
//           ),
//           onPressed: () => setState(() {
//             _isSearching = !_isSearching;
//             if (!_isSearching) {
//               _searchController.clear();
//               _searchQuery = '';
//             }
//           }),
//         ),
//         SizedBox(width: 8.w),
//       ],
//       flexibleSpace: FlexibleSpaceBar(
//         titlePadding: EdgeInsets.only(right: 16.w, bottom: 16.h),
//         title: AnimatedOpacity(
//           opacity:  innerScrolled ? 1.0 : 0.0,
//           duration: const Duration(milliseconds: 200),
//           child: Text('حجوزاتي',
//               style: TextStyle(
//                 fontSize:   20.sp,
//                 fontWeight: FontWeight.bold,
//                 color: isDark ? Colors.white : AppColors.black,
//               )),
//         ),
//         background: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topRight,
//               end:   Alignment.bottomLeft,
//               colors: isDark
//                   ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
//                   : [Colors.white, Colors.grey.shade50],
//             ),
//           ),
//           child: SafeArea(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.w),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment:  MainAxisAlignment.end,
//                 children: [
//                   Text('مواعيدي',
//                       style: TextStyle(
//                         fontSize:   32.sp,
//                         fontWeight: FontWeight.bold,
//                         color: isDark ? Colors.white : AppColors.black,
//                       ))
//                       .animate()
//                       .fadeIn(duration: 600.ms)
//                       .slideX(begin: -0.2),
//                   SizedBox(height: 4.h),
//                   Text('إدارة مواعيدك بسهولة',
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
//                       ))
//                       .animate()
//                       .fadeIn(delay: 200.ms)
//                       .slideX(begin: -0.2),
//                   SizedBox(height: 16.h),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════════════
//   // SEARCH BAR
//   // ══════════════════════════════════════════════════════════════════
//   Widget _buildSearchBar(bool isDark) {
//     if (!_isSearching) return const SizedBox.shrink();
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//       child: TextField(
//         controller: _searchController,
//         onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
//         decoration: InputDecoration(
//           hintText:   'ابحث عن موعد...',
//           prefixIcon: const Icon(Icons.search_rounded, color: AppColors.darkRed),
//           suffixIcon: _searchQuery.isNotEmpty
//               ? IconButton(
//             icon: Icon(Icons.clear_rounded, color: Colors.grey.shade500),
//             onPressed: () {
//               _searchController.clear();
//               setState(() => _searchQuery = '');
//             },
//           )
//               : null,
//           filled:    true,
//           fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//                 color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//                 color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: const BorderSide(color: AppColors.darkRed, width: 2),
//           ),
//         ),
//       ),
//     ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.3);
//   }
//
//   // ══════════════════════════════════════════════════════════════════
//   // FILTER ROW
//   // ══════════════════════════════════════════════════════════════════
//   Widget _buildFilterRow(bool isDark) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // ── الصف الأول: الترتيب + النوع ──────────────────────────
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//           child: Wrap(
//             spacing:    6.w,
//             runSpacing: 6.h,
//             crossAxisAlignment: WrapCrossAlignment.center,
//             children: [
//               _filterLabel('ترتيب:', isDark),
//               _chip('التاريخ', 'date',  Icons.calendar_today_rounded, isDark),
//               _chip('السعر',   'price', Icons.attach_money_rounded,   isDark),
//               _divider(isDark),
//               _filterLabel('النوع:', isDark),
//               _typeChip('الكل',  'all',    null,                 isDark),
//               _typeChip('فردي',  'single', Icons.person_rounded,  isDark),
//               _typeChip('جماعي', 'group',  Icons.people_rounded,  isDark),
//             ],
//           ),
//         ),
//
//         // ── الصف الثاني: فلتر نطاق التاريخ ──────────────────────
//         Padding(
//           padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 4.h),
//           child: Row(
//             children: [
//               Icon(Icons.date_range_rounded,
//                   size: 14.sp, color: AppColors.darkRed),
//               SizedBox(width: 6.w),
//               _filterLabel('الفترة:', isDark),
//               SizedBox(width: 6.w),
//
//               Expanded(
//                 child: _buildDateButton(
//                   label: _filterFromDate != null
//                       ? DateFormat('d MMM', 'ar').format(_filterFromDate!)
//                       : 'من تاريخ',
//                   isActive: _filterFromDate != null,
//                   isDark:   isDark,
//                   onTap: () => _pickDate(isFrom: true, isDark: isDark),
//                 ),
//               ),
//
//               SizedBox(width: 8.w),
//               Icon(Icons.arrow_left_rounded,
//                   color: Colors.grey.shade400, size: 20.sp),
//               SizedBox(width: 8.w),
//
//               Expanded(
//                 child: _buildDateButton(
//                   label: _filterToDate != null
//                       ? DateFormat('d MMM', 'ar').format(_filterToDate!)
//                       : 'إلى تاريخ',
//                   isActive: _filterToDate != null,
//                   isDark:   isDark,
//                   onTap: () => _pickDate(isFrom: false, isDark: isDark),
//                 ),
//               ),
//
//               if (_filterFromDate != null || _filterToDate != null) ...[
//                 SizedBox(width: 8.w),
//                 GestureDetector(
//                   onTap: () => setState(() {
//                     _filterFromDate = null;
//                     _filterToDate   = null;
//                   }),
//                   child: Container(
//                     padding: EdgeInsets.all(6.r),
//                     decoration: BoxDecoration(
//                       color: Colors.red.withValues(alpha: 0.1),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(Icons.close_rounded,
//                         size: 14.sp, color: Colors.red),
//                   ),
//                 ),
//               ],
//             ],
//           ),
//         ),
//
//         // ── الصف الثالث: إحصائيات سريعة ─────────────────────────
//         _buildStatsRow(isDark),
//       ],
//     ).animate().fadeIn(delay: 100.ms);
//   }
//
//   Widget _buildDateButton({
//     required String label,
//     required bool   isActive,
//     required bool   isDark,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
//         decoration: BoxDecoration(
//           color: isActive
//               ? AppColors.darkRed.withValues(alpha: 0.1)
//               : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
//           borderRadius: BorderRadius.circular(10.r),
//           border: Border.all(
//             color: isActive
//                 ? AppColors.darkRed
//                 : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.calendar_today_rounded,
//                 size:  12.sp,
//                 color: isActive ? AppColors.darkRed : Colors.grey.shade500),
//             SizedBox(width: 5.w),
//             Text(label,
//                 style: TextStyle(
//                   fontSize:   11.sp,
//                   fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
//                   color: isActive
//                       ? AppColors.darkRed
//                       : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
//                 )),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _filterLabel(String text, bool isDark) {
//     return Padding(
//       padding: EdgeInsets.only(left: 2.w),
//       child: Text(text,
//           style: TextStyle(
//             fontSize: 11.sp,
//             color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
//           )),
//     );
//   }
//
//   Widget _divider(bool isDark) {
//     return Container(
//       width:  1,
//       height: 18.h,
//       margin: EdgeInsets.symmetric(horizontal: 4.w),
//       color:  isDark ? Colors.grey.shade700 : Colors.grey.shade300,
//     );
//   }
//
//   Widget _chip(String label, String value, IconData icon, bool isDark) {
//     final selected = _sortBy == value;
//     return InkWell(
//       onTap: () => setState(() => _sortBy = value),
//       borderRadius: BorderRadius.circular(20.r),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//         decoration: BoxDecoration(
//           color: selected
//               ? AppColors.darkRed
//               : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
//           borderRadius: BorderRadius.circular(20.r),
//           border: Border.all(
//             color: selected
//                 ? AppColors.darkRed
//                 : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
//           ),
//         ),
//         child: Row(mainAxisSize: MainAxisSize.min, children: [
//           Icon(icon,
//               size:  11.sp,
//               color: selected ? Colors.white : AppColors.darkRed),
//           SizedBox(width: 3.w),
//           Text(label,
//               style: TextStyle(
//                 fontSize:   11.sp,
//                 fontWeight: selected ? FontWeight.bold : FontWeight.normal,
//                 color: selected
//                     ? Colors.white
//                     : (isDark ? Colors.grey.shade300 : AppColors.black),
//               )),
//         ]),
//       ),
//     );
//   }
//
//   Widget _typeChip(String label, String value, IconData? icon, bool isDark) {
//     final selected = _typeFilter == value;
//     return InkWell(
//       onTap: () => setState(() => _typeFilter = value),
//       borderRadius: BorderRadius.circular(20.r),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//         decoration: BoxDecoration(
//           color: selected
//               ? _kGold
//               : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
//           borderRadius: BorderRadius.circular(20.r),
//           border: Border.all(
//             color: selected
//                 ? _kGold
//                 : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
//           ),
//         ),
//         child: Row(mainAxisSize: MainAxisSize.min, children: [
//           if (icon != null) ...[
//             Icon(icon,
//                 size:  11.sp,
//                 color: selected ? Colors.white : _kGold),
//             SizedBox(width: 3.w),
//           ],
//           Text(label,
//               style: TextStyle(
//                 fontSize:   11.sp,
//                 fontWeight: selected ? FontWeight.bold : FontWeight.normal,
//                 color: selected
//                     ? Colors.white
//                     : (isDark ? Colors.grey.shade300 : AppColors.black),
//               )),
//         ]),
//       ),
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════════════
//   // STATS ROW
//   // ══════════════════════════════════════════════════════════════════
//   Widget _buildStatsRow(bool isDark) {
//     return Consumer<AppointmentProvider>(
//       builder: (_, prov, __) {
//         final all       = _applyFilters(prov.appointments);
//         final completed = all.where((a) => a.status == 'completed').length;
//         final pending   = all.where((a) =>
//             ['pending', 'confirmed', 'in_progress'].contains(a.status)).length;
//         final totalSpent = all
//             .where((a) => a.status == 'completed')
//             .fold(0.0, (s, a) => s + a.totalPrice);
//
//         if (all.isEmpty) return const SizedBox.shrink();
//
//         return Container(
//           margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//           padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: isDark
//                   ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
//                   : [Colors.white, Colors.grey.shade50],
//             ),
//             borderRadius: BorderRadius.circular(12.r),
//             border: Border.all(
//                 color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildStatItem('الكل',     '${all.length}',
//                   AppColors.darkRed,  Icons.calendar_month_rounded, isDark),
//               _buildStatDivider(isDark),
//               _buildStatItem('قادمة',    '$pending',
//                   Colors.orange,      Icons.upcoming_rounded,        isDark),
//               _buildStatDivider(isDark),
//               _buildStatItem('مكتملة',   '$completed',
//                   Colors.green,       Icons.check_circle_rounded,    isDark),
//               _buildStatDivider(isDark),
//               _buildStatItem('الإجمالي', '${totalSpent.toStringAsFixed(0)}',
//                   _kGold,             Icons.wallet_rounded,           isDark),
//             ],
//           ),
//         ).animate().fadeIn(delay: 200.ms);
//       },
//     );
//   }
//
//   Widget _buildStatItem(
//       String label, String value, Color color, IconData icon, bool isDark) {
//     return Column(mainAxisSize: MainAxisSize.min, children: [
//       Icon(icon, size: 16.sp, color: color),
//       SizedBox(height: 3.h),
//       Text(value,
//           style: TextStyle(
//             fontSize:   14.sp,
//             fontWeight: FontWeight.bold,
//             color: isDark ? Colors.white : AppColors.black,
//             fontFamily: 'Cairo',
//           )),
//       Text(label,
//           style: TextStyle(
//             fontSize: 10.sp,
//             color:    Colors.grey.shade500,
//             fontFamily: 'Cairo',
//           )),
//     ]);
//   }
//
//   Widget _buildStatDivider(bool isDark) {
//     return Container(
//       width: 1, height: 30.h,
//       color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════════════
//   // TAB BAR
//   // ══════════════════════════════════════════════════════════════════
//   Widget _buildTabBar(bool isDark) {
//     return Container(
//       margin: EdgeInsets.all(16.r),
//       decoration: BoxDecoration(
//         color:        isDark ? const Color(0xFF1E1E1E) : Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         border: Border.all(
//             color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
//         boxShadow: [
//           BoxShadow(
//             color:      Colors.black.withValues(alpha: 0.05),
//             blurRadius: 10,
//             offset:     const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: TabBar(
//         controller:           _tabController,
//         indicator: BoxDecoration(
//           color:        AppColors.darkRed,
//           borderRadius: BorderRadius.circular(12.r),
//         ),
//         indicatorSize:        TabBarIndicatorSize.tab,
//         dividerColor:         Colors.transparent,
//         labelColor:           Colors.white,
//         unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//         labelStyle: TextStyle(
//             fontSize: 14.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
//         padding: EdgeInsets.all(4.r),
//         tabs: const [
//           Tab(text: 'القادمة'),
//           Tab(text: 'المكتملة'),
//           Tab(text: 'الملغاة'),
//         ],
//       ),
//     ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.2);
//   }
//
//   // ══════════════════════════════════════════════════════════════════
//   // TAB CONTENT
//   // ══════════════════════════════════════════════════════════════════
//   Widget _buildTab(bool isDark, List<String> statuses) {
//     return Consumer<AppointmentProvider>(
//       builder: (_, prov, __) {
//         final list = _applyFilters(
//           prov.appointments.where((a) => statuses.contains(a.status)).toList(),
//         );
//
//         if (list.isEmpty) {
//           final isUpcoming  = statuses.contains('pending');
//           final isCompleted = statuses.contains('completed');
//           return _buildEmptyState(
//             icon: isUpcoming
//                 ? Icons.calendar_today_rounded
//                 : isCompleted
//                 ? Icons.check_circle_outline_rounded
//                 : Icons.cancel_outlined,
//             title: _searchQuery.isNotEmpty
//                 ? 'لا توجد نتائج'
//                 : _hasActiveFilter
//                 ? 'لا توجد نتائج للفلتر المحدد'
//                 : isUpcoming
//                 ? 'لا توجد حجوزات قادمة'
//                 : isCompleted
//                 ? 'لا توجد حجوزات مكتملة'
//                 : 'لا توجد حجوزات ملغاة',
//             subtitle: _searchQuery.isNotEmpty || _hasActiveFilter
//                 ? 'جرّب تغيير الفلاتر أو نطاق التاريخ'
//                 : isUpcoming
//                 ? 'احجز موعداً جديداً الآن'
//                 : isCompleted
//                 ? 'سيظهر هنا سجل حجوزاتك المكتملة'
//                 : 'لم تقم بإلغاء أي حجز بعد',
//             isDark:    isDark,
//             iconColor: isUpcoming
//                 ? Colors.orange
//                 : isCompleted
//                 ? Colors.green
//                 : Colors.red,
//           );
//         }
//
//         return RefreshIndicator(
//           onRefresh: _loadAppointments,
//           color:     AppColors.darkRed,
//           child: ListView.builder(
//             padding:   EdgeInsets.all(16.r),
//             itemCount: list.length,
//             itemBuilder: (_, i) => _buildAppointmentCard(list[i], isDark, i),
//           ),
//         );
//       },
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════════════
//   // APPOINTMENT CARD
//   // ══════════════════════════════════════════════════════════════════
//   Widget _buildAppointmentCard(
//       AppointmentModel appt, bool isDark, int index) {
//     final canCancel  = appt.canBeCancelled;
//     final canReview  = appt.canBeReviewed;
//     final isGroup    = _isGroup(appt);
//     final persons    = appt.personsCount ?? 1;
//     final hasReceipt = appt.hasReceipt;
//     final isPaidElec = appt.isElectronicPayment;
//
//     return Slidable(
//       key:     ValueKey(appt.id),
//       enabled: canCancel,
//       endActionPane: canCancel
//           ? ActionPane(
//         motion: const ScrollMotion(),
//         children: [
//           SlidableAction(
//             onPressed:       (_) => _cancelAppointment(appt),
//             backgroundColor: Colors.red,
//             foregroundColor: Colors.white,
//             icon:            Icons.cancel_rounded,
//             label:           'إلغاء',
//             borderRadius:    BorderRadius.circular(16.r),
//           ),
//         ],
//       )
//           : null,
//       child: GestureDetector(
//         onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (_) => AppointmentDetailsScreen(appointment: appt))),
//         child: Container(
//           margin: EdgeInsets.only(bottom: 16.h),
//           decoration: BoxDecoration(
//             color:        isDark ? const Color(0xFF1E1E1E) : Colors.white,
//             borderRadius: BorderRadius.circular(16.r),
//             border: Border.all(
//               color: isGroup
//                   ? _kGold.withValues(alpha: 0.4)
//                   : _getStatusColor(appt.status).withValues(alpha: 0.3),
//               width: isGroup ? 1.8 : 1.5,
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: isGroup
//                     ? _kGold.withValues(alpha: 0.08)
//                     : Colors.black.withValues(alpha: 0.05),
//                 blurRadius: 10,
//                 offset:     const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(children: [
//             // ── شريط علوي للحجز الجماعي ──────────────────────────
//             if (isGroup)
//               Container(
//                 width:  double.infinity,
//                 padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(colors: [_kGold, _kGoldDark]),
//                   borderRadius: BorderRadius.only(
//                     topRight: Radius.circular(14.r),
//                     topLeft:  Radius.circular(14.r),
//                   ),
//                 ),
//                 child: Row(children: [
//                   Icon(Icons.people_rounded, color: Colors.white, size: 14.sp),
//                   SizedBox(width: 6.w),
//                   Text(
//                     'حجز جماعي — $persons أشخاص',
//                     style: TextStyle(
//                       color:      Colors.white,
//                       fontSize:   12.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const Spacer(),
//                   Container(
//                     padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
//                     decoration: BoxDecoration(
//                       color:        Colors.white.withValues(alpha: 0.25),
//                       borderRadius: BorderRadius.circular(8.r),
//                     ),
//                     child: Text(
//                       '${appt.totalPrice.toStringAsFixed(0)} ريال',
//                       style: TextStyle(
//                         color:      Colors.white,
//                         fontSize:   11.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ]),
//               ),
//
//             // ── المحتوى الرئيسي ───────────────────────────────────
//             Padding(
//               padding: EdgeInsets.all(14.r),
//               child: Column(children: [
//
//                 // ── الصف الأول: أيقونة + معلومات + الحالة ────────
//                 Row(children: [
//                   Container(
//                     width:  54.w,
//                     height: 54.h,
//                     decoration: BoxDecoration(
//                       color: _getStatusColor(appt.status).withValues(alpha: 0.1),
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     child: Icon(
//                       _getStatusIcon(appt.status),
//                       color: _getStatusColor(appt.status),
//                       size:  26.sp,
//                     )
//                         .animate(onPlay: (c) => c.repeat())
//                         .then(delay: 2000.ms)
//                         .shimmer(
//                       duration: 1500.ms,
//                       color: _getStatusColor(appt.status)
//                           .withValues(alpha: 0.5),
//                     ),
//                   ),
//                   SizedBox(width: 12.w),
//
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(children: [
//                           Expanded(
//                             child: Text(
//                               _getServiceTitle(appt),
//                               style: TextStyle(
//                                 fontSize:   15.sp,
//                                 fontWeight: FontWeight.bold,
//                                 color: isDark ? Colors.white : AppColors.black,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           SizedBox(width: 6.w),
//                           _buildStatusBadge(appt.status, isDark),
//                         ]),
//                         SizedBox(height: 5.h),
//                         Row(children: [
//                           Icon(Icons.calendar_today,
//                               size: 13.sp, color: Colors.grey.shade500),
//                           SizedBox(width: 3.w),
//                           Text(
//                             DateFormat('d MMMM yyyy', 'ar')
//                                 .format(appt.appointmentDate),
//                             style: TextStyle(
//                                 fontSize: 12.sp, color: Colors.grey.shade500),
//                           ),
//                           SizedBox(width: 10.w),
//                           Icon(Icons.access_time,
//                               size: 13.sp, color: Colors.grey.shade500),
//                           SizedBox(width: 3.w),
//                           Text(
//                             _formatTime(appt.appointmentTime),
//                             style: TextStyle(
//                                 fontSize: 12.sp, color: Colors.grey.shade500),
//                           ),
//                         ]),
//                       ],
//                     ),
//                   ),
//                 ]),
//
//                 // ── صف الأشخاص (للحجز الجماعي فقط) ─────────────
//                 if (isGroup &&
//                     appt.persons != null &&
//                     appt.persons!.isNotEmpty) ...[
//                   SizedBox(height: 10.h),
//                   _buildPersonsRow(appt, isDark),
//                 ],
//
//                 Divider(height: 18.h),
//
//                 // ── الصف السفلي: الحلاق + السعر + الإيصال ────────
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(children: [
//                       CircleAvatar(
//                         radius: 14.r,
//                         backgroundColor: Colors.grey.shade300,
//                         backgroundImage: appt.employeeImageUrl?.isNotEmpty == true
//                             ? NetworkImage(appt.employeeImageUrl!)
//                             : null,
//                         child: appt.employeeImageUrl?.isEmpty != false
//                             ? Icon(Icons.person, size: 14.sp)
//                             : null,
//                       ),
//                       SizedBox(width: 6.w),
//                       Text(
//                         appt.employeeName ?? 'تلقائي',
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: isDark
//                               ? Colors.grey.shade300
//                               : AppColors.greyDark,
//                         ),
//                       ),
//                     ]),
//
//                     Row(children: [
//                       if (isPaidElec)
//                         Container(
//                           margin: EdgeInsets.only(left: 6.w),
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 7.w, vertical: 3.h),
//                           decoration: BoxDecoration(
//                             color: hasReceipt
//                                 ? Colors.green.withValues(alpha: 0.1)
//                                 : Colors.orange.withValues(alpha: 0.1),
//                             borderRadius: BorderRadius.circular(8.r),
//                             border: Border.all(
//                               color: hasReceipt
//                                   ? Colors.green.withValues(alpha: 0.4)
//                                   : Colors.orange.withValues(alpha: 0.4),
//                             ),
//                           ),
//                           child: Row(mainAxisSize: MainAxisSize.min, children: [
//                             Icon(
//                               hasReceipt
//                                   ? Icons.receipt_long_rounded
//                                   : Icons.pending_rounded,
//                               size:  11.sp,
//                               color: hasReceipt ? Colors.green : Colors.orange,
//                             ),
//                             SizedBox(width: 3.w),
//                             Text(
//                               hasReceipt ? 'إيصال' : 'انتظار',
//                               style: TextStyle(
//                                 fontSize:   10.sp,
//                                 color: hasReceipt ? Colors.green : Colors.orange,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ]),
//                         ),
//
//                       if (!isGroup)
//                         Text(
//                           '${appt.totalPrice.toStringAsFixed(0)} ريال',
//                           style: TextStyle(
//                             fontSize:   15.sp,
//                             fontWeight: FontWeight.bold,
//                             color:      _kGold,
//                           ),
//                         )
//                             .animate(onPlay: (c) => c.repeat())
//                             .then(delay: 3000.ms)
//                             .shimmer(duration: 1000.ms, color: _kGoldDark),
//                     ]),
//                   ],
//                 ),
//
//                 // ── معاينة الإيصال ────────────────────────────────
//                 if (hasReceipt) ...[
//                   SizedBox(height: 10.h),
//                   _buildReceiptPreview(appt.paymentReceiptUrl!, isDark),
//                 ],
//
//                 // ── أزرار الإجراءات ───────────────────────────────
//                 if (canCancel || canReview) ...[
//                   SizedBox(height: 10.h),
//                   if (canCancel)
//                     Row(children: [
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: () => _cancelAppointment(appt),
//                           icon: Icon(Icons.close_rounded,
//                               size: 16.sp, color: AppColors.error),
//                           label: Text('إلغاء',
//                               style: TextStyle(
//                                 color:      AppColors.error,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize:   13.sp,
//                               )),
//                           style: OutlinedButton.styleFrom(
//                             side: const BorderSide(color: AppColors.error),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.r)),
//                             padding: EdgeInsets.symmetric(vertical: 10.h),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 10.w),
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           onPressed: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (_) => AppointmentDetailsScreen(
//                                       appointment: appt))),
//                           icon: Icon(Icons.info_outline_rounded,
//                               size: 16.sp, color: Colors.white),
//                           label: Text('التفاصيل',
//                               style: TextStyle(
//                                 color:      Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize:   13.sp,
//                               )),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: AppColors.darkRed,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.r)),
//                             padding: EdgeInsets.symmetric(vertical: 10.h),
//                           ),
//                         ),
//                       ),
//                     ]),
//                   if (canReview)
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: () => _navigateToReview(appt),
//                         icon: Icon(Icons.star_rounded,
//                             size: 16.sp, color: Colors.white)
//                             .animate(onPlay: (c) => c.repeat())
//                             .then(delay: 1000.ms)
//                             .rotate(duration: 500.ms, begin: 0, end: 0.1)
//                             .then()
//                             .rotate(duration: 500.ms, begin: 0.1, end: 0),
//                         label: Text('قيّم الخدمة',
//                             style: TextStyle(
//                               color:      Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize:   13.sp,
//                             )),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _kGold,
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10.r)),
//                           padding: EdgeInsets.symmetric(vertical: 10.h),
//                         ),
//                       ),
//                     ),
//                 ],
//               ]),
//             ),
//           ]),
//         )
//             .animate(delay: Duration(milliseconds: 80 * index))
//             .fadeIn()
//             .slideY(begin: 0.15),
//       ),
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════════════
//   // HELPERS — CARD
//   // ══════════════════════════════════════════════════════════════════
//   String _getServiceTitle(AppointmentModel appt) {
//     if (_isGroup(appt)) {
//       final count = appt.personsCount ?? 1;
//       return 'حجز جماعي ($count أشخاص)';
//     }
//     return appt.services?.isNotEmpty == true
//         ? (appt.services!.first.serviceNameAr ?? 'خدمة')
//         : 'خدمة';
//   }
//
//   Widget _buildReceiptPreview(String url, bool isDark) {
//     return GestureDetector(
//       onTap: () => _showReceiptFullScreen(url),
//       child: Container(
//         height:     70.h,
//         decoration: BoxDecoration(
//           color: isDark ? const Color(0xFF262626) : Colors.grey.shade50,
//           borderRadius: BorderRadius.circular(10.r),
//           border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
//         ),
//         child: Row(children: [
//           ClipRRect(
//             borderRadius: BorderRadius.only(
//               topRight:    Radius.circular(9.r),
//               bottomRight: Radius.circular(9.r),
//             ),
//             child: CachedNetworkImage(
//               imageUrl:    url,
//               width:       70.w,
//               height:      70.h,
//               fit:         BoxFit.cover,
//               placeholder: (_, __) => Container(
//                 color: Colors.grey.shade200,
//                 child: Icon(Icons.image_outlined,
//                     color: Colors.grey, size: 24.sp),
//               ),
//               errorWidget: (_, __, ___) => Container(
//                 color: Colors.grey.shade200,
//                 child: Icon(Icons.broken_image_outlined,
//                     color: Colors.grey, size: 24.sp),
//               ),
//             ),
//           ),
//           SizedBox(width: 10.w),
//           Expanded(
//             child: Column(
//               mainAxisAlignment:  MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(children: [
//                   Icon(Icons.receipt_long_rounded,
//                       size: 14.sp, color: Colors.green),
//                   SizedBox(width: 5.w),
//                   Text('إيصال الدفع',
//                       style: TextStyle(
//                         fontSize:   12.sp,
//                         fontWeight: FontWeight.bold,
//                         color:      Colors.green,
//                       )),
//                 ]),
//                 SizedBox(height: 3.h),
//                 Text('اضغط للعرض الكامل',
//                     style: TextStyle(
//                         fontSize: 11.sp, color: Colors.grey.shade500)),
//               ],
//             ),
//           ),
//           Icon(Icons.arrow_forward_ios_rounded,
//               size: 14.sp, color: Colors.grey.shade400),
//           SizedBox(width: 10.w),
//         ]),
//       ),
//     );
//   }
//
//   void _showReceiptFullScreen(String url) {
//     showDialog(
//       context: context,
//       builder: (_) => Dialog(
//         backgroundColor: Colors.transparent,
//         insetPadding:    EdgeInsets.all(16.r),
//         child: Stack(children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(16.r),
//             child: CachedNetworkImage(imageUrl: url),
//           ),
//           Positioned(
//             top:  8.h,
//             left: 8.w,
//             child: GestureDetector(
//               onTap: () => Navigator.pop(context),
//               child: Container(
//                 padding:    EdgeInsets.all(8.r),
//                 decoration: const BoxDecoration(
//                     color: Colors.black54, shape: BoxShape.circle),
//                 child: Icon(Icons.close_rounded,
//                     color: Colors.white, size: 20.sp),
//               ),
//             ),
//           ),
//         ]),
//       ),
//     );
//   }
//
//   Widget _buildPersonsRow(AppointmentModel appt, bool isDark) {
//     final persons = appt.persons ?? [];
//     return Container(
//       padding:    EdgeInsets.all(10.r),
//       decoration: BoxDecoration(
//         color:        _kGold.withValues(alpha: 0.05),
//         borderRadius: BorderRadius.circular(10.r),
//         border:       Border.all(color: _kGold.withValues(alpha: 0.2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(children: [
//             Icon(Icons.group_rounded, size: 13.sp, color: _kGold),
//             SizedBox(width: 5.w),
//             Text('الأشخاص والخدمات',
//                 style: TextStyle(
//                   fontSize:   12.sp,
//                   fontWeight: FontWeight.bold,
//                   color:      _kGold,
//                 )),
//           ]),
//           SizedBox(height: 6.h),
//           ...persons.asMap().entries.map((e) {
//             final i    = e.key;
//             final p    = e.value;
//             final name = p.personName.isNotEmpty ? p.personName : 'شخص ${i + 1}';
//             final relatedSvc = appt.services
//                 ?.where((s) => s.personId == p.id)
//                 .map((s) => s.getDisplayName())
//                 .join(', ') ??
//                 '';
//             return Padding(
//               padding: EdgeInsets.only(bottom: 4.h),
//               child: Row(children: [
//                 Container(
//                   width:  20.w,
//                   height: 20.h,
//                   decoration: BoxDecoration(
//                     color: _kGold.withValues(alpha: 0.15),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Center(
//                     child: Text('${i + 1}',
//                         style: TextStyle(
//                           fontSize:   10.sp,
//                           fontWeight: FontWeight.bold,
//                           color:      _kGold,
//                         )),
//                   ),
//                 ),
//                 SizedBox(width: 6.w),
//                 Text(name,
//                     style: TextStyle(
//                       fontSize:   12.sp,
//                       fontWeight: FontWeight.w600,
//                       color: isDark ? Colors.white : AppColors.black,
//                     )),
//                 if (relatedSvc.isNotEmpty) ...[
//                   Text(' — ',
//                       style: TextStyle(
//                           fontSize: 11.sp, color: Colors.grey.shade500)),
//                   Expanded(
//                     child: Text(relatedSvc,
//                         style: TextStyle(
//                             fontSize: 11.sp, color: Colors.grey.shade500),
//                         overflow: TextOverflow.ellipsis),
//                   ),
//                 ],
//               ]),
//             );
//           }),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatusBadge(String status, bool isDark) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
//       decoration: BoxDecoration(
//         color:        _getStatusColor(status).withValues(alpha: 0.1),
//         borderRadius: BorderRadius.circular(10.r),
//         border: Border.all(
//             color: _getStatusColor(status).withValues(alpha: 0.3)),
//       ),
//       child: Text(
//         _getStatusText(status),
//         style: TextStyle(
//           fontSize:   10.sp,
//           fontWeight: FontWeight.bold,
//           color:      _getStatusColor(status),
//         ),
//       ),
//     )
//         .animate(onPlay: (c) => c.repeat())
//         .then(delay: 2000.ms)
//         .shimmer(
//       duration: 1000.ms,
//       color: _getStatusColor(status).withValues(alpha: 0.3),
//     );
//   }
//
//   Widget _buildShimmerLoading(bool isDark) {
//     return ListView.builder(
//       padding:   EdgeInsets.all(16.r),
//       itemCount: 5,
//       itemBuilder: (_, i) => Shimmer.fromColors(
//         baseColor:      isDark ? Colors.grey.shade800 : Colors.grey.shade300,
//         highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
//         child: Container(
//           margin:     EdgeInsets.only(bottom: 16.h),
//           height:     100.h,
//           decoration: BoxDecoration(
//             color:        Colors.white,
//             borderRadius: BorderRadius.circular(16.r),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState({
//     required IconData icon,
//     required String   title,
//     required String   subtitle,
//     required bool     isDark,
//     required Color    iconColor,
//   }) {
//     return Center(
//       child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
//         Container(
//           padding:    EdgeInsets.all(36.r),
//           decoration: BoxDecoration(
//             color: iconColor.withValues(alpha: 0.1),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, size: 72.sp, color: iconColor),
//         )
//             .animate(onPlay: (c) => c.repeat())
//             .scale(
//           duration: 2000.ms,
//           begin:    const Offset(1, 1),
//           end:      const Offset(1.08, 1.08),
//         )
//             .then()
//             .scale(
//           duration: 2000.ms,
//           begin:    const Offset(1.08, 1.08),
//           end:      const Offset(1, 1),
//         ),
//         SizedBox(height: 28.h),
//         Text(title,
//             style: TextStyle(
//               fontSize:   19.sp,
//               fontWeight: FontWeight.bold,
//               color: isDark ? Colors.white : AppColors.black,
//             ))
//             .animate()
//             .fadeIn(delay: 200.ms)
//             .slideY(begin: 0.2),
//         SizedBox(height: 8.h),
//         Text(subtitle,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 13.sp,
//               color: isDark ? Colors.grey.shade500 : AppColors.greyDark,
//             ))
//             .animate()
//             .fadeIn(delay: 400.ms)
//             .slideY(begin: 0.2),
//       ]),
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════════════
//   // DATE PICKER
//   // ══════════════════════════════════════════════════════════════════
//   Future<void> _pickDate({required bool isFrom, required bool isDark}) async {
//     final now  = DateTime.now();
//     final init = isFrom
//         ? (_filterFromDate ?? DateTime(now.year, now.month - 1, now.day))
//         : (_filterToDate   ?? now);
//
//     final picked = await showDatePicker(
//       context:      context,
//       initialDate:  init,
//       firstDate:    DateTime(2020),
//       lastDate:     DateTime(now.year + 1),
//       locale:       const Locale('ar'),
//       builder: (ctx, child) => Theme(
//         data: Theme.of(ctx).copyWith(
//           colorScheme: ColorScheme.fromSeed(
//             seedColor:  AppColors.darkRed,
//             brightness: isDark ? Brightness.dark : Brightness.light,
//           ),
//         ),
//         child: child!,
//       ),
//     );
//
//     if (picked == null || !mounted) return;
//
//     setState(() {
//       if (isFrom) {
//         _filterFromDate = picked;
//         if (_filterToDate != null && picked.isAfter(_filterToDate!)) {
//           _filterToDate = picked;
//         }
//       } else {
//         _filterToDate = picked;
//         if (_filterFromDate != null && picked.isBefore(_filterFromDate!)) {
//           _filterFromDate = picked;
//         }
//       }
//     });
//   }
//
//   // ══════════════════════════════════════════════════════════════════
//   // EXPORT SHEET
//   // ══════════════════════════════════════════════════════════════════
//   void _showExportSheet(bool isDark) {
//     final apptProv = Provider.of<AppointmentProvider>(context, listen: false);
//     final filtered  = _applyFilters(apptProv.appointments);
//
//     showModalBottomSheet(
//       context:            context,
//       isScrollControlled: true,
//       backgroundColor:    Colors.transparent,
//       builder: (_) => Directionality(
//         textDirection: ui.TextDirection.rtl,
//         child: Container(
//           padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
//           decoration: BoxDecoration(
//             color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//           ),
//           child: SafeArea(
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               Container(
//                 width: 40.w, height: 4.h,
//                 decoration: BoxDecoration(
//                   color:        Colors.grey.shade400,
//                   borderRadius: BorderRadius.circular(2.r),
//                 ),
//               ),
//               SizedBox(height: 16.h),
//
//               Row(children: [
//                 Container(
//                   padding: EdgeInsets.all(10.r),
//                   decoration: BoxDecoration(
//                     color:        AppColors.darkRed.withValues(alpha: 0.1),
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                   child: Icon(Icons.file_download_rounded,
//                       color: AppColors.darkRed, size: 22.sp),
//                 ),
//                 SizedBox(width: 12.w),
//                 Expanded(
//                   child: Column(crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('تصدير كشف الحجوزات',
//                             style: TextStyle(
//                               fontSize:   18.sp,
//                               fontWeight: FontWeight.bold,
//                               color: isDark ? Colors.white : AppColors.black,
//                               fontFamily: 'Cairo',
//                             )),
//                         Text(
//                             'سيتم تصدير ${filtered.length} حجز'
//                                 '${_filterFromDate != null || _filterToDate != null ? ' (مفلتر بالتاريخ)' : ''}',
//                             style: TextStyle(
//                               fontSize:   12.sp,
//                               color:      Colors.grey.shade500,
//                               fontFamily: 'Cairo',
//                             )),
//                       ]),
//                 ),
//               ]),
//               SizedBox(height: 16.h),
//
//               if (_filterFromDate != null || _filterToDate != null)
//                 Container(
//                   padding: EdgeInsets.all(12.r),
//                   margin: EdgeInsets.only(bottom: 16.h),
//                   decoration: BoxDecoration(
//                     color:  AppColors.darkRed.withValues(alpha: 0.07),
//                     borderRadius: BorderRadius.circular(12.r),
//                     border: Border.all(
//                         color: AppColors.darkRed.withValues(alpha: 0.2)),
//                   ),
//                   child: Row(children: [
//                     Icon(Icons.date_range_rounded,
//                         color: AppColors.darkRed, size: 16.sp),
//                     SizedBox(width: 8.w),
//                     Text(
//                         '${_filterFromDate != null ? DateFormat('d MMM yyyy', 'ar').format(_filterFromDate!) : 'البداية'}'
//                             '  ←  '
//                             '${_filterToDate != null ? DateFormat('d MMM yyyy', 'ar').format(_filterToDate!) : 'اليوم'}',
//                         style: TextStyle(
//                           fontSize:   12.sp,
//                           fontWeight: FontWeight.bold,
//                           color:      AppColors.darkRed,
//                           fontFamily: 'Cairo',
//                         )),
//                   ]),
//                 ),
//
//               _buildExportOption(
//                 icon:     Icons.table_chart_rounded,
//                 color:    Colors.green,
//                 title:    'تصدير CSV',
//                 subtitle: 'مناسب لـ Excel وجداول البيانات',
//                 isDark:   isDark,
//                 onTap: () {
//                   Navigator.pop(context);
//                   _exportAppointmentsCsv(filtered);
//                 },
//               ),
//               SizedBox(height: 10.h),
//               _buildExportOption(
//                 icon:     Icons.share_rounded,
//                 color:    Colors.blue,
//                 title:    'مشاركة ملخص نصي',
//                 subtitle: 'مشاركة الكشف عبر واتساب أو غيره',
//                 isDark:   isDark,
//                 onTap: () {
//                   Navigator.pop(context);
//                   _shareTextSummary(filtered);
//                 },
//               ),
//               SizedBox(height: 20.h),
//             ]),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildExportOption({
//     required IconData icon,
//     required Color    color,
//     required String   title,
//     required String   subtitle,
//     required bool     isDark,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(14.r),
//         decoration: BoxDecoration(
//           color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
//           borderRadius: BorderRadius.circular(14.r),
//           border: Border.all(
//               color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
//         ),
//         child: Row(children: [
//           Container(
//             padding: EdgeInsets.all(10.r),
//             decoration: BoxDecoration(
//               color:  color.withValues(alpha: 0.1),
//               shape:  BoxShape.circle,
//             ),
//             child: Icon(icon, color: color, size: 22.sp),
//           ),
//           SizedBox(width: 14.w),
//           Expanded(
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title,
//                       style: TextStyle(
//                         fontSize:   15.sp,
//                         fontWeight: FontWeight.bold,
//                         color: isDark ? Colors.white : AppColors.black,
//                         fontFamily: 'Cairo',
//                       )),
//                   Text(subtitle,
//                       style: TextStyle(
//                         fontSize:   12.sp,
//                         color:      Colors.grey.shade500,
//                         fontFamily: 'Cairo',
//                       )),
//                 ]),
//           ),
//           Icon(Icons.arrow_forward_ios_rounded,
//               size: 14.sp, color: Colors.grey.shade400),
//         ]),
//       ),
//     );
//   }
//
//   // ── تصدير CSV ────────────────────────────────────────────────────
//   Future<void> _exportAppointmentsCsv(List<AppointmentModel> appts) async {
//     if (!mounted) return;
//     setState(() => _isExporting = true);
//     try {
//       final buffer = StringBuffer();
//       buffer.writeln('رقم الحجز,الخدمة,التاريخ,الوقت,الحلاق,الحالة,المبلغ,طريقة الدفع');
//
//       for (final a in appts) {
//         final id      = a.id ?? '';
//         final service = (a.services?.isNotEmpty == true
//             ? (a.services!.first.serviceNameAr ?? 'خدمة')
//             : 'خدمة')
//             .replaceAll(',', '،');
//         final date    = DateFormat('yyyy-MM-dd').format(a.appointmentDate);
//         final time    = _formatTime(a.appointmentTime);
//         final emp     = (a.employeeName ?? 'تلقائي').replaceAll(',', '،');
//         final status  = _getStatusText(a.status);
//         final price   = a.totalPrice.toStringAsFixed(2);
//         final payment = a.paymentMethod == 'cash'
//             ? 'نقدي'
//             : a.paymentMethod == 'electronic'
//             ? 'إلكتروني'
//             : (a.paymentMethod ?? '');
//         buffer.writeln('"$id","$service","$date","$time","$emp","$status","$price","$payment"');
//       }
//
//       final total = appts.fold(0.0, (s, a) => s + a.totalPrice);
//       buffer.writeln('');
//       buffer.writeln('"الإجمالي","","","","","","${total.toStringAsFixed(2)}",""');
//
//       final dir      = await getTemporaryDirectory();
//       final dateStr  = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
//       final filePath = '${dir.path}/appointments_$dateStr.csv';
//       final file     = File(filePath);
//       await file.writeAsString('\uFEFF${buffer.toString()}',
//           encoding: const Utf8Codec());
//
//       if (mounted) {
//         await Share.shareXFiles(
//           [XFile(filePath, mimeType: 'text/csv')],
//           subject: 'كشف حجوزات - Millionaire Barber',
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content: Text('خطأ في التصدير: $e',
//               style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp)),
//           backgroundColor: Colors.red,
//           behavior:        SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10.r)),
//         ));
//       }
//     } finally {
//       if (mounted) setState(() => _isExporting = false);
//     }
//   }
//
//   // ── مشاركة ملخص نصي ──────────────────────────────────────────────
//   Future<void> _shareTextSummary(List<AppointmentModel> appts) async {
//     if (appts.isEmpty) return;
//
//     final total     = appts.fold(0.0, (s, a) => s + a.totalPrice);
//     final completed = appts.where((a) => a.status == 'completed').length;
//     final dateRange = (_filterFromDate != null || _filterToDate != null)
//         ? '\n📅 الفترة: ${_filterFromDate != null ? DateFormat('d MMM yyyy', 'ar').format(_filterFromDate!) : 'البداية'}'
//         ' → ${_filterToDate != null ? DateFormat('d MMM yyyy', 'ar').format(_filterToDate!) : 'اليوم'}'
//         : '';
//
//     final buffer = StringBuffer();
//     buffer.writeln('💈 كشف حجوزات - Millionaire Barber');
//     buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
//     buffer.writeln('📊 إجمالي الحجوزات: ${appts.length}$dateRange');
//     buffer.writeln('✅ المكتملة: $completed');
//     buffer.writeln('💰 الإجمالي المدفوع: ${total.toStringAsFixed(0)} ريال');
//     buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
//     buffer.writeln('');
//
//     final preview = appts.take(10).toList();
//     for (final a in preview) {
//       final svc  = a.services?.isNotEmpty == true
//           ? (a.services!.first.serviceNameAr ?? 'خدمة') : 'خدمة';
//       final date = DateFormat('d MMM', 'ar').format(a.appointmentDate);
//       final icon = a.status == 'completed'
//           ? '✅' : a.status == 'cancelled' ? '❌' : '⏳';
//       buffer.writeln('$icon $svc | $date | ${a.totalPrice.toStringAsFixed(0)} ر');
//     }
//     if (appts.length > 10) {
//       buffer.writeln('... و${appts.length - 10} حجز آخر');
//     }
//
//     await Share.share(buffer.toString(),
//         subject: 'كشف حجوزاتي - Millionaire Barber');
//   }
//
//   // ══════════════════════════════════════════════════════════════════
//   // CANCEL / REVIEW
//   // ══════════════════════════════════════════════════════════════════
//   Future<void> _navigateToReview(AppointmentModel appt) async {
//     final rev      = Provider.of<ReviewProvider>(context, listen: false);
//     final existing = await rev.checkAppointmentReview(appt.id!);
//     if (existing != null) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content:         const Text('لقد قمت بتقييم هذه الخدمة مسبقاً'),
//         backgroundColor: Colors.orange,
//         behavior:        SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
//       ));
//       return;
//     }
//     final result = await Navigator.push(context,
//         MaterialPageRoute(builder: (_) => AddReviewScreen(appointment: appt)));
//     if (result == true && mounted) {
//       final user = Provider.of<UserProvider>(context, listen: false);
//       await Provider.of<AppointmentProvider>(context, listen: false)
//           .fetchUserAppointments(user.user!.id!);
//     }
//   }
//
//   Future<void> _cancelAppointment(AppointmentModel appt) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (_) => Directionality(
//         textDirection: ui.TextDirection.rtl,
//         child: AlertDialog(
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20.r)),
//           backgroundColor:
//           Theme.of(context).brightness == Brightness.dark
//               ? const Color(0xFF1E1E1E) : Colors.white,
//           title: Row(children: [
//             Icon(Icons.warning_amber_rounded,
//                 color: AppColors.error, size: 26.sp)
//                 .animate(onPlay: (c) => c.repeat())
//                 .shake(duration: 500.ms, hz: 4)
//                 .then(delay: 500.ms),
//             SizedBox(width: 10.w),
//             const Text('إلغاء الموعد'),
//           ]),
//           content: Text(
//             'هل أنت متأكد من إلغاء هذا الموعد؟\n'
//                 'لن يتم إضافة نقاط الولاء المعلقة.',
//             style: TextStyle(fontSize: 14.sp, height: 1.5),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: Text('لا',
//                   style: TextStyle(
//                       color: Colors.grey.shade600, fontSize: 15.sp)),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context, true),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.error,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.r)),
//               ),
//               child: Text('نعم، إلغاء', style: TextStyle(fontSize: 15.sp)),
//             ),
//           ],
//         ),
//       ),
//     );
//
//     if (confirmed != true || !mounted) return;
//
//     final apptProv  = Provider.of<AppointmentProvider>(context, listen: false);
//     final notifProv = Provider.of<NotificationProvider>(context, listen: false);
//     final userProv  = Provider.of<UserProvider>(context, listen: false);
//
//     showDialog(
//       context:            context,
//       barrierDismissible: false,
//       builder: (_) => Center(
//         child: Material(
//           color: Colors.transparent,
//           child: Container(
//             width:   180.w,
//             padding: EdgeInsets.all(24.r),
//             decoration: BoxDecoration(
//               color: Theme.of(context).brightness == Brightness.dark
//                   ? const Color(0xFF262626) : Colors.white,
//               borderRadius: BorderRadius.circular(20.r),
//               boxShadow: [
//                 BoxShadow(
//                   color:      Colors.black.withValues(alpha: 0.1),
//                   blurRadius: 12,
//                 ),
//               ],
//             ),
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               Container(
//                 width:  50.w,
//                 height: 50.h,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: AppColors.darkRed.withValues(alpha: 0.1),
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.all(10.w),
//                   child: const CircularProgressIndicator(
//                     strokeWidth: 3,
//                     valueColor: AlwaysStoppedAnimation(AppColors.darkRed),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16.h),
//               Text('جارٍ الإلغاء...',
//                   style: TextStyle(
//                     fontSize:   15.sp,
//                     fontWeight: FontWeight.w600,
//                   )),
//             ]),
//           )
//               .animate()
//               .fadeIn(duration: 300.ms)
//               .scale(
//               begin: const Offset(0.9, 0.9),
//               end:   const Offset(1, 1)),
//         ),
//       ),
//     );
//
//     try {
//       final ok = await apptProv.cancelAppointment(appt.id!);
//       if (mounted) Navigator.pop(context);
//       if (ok && mounted) {
//         await notifProv.createCancellationNotification(
//           userId:        userProv.user!.id!,
//           appointmentId: appt.id!,
//           serviceName: appt.services?.isNotEmpty == true
//               ? (appt.services!.first.serviceNameAr ??
//               appt.services!.first.serviceName ?? 'الخدمة')
//               : 'الخدمة',
//         );
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content:         const Text('✅ تم إلغاء الموعد بنجاح'),
//           backgroundColor: Colors.orange,
//           behavior:        SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10.r)),
//         ));
//         await apptProv.fetchUserAppointments(userProv.user!.id!);
//       } else if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content:         const Text('❌ فشل إلغاء الموعد'),
//           backgroundColor: Colors.red,
//           behavior:        SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10.r)),
//         ));
//       }
//     } catch (e) {
//       if (mounted) {
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//           content:         Text('❌ خطأ: $e'),
//           backgroundColor: Colors.red,
//           behavior:        SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10.r)),
//         ));
//       }
//     }
//   }
//
//   // ══════════════════════════════════════════════════════════════════
//   // STATUS HELPERS
//   // ══════════════════════════════════════════════════════════════════
//   Color _getStatusColor(String s) {
//     switch (s) {
//       case 'pending':     return Colors.orange;
//       case 'confirmed':   return Colors.blue;
//       case 'in_progress': return Colors.purple;
//       case 'completed':   return Colors.green;
//       case 'cancelled':   return Colors.red;
//       case 'no_show':     return Colors.grey;
//       default:            return Colors.grey;
//     }
//   }
//
//   IconData _getStatusIcon(String s) {
//     switch (s) {
//       case 'pending':     return Icons.hourglass_empty_rounded;
//       case 'confirmed':   return Icons.check_circle_outline_rounded;
//       case 'in_progress': return Icons.pending_rounded;
//       case 'completed':   return Icons.check_circle_rounded;
//       case 'cancelled':   return Icons.cancel_rounded;
//       case 'no_show':     return Icons.event_busy_rounded;
//       default:            return Icons.help_outline_rounded;
//     }
//   }
//
//   String _getStatusText(String s) {
//     switch (s) {
//       case 'pending':     return 'قيد الانتظار';
//       case 'confirmed':   return 'مؤكد';
//       case 'in_progress': return 'جارٍ التنفيذ';
//       case 'completed':   return 'مكتمل';
//       case 'cancelled':   return 'ملغى';
//       case 'no_show':     return 'لم يحضر';
//       default:            return s;
//     }
//   }
// }



import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:millionaire_barber/core/constants/app_colors.dart';
import 'package:millionaire_barber/features/appointments/domain/models/appointment_model.dart';
import 'package:millionaire_barber/features/appointments/presentation/pages/appointment_details_screen.dart';
import 'package:millionaire_barber/features/appointments/presentation/providers/appointment_provider.dart';
import 'package:millionaire_barber/features/notifications/presentation/providers/notification_provider.dart';
import 'package:millionaire_barber/features/profile/presentation/providers/user_provider.dart';
import 'package:millionaire_barber/features/reviews/presentation/providers/review_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import '../../../reviews/presentation/pages/add_review_screen.dart';

// ── ثوابت الألوان ─────────────────────────────────────────────────
const _kGold     = Color(0xFFB8860B);
const _kGoldDark = Color(0xFF8B6914);

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading   = false;
  bool _isSearching = false;
  bool _isExporting = false;
  String _searchQuery = '';
  String _sortBy      = 'date';

  // ── فلتر النوع ────────────────────────────────────────────────────
  String _typeFilter = 'all'; // 'all' | 'single' | 'group'

  // ── فلتر نطاق التاريخ ─────────────────────────────────────────────
  DateTime? _filterFromDate;
  DateTime? _filterToDate;

  // ── فحص وجود فلتر نشط ────────────────────────────────────────────
  bool get _hasActiveFilter =>
      _filterFromDate != null ||
          _filterToDate   != null ||
          _typeFilter     != 'all' ||
          _sortBy         != 'date' ||
          _searchQuery.isNotEmpty;

  // ══════════════════════════════════════════════════════════════════
  // INIT / DISPOSE
  // ══════════════════════════════════════════════════════════════════
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAppointments());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user?.id == null) return;
    setState(() => _isLoading = true);
    final apptProv = Provider.of<AppointmentProvider>(context, listen: false);
    await apptProv.fetchUserAppointments(userProvider.user!.id!);
    if (mounted) setState(() => _isLoading = false);
  }

  // ── تنسيق الوقت ──────────────────────────────────────────────────
  String _formatTime(String time) {
    try {
      final parts  = time.split(':');
      final hour   = int.parse(parts[0]);
      final minute = parts.length > 1 ? parts[1] : '00';
      if (hour == 0)  return '12:$minute ص';
      if (hour < 12)  return '$hour:$minute ص';
      if (hour == 12) return '12:$minute م';
      return '${hour - 12}:$minute م';
    } catch (_) { return time; }
  }

  // ══════════════════════════════════════════════════════════════════
  // FILTER LOGIC
  // ══════════════════════════════════════════════════════════════════
  List<AppointmentModel> _applyFilters(List<AppointmentModel> list) {
    var result = list;

    // 1. فلتر النوع
    if (_typeFilter == 'group') {
      result = result.where((a) => _isGroup(a)).toList();
    } else if (_typeFilter == 'single') {
      result = result.where((a) => !_isGroup(a)).toList();
    }

    // 2. فلتر نطاق التاريخ
    if (_filterFromDate != null) {
      result = result.where((a) =>
      !a.appointmentDate.isBefore(
        DateTime(_filterFromDate!.year, _filterFromDate!.month, _filterFromDate!.day),
      ),
      ).toList();
    }
    if (_filterToDate != null) {
      result = result.where((a) =>
      !a.appointmentDate.isAfter(
        DateTime(_filterToDate!.year, _filterToDate!.month, _filterToDate!.day, 23, 59, 59),
      ),
      ).toList();
    }

    // 3. فلتر البحث
    if (_searchQuery.isNotEmpty) {
      result = result.where((a) {
        final svc  = (a.services?.isNotEmpty == true
            ? a.services!.first.serviceNameAr : '') ?? '';
        final date = DateFormat('d MMMM yyyy', 'ar').format(a.appointmentDate);
        final id   = a.id?.toString() ?? '';
        final emp  = a.employeeName ?? '';
        return svc.toLowerCase().contains(_searchQuery) ||
            date.toLowerCase().contains(_searchQuery)   ||
            id.contains(_searchQuery)                   ||
            emp.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    // 4. ترتيب
    if (_sortBy == 'date') {
      result.sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));
    } else {
      result.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
    }
    return result;
  }

  bool _isGroup(AppointmentModel a) => a.personsCount > 1;

  void _resetAllFilters() {
    setState(() {
      _filterFromDate = null;
      _filterToDate   = null;
      _typeFilter     = 'all';
      _sortBy         = 'date';
      _searchQuery    = '';
      _searchController.clear();
      _isSearching    = false;
    });
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
        backgroundColor:
        isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        body: NestedScrollView(
          headerSliverBuilder: (_, innerScrolled) =>
          [_buildAppBar(isDark, innerScrolled)],
          body: Column(children: [
            _buildSearchBar(isDark),
            _buildFilterRow(isDark),
            _buildTabBar(isDark),
            Expanded(
              child: _isLoading
                  ? _buildShimmerLoading(isDark)
                  : TabBarView(
                controller: _tabController,
                children: [
                  _buildTab(isDark, ['pending', 'confirmed', 'in_progress']),
                  _buildTab(isDark, ['completed']),
                  _buildTab(isDark, ['cancelled', 'no_show']),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // APP BAR
  // ══════════════════════════════════════════════════════════════════
  Widget _buildAppBar(bool isDark, bool innerScrolled) {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: false,
      pinned:   true,
      elevation: 0,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      leading: IconButton(
        icon: Container(
          padding:    EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color:        AppColors.darkRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.arrow_back_ios,
              size: 18.sp, color: AppColors.darkRed),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        // ── زر إعادة تعيين الفلاتر (يظهر فقط عند وجود فلتر نشط) ──
        if (_hasActiveFilter)
          IconButton(
            tooltip: 'إعادة تعيين الفلاتر',
            icon: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(Icons.filter_alt_off_rounded,
                  size: 18.sp, color: Colors.orange),
            ),
            onPressed: _resetAllFilters,
          ),

        // ── زر التصدير ────────────────────────────────────────────
        IconButton(
          tooltip: 'تصدير كشف الحجوزات',
          icon: _isExporting
              ? SizedBox(
            width: 20.w, height: 20.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.darkRed,
            ),
          )
              : Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.darkRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.file_download_rounded,
                size: 20.sp, color: AppColors.darkRed),
          ),
          onPressed: _isExporting ? null : () => _showExportSheet(isDark),
        ),

        // ── زر البحث ──────────────────────────────────────────────
        IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: _isSearching
                  ? AppColors.darkRed.withValues(alpha: 0.2)
                  : AppColors.darkRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              _isSearching ? Icons.search_off_rounded : Icons.search_rounded,
              size: 20.sp,
              color: AppColors.darkRed,
            ),
          ),
          onPressed: () => setState(() {
            _isSearching = !_isSearching;
            if (!_isSearching) {
              _searchController.clear();
              _searchQuery = '';
            }
          }),
        ),
        SizedBox(width: 8.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(right: 16.w, bottom: 16.h),
        title: AnimatedOpacity(
          opacity:  innerScrolled ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Text('حجوزاتي',
              style: TextStyle(
                fontSize:   20.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.black,
              )),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end:   Alignment.bottomLeft,
              colors: isDark
                  ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                  : [Colors.white, Colors.grey.shade50],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:  MainAxisAlignment.end,
                children: [
                  Text('مواعيدي',
                      style: TextStyle(
                        fontSize:   32.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.black,
                      ))
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideX(begin: -0.2),
                  SizedBox(height: 4.h),
                  Text('إدارة مواعيدك بسهولة',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                      ))
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideX(begin: -0.2),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // SEARCH BAR
  // ══════════════════════════════════════════════════════════════════
  Widget _buildSearchBar(bool isDark) {
    if (!_isSearching) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        decoration: InputDecoration(
          hintText:   'ابحث عن موعد...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.darkRed),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear_rounded, color: Colors.grey.shade500),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          )
              : null,
          filled:    true,
          fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.darkRed, width: 2),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.3);
  }

  // ══════════════════════════════════════════════════════════════════
  // FILTER ROW
  // ══════════════════════════════════════════════════════════════════
  Widget _buildFilterRow(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── الصف الأول: الترتيب + النوع ──────────────────────────
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: Wrap(
            spacing:    6.w,
            runSpacing: 6.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _filterLabel('ترتيب:', isDark),
              _chip('التاريخ', 'date',  Icons.calendar_today_rounded, isDark),
              _chip('السعر',   'price', Icons.attach_money_rounded,   isDark),
              _divider(isDark),
              _filterLabel('النوع:', isDark),
              _typeChip('الكل',  'all',    null,                 isDark),
              _typeChip('فردي',  'single', Icons.person_rounded,  isDark),
              _typeChip('جماعي', 'group',  Icons.people_rounded,  isDark),
            ],
          ),
        ),

        // ── الصف الثاني: فلتر نطاق التاريخ ──────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 4.h),
          child: Row(
            children: [
              Icon(Icons.date_range_rounded,
                  size: 14.sp, color: AppColors.darkRed),
              SizedBox(width: 6.w),
              _filterLabel('الفترة:', isDark),
              SizedBox(width: 6.w),

              Expanded(
                child: _buildDateButton(
                  label: _filterFromDate != null
                      ? DateFormat('d MMM', 'ar').format(_filterFromDate!)
                      : 'من تاريخ',
                  isActive: _filterFromDate != null,
                  isDark:   isDark,
                  onTap: () => _pickDate(isFrom: true, isDark: isDark),
                ),
              ),

              SizedBox(width: 8.w),
              Icon(Icons.arrow_left_rounded,
                  color: Colors.grey.shade400, size: 20.sp),
              SizedBox(width: 8.w),

              Expanded(
                child: _buildDateButton(
                  label: _filterToDate != null
                      ? DateFormat('d MMM', 'ar').format(_filterToDate!)
                      : 'إلى تاريخ',
                  isActive: _filterToDate != null,
                  isDark:   isDark,
                  onTap: () => _pickDate(isFrom: false, isDark: isDark),
                ),
              ),

              if (_filterFromDate != null || _filterToDate != null) ...[
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => setState(() {
                    _filterFromDate = null;
                    _filterToDate   = null;
                  }),
                  child: Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded,
                        size: 14.sp, color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── الصف الثالث: إحصائيات سريعة ─────────────────────────
        _buildStatsRow(isDark),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildDateButton({
    required String label,
    required bool   isActive,
    required bool   isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.darkRed.withValues(alpha: 0.1)
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isActive
                ? AppColors.darkRed
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_rounded,
                size:  12.sp,
                color: isActive ? AppColors.darkRed : Colors.grey.shade500),
            SizedBox(width: 5.w),
            Text(label,
                style: TextStyle(
                  fontSize:   11.sp,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? AppColors.darkRed
                      : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                )),
          ],
        ),
      ),
    );
  }

  Widget _filterLabel(String text, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: Text(text,
          style: TextStyle(
            fontSize: 11.sp,
            color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
          )),
    );
  }

  Widget _divider(bool isDark) {
    return Container(
      width:  1,
      height: 18.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      color:  isDark ? Colors.grey.shade700 : Colors.grey.shade300,
    );
  }

  Widget _chip(String label, String value, IconData icon, bool isDark) {
    final selected = _sortBy == value;
    return InkWell(
      onTap: () => setState(() => _sortBy = value),
      borderRadius: BorderRadius.circular(20.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.darkRed
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected
                ? AppColors.darkRed
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon,
              size:  11.sp,
              color: selected ? Colors.white : AppColors.darkRed),
          SizedBox(width: 3.w),
          Text(label,
              style: TextStyle(
                fontSize:   11.sp,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.grey.shade300 : AppColors.black),
              )),
        ]),
      ),
    );
  }

  Widget _typeChip(String label, String value, IconData? icon, bool isDark) {
    final selected = _typeFilter == value;
    return InkWell(
      onTap: () => setState(() => _typeFilter = value),
      borderRadius: BorderRadius.circular(20.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: selected
              ? _kGold
              : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected
                ? _kGold
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[
            Icon(icon,
                size:  11.sp,
                color: selected ? Colors.white : _kGold),
            SizedBox(width: 3.w),
          ],
          Text(label,
              style: TextStyle(
                fontSize:   11.sp,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.grey.shade300 : AppColors.black),
              )),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // STATS ROW
  // ══════════════════════════════════════════════════════════════════
  Widget _buildStatsRow(bool isDark) {
    return Consumer<AppointmentProvider>(
      builder: (_, prov, __) {
        final all       = _applyFilters(prov.appointments);
        final completed = all.where((a) => a.status == 'completed').length;
        final pending   = all.where((a) =>
            ['pending', 'confirmed', 'in_progress'].contains(a.status)).length;
        final totalSpent = all
            .where((a) => a.status == 'completed')
            .fold(0.0, (s, a) => s + a.totalPrice);

        if (all.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                  : [Colors.white, Colors.grey.shade50],
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('الكل',     '${all.length}',
                  AppColors.darkRed,  Icons.calendar_month_rounded, isDark),
              _buildStatDivider(isDark),
              _buildStatItem('قادمة',    '$pending',
                  Colors.orange,      Icons.upcoming_rounded,        isDark),
              _buildStatDivider(isDark),
              _buildStatItem('مكتملة',   '$completed',
                  Colors.green,       Icons.check_circle_rounded,    isDark),
              _buildStatDivider(isDark),
              _buildStatItem('الإجمالي', '${totalSpent.toStringAsFixed(0)}',
                  _kGold,             Icons.wallet_rounded,           isDark),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms);
      },
    );
  }

  Widget _buildStatItem(
      String label, String value, Color color, IconData icon, bool isDark) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 16.sp, color: color),
      SizedBox(height: 3.h),
      Text(value,
          style: TextStyle(
            fontSize:   14.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.black,
            fontFamily: 'Cairo',
          )),
      Text(label,
          style: TextStyle(
            fontSize: 10.sp,
            color:    Colors.grey.shade500,
            fontFamily: 'Cairo',
          )),
    ]);
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      width: 1, height: 30.h,
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // TAB BAR
  // ══════════════════════════════════════════════════════════════════
  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color:        isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller:           _tabController,
        indicator: BoxDecoration(
          color:        AppColors.darkRed,
          borderRadius: BorderRadius.circular(12.r),
        ),
        indicatorSize:        TabBarIndicatorSize.tab,
        dividerColor:         Colors.transparent,
        labelColor:           Colors.white,
        unselectedLabelColor: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        labelStyle: TextStyle(
            fontSize: 14.sp, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
        padding: EdgeInsets.all(4.r),
        tabs: const [
          Tab(text: 'القادمة'),
          Tab(text: 'المكتملة'),
          Tab(text: 'الملغاة'),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.2);
  }

  // ══════════════════════════════════════════════════════════════════
  // TAB CONTENT
  // ══════════════════════════════════════════════════════════════════
  Widget _buildTab(bool isDark, List<String> statuses) {
    return Consumer<AppointmentProvider>(
      builder: (_, prov, __) {
        final list = _applyFilters(
          prov.appointments.where((a) => statuses.contains(a.status)).toList(),
        );

        if (list.isEmpty) {
          final isUpcoming  = statuses.contains('pending');
          final isCompleted = statuses.contains('completed');
          return _buildEmptyState(
            icon: isUpcoming
                ? Icons.calendar_today_rounded
                : isCompleted
                ? Icons.check_circle_outline_rounded
                : Icons.cancel_outlined,
            title: _searchQuery.isNotEmpty
                ? 'لا توجد نتائج'
                : _hasActiveFilter
                ? 'لا توجد نتائج للفلتر المحدد'
                : isUpcoming
                ? 'لا توجد حجوزات قادمة'
                : isCompleted
                ? 'لا توجد حجوزات مكتملة'
                : 'لا توجد حجوزات ملغاة',
            subtitle: _searchQuery.isNotEmpty || _hasActiveFilter
                ? 'جرّب تغيير الفلاتر أو نطاق التاريخ'
                : isUpcoming
                ? 'احجز موعداً جديداً الآن'
                : isCompleted
                ? 'سيظهر هنا سجل حجوزاتك المكتملة'
                : 'لم تقم بإلغاء أي حجز بعد',
            isDark:    isDark,
            iconColor: isUpcoming
                ? Colors.orange
                : isCompleted
                ? Colors.green
                : Colors.red,
          );
        }

        return RefreshIndicator(
          onRefresh: _loadAppointments,
          color:     AppColors.darkRed,
          child: ListView.builder(
            padding:   EdgeInsets.all(16.r),
            itemCount: list.length,
            itemBuilder: (_, i) => _buildAppointmentCard(list[i], isDark, i),
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // APPOINTMENT CARD
  // ══════════════════════════════════════════════════════════════════
  Widget _buildAppointmentCard(
      AppointmentModel appt, bool isDark, int index) {
    final canCancel  = appt.canBeCancelled;
    final canReview  = appt.canBeReviewed;
    final isGroup    = _isGroup(appt);
    final persons    = appt.personsCount ?? 1;
    final hasReceipt = appt.hasReceipt;
    final isPaidElec = appt.isElectronicPayment;

    return Slidable(
      key:     ValueKey(appt.id),
      enabled: canCancel,
      endActionPane: canCancel
          ? ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed:       (_) => _cancelAppointment(appt),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon:            Icons.cancel_rounded,
            label:           'إلغاء',
            borderRadius:    BorderRadius.circular(16.r),
          ),
        ],
      )
          : null,
      child: GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => AppointmentDetailsScreen(appointment: appt))),
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color:        isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isGroup
                  ? _kGold.withValues(alpha: 0.4)
                  : _getStatusColor(appt.status).withValues(alpha: 0.3),
              width: isGroup ? 1.8 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isGroup
                    ? _kGold.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset:     const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: [
            // ── شريط علوي للحجز الجماعي ──────────────────────────
            if (isGroup)
              Container(
                width:  double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_kGold, _kGoldDark]),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(14.r),
                    topLeft:  Radius.circular(14.r),
                  ),
                ),
                child: Row(children: [
                  Icon(Icons.people_rounded, color: Colors.white, size: 14.sp),
                  SizedBox(width: 6.w),
                  Text(
                    'حجز جماعي — $persons أشخاص',
                    style: TextStyle(
                      color:      Colors.white,
                      fontSize:   12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color:        Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '${appt.totalPrice.toStringAsFixed(0)} ريال',
                      style: TextStyle(
                        color:      Colors.white,
                        fontSize:   11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]),
              ),

            // ── المحتوى الرئيسي ───────────────────────────────────
            Padding(
              padding: EdgeInsets.all(14.r),
              child: Column(children: [

                // ── الصف الأول: أيقونة + معلومات + الحالة ────────
                Row(children: [
                  Container(
                    width:  54.w,
                    height: 54.h,
                    decoration: BoxDecoration(
                      color: _getStatusColor(appt.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      _getStatusIcon(appt.status),
                      color: _getStatusColor(appt.status),
                      size:  26.sp,
                    )
                        .animate(onPlay: (c) => c.repeat())
                        .then(delay: 2000.ms)
                        .shimmer(
                      duration: 1500.ms,
                      color: _getStatusColor(appt.status)
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(
                              _getServiceTitle(appt),
                              style: TextStyle(
                                fontSize:   15.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.black,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          _buildStatusBadge(appt.status, isDark),
                        ]),
                        SizedBox(height: 5.h),
                        Row(children: [
                          Icon(Icons.calendar_today,
                              size: 13.sp, color: Colors.grey.shade500),
                          SizedBox(width: 3.w),
                          Text(
                            DateFormat('d MMMM yyyy', 'ar')
                                .format(appt.appointmentDate),
                            style: TextStyle(
                                fontSize: 12.sp, color: Colors.grey.shade500),
                          ),
                          SizedBox(width: 10.w),
                          Icon(Icons.access_time,
                              size: 13.sp, color: Colors.grey.shade500),
                          SizedBox(width: 3.w),
                          Text(
                            _formatTime(appt.appointmentTime),
                            style: TextStyle(
                                fontSize: 12.sp, color: Colors.grey.shade500),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ]),

                // ── صف الأشخاص (للحجز الجماعي فقط) ─────────────
                if (isGroup &&
                    appt.persons != null &&
                    appt.persons!.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  _buildPersonsRow(appt, isDark),
                ],

                Divider(height: 18.h),

                // ── الصف السفلي: الحلاق + السعر + الإيصال ────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      CircleAvatar(
                        radius: 14.r,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: appt.employeeImageUrl?.isNotEmpty == true
                            ? NetworkImage(appt.employeeImageUrl!)
                            : null,
                        child: appt.employeeImageUrl?.isEmpty != false
                            ? Icon(Icons.person, size: 14.sp)
                            : null,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        appt.employeeName ?? 'تلقائي',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark
                              ? Colors.grey.shade300
                              : AppColors.greyDark,
                        ),
                      ),
                    ]),

                    Row(children: [
                      if (isPaidElec)
                        Container(
                          margin: EdgeInsets.only(left: 6.w),
                          padding: EdgeInsets.symmetric(
                              horizontal: 7.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: hasReceipt
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: hasReceipt
                                  ? Colors.green.withValues(alpha: 0.4)
                                  : Colors.orange.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(
                              hasReceipt
                                  ? Icons.receipt_long_rounded
                                  : Icons.pending_rounded,
                              size:  11.sp,
                              color: hasReceipt ? Colors.green : Colors.orange,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              hasReceipt ? 'إيصال' : 'انتظار',
                              style: TextStyle(
                                fontSize:   10.sp,
                                color: hasReceipt ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]),
                        ),

                      if (!isGroup)
                        Text(
                          '${appt.totalPrice.toStringAsFixed(0)} ريال',
                          style: TextStyle(
                            fontSize:   15.sp,
                            fontWeight: FontWeight.bold,
                            color:      _kGold,
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat())
                            .then(delay: 3000.ms)
                            .shimmer(duration: 1000.ms, color: _kGoldDark),
                    ]),
                  ],
                ),

                // ── معاينة الإيصال ────────────────────────────────
                if (hasReceipt) ...[
                  SizedBox(height: 10.h),
                  _buildReceiptPreview(appt.paymentReceiptUrl!, isDark),
                ],

                // ── أزرار الإجراءات ───────────────────────────────
                if (canCancel || canReview) ...[
                  SizedBox(height: 10.h),
                  if (canCancel)
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _cancelAppointment(appt),
                          icon: Icon(Icons.close_rounded,
                              size: 16.sp, color: AppColors.error),
                          label: Text('إلغاء',
                              style: TextStyle(
                                color:      AppColors.error,
                                fontWeight: FontWeight.bold,
                                fontSize:   13.sp,
                              )),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r)),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AppointmentDetailsScreen(
                                      appointment: appt))),
                          icon: Icon(Icons.info_outline_rounded,
                              size: 16.sp, color: Colors.white),
                          label: Text('التفاصيل',
                              style: TextStyle(
                                color:      Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize:   13.sp,
                              )),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.darkRed,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r)),
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                          ),
                        ),
                      ),
                    ]),
                  if (canReview)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToReview(appt),
                        icon: Icon(Icons.star_rounded,
                            size: 16.sp, color: Colors.white)
                            .animate(onPlay: (c) => c.repeat())
                            .then(delay: 1000.ms)
                            .rotate(duration: 500.ms, begin: 0, end: 0.1)
                            .then()
                            .rotate(duration: 500.ms, begin: 0.1, end: 0),
                        label: Text('قيّم الخدمة',
                            style: TextStyle(
                              color:      Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize:   13.sp,
                            )),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kGold,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r)),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                ],
              ]),
            ),
          ]),
        )
            .animate(delay: Duration(milliseconds: 80 * index))
            .fadeIn()
            .slideY(begin: 0.15),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // HELPERS — CARD
  // ══════════════════════════════════════════════════════════════════
  String _getServiceTitle(AppointmentModel appt) {
    if (_isGroup(appt)) {
      final count = appt.personsCount ?? 1;
      return 'حجز جماعي ($count أشخاص)';
    }
    return appt.services?.isNotEmpty == true
        ? (appt.services!.first.serviceNameAr ?? 'خدمة')
        : 'خدمة';
  }

  Widget _buildReceiptPreview(String url, bool isDark) {
    return GestureDetector(
      onTap: () => _showReceiptFullScreen(url),
      child: Container(
        height:     70.h,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF262626) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topRight:    Radius.circular(9.r),
              bottomRight: Radius.circular(9.r),
            ),
            child: CachedNetworkImage(
              imageUrl:    url,
              width:       70.w,
              height:      70.h,
              fit:         BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Colors.grey.shade200,
                child: Icon(Icons.image_outlined,
                    color: Colors.grey, size: 24.sp),
              ),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey.shade200,
                child: Icon(Icons.broken_image_outlined,
                    color: Colors.grey, size: 24.sp),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              mainAxisAlignment:  MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.receipt_long_rounded,
                      size: 14.sp, color: Colors.green),
                  SizedBox(width: 5.w),
                  Text('إيصال الدفع',
                      style: TextStyle(
                        fontSize:   12.sp,
                        fontWeight: FontWeight.bold,
                        color:      Colors.green,
                      )),
                ]),
                SizedBox(height: 3.h),
                Text('اضغط للعرض الكامل',
                    style: TextStyle(
                        fontSize: 11.sp, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 14.sp, color: Colors.grey.shade400),
          SizedBox(width: 10.w),
        ]),
      ),
    );
  }

  void _showReceiptFullScreen(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding:    EdgeInsets.all(16.r),
        child: Stack(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: CachedNetworkImage(imageUrl: url),
          ),
          Positioned(
            top:  8.h,
            left: 8.w,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding:    EdgeInsets.all(8.r),
                decoration: const BoxDecoration(
                    color: Colors.black54, shape: BoxShape.circle),
                child: Icon(Icons.close_rounded,
                    color: Colors.white, size: 20.sp),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildPersonsRow(AppointmentModel appt, bool isDark) {
    final persons = appt.persons ?? [];
    return Container(
      padding:    EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color:        _kGold.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10.r),
        border:       Border.all(color: _kGold.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.group_rounded, size: 13.sp, color: _kGold),
            SizedBox(width: 5.w),
            Text('الأشخاص والخدمات',
                style: TextStyle(
                  fontSize:   12.sp,
                  fontWeight: FontWeight.bold,
                  color:      _kGold,
                )),
          ]),
          SizedBox(height: 6.h),
          ...persons.asMap().entries.map((e) {
            final i    = e.key;
            final p    = e.value;
            final name = p.personName.isNotEmpty ? p.personName : 'شخص ${i + 1}';
            final relatedSvc = appt.services
                ?.where((s) => s.personId == p.id)
                .map((s) => s.getDisplayName())
                .join(', ') ??
                '';
            return Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Row(children: [
                Container(
                  width:  20.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: _kGold.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('${i + 1}',
                        style: TextStyle(
                          fontSize:   10.sp,
                          fontWeight: FontWeight.bold,
                          color:      _kGold,
                        )),
                  ),
                ),
                SizedBox(width: 6.w),
                Text(name,
                    style: TextStyle(
                      fontSize:   12.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.black,
                    )),
                if (relatedSvc.isNotEmpty) ...[
                  Text(' — ',
                      style: TextStyle(
                          fontSize: 11.sp, color: Colors.grey.shade500)),
                  Expanded(
                    child: Text(relatedSvc,
                        style: TextStyle(
                            fontSize: 11.sp, color: Colors.grey.shade500),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ]),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color:        _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
            color: _getStatusColor(status).withValues(alpha: 0.3)),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          fontSize:   10.sp,
          fontWeight: FontWeight.bold,
          color:      _getStatusColor(status),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .then(delay: 2000.ms)
        .shimmer(
      duration: 1000.ms,
      color: _getStatusColor(status).withValues(alpha: 0.3),
    );
  }

  Widget _buildShimmerLoading(bool isDark) {
    return ListView.builder(
      padding:   EdgeInsets.all(16.r),
      itemCount: 5,
      itemBuilder: (_, i) => Shimmer.fromColors(
        baseColor:      isDark ? Colors.grey.shade800 : Colors.grey.shade300,
        highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
        child: Container(
          margin:     EdgeInsets.only(bottom: 16.h),
          height:     100.h,
          decoration: BoxDecoration(
            color:        Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String   title,
    required String   subtitle,
    required bool     isDark,
    required Color    iconColor,
  }) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding:    EdgeInsets.all(36.r),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 72.sp, color: iconColor),
        )
            .animate(onPlay: (c) => c.repeat())
            .scale(
          duration: 2000.ms,
          begin:    const Offset(1, 1),
          end:      const Offset(1.08, 1.08),
        )
            .then()
            .scale(
          duration: 2000.ms,
          begin:    const Offset(1.08, 1.08),
          end:      const Offset(1, 1),
        ),
        SizedBox(height: 28.h),
        Text(title,
            style: TextStyle(
              fontSize:   19.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.black,
            ))
            .animate()
            .fadeIn(delay: 200.ms)
            .slideY(begin: 0.2),
        SizedBox(height: 8.h),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? Colors.grey.shade500 : AppColors.greyDark,
            ))
            .animate()
            .fadeIn(delay: 400.ms)
            .slideY(begin: 0.2),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // DATE PICKER
  // ══════════════════════════════════════════════════════════════════
  Future<void> _pickDate({required bool isFrom, required bool isDark}) async {
    final now  = DateTime.now();
    final init = isFrom
        ? (_filterFromDate ?? DateTime(now.year, now.month - 1, now.day))
        : (_filterToDate   ?? now);

    final picked = await showDatePicker(
      context:      context,
      initialDate:  init,
      firstDate:    DateTime(2020),
      lastDate:     DateTime(now.year + 1),
      locale:       const Locale('ar'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor:  AppColors.darkRed,
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

  // ══════════════════════════════════════════════════════════════════
  // EXPORT SHEET
  // ══════════════════════════════════════════════════════════════════
  void _showExportSheet(bool isDark) {
    final apptProv = Provider.of<AppointmentProvider>(context, listen: false);
    final filtered  = _applyFilters(apptProv.appointments);

    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: SafeArea(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 40.w, height: 4.h,
                decoration: BoxDecoration(
                  color:        Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),

              Row(children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color:        AppColors.darkRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.file_download_rounded,
                      color: AppColors.darkRed, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('تصدير كشف الحجوزات',
                            style: TextStyle(
                              fontSize:   18.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.black,
                              fontFamily: 'Cairo',
                            )),
                        Text(
                            'سيتم تصدير ${filtered.length} حجز'
                                '${_filterFromDate != null || _filterToDate != null ? ' (مفلتر بالتاريخ)' : ''}',
                            style: TextStyle(
                              fontSize:   12.sp,
                              color:      Colors.grey.shade500,
                              fontFamily: 'Cairo',
                            )),
                      ]),
                ),
              ]),
              SizedBox(height: 16.h),

              if (_filterFromDate != null || _filterToDate != null)
                Container(
                  padding: EdgeInsets.all(12.r),
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color:  AppColors.darkRed.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                        color: AppColors.darkRed.withValues(alpha: 0.2)),
                  ),
                  child: Row(children: [
                    Icon(Icons.date_range_rounded,
                        color: AppColors.darkRed, size: 16.sp),
                    SizedBox(width: 8.w),
                    Text(
                        '${_filterFromDate != null ? DateFormat('d MMM yyyy', 'ar').format(_filterFromDate!) : 'البداية'}'
                            '  ←  '
                            '${_filterToDate != null ? DateFormat('d MMM yyyy', 'ar').format(_filterToDate!) : 'اليوم'}',
                        style: TextStyle(
                          fontSize:   12.sp,
                          fontWeight: FontWeight.bold,
                          color:      AppColors.darkRed,
                          fontFamily: 'Cairo',
                        )),
                  ]),
                ),

              _buildExportOption(
                icon:     Icons.picture_as_pdf_rounded,
                color:    Colors.red,
                title:    'طباعة PDF',
                subtitle: 'إنشاء ملف PDF وطباعته أو مشاركته',
                isDark:   isDark,
                onTap: () {
                  Navigator.pop(context);
                  _exportAppointmentsPdf(filtered);
                },
              ),
              SizedBox(height: 10.h),
              _buildExportOption(
                icon:     Icons.table_chart_rounded,
                color:    Colors.green,
                title:    'تصدير CSV',
                subtitle: 'مناسب لـ Excel وجداول البيانات',
                isDark:   isDark,
                onTap: () {
                  Navigator.pop(context);
                  _exportAppointmentsCsv(filtered);
                },
              ),
              SizedBox(height: 10.h),
              _buildExportOption(
                icon:     Icons.share_rounded,
                color:    Colors.blue,
                title:    'مشاركة ملخص نصي',
                subtitle: 'مشاركة الكشف عبر واتساب أو غيره',
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
    required IconData icon,
    required Color    color,
    required String   title,
    required String   subtitle,
    required bool     isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        ),
        child: Row(children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color:  color.withValues(alpha: 0.1),
              shape:  BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize:   15.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.black,
                        fontFamily: 'Cairo',
                      )),
                  Text(subtitle,
                      style: TextStyle(
                        fontSize:   12.sp,
                        color:      Colors.grey.shade500,
                        fontFamily: 'Cairo',
                      )),
                ]),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 14.sp, color: Colors.grey.shade400),
        ]),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // PDF EXPORT - NEW FUNCTION
  // ══════════════════════════════════════════════════════════════════
  // Future<void> _exportAppointmentsPdf(List<AppointmentModel> appts) async {
  //   if (!mounted) return;
  //   setState(() => _isExporting = true);
  //
  //   try {
  //     final pdf = pw.Document();
  //
  //     // تحميل الخط العربي
  //     final arabicFont = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
  //     final ttf = pw.Font.ttf(arabicFont);
  //     final boldFont = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');
  //     final ttfBold = pw.Font.ttf(boldFont);
  //
  //     // حساب الإحصائيات
  //     final total = appts.fold(0.0, (s, a) => s + a.totalPrice);
  //     final completed = appts.where((a) => a.status == 'completed').length;
  //     final dateRange = (_filterFromDate != null || _filterToDate != null)
  //         ? 'من ${_filterFromDate != null ? DateFormat('d/M/yyyy').format(_filterFromDate!) : "البداية"} إلى ${_filterToDate != null ? DateFormat('d/M/yyyy').format(_filterToDate!) : "اليوم"}'
  //         : 'جميع التواريخ';
  //
  //     pdf.addPage(
  //       pw.MultiPage(
  //         textDirection: pw.TextDirection.rtl,
  //         theme: pw.ThemeData.withFont(
  //           base: ttf,
  //           bold: ttfBold,
  //         ),
  //         pageFormat: PdfPageFormat.a4,
  //         margin: const pw.EdgeInsets.all(32),
  //         build: (context) => [
  //           // العنوان الرئيسي
  //           pw.Container(
  //             padding: const pw.EdgeInsets.all(20),
  //             decoration: pw.BoxDecoration(
  //               color: PdfColors.red900,
  //               borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
  //             ),
  //             child: pw.Column(
  //               children: [
  //                 pw.Text(
  //                   'كشف الحجوزات',
  //                   style: pw.TextStyle(
  //                     font: ttfBold,
  //                     fontSize: 28,
  //                     color: PdfColors.white,
  //                   ),
  //                 ),
  //                 pw.SizedBox(height: 8),
  //                 pw.Text(
  //                   'Millionaire Barber',
  //                   style: pw.TextStyle(
  //                     font: ttf,
  //                     fontSize: 16,
  //                     color: PdfColors.white,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           pw.SizedBox(height: 24),
  //
  //           // الإحصائيات
  //           pw.Container(
  //             padding: const pw.EdgeInsets.all(16),
  //             decoration: pw.BoxDecoration(
  //               border: pw.Border.all(color: PdfColors.grey400),
  //               borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
  //             ),
  //             child: pw.Column(
  //               crossAxisAlignment: pw.CrossAxisAlignment.start,
  //               children: [
  //                 pw.Row(
  //                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     _buildPdfStat('إجمالي الحجوزات', '${appts.length}', ttf, ttfBold),
  //                     _buildPdfStat('المكتملة', '$completed', ttf, ttfBold),
  //                     _buildPdfStat('الإجمالي المدفوع', '${total.toStringAsFixed(0)} ريال', ttf, ttfBold),
  //                   ],
  //                 ),
  //                 pw.SizedBox(height: 12),
  //                 pw.Text(
  //                   'الفترة: $dateRange',
  //                   style: pw.TextStyle(font: ttf, fontSize: 11, color: PdfColors.grey700),
  //                 ),
  //                 pw.Text(
  //                   'تاريخ التصدير: ${DateFormat('d MMMM yyyy - hh:mm a', 'ar').format(DateTime.now())}',
  //                   style: pw.TextStyle(font: ttf, fontSize: 11, color: PdfColors.grey700),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           pw.SizedBox(height: 24),
  //
  //           // الجدول
  //           pw.Table(
  //             border: pw.TableBorder.all(color: PdfColors.grey400),
  //             columnWidths: {
  //               0: const pw.FixedColumnWidth(30),
  //               1: const pw.FlexColumnWidth(3),
  //               2: const pw.FlexColumnWidth(2),
  //               3: const pw.FlexColumnWidth(2),
  //               4: const pw.FlexColumnWidth(2),
  //               5: const pw.FlexColumnWidth(1.5),
  //               6: const pw.FlexColumnWidth(1.5),
  //             },
  //             children: [
  //               // الرأس
  //               pw.TableRow(
  //                 decoration: const pw.BoxDecoration(color: PdfColors.grey300),
  //                 children: [
  //                   _buildTableHeader('#', ttfBold),
  //                   _buildTableHeader('الخدمة', ttfBold),
  //                   _buildTableHeader('التاريخ', ttfBold),
  //                   _buildTableHeader('الوقت', ttfBold),
  //                   _buildTableHeader('الحلاق', ttfBold),
  //                   _buildTableHeader('الحالة', ttfBold),
  //                   _buildTableHeader('المبلغ', ttfBold),
  //                 ],
  //               ),
  //               // الصفوف
  //               ...appts.asMap().entries.map((entry) {
  //                 final index = entry.key;
  //                 final appt = entry.value;
  //                 return pw.TableRow(
  //                   decoration: pw.BoxDecoration(
  //                     color: index.isEven ? PdfColors.grey100 : PdfColors.white,
  //                   ),
  //                   children: [
  //                     _buildTableCell('${index + 1}', ttf),
  //                     _buildTableCell(_getServiceTitle(appt), ttf),
  //                     _buildTableCell(DateFormat('d/M/yyyy').format(appt.appointmentDate), ttf),
  //                     _buildTableCell(_formatTime(appt.appointmentTime), ttf),
  //                     _buildTableCell(appt.employeeName ?? 'تلقائي', ttf),
  //                     _buildTableCell(_getStatusText(appt.status), ttf),
  //                     _buildTableCell('${appt.totalPrice.toStringAsFixed(0)} ريال', ttf),
  //                   ],
  //                 );
  //               }).toList(),
  //               // الإجمالي
  //               pw.TableRow(
  //                 decoration: const pw.BoxDecoration(color: PdfColors.grey200),
  //                 children: [
  //                   pw.Container(),
  //                   _buildTableHeader('الإجمالي الكلي', ttfBold),
  //                   pw.Container(),
  //                   pw.Container(),
  //                   pw.Container(),
  //                   pw.Container(),
  //                   _buildTableHeader('${total.toStringAsFixed(0)} ريال', ttfBold),
  //                 ],
  //               ),
  //             ],
  //           ),
  //
  //           pw.SizedBox(height: 32),
  //
  //           // تذييل
  //           pw.Container(
  //             padding: const pw.EdgeInsets.all(12),
  //             decoration: pw.BoxDecoration(
  //               color: PdfColors.grey200,
  //               borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
  //             ),
  //             child: pw.Column(
  //               crossAxisAlignment: pw.CrossAxisAlignment.start,
  //               children: [
  //                 pw.Text(
  //                   'ملاحظات:',
  //                   style: pw.TextStyle(font: ttfBold, fontSize: 12),
  //                 ),
  //                 pw.SizedBox(height: 4),
  //                 pw.Text(
  //                   '• هذا الكشف يعرض جميع الحجوزات حسب الفلاتر المطبقة',
  //                   style: pw.TextStyle(font: ttf, fontSize: 10),
  //                 ),
  //                 pw.Text(
  //                   '• للاستفسارات، يرجى التواصل مع صالون Millionaire Barber',
  //                   style: pw.TextStyle(font: ttf, fontSize: 10),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //         footer: (context) => pw.Container(
  //           alignment: pw.Alignment.centerLeft,
  //           margin: const pw.EdgeInsets.only(top: 16),
  //           child: pw.Text(
  //             'صفحة ${context.pageNumber} من ${context.pagesCount}',
  //             style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey600),
  //           ),
  //         ),
  //       ),
  //     );
  //
  //     // عرض معاينة الطباعة
  //     await Printing.layoutPdf(
  //       onLayout: (format) async => pdf.save(),
  //       name: 'appointments_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf',
  //     );
  //
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         content: Text('خطأ في إنشاء PDF: $e',
  //             style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp)),
  //         backgroundColor: Colors.red,
  //         behavior:        SnackBarBehavior.floating,
  //         shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10.r)),
  //       ));
  //     }
  //   } finally {
  //     if (mounted) setState(() => _isExporting = false);
  //   }
  // }
  //
  // pw.Widget _buildPdfStat(String label, String value, pw.Font font, pw.Font boldFont) {
  //   return pw.Column(
  //     crossAxisAlignment: pw.CrossAxisAlignment.center,
  //     children: [
  //       pw.Text(
  //         value,
  //         style: pw.TextStyle(font: boldFont, fontSize: 18, color: PdfColors.red900),
  //       ),
  //       pw.SizedBox(height: 4),
  //       pw.Text(
  //         label,
  //         style: pw.TextStyle(font: font, fontSize: 11, color: PdfColors.grey700),
  //       ),
  //     ],
  //   );
  // }
  //
  // pw.Widget _buildTableHeader(String text, pw.Font font) {
  //   return pw.Container(
  //     padding: const pw.EdgeInsets.all(8),
  //     child: pw.Text(
  //       text,
  //       style: pw.TextStyle(font: font, fontSize: 11),
  //       textAlign: pw.TextAlign.center,
  //     ),
  //   );
  // }
  //
  // pw.Widget _buildTableCell(String text, pw.Font font) {
  //   return pw.Container(
  //     padding: const pw.EdgeInsets.all(6),
  //     child: pw.Text(
  //       text,
  //       style: pw.TextStyle(font: font, fontSize: 9),
  //       textAlign: pw.TextAlign.center,
  //     ),
  //   );
  // }

  Future<void> _exportAppointmentsPdf(List<AppointmentModel> appts) async {
    if (!mounted) return;
    setState(() => _isExporting = true);

    try {
      final pdf = pw.Document();

      // تحميل الخطوط العربية
      final arabicFont = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      final boldFont = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');

      final ttf = pw.Font.ttf(arabicFont);
      final ttfBold = pw.Font.ttf(boldFont);

      // تحميل الشعار
      final logo = pw.MemoryImage(
        (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List(),
      );

      // حساب الإحصائيات
      final total = appts.fold(0.0, (s, a) => s + a.totalPrice);
      final completed = appts.where((a) => a.status == 'completed').length;

      final dateRange = (_filterFromDate != null || _filterToDate != null)
          ? 'من ${_filterFromDate != null ? DateFormat('d/M/yyyy').format(_filterFromDate!) : "البداية"} إلى ${_filterToDate != null ? DateFormat('d/M/yyyy').format(_filterToDate!) : "اليوم"}'
          : 'جميع التواريخ';

      pdf.addPage(
        pw.MultiPage(
          textDirection: pw.TextDirection.rtl,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),

          theme: pw.ThemeData.withFont(
            base: ttf,
            bold: ttfBold,
          ),

          // HEADER
          header: (context) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 20),
              child: pw.Row(
                // textDirection: pw.TextDirection.rtl,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [

                  // عنوان التقرير
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'كشف الحجوزات',
                        style: pw.TextStyle(
                          font: ttfBold,
                          fontSize: 20,
                        ),
                      ),
                      pw.Text(
                        'مركـــز المليونير للحلاقة والعناية بالرجل',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),

                  // الشعار
                  pw.Container(
                    height: 60,
                    width: 60,
                    child: pw.Image(logo),
                  ),
                ],
              ),
            );
          },

          build: (context) => [

            // الإحصائيات
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                children: [

                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [

                      _buildPdfStat(
                          'إجمالي الحجوزات',
                          '${appts.length}',
                          ttf,
                          ttfBold),

                      _buildPdfStat(
                          'المكتملة',
                          '$completed',
                          ttf,
                          ttfBold),

                      _buildPdfStat(
                          'الإجمالي المدفوع',
                          '${total.toStringAsFixed(0)} ريال',
                          ttf,
                          ttfBold),
                    ],
                  ),

                  pw.SizedBox(height: 10),

                  pw.Text(
                    'الفترة: $dateRange',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 11,
                      color: PdfColors.grey700,
                    ),
                  ),

                  pw.Text(
                    'تاريخ التصدير: ${DateFormat('d MMMM yyyy - hh:mm a', 'ar').format(DateTime.now())}',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 11,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // الجدول
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),

              columnWidths: {
                0: const pw.FlexColumnWidth(1.5),
                1: const pw.FlexColumnWidth(1.5),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
                4: const pw.FlexColumnWidth(2),
                5: const pw.FlexColumnWidth(3),
                6: const pw.FixedColumnWidth(30),
              },

              children: [

                // رأس الجدول
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  children: [

                    _buildTableHeader('المبلغ', ttfBold),
                    _buildTableHeader('الحالة', ttfBold),
                    _buildTableHeader('الحلاق', ttfBold),
                    _buildTableHeader('الوقت', ttfBold),
                    _buildTableHeader('التاريخ', ttfBold),
                    _buildTableHeader('الخدمة', ttfBold),
                    _buildTableHeader('#', ttfBold),
                  ],
                ),

                // الصفوف
                ...appts.asMap().entries.map((entry) {

                  final index = entry.key;
                  final appt = entry.value;

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: index.isEven
                          ? PdfColors.grey100
                          : PdfColors.white,
                    ),

                    children: [

                      _buildTableCell(
                          // '${appt.totalPrice.toStringAsFixed(0)} ريال',
                          '${total.toStringAsFixed(0)} ريال'                        ,
                          ttf),

                      _buildTableCell(
                          _getStatusText(appt.status),
                          ttf),

                      _buildTableCell(
                          appt.employeeName ?? 'تلقائي',
                          ttf),

                      _buildTableCell(
                          _formatTime(appt.appointmentTime),
                          ttf),

                      _buildTableCell(
                          DateFormat('d/M/yyyy')
                              .format(appt.appointmentDate),
                          ttf),

                      _buildTableCell(
                          _getServiceTitle(appt),
                          ttf),

                      _buildTableCell(
                          '${index + 1}',
                          ttf),
                    ],
                  );
                }),

                // الإجمالي
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                  ),
                  children: [

                    _buildTableHeader(
                        '${total.toStringAsFixed(0)} ريال',
                        
                        ttfBold),

                    pw.Container(),
                    pw.Container(),
                    pw.Container(),
                    pw.Container(),

                    _buildTableHeader(
                        'الإجمالي الكلي',
                        ttfBold),

                    pw.Container(),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 30),

            // ملاحظات
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [

                  pw.Text(
                    'ملاحظات',
                    style: pw.TextStyle(
                      font: ttfBold,
                      fontSize: 12,
                    ),
                  ),

                  pw.SizedBox(height: 5),

                  pw.Text(
                    '• هذا التقرير يعرض الحجوزات حسب الفلاتر المطبقة',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 10,
                    ),
                  ),

                  pw.Text(
                    '• للاستفسار يرجى التواصل مع الصالون',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Footer
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerLeft,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'صفحة ${context.pageNumber} من ${context.pagesCount}',
              style: pw.TextStyle(
                font: ttf,
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ),
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name:
        'appointments_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf',
      );
    } catch (e) {

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إنشاء PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
  pw.Widget _buildPdfStat(String label, String value, pw.Font font, pw.Font boldFont) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 18,
            color: PdfColors.red900,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: pw.TextStyle(
            font: font,
            fontSize: 11,
            color: PdfColors.grey700,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTableHeader(String text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          font: font,
          fontSize: 11,
        ),
      ),
    );
  }

  pw.Widget _buildTableCell(String text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          font: font,
          fontSize: 9,
        ),
      ),
    );
  }

  // ── تصدير CSV ────────────────────────────────────────────────────
  Future<void> _exportAppointmentsCsv(List<AppointmentModel> appts) async {
    if (!mounted) return;
    setState(() => _isExporting = true);
    try {
      final buffer = StringBuffer();
      buffer.writeln('رقم الحجز,الخدمة,التاريخ,الوقت,الحلاق,الحالة,المبلغ,طريقة الدفع');

      for (final a in appts) {
        final id      = a.id ?? '';
        final service = (a.services?.isNotEmpty == true
            ? (a.services!.first.serviceNameAr ?? 'خدمة')
            : 'خدمة')
            .replaceAll(',', '،');
        final date    = DateFormat('yyyy-MM-dd').format(a.appointmentDate);
        final time    = _formatTime(a.appointmentTime);
        final emp     = (a.employeeName ?? 'تلقائي').replaceAll(',', '،');
        final status  = _getStatusText(a.status);
        final price   = a.totalPrice.toStringAsFixed(2);
        final payment = a.paymentMethod == 'cash'
            ? 'نقدي'
            : a.paymentMethod == 'electronic'
            ? 'إلكتروني'
            : (a.paymentMethod ?? '');
        buffer.writeln('"$id","$service","$date","$time","$emp","$status","$price","$payment"');
      }

      final total = appts.fold(0.0, (s, a) => s + a.totalPrice);
      buffer.writeln('');
      buffer.writeln('"الإجمالي","","","","","","${total.toStringAsFixed(2)}",""');

      final dir      = await getTemporaryDirectory();
      final dateStr  = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final filePath = '${dir.path}/appointments_$dateStr.csv';
      final file     = File(filePath);
      await file.writeAsString('\uFEFF${buffer.toString()}',
          encoding: const Utf8Codec());

      if (mounted) {
        await Share.shareXFiles(
          [XFile(filePath, mimeType: 'text/csv')],
          subject: 'كشف حجوزات - Millionaire Barber',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('خطأ في التصدير: $e',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13.sp)),
          backgroundColor: Colors.red,
          behavior:        SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  // ── مشاركة ملخص نصي ──────────────────────────────────────────────
  Future<void> _shareTextSummary(List<AppointmentModel> appts) async {
    if (appts.isEmpty) return;

    final total     = appts.fold(0.0, (s, a) => s + a.totalPrice);
    final completed = appts.where((a) => a.status == 'completed').length;
    final dateRange = (_filterFromDate != null || _filterToDate != null)
        ? '\n📅 الفترة: ${_filterFromDate != null ? DateFormat('d MMM yyyy', 'ar').format(_filterFromDate!) : 'البداية'}'
        ' → ${_filterToDate != null ? DateFormat('d MMM yyyy', 'ar').format(_filterToDate!) : 'اليوم'}'
        : '';

    final buffer = StringBuffer();
    buffer.writeln('💈 كشف حجوزات - Millionaire Barber');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('📊 إجمالي الحجوزات: ${appts.length}$dateRange');
    buffer.writeln('✅ المكتملة: $completed');
    buffer.writeln('💰 الإجمالي المدفوع: ${total.toStringAsFixed(0)} ريال');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('');

    final preview = appts.take(10).toList();
    for (final a in preview) {
      final svc  = a.services?.isNotEmpty == true
          ? (a.services!.first.serviceNameAr ?? 'خدمة') : 'خدمة';
      final date = DateFormat('d MMM', 'ar').format(a.appointmentDate);
      final icon = a.status == 'completed'
          ? '✅' : a.status == 'cancelled' ? '❌' : '⏳';
      buffer.writeln('$icon $svc | $date | ${a.totalPrice.toStringAsFixed(0)} ر');
    }
    if (appts.length > 10) {
      buffer.writeln('... و${appts.length - 10} حجز آخر');
    }

    await Share.share(buffer.toString(),
        subject: 'كشف حجوزاتي - Millionaire Barber');
  }

  // ══════════════════════════════════════════════════════════════════
  // CANCEL / REVIEW
  // ══════════════════════════════════════════════════════════════════
  Future<void> _navigateToReview(AppointmentModel appt) async {
    final rev      = Provider.of<ReviewProvider>(context, listen: false);
    final existing = await rev.checkAppointmentReview(appt.id!);
    if (existing != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:         const Text('لقد قمت بتقييم هذه الخدمة مسبقاً'),
        backgroundColor: Colors.orange,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ));
      return;
    }
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (_) => AddReviewScreen(appointment: appt)));
    if (result == true && mounted) {
      final user = Provider.of<UserProvider>(context, listen: false);
      await Provider.of<AppointmentProvider>(context, listen: false)
          .fetchUserAppointments(user.user!.id!);
    }
  }

  Future<void> _cancelAppointment(AppointmentModel appt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r)),
          backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E) : Colors.white,
          title: Row(children: [
            Icon(Icons.warning_amber_rounded,
                color: AppColors.error, size: 26.sp)
                .animate(onPlay: (c) => c.repeat())
                .shake(duration: 500.ms, hz: 4)
                .then(delay: 500.ms),
            SizedBox(width: 10.w),
            const Text('إلغاء الموعد'),
          ]),
          content: Text(
            'هل أنت متأكد من إلغاء هذا الموعد؟\n'
                'لن يتم إضافة نقاط الولاء المعلقة.',
            style: TextStyle(fontSize: 14.sp, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('لا',
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 15.sp)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              child: Text('نعم، إلغاء', style: TextStyle(fontSize: 15.sp)),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    final apptProv  = Provider.of<AppointmentProvider>(context, listen: false);
    final notifProv = Provider.of<NotificationProvider>(context, listen: false);
    final userProv  = Provider.of<UserProvider>(context, listen: false);

    showDialog(
      context:            context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width:   180.w,
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF262626) : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color:      Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width:  50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkRed.withValues(alpha: 0.1),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(AppColors.darkRed),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text('جارٍ الإلغاء...',
                  style: TextStyle(
                    fontSize:   15.sp,
                    fontWeight: FontWeight.w600,
                  )),
            ]),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(
              begin: const Offset(0.9, 0.9),
              end:   const Offset(1, 1)),
        ),
      ),
    );

    try {
      final ok = await apptProv.cancelAppointment(appt.id!);
      if (mounted) Navigator.pop(context);
      if (ok && mounted) {
        await notifProv.createCancellationNotification(
          userId:        userProv.user!.id!,
          appointmentId: appt.id!,
          serviceName: appt.services?.isNotEmpty == true
              ? (appt.services!.first.serviceNameAr ??
              appt.services!.first.serviceName ?? 'الخدمة')
              : 'الخدمة',
        );
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:         const Text('✅ تم إلغاء الموعد بنجاح'),
          backgroundColor: Colors.orange,
          behavior:        SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r)),
        ));
        await apptProv.fetchUserAppointments(userProv.user!.id!);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:         const Text('❌ فشل إلغاء الموعد'),
          backgroundColor: Colors.red,
          behavior:        SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r)),
        ));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:         Text('❌ خطأ: $e'),
          backgroundColor: Colors.red,
          behavior:        SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r)),
        ));
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // STATUS HELPERS
  // ══════════════════════════════════════════════════════════════════
  Color _getStatusColor(String s) {
    switch (s) {
      case 'pending':     return Colors.orange;
      case 'confirmed':   return Colors.blue;
      case 'in_progress': return Colors.purple;
      case 'completed':   return Colors.green;
      case 'cancelled':   return Colors.red;
      case 'no_show':     return Colors.grey;
      default:            return Colors.grey;
    }
  }

  IconData _getStatusIcon(String s) {
    switch (s) {
      case 'pending':     return Icons.hourglass_empty_rounded;
      case 'confirmed':   return Icons.check_circle_outline_rounded;
      case 'in_progress': return Icons.pending_rounded;
      case 'completed':   return Icons.check_circle_rounded;
      case 'cancelled':   return Icons.cancel_rounded;
      case 'no_show':     return Icons.event_busy_rounded;
      default:            return Icons.help_outline_rounded;
    }
  }

  String _getStatusText(String s) {
    switch (s) {
      case 'pending':     return 'قيد الانتظار';
      case 'confirmed':   return 'مؤكد';
      case 'in_progress': return 'جارٍ التنفيذ';
      case 'completed':   return 'مكتمل';
      case 'cancelled':   return 'ملغى';
      case 'no_show':     return 'لم يحضر';
      default:            return s;
    }
  }
}
