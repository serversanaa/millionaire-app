import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅ أضف هذا
import 'package:intl/date_symbol_data_local.dart';
import 'package:millionaire_barber/core/services/firebase_messaging_service.dart';
import 'package:millionaire_barber/core/themes/app_theme.dart';
import 'package:millionaire_barber/core/themes/theme_provider.dart';
import 'package:millionaire_barber/features/appointments/presentation/providers/multi_appointment_provider.dart';
import 'package:millionaire_barber/features/coupons/data/repositories/coupon_repository.dart';
import 'package:millionaire_barber/features/coupons/presentation/providers/coupon_provider.dart';
import 'package:millionaire_barber/features/home/presentation/providers/banner_provider.dart';
import 'package:millionaire_barber/features/loyalty/data/repositories/loyalty_transaction_repository.dart';
import 'package:millionaire_barber/features/loyalty/presentation/providers/loyalty_transaction_provider.dart';
import 'package:millionaire_barber/features/packages/data/repositories/package_subscription_repository.dart';
import 'package:millionaire_barber/features/packages/data/repositories/packages_repository.dart';
import 'package:millionaire_barber/features/packages/presentation/providers/package_subscription_provider.dart';
import 'package:millionaire_barber/features/packages/presentation/providers/packages_provider.dart';
import 'package:millionaire_barber/features/products/presentation/providers/cart_provider.dart';
import 'package:millionaire_barber/features/products/presentation/providers/order_provider.dart';
import 'package:millionaire_barber/features/products/presentation/providers/product_category_provider.dart';
import 'package:millionaire_barber/features/products/presentation/providers/product_provider.dart';
import 'package:millionaire_barber/features/settings/data/repositories/settings_repository.dart';
import 'package:millionaire_barber/features/settings/presentation/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core imports
import 'core/routes/app_routes.dart';

// Features imports
import 'features/appointments/data/repositories/appointment_repository.dart';
import 'features/appointments/presentation/providers/appointment_provider.dart';
import 'features/favorites/data/repositories/favorite_repository.dart';
import 'features/favorites/presentation/providers/favorite_provider.dart';
import 'features/notifications/data/repositories/notification_repository.dart';
import 'features/notifications/data/services/notification_service.dart';
import 'features/notifications/presentation/providers/notification_provider.dart';
import 'features/offers/data/repositories/offer_repository.dart';
import 'features/offers/presentation/providers/offer_provider.dart';
import 'features/profile/data/repositories/user_repository.dart';
import 'features/profile/presentation/providers/user_provider.dart';
import 'features/reviews/data/repositories/review_repository.dart';
import 'features/reviews/presentation/providers/review_provider.dart';
import 'features/services/data/repositories/services_repository.dart';
import 'features/services/presentation/providers/services_provider.dart';
import 'features/support/data/repositories/support_repository.dart';
import 'features/support/presentation/providers/support_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

// ════════════════════════════════════════════════════════════════════════════
// ✅ MAIN FUNCTION - Entry Point
// ════════════════════════════════════════════════════════════════════════════

void main() async {
  // ✅ تهيئة Flutter Bindings
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ تعطيل كل رسائل debugPrint في وضع الإنتاج
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // ✅ تحميل .env مع معالجة الخطأ
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // يمكنك إضافة قيم افتراضية هنا للتطوير
    dotenv.load(fileName: '''
      WHATSAPP_API_KEY=1316911
    ''');
  }

  // ✅ 1. Global Error Handling
  await _setupErrorHandling();

  // ✅ 2. Initialize App
  await _initializeApp();

  // ✅ 3. Run App
  runApp(
    ErrorBoundary(
      child: const MyApp(),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════════════
// ✅ ERROR HANDLING SETUP
// ════════════════════════════════════════════════════════════════════════════

Future<void> _setupErrorHandling() async {
  // ✅ معالجة أخطاء Flutter Widgets
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);

    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    }

  };

  // ✅ معالجة الأخطاء غير المعالجة (Async)
  PlatformDispatcher.instance.onError = (error, stack) {

    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }

    return true; // منع التطبيق من السقوط
  };
}

