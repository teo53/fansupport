import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/main_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/wallet/screens/wallet_screen.dart';
import '../../features/support/screens/support_screen.dart';
import '../../features/idol/screens/idol_list_screen.dart';
import '../../features/idol/screens/idol_detail_screen.dart';
import '../../features/campaign/screens/campaign_list_screen.dart';
import '../../features/campaign/screens/campaign_detail_screen.dart';
import '../../features/booking/screens/booking_screen.dart';
import '../../features/community/screens/community_feed_screen.dart';
import '../../features/ranking/screens/ranking_screen.dart';
import '../../features/bubble/screens/bubble_list_screen.dart';
import '../../features/date_ticket/screens/date_ticket_screen.dart';
import '../../features/advertisement/screens/ad_shop_screen.dart';
import '../../features/crm/screens/idol_registration_screen.dart';
import '../../features/agency/screens/agency_dashboard_screen.dart';
import '../../features/idol/screens/idol_dashboard_screen.dart';
import '../../features/message/screens/message_creation_screen.dart';
import '../../features/schedule/screens/schedule_screen.dart';
import '../../shared/models/idol_model.dart';
import '../../core/navigation/page_transitions.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.value?.isLoggedIn ?? false;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/idols',
            builder: (context, state) => const IdolListScreen(),
          ),
          GoRoute(
            path: '/idols/:id',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: IdolDetailScreen(
                idolId: state.pathParameters['id']!,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                );
                return FadeTransition(
                  opacity: curvedAnimation,
                  child: ScaleTransition(
                    scale: Tween(begin: 0.92, end: 1.0).animate(curvedAnimation),
                    child: child,
                  ),
                );
              },
            ),
          ),
          GoRoute(
            path: '/ranking',
            builder: (context, state) => const RankingScreen(),
          ),
          GoRoute(
            path: '/campaigns',
            builder: (context, state) => const CampaignListScreen(),
          ),
          GoRoute(
            path: '/campaigns/:id',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: CampaignDetailScreen(
                campaignId: state.pathParameters['id']!,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                );
                return SlideTransition(
                  position: Tween(
                    begin: const Offset(0.0, 0.08),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: FadeTransition(
                    opacity: curvedAnimation,
                    child: child,
                  ),
                );
              },
            ),
          ),
          GoRoute(
            path: '/booking',
            builder: (context, state) => const BookingScreen(),
          ),
          GoRoute(
            path: '/community',
            builder: (context, state) => const CommunityFeedScreen(),
          ),
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const ScheduleScreen(),
          ),
          GoRoute(
            path: '/wallet',
            builder: (context, state) => const WalletScreen(),
          ),
          GoRoute(
            path: '/support/:receiverId',
            builder: (context, state) => SupportScreen(
              receiverId: state.pathParameters['receiverId']!,
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                );
                return FadeTransition(
                  opacity: curvedAnimation,
                  child: ScaleTransition(
                    scale: Tween(begin: 0.95, end: 1.0).animate(curvedAnimation),
                    child: child,
                  ),
                );
              },
            ),
          ),
          GoRoute(
            path: '/bubble',
            builder: (context, state) => const BubbleListScreen(),
          ),
          GoRoute(
            path: '/date-tickets',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DateTicketScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                );
                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOut,
                  ),
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0.0, 0.1),
                      end: Offset.zero,
                    ).animate(curvedAnimation),
                    child: child,
                  ),
                );
              },
            ),
          ),
          GoRoute(
            path: '/ad-shop',
            builder: (context, state) => const AdShopScreen(),
          ),
          GoRoute(
            path: '/crm/register-idol',
            builder: (context, state) => const IdolRegistrationScreen(),
          ),
          GoRoute(
            path: '/agency',
            builder: (context, state) => const AgencyDashboardScreen(),
          ),
          GoRoute(
            path: '/idol/dashboard',
            builder: (context, state) =>
                IdolDashboardScreen(idol: state.extra as IdolModel),
          ),
          GoRoute(
            path: '/message/create',
            builder: (context, state) =>
                MessageCreationScreen(idol: state.extra as IdolModel),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});
