import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../repositories/vendor_posts_repository.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth_landing_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/market_discovery_screen.dart';
import '../screens/market_detail_screen.dart';
import '../screens/shopper_home.dart';
import '../screens/vendor_dashboard.dart';
import '../screens/create_popup_screen.dart';
import '../screens/vendor_my_popups.dart';
import '../models/market.dart';

class AppRouter {
  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/onboarding',
      routes: [
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/auth',
          name: 'auth',
          builder: (context, state) => const AuthLandingScreen(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) {
            final userType = state.uri.queryParameters['type'] ?? 'shopper';
            return AuthScreen(userType: userType, isLogin: true);
          },
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) {
            final userType = state.uri.queryParameters['type'] ?? 'shopper';
            return AuthScreen(userType: userType, isLogin: false);
          },
        ),
        GoRoute(
          path: '/shopper',
          name: 'shopper',
          builder: (context, state) => const MarketDiscoveryScreen(),
          routes: [
            GoRoute(
              path: 'market-detail',
              name: 'marketDetail',
              builder: (context, state) {
                final market = state.extra as Market;
                return MarketDetailScreen(market: market);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/vendor',
          name: 'vendor',
          builder: (context, state) => const VendorDashboard(),
          routes: [
            GoRoute(
              path: 'create-popup',
              name: 'createPopup',
              builder: (context, state) => CreatePopUpScreen(
                postsRepository: context.read<IVendorPostsRepository>(),
              ),
            ),
            GoRoute(
              path: 'my-popups',
              name: 'myPopups',
              builder: (context, state) => const VendorMyPopups(),
            ),
          ],
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authBloc.state;
        
        // If authenticated, redirect based on user type
        if (authState is Authenticated) {
          final isAuthRoute = ['/auth', '/login', '/signup'].contains(state.matchedLocation);
          if (isAuthRoute) {
            return authState.userType == 'vendor' ? '/vendor' : '/shopper';
          }
          
          // Skip onboarding for vendors - they go straight to dashboard
          if (authState.userType == 'vendor' && state.matchedLocation == '/onboarding') {
            return '/vendor';
          }
          
          // Prevent wrong user type from accessing wrong routes
          if (authState.userType == 'vendor' && state.matchedLocation.startsWith('/shopper')) {
            return '/vendor';
          }
          if (authState.userType == 'shopper' && state.matchedLocation.startsWith('/vendor')) {
            return '/shopper';
          }
        }
        
        // If unauthenticated and not on auth routes, go to auth landing
        if (authState is Unauthenticated) {
          final authRoutes = ['/auth', '/login', '/signup', '/onboarding'];
          if (!authRoutes.contains(state.matchedLocation)) {
            return '/auth';
          }
        }
        
        return null;
      },
      refreshListenable: GoRouterRefreshStream(authBloc),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(AuthBloc authBloc) {
    authBloc.stream.listen((_) {
      notifyListeners();
    });
  }
}