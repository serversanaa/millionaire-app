import 'package:flutter/material.dart';
import 'package:millionaire_barber/features/appointments/presentation/pages/appointment_history_screen.dart';
import 'package:millionaire_barber/features/appointments/presentation/pages/book_appointment_screen.dart';
import 'package:millionaire_barber/features/favorites/presentation/pages/favorites_screen.dart';
import 'package:millionaire_barber/features/home/presentation/screens/home_screen.dart';
import 'package:millionaire_barber/features/loyalty/presentation/pages/loyalty_screen.dart';
import 'package:millionaire_barber/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:millionaire_barber/features/offers/presentation/pages/offer_screen.dart';
import 'package:millionaire_barber/features/packages/presentation/pages/my_subscriptions_screen.dart';
import 'package:millionaire_barber/features/packages/presentation/pages/packages_screen.dart';
import 'package:millionaire_barber/features/services/domain/models/service_model.dart';
import 'package:millionaire_barber/features/services/presentation/pages/services_screen.dart';
import 'package:millionaire_barber/features/settings/presentation/pages/settings_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/authentication/presentation/pages/login_screen.dart';
import '../../features/authentication/presentation/pages/register_screen.dart';
import '../../features/profile/presentation/pages/profile_screen.dart';
import '../../features/appointments/presentation/pages/my_appointments_screen.dart';
// ✅ إضافة الشاشات المفقودة (سنضيف نسخة بسيطة منها)

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String services = '/services';
  static const String packages = '/packages'; // ✅ إضافة Route الباقات
  static const String appointments = '/appointments';
  static const String myAppointments = '/my-appointments';
  static const String notifications = '/notifications';
  static const String favorites = '/favorites';
  static const String history = '/history';
  static const String offers = '/offers';
  static const String loyalty = '/loyalty';
  static const String settings = '/settings';
  static const String support = '/support';
  static const String mysubscriptions = '/my-subscriptions';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingPage(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      home: (context) => const HomeScreen(),
      profile: (context) => const ProfileScreen(),
      services: (context) => const ServicesScreen(),
      packages: (context) => const PackagesScreen(),
      myAppointments: (context) => const MyAppointmentsScreen(),
      notifications: (context) => const NotificationsScreen(),
      favorites: (context) => const FavoritesScreen(),
      history: (context) => const AppointmentHistoryScreen(),
      offers: (context) => const OffersScreen(),
      settings: (context) => const SettingsScreen(),
      loyalty: (context) => const LoyaltyScreen(),
      mysubscriptions: (context) => const MySubscriptionsScreen(),

      // ✅ شاشات مؤقتة (سننشئها)
      support: (context) => const PlaceholderScreen(title: 'الدعم'),
    };
  }

  // ✅ دالة خاصة للانتقال إلى BookAppointment
  static Future<T?> navigateToBookAppointment<T>({
    required BuildContext context,
    required ServiceModel service,
    Map<String, dynamic>? appliedOffer,
    int? offerId,
    String? promoCode,
  }) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        // builder: (context) => BookAppointmentScreen(service: service),
        builder: (context) => BookAppointmentScreen(services: [service]),
        settings: RouteSettings(
          arguments: {
            if (appliedOffer != null) 'applied_offer': appliedOffer,
            if (offerId != null) 'offer_id': offerId,
            if (promoCode != null) 'promo_code': promoCode,
          },
        ),
      ),
    );
  }

  static void navigateAndReplace(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  static void navigate(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  static void navigateAndRemoveUntil(BuildContext context, String routeName) {
    Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
  }

  static Future<T?> navigateWithData<T>(BuildContext context, Widget screen) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  static Future<T?> navigateAndReplaceWithData<T>(
      BuildContext context, Widget screen) {
    return Navigator.pushReplacement<T, void>(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}

// ✅ شاشة مؤقتة للشاشات المفقودة
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF8B0000),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'قريباً...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
