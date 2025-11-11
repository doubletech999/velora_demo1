// lib/core/router/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../presentation/providers/user_provider.dart';
import '../../presentation/providers/paths_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/onboarding_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart'; // إضافة هذا الاستيراد
import '../../presentation/screens/auth/terms_and_conditions_screen.dart';
import '../../presentation/screens/reviews/reviews_screen.dart';
import '../../presentation/screens/explore/explore_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/map/map_screen.dart';
import '../../presentation/screens/paths/path_details_screen.dart';
import '../../presentation/screens/paths/paths_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/saved_paths/saved_paths_screen.dart';
import '../../presentation/screens/achievements/achievements_screen.dart';
import '../../presentation/screens/journey/journey_tracking_screen.dart';
import '../../presentation/widgets/navigation/scaffold_with_navbar.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    initialLocation: '/splash',
    navigatorKey: _rootNavigatorKey,
    redirect: _routeGuard,
    routes: [
      // Auth and splash routes
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // إضافة مسار نسيت كلمة المرور هنا
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // Terms and Conditions
      GoRoute(
        path: '/terms-and-conditions',
        builder: (context, state) => const TermsAndConditionsScreen(),
      ),
      // Reviews
      GoRoute(
        path: '/reviews/:siteId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final siteId = state.pathParameters['siteId']!;
          final pathName = state.uri.queryParameters['pathName'];
          return ReviewsScreen(siteId: siteId, pathName: pathName);
        },
      ),
      
      // Journey tracking route (خارج الشل للشاشة الكاملة)
      GoRoute(
        path: '/journey/:pathId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final pathId = state.pathParameters['pathId']!;
          final pathsProvider = Provider.of<PathsProvider>(context, listen: false);
          final path = pathsProvider.getPathById(pathId);
          
          if (path == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pop();
            });
            return const Scaffold(
              body: Center(
                child: Text('لم يتم العثور على المسار'),
              ),
            );
          }
          
          return JourneyTrackingScreen(path: path);
        },
      ),
      
      // Main app routes with bottom navigation bar shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ScaffoldWithNavBar(
          location: state.uri.path,
          child: child,
        ),
        routes: [
          // Home
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'search',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          
          // Paths
          GoRoute(
            path: '/paths',
            builder: (context, state) => const PathsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => PathDetailsScreen(
                  pathId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          
          // Explore
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          
          // Map
          GoRoute(
            path: '/map',
            builder: (context, state) => const MapScreen(),
          ),
          
          // Profile
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'settings',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                path: 'saved',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const SavedPathsScreen(),
              ),
              GoRoute(
                path: 'achievements',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const AchievementsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // Route guard function to handle authentication
  static String? _routeGuard(BuildContext context, GoRouterState state) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isLoggedIn = userProvider.isLoggedIn;
    final isGuest = userProvider.isGuest;
    final isInitialRoute = state.matchedLocation == '/splash';
    final isAuthRoute = state.matchedLocation == '/login' || 
                       state.matchedLocation == '/register' ||
                       state.matchedLocation == '/onboarding' ||
                       state.matchedLocation == '/forgot-password' ||
                       state.matchedLocation == '/terms-and-conditions' ||
                       state.matchedLocation.startsWith('/reviews/');
    
    // Guest-restricted routes (profile sub-pages only, not main profile)
    final isGuestRestrictedRoute = state.matchedLocation.startsWith('/profile/saved') ||
                                   state.matchedLocation.startsWith('/profile/achievements') ||
                                   state.matchedLocation.startsWith('/profile/settings');
    
    // Redirect guests from profile sub-pages to login (but allow main profile page)
    if (isLoggedIn && isGuest && isGuestRestrictedRoute) {
      return '/login';
    }
    
    // Allow splash and auth routes without authentication
    if (isInitialRoute || isAuthRoute) {
      return null;
    }
    
    // Redirect to login if not authenticated
    if (!isLoggedIn) {
      return '/login';
    }
    
    // Allow all other routes when authenticated
    return null;
  }
}