import 'package:go_router/go_router.dart';
import 'package:nextcart/data/models/product_model.dart';
import 'package:nextcart/data/repository/address_repository.dart';
import 'package:nextcart/features/address/presentation/address_list_page.dart';
import 'package:nextcart/features/address/presentation/address_form_page.dart';
import 'package:nextcart/features/admin/presentation/admin_navigation_container.dart';
import 'package:nextcart/features/admin/presentation/product/product_form.dart';
import 'package:nextcart/features/cart/presentation/cart_page.dart';
import 'package:nextcart/features/location/address_selection_page.dart';
import 'package:nextcart/features/onboarding/onboarding_page.dart';
import 'package:nextcart/features/order/presentation/order_detail_page.dart';
import 'package:nextcart/features/product/presentation/product_detail_page.dart';
import 'package:nextcart/features/product/presentation/view_all_product_page.dart';
import 'package:nextcart/features/profile/presentation/profile_detail_page.dart';
import 'package:nextcart/features/review/presentation/review_form_page.dart';
import 'package:nextcart/features/review/presentation/review_list_page.dart';
import 'package:nextcart/features/splash/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextcart/features/home/main_navigation_container.dart';
import 'package:nextcart/features/notification/presentation/notification_list_page.dart';
import '../../features/auth/presentation/auth_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final location = state.matchedLocation;

      final isPublicRoute = location == '/' ||
                            location == '/onboarding' ||
                            location == '/auth';

      if (session == null && !isPublicRoute) {
        return '/auth';
      }

      if (session != null && isPublicRoute) {
        final role = Supabase.instance.client.auth.currentUser?.userMetadata?['role'];
        if (role == 'admin') {
          return '/admin-dashboard';
        }
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthPage(),
      ),

      GoRoute(
        path: '/home',
        builder: (context, state) => const MainNavigationContainer(),
      ),

      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminNavigationContainer(),
      ),
      GoRoute(
        path: '/add-product',
        builder: (context, state) {
          final product = state.extra is Product
              ? state.extra as Product
              : null;
          return ProductFormPage(product: product);
        },
      ),

      GoRoute(
        path: '/product-detail',
        builder: (context, state) {
          final product = state.extra as Product;
          return ProductDetailPage(product: product);
        },
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: '/view-all',
        name: 'view-all',
        builder: (context, state) {
          final extra = state.extra;
          final focusSearch =
              extra is Map<String, dynamic> && extra['focusSearch'] == true;
          return ViewAllProductsPage(
            title: 'Semua Produk',
            focusSearch: focusSearch,
          );
        },
      ),
      GoRoute(
        path: '/order-detail',
        builder: (context, state) {
          final orderData = state.extra as Map<String, dynamic>;
          return OrderDetailPage(order: orderData);
        },
      ),
      GoRoute(
        path: '/address-selection',
        builder: (context, state) => const AddressSelectionPage(),
      ),
      GoRoute(
        path: '/address-list',
        builder: (context, state) => const AddressListPage(),
      ),
      GoRoute(
        path: '/address-form',
        builder: (context, state) {
          final address = state.extra is ShippingAddress
              ? state.extra as ShippingAddress
              : null;
          return AddressFormPage(address: address);
        },
      ),
      GoRoute(
        path: '/profile-detail',
        builder: (context, state) {
          final profileData = state.extra as Map<String, dynamic>?;
          return ProfileDetailPage(profileData: profileData);
        },
      ),
      GoRoute(
        path: '/review-list',
        builder: (context, state) {
          final productId = state.extra as String;
          return ReviewListPage(productId: productId);
        },
      ),
      GoRoute(
        path: '/review-form',
        builder: (context, state) {
          final productId = state.extra as String;
          return ReviewFormPage(productId: productId);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationListPage(),
      ),
    ],
  );
}