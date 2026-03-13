// lib/features/reviews/domain/models/rating_summary_model.dart
class RatingSummaryModel {
  final int totalReviews;
  final double averageRating;
  final int rating5Star;
  final int rating4Star;
  final int rating3Star;
  final int rating2Star;
  final int rating1Star;
  final DateTime updatedAt;

  RatingSummaryModel({
    required this.totalReviews,
    required this.averageRating,
    required this.rating5Star,
    required this.rating4Star,
    required this.rating3Star,
    required this.rating2Star,
    required this.rating1Star,
    required this.updatedAt,
  });

  factory RatingSummaryModel.fromJson(Map<String, dynamic> json) {
    return RatingSummaryModel(
      totalReviews: json['total_reviews'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      rating5Star: json['rating_5_star'] as int? ?? 0,
      rating4Star: json['rating_4_star'] as int? ?? 0,
      rating3Star: json['rating_3_star'] as int? ?? 0,
      rating2Star: json['rating_2_star'] as int? ?? 0,
      rating1Star: json['rating_1_star'] as int? ?? 0,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // حساب نسبة كل تقييم
  double getPercentage(int starCount) {
    if (totalReviews == 0) return 0.0;
    return (starCount / totalReviews) * 100;
  }

  // حساب عدد التقييمات لنجمة معينة
  int getStarCount(int stars) {
    switch (stars) {
      case 5:
        return rating5Star;
      case 4:
        return rating4Star;
      case 3:
        return rating3Star;
      case 2:
        return rating2Star;
      case 1:
        return rating1Star;
      default:
        return 0;
    }
  }

  factory RatingSummaryModel.empty() {
    return RatingSummaryModel(
      totalReviews: 0,
      averageRating: 0.0,
      rating5Star: 0,
      rating4Star: 0,
      rating3Star: 0,
      rating2Star: 0,
      rating1Star: 0,
      updatedAt: DateTime.now(),
    );
  }
}
