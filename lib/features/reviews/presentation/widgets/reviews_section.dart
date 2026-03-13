// lib/features/reviews/presentation/widgets/reviews_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/review_provider.dart';
import '../../domain/models/review_model.dart';
import '../../domain/models/rating_summary_model.dart';
import 'dart:ui' as ui;

class ReviewsSection extends StatelessWidget {
  final int serviceId;
  final int? employeeId;

  const ReviewsSection({
    Key? key,
    required this.serviceId,
    this.employeeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, _) {
        if (reviewProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final summary = reviewProvider.ratingSummary;
        final reviews = reviewProvider.reviews;

        if (summary == null || summary.totalReviews == 0) {
          return _buildEmptyState(isDark);
        }

        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRatingSummary(summary, isDark),
              const SizedBox(height: 24),
              _buildRatingDistribution(summary, isDark),
              const SizedBox(height: 24),
              _buildReviewsList(reviews, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 60,
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد تقييمات بعد',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'كن أول من يقيّم هذه الخدمة',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(RatingSummaryModel summary, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                summary.averageRating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.black,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < summary.averageRating.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.gold,
                    size: 20,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '${summary.totalReviews} تقييم',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRatingBar(
                    5, summary.getStarCount(5), summary.totalReviews, isDark),
                const SizedBox(height: 8),
                _buildRatingBar(
                    4, summary.getStarCount(4), summary.totalReviews, isDark),
                const SizedBox(height: 8),
                _buildRatingBar(
                    3, summary.getStarCount(3), summary.totalReviews, isDark),
                const SizedBox(height: 8),
                _buildRatingBar(
                    2, summary.getStarCount(2), summary.totalReviews, isDark),
                const SizedBox(height: 8),
                _buildRatingBar(
                    1, summary.getStarCount(1), summary.totalReviews, isDark),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildRatingBar(int stars, int count, int total, bool isDark) {
    final percentage = total > 0 ? (count / total) : 0.0;

    return Row(
      children: [
        Text(
          '$stars',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.star, color: AppColors.gold, size: 12),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerRight,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingDistribution(RatingSummaryModel summary, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn(
              'ممتاز', summary.rating5Star, AppColors.gold, isDark),
          _buildStatColumn(
              'جيد جداً', summary.rating4Star, Colors.green, isDark),
          _buildStatColumn('جيد', summary.rating3Star, Colors.orange, isDark),
          _buildStatColumn(
              'مقبول', summary.rating2Star, Colors.deepOrange, isDark),
          _buildStatColumn(
              'ضعيف', summary.rating1Star, AppColors.error, isDark),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int count, Color color, bool isDark) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsList(List<ReviewModel> reviews, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'آراء العملاء',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.black,
              ),
            ),
            Text(
              '${reviews.length} تقييم',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            return _buildReviewCard(reviews[index], isDark)
                .animate(delay: Duration(milliseconds: 50 * index))
                .fadeIn()
                .slideX(begin: 0.2);
          },
        ),
      ],
    );
  }

  Widget _buildReviewCard(ReviewModel review, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.darkRed.withOpacity(0.1),
                backgroundImage: review.userImageUrl != null &&
                        review.userImageUrl!.isNotEmpty
                    ? NetworkImage(review.userImageUrl!)
                    : null,
                child:
                    review.userImageUrl == null || review.userImageUrl!.isEmpty
                        ? const Icon(Icons.person,
                            color: AppColors.darkRed, size: 20)
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.isAnonymous
                          ? 'مستخدم مجهول'
                          : (review.userName ?? 'مستخدم'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(review.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_outline,
                    color: AppColors.gold,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade300 : AppColors.greyDark,
                height: 1.5,
              ),
            ),
          ],
          if (review.helpfulCount > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.thumb_up_outlined,
                  size: 14,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '${review.helpfulCount} شخص وجدوا هذا مفيداً',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'منذ $weeks ${weeks == 1 ? "أسبوع" : "أسابيع"}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'منذ $months ${months == 1 ? "شهر" : "أشهر"}';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}
