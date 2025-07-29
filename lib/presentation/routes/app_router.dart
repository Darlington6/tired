// lib/presentation/routes/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:rovify/presentation/screens/home/pages/event_form_page.dart';
import 'package:rovify/presentation/screens/home/tabs/explore_tab.dart';
import 'package:rovify/presentation/screens/home/widgets/creator/create_event_screen.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';

/// Handles all app navigation routes using GoRouter.
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/explore',
        name: 'explore',
        builder: (context, state) => const ExploreTab(),
      ),
      GoRoute(
        path: '/addEvent',
        name: 'addEvent',
        builder: (context, state) => const EventFormScreen(),
      ),
      GoRoute(
        path: '/creatorDashboard',
        name: 'creatorDashboard',
        builder: (context, state) {
          final userId = state.extra as String?;
          if (userId == null) {
            return const Scaffold(
              body: Center(child: Text('User ID not provided')),
            );
          }
          return CreatorDashboardScreen(userId: userId);
        },
      ),
    ],
  );
}