// ════════════════════════════════════════════════════════════════════════════
// ✅ APP INITIALIZATION
// ════════════════════════════════════════════════════════════════════════════

Future<void> _initializeApp() async {
  try {

    // ✅ 1. Firebase Core
    await _initializeFirebase();

    // ✅ 2. Firebase Services
    await _initializeFirebaseServices();

    // ✅ 3. Supabase
    await _initializeSupabase();

    // ✅ 4. Other Configurations
    await _configureApp();

  } catch (e, stackTrace) {

    // ✅ لا نوقف التطبيق، نحاول المتابعة
  }
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    rethrow;
  }
}

Future<void> _initializeFirebaseServices() async {
  // ✅ Crashlytics
  try {
    if (!kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }
  } catch (e) {
  }

  // ✅ Performance Monitoring
  try {
    final performance = FirebasePerformance.instance;
    await performance.setPerformanceCollectionEnabled(true);
  } catch (e) {
  }

  // ✅ Firebase Messaging
  try {
    await FirebaseMessagingService().initialize();

    final fcmToken = FirebaseMessagingService().fcmToken;
  } catch (e) {
  }
}

Future<void> _initializeSupabase() async {
  try {
    await Supabase.initialize(
      url: 'https://xdkdyrgkxltixyaeqevb.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhka2R5cmdreGx0aXh5YWVxZXZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgyOTg1MjQsImV4cCI6MjA3Mzg3NDUyNH0.5RKfYp-JO_xhZ3x8bEqr-vYiiFnNBW-IwsNq6vBWo-Y',
    );
  } catch (e) {
    rethrow;
  }
}

Future<void> _configureApp() async {
  // ✅ Date Formatting
  try {
    await initializeDateFormatting('ar', null);
  } catch (e) {
  }

  // ✅ Screen Orientation
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
  }

  // ✅ System UI Styling
  try {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  } catch (e) {
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ✅ ERROR BOUNDARY WIDGET
// ════════════════════════════════════════════════════════════════════════════

class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({Key? key, required this.child}) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  ErrorDetails? _error;

  @override
  void initState() {
    super.initState();

    // ✅ Custom Error Widget Builder
    ErrorWidget.builder = (FlutterErrorDetails details) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _error = ErrorDetails(
              message: details.exception.toString(),
              stackTrace: details.stack.toString(),
            );
          });
        }
      });

      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA62424)),
          ),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ErrorScreen(
          error: _error!,
          onRetry: () {
            setState(() => _error = null);
          },
        ),
      );
    }

    return widget.child;
  }
}

class ErrorDetails {
  final String message;
  final String stackTrace;

  ErrorDetails({required this.message, required this.stackTrace});
}

// ════════════════════════════════════════════════════════════════════════════
// ✅ ERROR SCREEN
// ════════════════════════════════════════════════════════════════════════════

class ErrorScreen extends StatelessWidget {
  final ErrorDetails error;
  final VoidCallback onRetry;

