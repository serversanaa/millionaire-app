// // lib/features/booking/domain/models/employee_model.dart
// import 'package:millionaire_barber/core/utils/type_parser.dart';
//
// class EmployeeModel {
//   final int? id;
//   final String fullName;
//   final String phone;
//   final String? email;
//   final String employeeCode;
//   final List<String>? specialties;
//   final String? profileImageUrl;
//   final DateTime hireDate;
//   final double? salary;
//   final double commissionRate;
//   final String workingHoursStart;
//   final String workingHoursEnd;
//   final List<int> workingDays;
//   final bool isActive;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//
//   // معلومات إضافية
//   final double? rating;
//   final int? totalAppointments;
//
//   EmployeeModel({
//     this.id,
//     required this.fullName,
//     required this.phone,
//     this.email,
//     required this.employeeCode,
//     this.specialties,
//     this.profileImageUrl,
//     required this.hireDate,
//     this.salary,
//     this.commissionRate = 0.0,
//     this.workingHoursStart = '09:00:00',
//     this.workingHoursEnd = '22:00:00',
//     this.workingDays = const [1, 2, 3, 4, 5, 6, 7],
//     this.isActive = true,
//     this.createdAt,
//     this.updatedAt,
//     this.rating,
//     this.totalAppointments,
//   });
//
//   factory EmployeeModel.fromJson(Map<String, dynamic> json) {
//     return EmployeeModel(
//       id: parseInt(json['id']),
//       fullName: parseString(json['full_name']),
//       phone: parseString(json['phone']),
//       email: parseString(json['email'], defaultValue: ''),
//       employeeCode: parseString(json['employee_code']),
//       specialties: json['specialties'] != null && json['specialties'] is List
//           ? List<String>.from(json['specialties'] as List)
//           : null,
//       profileImageUrl: parseString(json['profile_image_url'], defaultValue: ''),
//       hireDate: parseDateTime(json['hire_date']) ?? DateTime.now(),
//       salary: json['salary'] != null ? parseDouble(json['salary']) : null,
//       commissionRate: parseDouble(json['commission_rate'], defaultValue: 0.0),
//       workingHoursStart: parseString(json['working_hours_start'], defaultValue: '09:00:00'),
//       workingHoursEnd: parseString(json['working_hours_end'], defaultValue: '22:00:00'),
//       workingDays: json['working_days'] != null && json['working_days'] is List
//           ? List<int>.from(json['working_days'] as List)
//           : [1, 2, 3, 4, 5, 6, 7],
//       isActive: parseBool(json['is_active'], defaultValue: true),
//       createdAt: parseDateTime(json['created_at']),
//       updatedAt: parseDateTime(json['updated_at']),
//       rating: json['rating'] != null ? parseDouble(json['rating']) : null,
//       totalAppointments: json['total_appointments'] != null ? parseInt(json['total_appointments']) : null,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'full_name': fullName,
//       'phone': phone,
//       'email': email,
//       'employee_code': employeeCode,
//       'specialties': specialties,
//       'profile_image_url': profileImageUrl,
//       'hire_date': hireDate.toIso8601String(),
//       'salary': salary,
//       'commission_rate': commissionRate,
//       'working_hours_start': workingHoursStart,
//       'working_hours_end': workingHoursEnd,
//       'working_days': workingDays,
//       'is_active': isActive,
//     };
//   }
// }


// lib/features/booking/domain/models/employee_model.dart
import 'package:millionaire_barber/core/utils/type_parser.dart';

class EmployeeModel {
  final int? id;
  final String fullName;
  final String phone;
  final String? email;
  final String employeeCode;
  final List<String>? specialties;
  final String? profileImageUrl;
  final DateTime hireDate;
  final double? salary;
  final double commissionRate;
  final String workingHoursStart;
  final String workingHoursEnd;
  final List<int> workingDays;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ✅ إصلاح: إعادة تسمية rating → averageRating
  final double? averageRating;
  // ✅ إصلاح: إعادة تسمية totalAppointments → totalReviews
  final int? totalReviews;
  // ✅ إضافة: jobTitle
  final String? jobTitle;

  EmployeeModel({
    this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.employeeCode,
    this.specialties,
    this.profileImageUrl,
    required this.hireDate,
    this.salary,
    this.commissionRate = 0.0,
    this.workingHoursStart = '09:00:00',
    this.workingHoursEnd = '22:00:00',
    this.workingDays = const [1, 2, 3, 4, 5, 6, 7],
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.averageRating,
    this.totalReviews,
    this.jobTitle,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: parseInt(json['id']),
      fullName: parseString(json['full_name']),
      phone: parseString(json['phone']),
      email: parseString(json['email'], defaultValue: ''),
      employeeCode: parseString(json['employee_code']),
      specialties: json['specialties'] != null && json['specialties'] is List
          ? List<String>.from(json['specialties'] as List)
          : null,
      profileImageUrl: parseString(json['profile_image_url'], defaultValue: ''),
      hireDate: parseDateTime(json['hire_date']) ?? DateTime.now(),
      salary: json['salary'] != null ? parseDouble(json['salary']) : null,
      commissionRate: parseDouble(json['commission_rate'], defaultValue: 0.0),
      workingHoursStart:
      parseString(json['working_hours_start'], defaultValue: '09:00:00'),
      workingHoursEnd:
      parseString(json['working_hours_end'], defaultValue: '22:00:00'),
      workingDays: json['working_days'] != null && json['working_days'] is List
          ? List<int>.from(json['working_days'] as List)
          : [1, 2, 3, 4, 5, 6, 7],
      isActive: parseBool(json['is_active'], defaultValue: true),
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),

      // ✅ rating / average_rating كلاهما مقبول من قاعدة البيانات
      averageRating: json['average_rating'] != null
          ? parseDouble(json['average_rating'])
          : json['rating'] != null
          ? parseDouble(json['rating'])
          : null,

      // ✅ total_reviews / total_appointments كلاهما مقبول
      totalReviews: json['total_reviews'] != null
          ? parseInt(json['total_reviews'])
          : json['total_appointments'] != null
          ? parseInt(json['total_appointments'])
          : null,

      // ✅ job_title من قاعدة البيانات
      jobTitle: json['job_title'] != null
          ? parseString(json['job_title'], defaultValue: '')
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'employee_code': employeeCode,
      'specialties': specialties,
      'profile_image_url': profileImageUrl,
      'hire_date': hireDate.toIso8601String(),
      'salary': salary,
      'commission_rate': commissionRate,
      'working_hours_start': workingHoursStart,
      'working_hours_end': workingHoursEnd,
      'working_days': workingDays,
      'is_active': isActive,
      'job_title': jobTitle,
    };
  }

  /// ✅ Getters للتوافق مع الكود القديم إذا لزم الأمر
  double? get rating => averageRating;
  int? get totalAppointments => totalReviews;
}
