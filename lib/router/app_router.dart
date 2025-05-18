import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:real_estate_app/features/auth/presentation/screens/login_screen.dart';
import 'package:real_estate_app/features/auth/presentation/screens/register_screen.dart';
import 'package:real_estate_app/features/auth/providers/auth_provider.dart';
import 'package:real_estate_app/features/home/presentation/screens/home_screen.dart';
import 'package:real_estate_app/features/listing/presentation/screens/add_listing_screen.dart';
import 'package:real_estate_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:real_estate_app/features/splash/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  debugPrint('📍 Initializing Router Provider');
  final authState = ref.watch(authProvider);
  debugPrint(
      '👤 Current Auth State: ${authState.value != null ? "Logged In" : "Not Logged In"}');

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      debugPrint(
          '🔄 Router Redirect Check - Current Location: ${state.matchedLocation}');

      // Don't redirect when auth state is still loading
      if (authState.isLoading || authState.hasError) {
        debugPrint('⏳ Auth State is loading or has error - No redirect');
        return null;
      }

      final isLoggedIn = authState.value != null;
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';

      debugPrint(
          '📊 Route Status - LoggedIn: $isLoggedIn, GoingToLogin: $isGoingToLogin, GoingToRegister: $isGoingToRegister');

      // If not logged in and not going to auth screens, redirect to login
      if (!isLoggedIn &&
          !isGoingToLogin &&
          !isGoingToRegister &&
          state.matchedLocation != '/') {
        debugPrint('🔒 User not logged in - Redirecting to login');
        return '/login';
      }

      // If logged in and trying to go to auth screens, redirect to home
      if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
        debugPrint('🏠 User already logged in - Redirecting to home');
        return '/home';
      }

      // If user is on splash screen and auth state is determined, redirect to appropriate screen
      if (state.matchedLocation == '/') {
        debugPrint('💫 On Splash Screen - Determining redirect path');
        // Wait a short time on splash screen for better user experience
        Future.delayed(const Duration(milliseconds: 1500), () {});
        final redirectPath = isLoggedIn ? '/home' : '/login';
        debugPrint('🎯 Splash Screen redirect path: $redirectPath');
        return redirectPath;
      }

      debugPrint(
          '✅ No redirect needed - Continuing to ${state.matchedLocation}');
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          debugPrint('🎨 Building Splash Screen');
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          debugPrint('🎨 Building Login Screen');
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          debugPrint('🎨 Building Register Screen');
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          debugPrint('🎨 Building Home Screen');
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/add-listing',
        builder: (context, state) {
          debugPrint('🎨 Building Add Listing Screen');
          return const AddListingScreen();
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) {
          debugPrint('🎨 Building Profile Screen');
          return const ProfileScreen();
        },
      ),
    ],
  );
});
