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
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/change_password_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/notification/screens/notification_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/follow_list_screen.dart';

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
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
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
            path: '/calendar',
            builder: (context, state) => const CalendarScreen(),
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
            path: '/profile/edit',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: '/profile/followers',
            builder: (context, state) => FollowListScreen(
              userId: state.uri.queryParameters['userId'] ?? '',
              userName: state.uri.queryParameters['userName'] ?? '',
              initialType: FollowListType.followers,
            ),
          ),
          GoRoute(
            path: '/profile/following',
            builder: (context, state) => FollowListScreen(
              userId: state.uri.queryParameters['userId'] ?? '',
              userName: state.uri.queryParameters['userName'] ?? '',
              initialType: FollowListType.following,
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/settings/change-password',
            builder: (context, state) => const ChangePasswordScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationScreen(),
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
