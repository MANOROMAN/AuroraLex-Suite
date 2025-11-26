import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/data/auth_service.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>(
  (ref) {
    final authState = ref.watch(authStateProvider);

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AuroraRoutes.splash,
      redirect: (context, state) {
        if (state.matchedLocation == AuroraRoutes.splash) {
          return null;
        }
        final isLoggedIn = authState.value != null;
        final isOnAuthPage = state.matchedLocation.startsWith('/welcome') ||
            state.matchedLocation.startsWith('/login') ||
            state.matchedLocation.startsWith('/register');

        // If logged in and trying to access auth pages, redirect to home
        if (isLoggedIn && isOnAuthPage) {
          return AuroraRoutes.home;
        }

        // If not logged in and trying to access protected pages, redirect to welcome
        if (!isLoggedIn && !isOnAuthPage) {
          return AuroraRoutes.welcome;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AuroraRoutes.splash,
          builder: (context, state) => const AuroraSplashScreen(),
        ),
        GoRoute(
          path: AuroraRoutes.welcome,
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: AuroraRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AuroraRoutes.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: AuroraRoutes.home,
          builder: (context, state) => const AuroraHomeScreen(),
        ),
      ],
    );
  },
);

class AuroraRoutes {
  const AuroraRoutes._();

  static const splash = '/splash';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
}
