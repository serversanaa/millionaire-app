// lib/features/reviews/data/repositories/review_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/review_model.dart';
import '../../domain/models/rating_summary_model.dart';

class ReviewRepository {
  final SupabaseClient client;

  ReviewRepository(this.client);

  /// إنشاء تقييم جديد
  Future<ReviewModel?> createReview(ReviewModel review) async {
    try {
      final data = review.toJson();
      data.remove('id');

      final response =
          await client.from('reviews').insert(data).select().single();

      return ReviewModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// تحديث تقييم
  Future<bool> updateReview(int reviewId, int rating, String? comment) async {
    try {
      await client.from('reviews').update({
        'rating': rating,
        'comment': comment,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', reviewId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// حذف تقييم
  Future<bool> deleteReview(int reviewId) async {
    try {
      await client.from('reviews').delete().eq('id', reviewId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// جلب تقييمات خدمة معينة
  Future<List<ReviewModel>> getServiceReviews(int serviceId,
      {int limit = 50}) async {
    try {
      final response = await client
          .from('reviews')
          .select('''
            *,
            users!inner(full_name, profile_image_url)
          ''')
          .eq('service_id', serviceId)
          .eq('is_approved', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) {
        final reviewJson = Map<String, dynamic>.from(json as Map);
        if (reviewJson['users'] != null) {
          final userMap = reviewJson['users'] as Map<String, dynamic>;
          reviewJson['user_name'] = userMap['full_name'];
          reviewJson['user_image_url'] = userMap['profile_image_url'];
        }
        return ReviewModel.fromJson(reviewJson);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// جلب تقييمات موظف معين
  Future<List<ReviewModel>> getEmployeeReviews(int employeeId,
      {int limit = 50}) async {
    try {
      final response = await client
          .from('reviews')
          .select('''
            *,
            users!inner(full_name, profile_image_url)
          ''')
          .eq('employee_id', employeeId)
          .eq('is_approved', true)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) {
        final reviewJson = Map<String, dynamic>.from(json as Map);
        if (reviewJson['users'] != null) {
          final userMap = reviewJson['users'] as Map<String, dynamic>;
          reviewJson['user_name'] = userMap['full_name'];
          reviewJson['user_image_url'] = userMap['profile_image_url'];
        }
        return ReviewModel.fromJson(reviewJson);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// جلب تقييمات المستخدم
  Future<List<ReviewModel>> getUserReviews(int userId) async {
    try {
      final response = await client.from('reviews').select('''
            *,
            services(service_name, service_name_ar),
            employees(full_name)
          ''').eq('user_id', userId).order('created_at', ascending: false);

      return (response as List).map((json) {
        final reviewJson = Map<String, dynamic>.from(json as Map);
        if (reviewJson['services'] != null) {
          final serviceMap = reviewJson['services'] as Map<String, dynamic>;
          reviewJson['service_name'] =
              serviceMap['service_name_ar'] ?? serviceMap['service_name'];
        }
        if (reviewJson['employees'] != null) {
          final employeeMap = reviewJson['employees'] as Map<String, dynamic>;
          reviewJson['employee_name'] = employeeMap['full_name'];
        }
        return ReviewModel.fromJson(reviewJson);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// جلب ملخص تقييم خدمة
  Future<RatingSummaryModel> getServiceRatingSummary(int serviceId) async {
    try {
      final response = await client
          .from('service_ratings')
          .select()
          .eq('service_id', serviceId)
          .maybeSingle();

      if (response == null) {
        return RatingSummaryModel.empty();
      }

      return RatingSummaryModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return RatingSummaryModel.empty();
    }
  }

  /// جلب ملخص تقييم موظف
  Future<RatingSummaryModel> getEmployeeRatingSummary(int employeeId) async {
    try {
      final response = await client
          .from('employee_ratings')
          .select()
          .eq('employee_id', employeeId)
          .maybeSingle();

      if (response == null) {
        return RatingSummaryModel.empty();
      }

      return RatingSummaryModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return RatingSummaryModel.empty();
    }
  }

  /// التحقق من إذا كان المستخدم قيّم الموعد
  Future<ReviewModel?> getReviewByAppointment(int appointmentId) async {
    try {
      final response = await client
          .from('reviews')
          .select()
          .eq('appointment_id', appointmentId)
          .maybeSingle();

      if (response == null) return null;

      return ReviewModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// زيادة عدد "مفيد"
  Future<bool> incrementHelpfulCount(int reviewId) async {
    try {
      await client
          .rpc('increment_helpful_count', params: {'review_id': reviewId});
      return true;
    } catch (e) {
      return false;
    }
  }
}