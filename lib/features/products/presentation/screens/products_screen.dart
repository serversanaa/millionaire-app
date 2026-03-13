import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../../shared/widgets/product_page_transitions.dart';
import '../../data/models/product_model.dart';
import '../providers/product_provider.dart';
import '../providers/product_category_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'product_details_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  // ✅ Controllers
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _headerAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _headerAnimation;

  // ✅ State Variables
  bool _showFloatingSearch = false;
  String _selectedSortOption = 'الأحدث';
  double _minPrice = 0;
  double _maxPrice = 5000;
  bool _showAvailableOnly = false;
  bool _showDiscountedOnly = false;
  bool _isFiltered = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    _loadInitialData();
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    );

    _headerAnimationController.forward();
    _fabAnimationController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (!mounted) return;

      final offset = _scrollController.offset;

      if (offset > 200 && !_showFloatingSearch) {
        setState(() => _showFloatingSearch = true);
      } else if (offset <= 200 && _showFloatingSearch) {
        setState(() => _showFloatingSearch = false);
      }
    });
  }



// ✅ الكود الصحيح
  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // ✅ جلب الفئات دائماً
      context.read<ProductCategoryProvider>().fetchCategories();

      // ✅ جلب المنتجات دائماً
      context.read<ProductProvider>().fetchProducts();

      debugPrint('🔄 Loading products and categories...');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _headerAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF5F7FA),
        extendBodyBehindAppBar: true,

        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildAnimatedHeader(isDark),
                _buildSearchSection(isDark),
                _buildCategoriesSection(),
                _buildProductsGrid(),
                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            ),

            Positioned(
              bottom: 20.h,
              right: 20.w,
              child: _buildFloatingCartButton(),
            ),

            if (_showFloatingSearch) _buildFloatingSearch(isDark),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ✅ 1. ANIMATED HEADER
  // ════════════════════════════════════════════════════════════

  Widget _buildAnimatedHeader(bool isDark) {
    return SliverAppBar(
      expandedHeight: 220.h,
      floating: false,
      pinned: true,
      elevation: 0,
      stretch: true,
      backgroundColor: Colors.transparent,

      leading: _buildHeaderButton(
        icon: Icons.arrow_back,
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
      ),

      actions: [
        Padding(
          padding: EdgeInsets.all(8.w),
          child: _buildCartHeaderButton(),
        ),
      ],

      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: _buildHeaderBackground(isDark),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha:0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha:0.3)),
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onPressed,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildCartHeaderButton() {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha:0.3),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha:0.3)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                onPressed: _navigateToCart,
              ),
              if (cart.itemCount > 0)
                Positioned(
                  top: 6.h,
                  right: 6.w,
                  child: _buildCartBadge(cart.itemCount),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartBadge(int count) {
    return Container(
      padding: EdgeInsets.all(4.w),
      constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.h),
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildHeaderBackground(bool isDark) {
    return FadeTransition(
      opacity: _headerAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark
                ? [
              const Color(0xFFB8860B),
              const Color(0xFF8B6914),
              const Color(0xFF6B5010),
            ]
                : [
              const Color(0xFFFFD700),
              const Color(0xFFB8860B),
              const Color(0xFF8B6914),
            ],
          ),
        ),
        child: Stack(
          children: [
            ..._buildAnimatedParticles(),
            _buildHeaderContent(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAnimatedParticles() {
    return List.generate(15, (index) {
      return Positioned(
        left: (index * 60.0) % MediaQuery.of(context).size.width,
        top: (index * 90.0) % 200.h,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 1500 + (index * 100)),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, -value * 40),
              child: Opacity(
                opacity: (1 - value) * 0.6,
                child: Container(
                  width: 4.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildHeaderContent() {
    return Positioned(
      bottom: 40.h,
      right: 20.w,
      left: 20.w,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withValues(alpha:0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'منتجاتنا المميزة',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'اكتشف أفضل المنتجات الحصرية',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white.withValues(alpha:0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ✅ 2. SEARCH SECTION
  // ════════════════════════════════════════════════════════════

  Widget _buildSearchSection(bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _headerAnimationController,
            curve: Curves.easeOut,
          )),
          child: _buildSearchBar(isDark),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      height: 54.h,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha:0.3)
                : const Color(0xFFB8860B).withValues(alpha:0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              textDirection: TextDirection.rtl,
              style: TextStyle(fontSize: 15.sp),
              decoration: InputDecoration(
                hintText: 'ابحث عن منتجك المفضل...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: const Color(0xFFB8860B),
                  size: 24.sp,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, size: 20.sp, color: Colors.grey),
                  onPressed: _clearSearch,
                )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
              ),
              onChanged: _handleSearchChange,
            ),
          ),
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      margin: EdgeInsets.only(left: 8.w),
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showFilterBottomSheet(context),
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB8860B), Color(0xFF8B6914)],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.tune_rounded, color: Colors.white, size: 22.sp),
              ),
            ),
          ),
          if (_isFiltered)
            Positioned(
              top: 4.w,
              right: 4.w,
              child: Container(
                width: 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<ProductProvider>().clearSearch();
    context.read<ProductProvider>().fetchProducts();
    setState(() {});
  }

  void _handleSearchChange(String value) {
    if (value.isEmpty) {
      context.read<ProductProvider>().clearSearch();
      context.read<ProductProvider>().fetchProducts();
    } else if (value.length >= 2) {
      context.read<ProductProvider>().searchProducts(value);
    }
    setState(() {});
  }

  // ════════════════════════════════════════════════════════════
  // ✅ 3. CATEGORIES SECTION
  // ════════════════════════════════════════════════════════════

  Widget _buildCategoriesSection() {
    return Consumer<ProductCategoryProvider>(
      builder: (context, categoryProvider, _) {
        if (categoryProvider.isLoading || categoryProvider.categories.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoriesHeader(),
              _buildCategoriesList(categoryProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 12.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 20.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB8860B), Color(0xFF8B6914)],
              ),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'التصنيفات',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(ProductCategoryProvider categoryProvider) {
    return Container(
      height: 48.h,
      margin: EdgeInsets.only(bottom: 20.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        physics: const BouncingScrollPhysics(),
        itemCount: categoryProvider.categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip(
              label: 'الكل',
              isSelected: categoryProvider.selectedCategory == null,
              onTap: () {
                categoryProvider.clearSelectedCategory();
                context.read<ProductProvider>().fetchProducts();
              },
            );
          }

          final category = categoryProvider.categories[index - 1];
          return _buildCategoryChip(
            label: category.name,
            isSelected: categoryProvider.selectedCategory?.id == category.id,
            onTap: () {
              categoryProvider.selectCategory(category);
              context.read<ProductProvider>().fetchProductsByCategory(category.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: 10.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                colors: [Color(0xFFB8860B), Color(0xFF8B6914)],
              )
                  : null,
              color: isSelected ? null : Colors.grey[200],
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: const Color(0xFFB8860B).withValues(alpha:0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ✅ 4. PRODUCTS GRID
  // ════════════════════════════════════════════════════════════

  Widget _buildProductsGrid() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, _) {
        if (productProvider.isLoading || productProvider.isSearching) {
          return _buildLoadingState();
        }

        final products = _searchController.text.isNotEmpty
            ? productProvider.searchResults
            : productProvider.products;

        if (products.isEmpty) {
          return SliverFillRemaining(child: _buildEmptyState());
        }

        return SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildProductItem(products[index], index),
              childCount: products.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductItem(Product product, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(
        milliseconds: (300 + (index * 50)).clamp(300, 800),
      ),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Opacity(
            opacity: value,
            child: Hero(
              tag: 'product-${product.id}',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _navigateToProductDetails(product),
                  borderRadius: BorderRadius.circular(16.r),
                  child: ProductCard(product: product),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToProductDetails(Product product) {
    HapticFeedback.mediumImpact();

    context.pushParticles(
      ProductDetailsScreen(product: product),
      particleColor: const Color(0xFFB8860B),
    );
  }

  Widget _buildLoadingState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 2 * math.pi,
                  child: Container(
                    width: 60.w,
                    height: 60.h,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFB8860B), Color(0xFF8B6914)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 30.sp,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20.h),
            Text(
              'جاري تحميل المنتجات...',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFB8860B).withValues(alpha:0.2),
                  const Color(0xFF8B6914).withValues(alpha:0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 60.sp,
              color: const Color(0xFFB8860B),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'لا توجد منتجات',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              _searchController.text.isNotEmpty
                  ? 'لم نجد نتائج لبحثك، جرب كلمات أخرى'
                  : 'لا توجد منتجات متاحة حالياً',
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.grey[500],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ✅ 5. FLOATING ELEMENTS
  // ════════════════════════════════════════════════════════════

  Widget _buildFloatingCartButton() {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        if (cart.isEmpty) return const SizedBox.shrink();

        return ScaleTransition(
          scale: CurvedAnimation(
            parent: _fabAnimationController,
            curve: Curves.elasticOut,
          ),
          child: GestureDetector(
            onTap: _navigateToCart,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB8860B), Color(0xFF8B6914)],
                ),
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB8860B).withValues(alpha:0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      Icon(Icons.shopping_cart, color: Colors.white, size: 24.sp),
                      Positioned(
                        top: -2,
                        right: -2,
                        child: _buildCartBadge(cart.itemCount),
                      ),
                    ],
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '${cart.totalPrice.toStringAsFixed(0)} ر.ي',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingSearch(bool isDark) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8.h,
      left: 20.w,
      right: 20.w,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _fabAnimationController,
          curve: Curves.easeOut,
        )),
        child: Container(
          height: 50.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(25.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: const Color(0xFFB8860B), size: 22.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  _searchController.text.isEmpty
                      ? 'ابحث عن منتجك المفضل...'
                      : _searchController.text,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: _searchController.text.isEmpty
                        ? Colors.grey
                        : (isDark ? Colors.white : Colors.black87),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ✅ 6. FILTER BOTTOM SHEET
  // ════════════════════════════════════════════════════════════

  void _showFilterBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الفلترة والترتيب',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _resetFilters();
                          });
                        },
                        child: Text(
                          'إعادة تعيين',
                          style: TextStyle(
                            color: const Color(0xFFB8860B),
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1.h),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSortOptions(setModalState),
                        SizedBox(height: 24.h),
                        _buildPriceRange(setModalState, isDark),
                        SizedBox(height: 24.h),
                        _buildQuickFilters(setModalState),
                      ],
                    ),
                  ),
                ),
                _buildApplyButton(isDark, bottomSheetContext),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortOptions(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الترتيب حسب',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: [
            'الأحدث',
            'الأقدم',
            'الأعلى سعراً',
            'الأقل سعراً',
            'الأكثر مبيعاً',
            'الأعلى تقييماً',
          ].map((option) {
            final isSelected = _selectedSortOption == option;
            return GestureDetector(
              onTap: () {
                setModalState(() => _selectedSortOption = option);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFB8860B) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceRange(StateSetter setModalState, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نطاق السعر',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildPriceBox('من', _minPrice, isDark),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildPriceBox('إلى', _maxPrice, isDark),
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(_minPrice, _maxPrice),
          min: 0,
          max: 5000,
          divisions: 100,
          activeColor: const Color(0xFFB8860B),
          inactiveColor: Colors.grey[300],
          labels: RangeLabels(
            '${_minPrice.toInt()}',
            '${_maxPrice.toInt()}',
          ),
          onChanged: (RangeValues values) {
            setModalState(() {
              _minPrice = values.start;
              _maxPrice = values.end;
            });
          },
        ),
      ],
    );
  }

  Widget _buildPriceBox(String label, double value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '${value.toInt()} ر.ي',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilters(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'فلاتر سريعة',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        _buildSwitchTile(
          title: 'المنتجات المتاحة فقط',
          subtitle: 'إخفاء المنتجات غير المتوفرة',
          value: _showAvailableOnly,
          onChanged: (value) {
            setModalState(() => _showAvailableOnly = value);
          },
        ),
        SizedBox(height: 12.h),
        _buildSwitchTile(
          title: 'العروض فقط',
          subtitle: 'المنتجات التي عليها خصم',
          value: _showDiscountedOnly,
          onChanged: (value) {
            setModalState(() => _showDiscountedOnly = value);
          },
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2C2C2C)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFB8860B),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton(bool isDark, BuildContext bottomSheetContext) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: () {
              _applyFilters();
              Navigator.pop(bottomSheetContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB8860B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'تطبيق الفلترة',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // ✅ HELPER METHODS
  // ════════════════════════════════════════════════════════════

  void _navigateToCart() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedSortOption = 'الأحدث';
      _minPrice = 0;
      _maxPrice = 5000;
      _showAvailableOnly = false;
      _showDiscountedOnly = false;
      _isFiltered = false;
    });
  }

  void _applyFilters() {
    final productProvider = context.read<ProductProvider>();
    List<Product> filteredProducts = [...productProvider.products];

    filteredProducts = filteredProducts.where((product) {
      return product.finalPrice >= _minPrice && product.finalPrice <= _maxPrice;
    }).toList();

    if (_showAvailableOnly) {
      filteredProducts = filteredProducts.where((p) => p.isAvailable).toList();
    }

    if (_showDiscountedOnly) {
      filteredProducts = filteredProducts.where((p) => p.hasDiscount).toList();
    }

    switch (_selectedSortOption) {
      case 'الأحدث':
        filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'الأقدم':
        filteredProducts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'الأعلى سعراً':
        filteredProducts.sort((a, b) => b.finalPrice.compareTo(a.finalPrice));
        break;
      case 'الأقل سعراً':
        filteredProducts.sort((a, b) => a.finalPrice.compareTo(b.finalPrice));
        break;
      case 'الأكثر مبيعاً':
        filteredProducts.sort((a, b) => b.salesCount.compareTo(a.salesCount));
        break;
      case 'الأعلى تقييماً':
        filteredProducts.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));
        break;
    }

    setState(() {
      _isFiltered = filteredProducts.length != productProvider.products.length ||
          _selectedSortOption != 'الأحدث' ||
          _minPrice != 0 ||
          _maxPrice != 5000 ||
          _showAvailableOnly ||
          _showDiscountedOnly;
    });
  }
}
