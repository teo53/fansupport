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
import '../../features/schedule/screens/schedule_screen.dart';
import '../../features/crm/screens/agency_crm_screen.dart';

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
          // 스케줄 - 초기 유저 유입 훅
          GoRoute(
            path: '/schedule',
            builder: (context, state) => const ScheduleScreen(),
          ),
          GoRoute(
            path: '/idols',
            builder: (context, state) => const IdolListScreen(),
          ),
          GoRoute(
            path: '/idols/:id',
            builder: (context, state) => IdolDetailScreen(
              idolId: state.pathParameters['id']!,
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
            builder: (context, state) => CampaignDetailScreen(
              campaignId: state.pathParameters['id']!,
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
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/bubble',
            builder: (context, state) => const BubbleListScreen(),
          ),
          GoRoute(
            path: '/date-tickets',
            builder: (context, state) => const DateTicketScreen(),
          ),
          GoRoute(
            path: '/ad-shop',
            builder: (context, state) => const AdShopScreen(),
          ),
          GoRoute(
            path: '/crm/register-idol',
            builder: (context, state) => const IdolRegistrationScreen(),
          ),
          // 소속사 CRM 대시보드
          GoRoute(
            path: '/crm/dashboard',
            builder: (context, state) => const AgencyCrmScreen(),
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
