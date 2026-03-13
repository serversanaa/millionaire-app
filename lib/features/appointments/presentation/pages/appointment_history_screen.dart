import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;

import '../../../../core/constants/app_colors.dart';
import '../../../appointments/domain/models/appointment_model.dart';
import '../../../appointments/presentation/providers/appointment_provider.dart';
import 'appointment_details_screen.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentHistoryScreen> createState() => _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    // ✅ فلترة الحجوزات المكتملة والملغية
    final historyAppointments = appointmentProvider.appointments
        .where((apt) => apt.status == 'completed' || apt.status == 'cancelled')
        .toList();

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text(
            'سجل الحجوزات',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          backgroundColor: AppColors.darkRed,
        ),
        body: historyAppointments.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_rounded,
                size: 80.sp,
                color: Colors.grey,
              ),
              SizedBox(height: 16.h),
              Text(
                'لا يوجد سجل حجوزات',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: EdgeInsets.all(16.r),
          itemCount: historyAppointments.length,
          itemBuilder: (context, index) {
            final appointment = historyAppointments[index];
            return _buildAppointmentCard(appointment, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment, bool isDark) {
    final isCompleted = appointment.status == 'completed';

    // ✅ جلب أسماء الخدمات من services الخاصة بالموعد
    String serviceName = 'خدمات';
    if (appointment.services != null && appointment.services!.isNotEmpty) {
      if (appointment.services!.length == 1) {
        serviceName = appointment.services!.first.getDisplayName();
      } else {
        serviceName = '${appointment.services!.length} خدمات';
      }
    }

    // ✅ تنسيق التاريخ
    final formattedDate = '${appointment.appointmentDate.year}/${appointment.appointmentDate.month}/${appointment.appointmentDate.day}';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentDetailsScreen(appointment: appointment),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: (isCompleted ? Colors.green : Colors.red).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.cancel,
                color: isCompleted ? Colors.green : Colors.red,
                size: 32.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.black,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$formattedDate - ${appointment.appointmentTime}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: (isCompleted ? Colors.green : Colors.red).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          isCompleted ? 'مكتمل' : 'ملغي',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: isCompleted ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${appointment.totalPrice.toStringAsFixed(0)} ريال',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
