import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_providers.dart';
import '../ui/screens/alerts/alerts_screen.dart';
import '../ui/screens/analytics/analytics_screen.dart';
import '../ui/screens/auth/auth_gate_screen.dart';
import '../ui/screens/diagnostics/diagnostics_screen.dart';
import '../ui/screens/home/home_screen.dart';
import '../ui/screens/onboarding/add_device_screen.dart';
import '../ui/screens/onboarding/onboarding_complete_screen.dart';
import '../ui/screens/profile/profile_screen.dart';
import '../ui/screens/settings/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authUserProvider);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: GoRouterRefreshStream(ref.watch(authStateChangesProvider.stream)),
    redirect: (context, state) {
      final isAuth = authState != null;
      final loggingIn = state.subloc == '/auth';
      if (!isAuth && !loggingIn) {
        return '/auth';
      }
      if (isAuth && loggingIn) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        name: AuthGateScreen.routeName,
        builder: (context, state) => const AuthGateScreen(),
      ),
      GoRoute(
        path: '/home',
        name: HomeScreen.routeName,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/analytics',
        name: AnalyticsScreen.routeName,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/alerts',
        name: AlertsScreen.routeName,
        builder: (context, state) => const AlertsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: SettingsScreen.routeName,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: ProfileScreen.routeName,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/diagnostics',
        name: DiagnosticsScreen.routeName,
        builder: (context, state) => const DiagnosticsScreen(),
      ),
      GoRoute(
        path: '/onboarding/add',
        name: AddDeviceScreen.routeName,
        builder: (context, state) => const AddDeviceScreen(),
      ),
      GoRoute(
        path: '/onboarding/complete',
        name: OnboardingCompleteScreen.routeName,
        builder: (context, state) => const OnboardingCompleteScreen(),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
