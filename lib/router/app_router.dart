import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_providers.dart';
import '../screens/add_stock_screen.dart';
import '../screens/choose_role_screen.dart';
import '../screens/create_order_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/inventory_screen.dart';
import '../screens/login_screen.dart';
import '../screens/order_history_screen.dart';
import '../screens/production_screen.dart';
import '../screens/purchase_screen.dart';
import '../screens/set_password_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';

/// Helper ChangeNotifier that notifies listeners on every event from a Stream.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  void refresh() {
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  );
  ref.onDispose(refreshListenable.dispose);

  // Notify router when business provider or splash delay updates
  ref.listen(currentBusinessProvider, (previous, next) {
    refreshListenable.refresh();
  });
  ref.listen(splashMinDelayProvider, (previous, next) {
    refreshListenable.refresh();
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    redirect: (BuildContext context, GoRouterState state) {
      final loc = state.matchedLocation;

      final splashDelayAsync = ref.read(splashMinDelayProvider);
      final authStateAsync = ref.read(authStateProvider);
      final businessAsync = ref.read(currentBusinessProvider);

      // Initial splash screen delay on cold start
      if (splashDelayAsync.isLoading) {
        if (loc != '/splash') return '/splash';
        return null;
      }

      // If on splash, wait until auth & business state resolve before navigating away
      if (loc == '/splash' &&
          (authStateAsync.isLoading || businessAsync.isLoading)) {
        return null;
      }

      final hasSession = Supabase.instance.client.auth.currentSession != null;

      // State 1: No authenticated Supabase session -> show Login/Signup
      if (!hasSession) {
        if (loc != '/login' && loc != '/signup' && loc != '/reset-password') return '/login';
        return null;
      }

      final business = businessAsync.valueOrNull;

      // State 2: Session exists, but no business row exists yet -> /choose-role
      if (business == null) {
        if (loc == '/reset-password') return null;
        if (loc != '/choose-role') return '/choose-role';
        return null;
      }

      // State 3: Session exists AND a business row exists -> Dashboard
      if (loc == '/choose-role' ||
          loc == '/login' ||
          loc == '/signup' ||
          loc == '/splash' ||
          loc == '/plan-selection') {
        return '/dashboard';
      }

      // Allow access to requested route
      return null;
    },
    routes: [
      // ── Unauthenticated / Onboarding Routes ──
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) => const SetPasswordScreen(
          mode: SetPasswordMode.reset,
        ),
      ),
      GoRoute(
        path: '/choose-role',
        name: 'choose-role',
        builder: (context, state) => const ChooseRoleScreen(),
      ),

      // ── Main App Shell with Bottom Navigation Tabs ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inventory',
                name: 'inventory',
                builder: (context, state) => const InventoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                name: 'orders',
                builder: (context, state) => const OrderHistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Full-screen Modal / Detail Routes (Pushed on top of Bottom Nav Shell) ──
      GoRoute(
        path: '/add-stock',
        name: 'add-stock',
        builder: (context, state) {
          final business = ref.read(currentBusinessProvider).valueOrNull;
          return AddStockScreen(
            businessId: business?.id ?? '00000000-0000-0000-0000-000000000000',
          );
        },
      ),
      GoRoute(
        path: '/create-order',
        name: 'create-order',
        builder: (context, state) {
          final business = ref.read(currentBusinessProvider).valueOrNull;
          return CreateOrderScreen(
            businessId: business?.id ?? '00000000-0000-0000-0000-000000000000',
          );
        },
      ),
      GoRoute(
        path: '/purchase',
        name: 'purchase',
        builder: (context, state) {
          final business = ref.read(currentBusinessProvider).valueOrNull;
          return PurchaseScreen(
            businessId: business?.id ?? '00000000-0000-0000-0000-000000000000',
          );
        },
      ),
      GoRoute(
        path: '/production',
        name: 'production',
        builder: (context, state) {
          final business = ref.read(currentBusinessProvider).valueOrNull;
          return ProductionScreen(
            businessId: business?.id ?? '00000000-0000-0000-0000-000000000000',
          );
        },
      ),
    ],
  );
});
