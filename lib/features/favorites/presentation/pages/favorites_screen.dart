// lib/features/favorites/presentation/pages/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:millionaire_barber/features/favorites/domain/models/favorite_model.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../profile/presentation/providers/user_provider.dart';
import '../../../services/presentation/pages/service_detail_screen.dart';
import '../providers/favorite_provider.dart';
import 'dart:ui' as ui;

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  Future<void> _loadFavorites() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);

    if (userProvider.user != null) {
      await favoriteProvider.fetchFavorites(userProvider.user!.id!);
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
        body: Consumer<FavoriteProvider>(
          builder: (context, favoriteProvider, _) {
            if (favoriteProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.darkRed),
              );
            }

            if (favoriteProvider.favorites.isEmpty) {
              return _buildEmptyState(isDark);
            }

            return RefreshIndicator(
              onRefresh: _loadFavorites,
              color: AppColors.darkRed,
              child: Column(
                children: [
                  _buildHeader(favoriteProvider.favoritesCount, isDark),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: favoriteProvider.favorites.length,
                      itemBuilder: (context, index) {
                        final favorite = favoriteProvider.favorites[index];
                        return _buildFavoriteCard(favorite, index, isDark);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: isDark ? Colors.white : AppColors.black,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'المفضلة',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.black,
        ),
      ),
      centerTitle: true,
      actions: [
        Consumer<FavoriteProvider>(
          builder: (context, favoriteProvider, _) {
            if (favoriteProvider.favorites.isEmpty) {
              return const SizedBox.shrink();
            }

            return IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: isDark ? Colors.white : AppColors.black,
              ),
              onPressed: () => _showClearAllDialog(isDark),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(int count, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkRed.withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: AppColors.darkRed, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خدماتي المفضلة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count ${count == 1 ? "خدمة" : "خدمات"}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildFavoriteCard(FavoriteModel favorite, int index, bool isDark) {
    final service = favorite.service;

    if (service == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceDetailScreen(service: service),
          ),
        );
      },
      child: Container(
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
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: (service.imageUrl != null && service.imageUrl!.isNotEmpty)
                        ? Image.network(
                      service.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(isDark),
                    )
                        : _buildPlaceholder(isDark),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _removeFavorite(service.id ?? 0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha:0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.serviceNameAr ?? service.serviceName ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            '${service.durationMinutes ?? 0} د',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                      Text(
                        '${(service.price ?? 0).toStringAsFixed(0)} ريال',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate(delay: Duration(milliseconds: 50 * index)).fadeIn().scale(),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
      child: Center(
        child: Icon(
          Icons.content_cut_rounded,
          size: 50,
          color: isDark ? Colors.grey.shade700 : AppColors.gold.withValues(alpha:0.5),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: (isDark ? Colors.grey.shade900 : AppColors.greyLight).withValues(alpha:0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 80,
              color: isDark ? Colors.grey.shade700 : AppColors.greyMedium,
            ),
          ).animate().scale(duration: 600.ms),
          const SizedBox(height: 24),
          Text(
            'لا توجد خدمات مفضلة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.black,
            ),
          ).animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 8),
          Text(
            'أضف خدماتك المفضلة لسهولة الوصول إليها',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade500 : AppColors.greyDark,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 300.ms).fadeIn(),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.search_rounded),
            label: const Text('استكشف الخدمات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ).animate(delay: 400.ms).fadeIn().scale(),
        ],
      ),
    );
  }

  Future<void> _removeFavorite(int serviceId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);

    if (userProvider.user == null) return;

    final success = await favoriteProvider.toggleFavorite(
      userProvider.user!.id!,
      serviceId,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم الحذف من المفضلة'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showClearAllDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'مسح الكل',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'هل أنت متأكد من حذف جميع الخدمات المفضلة؟',
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : AppColors.greyDark,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                final favoriteProvider = Provider.of<FavoriteProvider>(context, listen: false);

                if (userProvider.user != null) {
                  await favoriteProvider.clearAllFavorites(userProvider.user!.id!);

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ تم مسح جميع المفضلات'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('مسح الكل'),
            ),
          ],
        ),
      ),
    );
  }
}
