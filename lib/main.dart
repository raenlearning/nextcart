import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nextcart/core/service/push_service.dart';
import 'package:nextcart/data/repository/admin_analytic_repository.dart';
import 'package:nextcart/data/repository/admin_repository.dart';
import 'package:nextcart/features/admin/bloc/analytics/admin_analytic_bloc.dart';
import 'package:nextcart/features/admin/bloc/product/admin_product_bloc.dart';
import 'package:nextcart/data/repository/auth_repository.dart';
import 'package:nextcart/data/repository/product_repository.dart';
import 'package:nextcart/data/repository/wishlist_repository.dart';
import 'package:nextcart/features/auth/bloc/auth_bloc.dart';
import 'package:nextcart/features/cart/bloc/cart_bloc.dart';
import 'package:nextcart/features/product/bloc/product_bloc.dart';
import 'package:nextcart/features/wishlist/bloc/wishlist_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextcart/core/router/app_router.dart';
import 'package:nextcart/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  await initializeDateFormatting('id_ID');

  await PushService.instance.init();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => AuthRepository()),

        RepositoryProvider<ProductRepository>(
          create: (_) => ProductRepository(),
        ),

        RepositoryProvider<WishlistRepository>(
          create: (_) => WishlistRepository(),
        ),

        RepositoryProvider<AdminRepository>(create: (_) => AdminRepository()),
        
        RepositoryProvider<AdminAnalyticsRepository>(
          create: (_) => const SupabaseAdminAnalyticsRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>()),
          ),

          BlocProvider<ProductBloc>(
            create: (context) => ProductBloc(
              productRepository: context.read<ProductRepository>(),
            ),
          ),

          BlocProvider<AdminProductBloc>(
            create: (context) => AdminProductBloc(
              adminRepository: context.read<AdminRepository>(),
            ),
          ),

          BlocProvider(
            create: (context) => AdminAnalyticsBloc(
              repository: context.read<AdminAnalyticsRepository>(),
            ),
          ),

          BlocProvider(create: (_) => CartBloc()),

          BlocProvider(
            create: (context) =>
                WishlistBloc(repository: context.read<WishlistRepository>())
                  ..add(WishlistLoad()),
          ),
        ],
        child: MaterialApp.router(
          title: 'Nextcart E-Commerce',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: PushService.instance.messengerKey,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
