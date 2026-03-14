import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:millionaire_barber/core/routes/app_routes.dart';
import 'package:millionaire_barber/features/appointments/presentation/pages/appointment_details_screen.dart';
import 'package:millionaire_barber/features/appointments/presentation/providers/appointment_provider.dart';
import 'package:millionaire_barber/features/profile/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import '../../../../core/constants/app_colors.dart';
import '../../domain/models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
      _subscribeToRealtimeUpdates(); // ✅ أضف هذا

    });
  }

  // ✅ دالة جديدة
  void _subscribeToRealtimeUpdates() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    if (userProvider.user?.id != null) {
      notificationProvider.subscribeToUserNotifications(userProvider.user!.id!);
    }
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    if (userProvider.user?.id != null) {
      await notificationProvider.fetchNotifications(userProvider.user!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        appBar: _buildAppBar(isDark),
        body: Consumer2<NotificationProvider, UserProvider>(
          builder: (context, notificationProvider, userProvider, _) {
            if (notificationProvider.isLoading) {
              return _buildLoadingState(isDark);
            }

            if (notificationProvider.notifications.isEmpty) {
              return _buildEmptyState(isDark);
            }

            return Column(
              children: [
                // ✅ Tabs
                _buildTabBar(isDark, notificationProvider),

                // ✅ Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // All Notifications
                      _buildNotificationsList(
                        notificationProvider.notifications,
                        isDark,
                        userProvider.user?.id ?? 0,
                      ),
                      // Unread Only
                      _buildNotificationsList(
                        notificationProvider.unreadNotifications,
                        isDark,
                        userProvider.user?.id ?? 0,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// APP BAR
  /// ═══════════════════════════════════════════════════════════════

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: AppColors.darkRed,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20.sp),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_rounded, color: Colors.white, size: 24.sp),
          SizedBox(width: 8.w),
          Text(
            'الإشعارات',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Consumer2<NotificationProvider, UserProvider>(
          builder: (context, notificationProvider, userProvider, _) {
            if (notificationProvider.notifications.isEmpty) {
              return const SizedBox.shrink();
            }

            return PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: Colors.white, size: 24.sp),
              color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              itemBuilder: (context) => [
                if (notificationProvider.unreadCount > 0)
                  PopupMenuItem(
                    value: 'mark_all',
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(Icons.done_all_rounded, color: Colors.green, size: 18.sp),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'تعليم الكل كمقروء',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Cairo',
                            color: isDark ? Colors.white : AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'delete_read',
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.delete_sweep_rounded, color: AppColors.error, size: 18.sp),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'حذف المقروءة',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: 'Cairo',
                          color: isDark ? Colors.white : AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete_all',
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.r),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 18.sp),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'حذف الكل',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontFamily: 'Cairo',
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                final userId = userProvider.user!.id!;

                if (value == 'mark_all') {
                  await notificationProvider.markAllAsRead(userId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('✅ تم تعليم جميع الإشعارات كمقروءة'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    );
                  }
                } else if (value == 'delete_read') {
                  _showDeleteConfirmDialog(
                    title: 'حذف الإشعارات المقروءة',
                    message: 'هل أنت متأكد من حذف جميع الإشعارات المقروءة؟',
                    onConfirm: () async {
                      await notificationProvider.deleteReadNotifications(userId);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('✅ تم حذف الإشعارات المقروءة'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          ),
                        );
                      }
                    },
                  );
                } else if (value == 'delete_all') {
                  _showDeleteConfirmDialog(
                    title: 'حذف جميع الإشعارات',
                    message: 'هل أنت متأكد من حذف جميع الإشعارات؟ لا يمكن التراجع عن هذا الإجراء.',
                    onConfirm: () async {
                      await notificationProvider.deleteAllNotifications(userId);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('✅ تم حذف جميع الإشعارات'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          ),
                        );
                      }
                    },
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// TAB BAR
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildTabBar(bool isDark, NotificationProvider notificationProvider) {
    return Container(
      margin: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.darkRed,
          borderRadius: BorderRadius.circular(10.r),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? Colors.grey.shade400 : AppColors.greyDark,
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          fontFamily: 'Cairo',
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('الكل'),
                if (notificationProvider.notifications.isNotEmpty) ...[
                  SizedBox(width: 6.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: _tabController.index == 0
                          ? Colors.white.withValues(alpha:0.2)
                          : AppColors.darkRed.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '${notificationProvider.notifications.length}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('غير مقروءة'),
                if (notificationProvider.unreadCount > 0) ...[
                  SizedBox(width: 6.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: _tabController.index == 1
                          ? Colors.white.withValues(alpha:0.2)
                          : AppColors.darkRed,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '${notificationProvider.unreadCount}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  /// ═══════════════════════════════════════════════════════════════
  /// NOTIFICATIONS LIST
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildNotificationsList(List<NotificationModel> notifications, bool isDark, int userId) {
    if (notifications.isEmpty) {
      return _buildEmptyTabState(isDark);
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: AppColors.darkRed,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(
            notification,
            isDark,
            userId,
          ).animate(delay: Duration(milliseconds: 50 * index))
              .fadeIn(duration: 400.ms)
              .slideX(begin: 0.2, duration: 400.ms);
        },
      ),
    );
  }




// ✅ دالة جديدة — تجلب الحجز وتفتح التفاصيل
  Future<void> _openAppointmentDetails(int appointmentId) async {
    try {
      // أظهر loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.darkRed),
        ),
      );

      final appointmentProvider =
      Provider.of<AppointmentProvider>(context, listen: false);

      final appointment =
      await appointmentProvider.getAppointmentById(appointmentId);

      if (!mounted) return;
      Navigator.pop(context); // أغلق loading

      if (appointment != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AppointmentDetailsScreen(appointment: appointment),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تعذّر فتح تفاصيل الحجز'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // أغلق loading عند الخطأ
        debugPrint('❌ خطأ في فتح تفاصيل الحجز: $e');
      }
    }
  }

  /// ═══════════════════════════════════════════════════════════════
  /// NOTIFICATION CARD
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildNotificationCard(NotificationModel notification, bool isDark, int userId) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteSingleConfirmDialog(notification.title);
      },
      background: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.error.withValues(alpha:0.8), AppColors.error],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 28.sp),
            SizedBox(height: 4.h),
            Text(
              'حذف',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        Provider.of<NotificationProvider>(context, listen: false)
            .deleteNotification(notification.id!, userId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم حذف الإشعار'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            action: SnackBarAction(
              label: 'تراجع',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Implement undo
              },
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            Provider.of<NotificationProvider>(context, listen: false)
                .markAsRead(notification.id!, userId);
          }
          _handleNotificationTap(notification);
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: notification.isRead
                ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
                : (isDark ? const Color(0xFF2A2A2A) : AppColors.darkRed.withValues(alpha:0.08)),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: notification.isRead
                  ? (isDark ? Colors.grey.shade800 : Colors.grey.shade200)
                  : AppColors.darkRed.withValues(alpha:0.3),
              width: notification.isRead ? 1 : 2,
            ),
            boxShadow: [
              if (!notification.isRead)
                BoxShadow(
                  color: AppColors.darkRed.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.black,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 10.w,
                            height: 10.h,
                            decoration: BoxDecoration(
                              color: AppColors.darkRed,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.darkRed.withValues(alpha:0.4),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ).animate(onPlay: (controller) => controller.repeat())
                              .shimmer(duration: 2000.ms),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                        fontFamily: 'Cairo',
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14.sp,
                          color: isDark ? Colors.grey.shade500 : AppColors.greyMedium,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          _formatDate(notification.createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark ? Colors.grey.shade500 : AppColors.greyMedium,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// LOADING STATE
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.darkRed),
          SizedBox(height: 20.h),
          Text(
            'جارٍ تحميل الإشعارات...',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// EMPTY STATE
  /// ═══════════════════════════════════════════════════════════════

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(40.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 80.sp,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
          ).animate().fadeIn().scale(),
          SizedBox(height: 24.h),
          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.black,
              fontFamily: 'Cairo',
            ),
          ).animate(delay: 200.ms).fadeIn(),
          SizedBox(height: 8.h),
          Text(
            'سنرسل لك إشعاراً عند وجود تحديثات',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 300.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildEmptyTabState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 80.sp,
            color: Colors.green.withValues(alpha:0.5),
          ).animate().fadeIn().scale(),
          SizedBox(height: 20.h),
          Text(
            'لا توجد إشعارات غير مقروءة',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.black,
              fontFamily: 'Cairo',
            ),
          ).animate(delay: 200.ms).fadeIn(),
          SizedBox(height: 8.h),
          Text(
            'أنت على اطلاع بكل شيء! 🎉',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
              fontFamily: 'Cairo',
            ),
          ).animate(delay: 300.ms).fadeIn(),
        ],
      ),
    );
  }

  /// ═══════════════════════════════════════════════════════════════
  /// DIALOGS
  /// ═══════════════════════════════════════════════════════════════

  void _showDeleteConfirmDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Cairo',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                  fontSize: 14.sp,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: Text(
                'حذف',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteSingleConfirmDialog(String title) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              Icon(Icons.delete_rounded, color: AppColors.error, size: 24.sp),
              SizedBox(width: 12.w),
              const Text('حذف الإشعار'),
            ],
          ),
          content: Text(
            'هل تريد حذف "$title"؟',
            style: TextStyle(fontSize: 14.sp, fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    ) ?? false;
  }

  /// ═══════════════════════════════════════════════════════════════
  /// HANDLE NOTIFICATION TAP
  /// ═══════════════════════════════════════════════════════════════
  void _handleNotificationTap(NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.bookingConfirmed:
      case NotificationType.reminder:
      case NotificationType.completed:
      case NotificationType.cancelled:
      // ✅ استبدل relatedId بـ appointmentId
        if (notification.appointmentId != null) {
          _openAppointmentDetails(notification.appointmentId!);
        }
        break;
      case NotificationType.offer:
        Navigator.pushNamed(context, AppRoutes.offers);
        break;
      default:
        break;
    }
  }

  // void _handleNotificationTap(NotificationModel notification) {
  //   // TODO: Navigate based on notification type
  //   switch (notification.type) {
  //     case NotificationType.bookingConfirmed:
  //     case NotificationType.reminder:
  //     case NotificationType.completed:
  //     case NotificationType.cancelled:
  //     // Navigate to appointment details
  //     // Navigator.pushNamed(context, AppRoutes.appointmentDetails, arguments: notification.relatedId);
  //       break;
  //     case NotificationType.offer:
  //     // Navigate to offers screen
  //     // Navigator.pushNamed(context, AppRoutes.offers);
  //       break;
  //     default:
  //       break;
  //   }
  // }

  /// ═══════════════════════════════════════════════════════════════
  /// HELPERS
  /// ═══════════════════════════════════════════════════════════════

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.bookingConfirmed:
        return Icons.check_circle_rounded;
      case NotificationType.reminder:
        return Icons.alarm_rounded;
      case NotificationType.cancelled:
        return Icons.cancel_rounded;
      case NotificationType.completed:
        return Icons.task_alt_rounded;
      case NotificationType.offer:
        return Icons.local_offer_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.bookingConfirmed:
        return Colors.green;
      case NotificationType.reminder:
        return Colors.orange;
      case NotificationType.cancelled:
        return AppColors.error;
      case NotificationType.completed:
        return Colors.blue;
      case NotificationType.offer:
        return AppColors.gold;
      default:
        return AppColors.darkRed;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'منذ $weeks ${weeks == 1 ? 'أسبوع' : 'أسابيع'}';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}