  const ErrorScreen({
    Key? key,
    required this.error,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            // ✅ أضف هذا
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.15), // ✅ مسافة مرنة

                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 60,
                      color: Colors.red.shade400,
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    'عذراً، حدث خطأ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Cairo',
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'نعمل على إصلاح المشكلة\nالرجاء المحاولة مرة أخرى',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontFamily: 'Cairo',
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: onRetry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA62424),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh_rounded, size: 24),
                          SizedBox(width: 8),
                          Text(
                            'إعادة المحاولة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (kDebugMode) ...[
                    const SizedBox(height: 24),
                    ExpansionTile(
                      title: const Text(
                        'تفاصيل الخطأ (Debug)',
                        style: TextStyle(fontSize: 14),
                      ),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            error.message,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.1), // ✅ مسافة مرنة
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// ✅ MY APP
// ════════════════════════════════════════════════════════════════════════════

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            // ✅ 1. ThemeProvider أولاً
            ChangeNotifierProvider(
              create: (_) => ThemeProvider(),
            ),

            // ✅ 2. باقي الـ Providers
            ChangeNotifierProvider(
              create: (_) => UserProvider(
                userRepository: UserRepository(Supabase.instance.client),
              ),
            ),

            ChangeNotifierProvider(
              create: (_) => ServicesProvider(
                servicesRepository:
                    ServicesRepository(Supabase.instance.client),
              ),
            ),

            ChangeNotifierProvider(
              create: (_) => OfferProvider(
                offerRepository: OfferRepository(Supabase.instance.client),
              ),
            ),

            ChangeNotifierProvider(
              create: (_) => AppointmentProvider(
                repository: AppointmentRepository(Supabase.instance.client),
              ),
            ),

            ChangeNotifierProvider(
              create: (_) {
                final provider = NotificationProvider(
                  notificationRepository:
                      NotificationRepository(Supabase.instance.client),
                  notificationService: NotificationService(),
                );
                provider.initializeNotifications();
                return provider;
              },
            ),

            ChangeNotifierProvider(
              create: (_) => ReviewProvider(
                reviewRepository: ReviewRepository(Supabase.instance.client),
              ),
            ),

            ChangeNotifierProvider(
              create: (_) => FavoriteProvider(
                favoriteRepository:
                    FavoriteRepository(Supabase.instance.client),
              ),
            ),

            ChangeNotifierProvider(
              create: (_) => CouponProvider(
                couponRepository: CouponRepository(),
              ),
            ),

            ChangeNotifierProvider(
              create: (_) => SupportProvider(
                supportRepository: SupportRepository(Supabase.instance.client),
              ),
            ),

            ChangeNotifierProvider(
              create: (_) => SettingsProvider(
                repository: SettingsRepository(Supabase.instance.client),
              ),
            ),

            ChangeNotifierProvider(
              create: (_) => LoyaltyTransactionProvider(
                repository:
                    LoyaltyTransactionRepository(Supabase.instance.client),
              ),
            ),
            // ✅ 3. PackagesProvider (جديد)
            ChangeNotifierProvider(
              create: (_) => PackagesProvider(
                PackagesRepository(Supabase.instance.client),
              ),
            ),
            // ✅ 3. PackagesProvider
            ChangeNotifierProvider(
              create: (_) => PackagesProvider(
                PackagesRepository(Supabase.instance.client),
              ),
            ),
            ChangeNotifierProvider(
              create: (_) => PackageSubscriptionProvider(
                repository: PackageSubscriptionRepository(),
              ),
            ),
            ChangeNotifierProvider(create: (_) => ProductCategoryProvider()),
            ChangeNotifierProvider(create: (_) => ProductProvider()),
            ChangeNotifierProvider(create: (_) => OrderProvider()),
            ChangeNotifierProvider(create: (_) => CartProvider()),
            // ✅ صحيح - أنشئه مباشرة
            ChangeNotifierProvider(
              create: (_) => MultiAppointmentProvider(
                repository: AppointmentRepository(Supabase.instance.client),
              ),
            ),
            ChangeNotifierProvider(create: (_) => BannerProvider()),


          ],

          // ✅ Consumer داخل MultiProvider
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                title: 'مركز المليونير',
                debugShowCheckedModeBanner: false,

                // Themes
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,

                // Localization
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('ar', 'SA'),
                  Locale('en', 'US'),
                ],
                locale: const Locale('ar', 'SA'),

                // Routes
                initialRoute: AppRoutes.splash,
                routes: AppRoutes.routes,

                // Text scaling
                builder: (context, widget) {
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: const TextScaler.linear(1.0),
                    ),
                    child: widget!,
                  );
                },

                // Unknown route
                onUnknownRoute: (settings) {
                  return MaterialPageRoute(
                    builder: (context) => _buildNotFoundScreen(context),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNotFoundScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خطأ'),
        backgroundColor: const Color(0xFFA62424),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 100,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 30),
              const Text(
                'الصفحة غير موجودة',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'عذراً، الصفحة المطلوبة غير متاحة',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text(
                  'العودة للرئيسية',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA62424),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}