import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/review_repository.dart';
import '../../domain/models/review_model.dart';
import '../../domain/models/rating_summary_model.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewRepository reviewRepository;
  final SupabaseClient _supabase = Supabase.instance.client;

  ReviewProvider({required this.reviewRepository});

  List<ReviewModel> _reviews = [];
  List<ReviewModel> get reviews => _reviews;

  RatingSummaryModel? _ratingSummary;
  RatingSummaryModel? get ratingSummary => _ratingSummary;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // ✅ قناة Realtime
  RealtimeChannel? _realtimeChannel;

  /// إنشاء تقييم جديد
  Future<bool> createReview({
    required int userId,
    required int appointmentId,
    int? serviceId,
    int? employeeId,
    required int rating,
    String? comment,
    bool isAnonymous = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final review = ReviewModel(
        userId: userId,
        appointmentId: appointmentId,
        serviceId: serviceId,
        employeeId: employeeId,
        rating: rating,
        comment: comment,
        isAnonymous: isAnonymous,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final created = await reviewRepository.createReview(review);

      if (created != null) {
        _reviews.insert(0, created);

        // ✅ إعادة حساب الملخص
        if (serviceId != null) {
          await _refreshRatingSummary(serviceId: serviceId);
        } else if (employeeId != null) {
          await _refreshRatingSummary(employeeId: employeeId);
        }

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _error = 'فشل إضافة التقييم';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// تحديث تقييم
  Future<bool> updateReview(int reviewId, int rating, String? comment) async {
    try {
      final success = await reviewRepository.updateReview(reviewId, rating, comment);

      if (success) {
        final index = _reviews.indexWhere((r) => r.id == reviewId);
        if (index != -1) {
          _reviews[index] = _reviews[index].copyWith(
            rating: rating,
            comment: comment,
            updatedAt: DateTime.now(),
          );

          // ✅ إعادة حساب الملخص
          final review = _reviews[index];
          if (review.serviceId != null) {
            await _refreshRatingSummary(serviceId: review.serviceId);
          } else if (review.employeeId != null) {
            await _refreshRatingSummary(employeeId: review.employeeId);
          }

          notifyListeners();
        }
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// حذف تقييم
  Future<bool> deleteReview(int reviewId) async {
    try {
      final review = _reviews.firstWhere((r) => r.id == reviewId);
      final success = await reviewRepository.deleteReview(reviewId);

      if (success) {
        _reviews.removeWhere((r) => r.id == reviewId);

        // ✅ إعادة حساب الملخص
        if (review.serviceId != null) {
          await _refreshRatingSummary(serviceId: review.serviceId);
        } else if (review.employeeId != null) {
          await _refreshRatingSummary(employeeId: review.employeeId);
        }

        notifyListeners();
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// جلب تقييمات خدمة معينة
  Future<void> fetchServiceReviews(int serviceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reviews = await reviewRepository.getServiceReviews(serviceId);
      _ratingSummary = await reviewRepository.getServiceRatingSummary(serviceId);
    } catch (e) {
      _error = 'فشل تحميل التقييمات';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب تقييمات موظف معين
  Future<void> fetchEmployeeReviews(int employeeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reviews = await reviewRepository.getEmployeeReviews(employeeId);
      _ratingSummary = await reviewRepository.getEmployeeRatingSummary(employeeId);
    } catch (e) {
      _error = 'فشل تحميل التقييمات';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب تقييمات المستخدم
  Future<void> fetchUserReviews(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reviews = await reviewRepository.getUserReviews(userId);
    } catch (e) {
      _error = 'فشل تحميل تقييماتك';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// التحقق من إذا قيّم المستخدم الموعد
  Future<ReviewModel?> checkAppointmentReview(int appointmentId) async {
    try {
      return await reviewRepository.getReviewByAppointment(appointmentId);
    } catch (e) {
      return null;
    }
  }

  /// زيادة عدد "مفيد"
  Future<void> markAsHelpful(int reviewId) async {
    try {
      final success = await reviewRepository.incrementHelpfulCount(reviewId);

      if (success) {
        final index = _reviews.indexWhere((r) => r.id == reviewId);
        if (index != -1) {
          _reviews[index] = _reviews[index].copyWith(
            helpfulCount: _reviews[index].helpfulCount + 1,
          );
          notifyListeners();
        }
      }
    } catch (e) {
    }
  }

  /// ✅ إعادة حساب ملخص التقييمات
  Future<void> _refreshRatingSummary({int? serviceId, int? employeeId}) async {
    try {
      if (serviceId != null) {
        _ratingSummary = await reviewRepository.getServiceRatingSummary(serviceId);
      } else if (employeeId != null) {
        _ratingSummary = await reviewRepository.getEmployeeRatingSummary(employeeId);
      }
    } catch (e) {
    }
  }

  /// ✅ الاشتراك في تحديثات تقييمات خدمة معينة
  void subscribeToServiceReviews(int serviceId) {
    unsubscribeFromReviews();


    _realtimeChannel = _supabase
        .channel('reviews_service_$serviceId')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'reviews',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'service_id',
        value: serviceId,
      ),
      callback: (payload) {

        // إعادة جلب التقييمات
        fetchServiceReviews(serviceId);
      },
    )
        .subscribe();
  }

  /// ✅ الاشتراك في تحديثات تقييمات موظف معين
  void subscribeToEmployeeReviews(int employeeId) {
    unsubscribeFromReviews();


    _realtimeChannel = _supabase
        .channel('reviews_employee_$employeeId')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'reviews',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'employee_id',
        value: employeeId,
      ),
      callback: (payload) {

        // إعادة جلب التقييمات
        fetchEmployeeReviews(employeeId);
      },
    )
        .subscribe();
  }

  /// ✅ إلغاء الاشتراك
  void unsubscribeFromReviews() {
    if (_realtimeChannel != null) {
      _realtimeChannel!.unsubscribe();
      _realtimeChannel = null;
    }
  }

  /// مسح البيانات
  void clear() {
    _reviews = [];
    _ratingSummary = null;
    _error = null;
    unsubscribeFromReviews();
    notifyListeners();
  }

  @override
  void dispose() {
    unsubscribeFromReviews();
    super.dispose();
  }
}