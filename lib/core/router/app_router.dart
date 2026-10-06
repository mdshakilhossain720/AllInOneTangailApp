import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/auth/login_screen.dart';
import '../../features/auth/onboarding_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../data/models.dart' show ServiceKind;
import '../../features/explore/business/business_screens.dart';
import '../../features/explore/community/community_screen.dart';
import '../../features/explore/daily/bazar_prayer_screens.dart';
import '../../features/explore/daily/education_screen.dart';
import '../../features/explore/daily/jobs_screens.dart';
import '../../features/explore/daily/news_screens.dart';
import '../../features/explore/explore_screen.dart';
import '../../features/explore/health/blood_screen.dart';
import '../../features/explore/health/doctors_screen.dart';
import '../../features/explore/health/hospitals_screen.dart';
import '../../features/explore/health/services_screens.dart';
import '../../features/explore/legal/lawyers_screen.dart';
import '../../features/explore/travel/tourism_screen.dart';
import '../../features/explore/travel/transport_screen.dart';
import '../../features/home/categories_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/notifications_screen.dart';
import '../../features/profile/profile_pages.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/settings_screen.dart';
import '../../features/saved/saved_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/shop/cart_screen.dart';
import '../../features/shop/chat_screen.dart';
import '../../features/shop/checkout_screen.dart';
import '../../features/shop/order_success_screen.dart';
import '../../features/shop/orders_screen.dart';
import '../../features/shop/product_detail_screen.dart';
import '../../features/shop/product_list_screen.dart';
import '../../features/shop/shop_home_screen.dart';
import '../../features/shop/store_screen.dart';
import '../../features/shop/wallet_screen.dart';
import '../../features/seller/product_editor_screen.dart';
import '../../features/seller/seller_dashboard_screen.dart';
import '../../features/seller/seller_onboarding_screen.dart';
import '../../features/seller/seller_orders_screen.dart';
import '../../features/seller/seller_products_screen.dart';
import '../../features/seller/store_settings_screen.dart';
import '../../widgets/widgets.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Shorthand for a top-level (full-screen, over the shell) route.
GoRoute _page(String path, Widget Function(GoRouterState s) build) => GoRoute(path: path, builder: (_, s) => build(s));

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      _page('/splash', (_) => const SplashScreen()),
      _page('/onboarding', (_) => const OnboardingScreen()),
      _page('/login', (_) => const LoginScreen()),
      _page('/otp', (s) => OtpScreen(phone: s.uri.queryParameters['phone'] ?? '')),
      _page('/location', (s) => LocationPickerScreen(fromSettings: s.uri.queryParameters['from'] == 'settings')),
      StatefulShellRoute(
        builder: (context, state, shell) => shell,
        navigatorContainerBuilder: (context, shell, children) => AppShell(shell: shell, children: children),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/explore', builder: (_, _) => const ExploreScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/shop', builder: (_, _) => const ShopHomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/saved', builder: (_, _) => const SavedScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen())],
          ),
        ],
      ),
      _page(
        '/search',
        (s) => SearchScreen(
          startWithVoice: s.uri.queryParameters['voice'] == '1',
          initialQuery: s.uri.queryParameters['q'] ?? '',
        ),
      ),
      _page('/notifications', (_) => const NotificationsScreen()),
      _page('/categories', (_) => const CategoriesScreen()),

      // ---- Explore modules
      _page('/explore/hospitals', (_) => const HospitalsScreen()),
      _page('/explore/hospitals/:id', (s) => HospitalDetailScreen(id: s.pathParameters['id']!)),
      _page('/explore/doctors', (_) => const DoctorsScreen()),
      _page('/explore/doctors/:id', (s) => DoctorDetailScreen(id: s.pathParameters['id']!)),
      _page('/explore/ambulance', (_) => const AmbulanceScreen()),
      _page('/explore/blood', (_) => const BloodDonorsScreen()),
      _page('/explore/blood/register', (_) => const RegisterDonorScreen()),
      _page('/explore/blood/request', (_) => const RequestBloodScreen()),
      _page('/explore/police', (_) => const EmergencyServiceScreen(kind: ServiceKind.police)),
      _page('/explore/fire', (_) => const EmergencyServiceScreen(kind: ServiceKind.fire)),
      _page('/explore/govt', (_) => const GovtOfficesScreen()),
      _page('/explore/lawyers', (_) => const LawyersScreen()),
      _page('/explore/lawyers/:id', (s) => LawyerDetailScreen(id: s.pathParameters['id']!)),
      _page('/explore/transport', (_) => const TransportScreen()),
      _page('/explore/transport/buses', (s) {
        final q = s.uri.queryParameters;
        return BusResultsScreen(
          from: q['from'] ?? 'Tangail',
          to: q['to'] ?? 'Dhaka (Mohakhali)',
          date: DateTime.tryParse(q['date'] ?? '') ?? DateTime.now(),
        );
      }),
      _page('/explore/business', (_) => const BusinessListScreen()),
      _page('/explore/business/add', (_) => const AddBusinessScreen()),
      _page('/explore/business/pending', (_) => const PendingApprovalScreen()),
      _page('/explore/business/:id', (s) => BusinessDetailScreen(id: s.pathParameters['id']!)),
      _page('/explore/education', (_) => const EducationScreen()),
      _page('/explore/tourism', (_) => const TourismScreen()),
      _page('/explore/tourism/:id', (s) => PlaceDetailScreen(id: s.pathParameters['id']!)),
      _page('/explore/news', (_) => const NewsScreen()),
      _page('/explore/news/:id', (s) => NewsDetailScreen(id: s.pathParameters['id']!)),
      _page('/explore/jobs', (_) => const JobsScreen()),
      _page('/explore/jobs/:id', (s) => JobDetailScreen(id: s.pathParameters['id']!)),
      _page('/explore/bazar', (_) => const BazarScreen()),
      _page('/explore/prayer', (_) => const PrayerTimesScreen()),
      _page(
        '/explore/community',
        (s) => CommunityScreen(initialTab: int.tryParse(s.uri.queryParameters['tab'] ?? '') ?? 0),
      ),
      _page('/explore/community/post', (_) => const PostLostFoundScreen()),

      // ---- Shop (buyer)
      _page('/shop/products', (s) {
        final q = s.uri.queryParameters;
        return ProductListScreen(
          key: ValueKey(s.uri.toString()),
          category: q['cat'],
          madeInTangail: q['mit'] == '1',
          flash: q['flash'] == '1',
          focusSearch: q['focus'] == '1',
          storeId: q['store'],
        );
      }),
      _page(
        '/shop/product/:id',
        (s) => ProductDetailScreen(productId: s.pathParameters['id']!, heroScope: s.uri.queryParameters['h']),
      ),
      _page('/shop/store/:id', (s) => StoreScreen(storeId: s.pathParameters['id']!)),
      _page(
        '/shop/chat/:id',
        (s) => ChatScreen(storeId: s.pathParameters['id']!, productId: s.uri.queryParameters['product']),
      ),
      _page('/cart', (_) => const CartScreen()),
      _page('/checkout', (_) => const CheckoutScreen()),
      _page('/order-success', (s) => OrderSuccessScreen(orderId: s.uri.queryParameters['id'] ?? 'TAO-000000')),
      _page('/orders', (s) => OrdersScreen(initialTab: int.tryParse(s.uri.queryParameters['tab'] ?? '') ?? 0)),
      _page('/orders/:id', (s) => OrderDetailScreen(orderId: s.pathParameters['id']!)),
      _page('/orders/:id/review', (s) => WriteReviewScreen(orderId: s.pathParameters['id']!)),
      _page('/wallet', (_) => const WalletScreen()),

      // ---- Seller
      _page('/seller/onboarding', (_) => const SellerOnboardingScreen()),
      _page('/seller', (_) => const SellerDashboardScreen()),
      _page('/seller/products', (_) => const SellerProductsScreen()),
      _page('/seller/products/edit', (s) => ProductEditorScreen(productId: s.uri.queryParameters['id'])),
      _page('/seller/orders', (_) => const SellerOrdersScreen()),
      _page(
        '/seller/settings',
        (s) => StoreSettingsScreen(initialTab: int.tryParse(s.uri.queryParameters['tab'] ?? '') ?? 0),
      ),

      // ---- Profile
      _page('/settings', (_) => const SettingsScreen()),
      _page('/addresses', (_) => const AddressesScreen()),
      _page('/my-listings', (_) => const MyListingsScreen()),
      _page('/donor-profile', (_) => const DonorProfileScreen()),
      _page('/report', (s) => ReportScreen(item: s.uri.queryParameters['item'])),
      _page('/help', (_) => const HelpScreen()),
      _page('/about', (_) => const AboutScreen()),
    ],
    errorBuilder: (context, state) => AppScaffold(
      title: 'Tangail All in One',
      body: EmptyState(
        icon: Icons.construction_rounded,
        title: context.l10n.nothingHere,
        message: state.uri.toString(),
        actionLabel: context.l10n.backToHome,
        onAction: () => context.go('/home'),
      ),
    ),
  );
});
