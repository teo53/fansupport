import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/main_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
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
import '../../shared/models/idol_model.dart';
import '../../features/safety/screens/spending_limit_screen.dart';
// New Inbox-first screens
import '../../features/inbox/screens/inbox_dashboard_screen.dart';
import '../../features/explore/screens/explore_screen.dart';
import '../../features/reply_request/screens/request_composer_screen.dart';
import '../../features/reply_request/screens/reply_request_detail_screen.dart';
import '../../features/feed/screens/feed_screen.dart';
import '../../features/creator_queue/screens/creator_queue_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/inbox',  // Changed: Inbox-first navigation
    redirect: (context, state) {
      // While auth is loading, don't redirect
      final isLoading = authState.isLoading;
      if (isLoading) {
        return null;
      }

      final isLoggedIn = authState.value?.isLoggedIn ?? false;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Not logged in and not on login/register page -> redirect to login
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // Logged in and on login/register page -> redirect to inbox (new default)
      if (isLoggedIn && isLoggingIn) {
        return '/inbox';
      }

      // Redirect old home route to inbox
      if (isLoggedIn && state.matchedLocation == '/') {
        return '/inbox';
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
          // ==================== NEW INBOX-FIRST ROUTES ====================
          // Tab 0: Inbox (받은함)
          GoRoute(
            path: '/inbox',
            builder: (context, state) => const InboxDashboardScreen(),
          ),
          // Tab 1: Explore (탐색)
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          // Tab 2: Create (리프 요청)
          GoRoute(
            path: '/create',
            builder: (context, state) => RequestComposerScreen(
              creatorId: state.uri.queryParameters['creatorId'],
            ),
          ),
          // Tab 3: Feed (피드)
          GoRoute(
            path: '/feed',
            builder: (context, state) => const FeedScreen(),
          ),
          // Reply request detail
          GoRoute(
            path: '/reply-requests/:id',
            builder: (context, state) => ReplyRequestDetailScreen(
              requestId: state.pathParameters['id']!,
            ),
          ),
          // Creator queue (크리에이터 모드)
          GoRoute(
            path: '/creator/queue',
            builder: (context, state) => const CreatorQueueScreen(),
          ),

          // ==================== EXISTING ROUTES (kept for compatibility) ====================
          // Old home redirects to inbox now via redirect logic
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          // Creator profiles (still needed for explore -> profile flow)
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
          // Campaigns (deferred but kept for backward compat)
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
          // Booking (deferred)
          GoRoute(
            path: '/booking',
            builder: (context, state) => const BookingScreen(),
          ),
          // Community (now in feed tab but keep route)
          GoRoute(
            path: '/community',
            builder: (context, state) => const CommunityFeedScreen(),
          ),
          // Tab 4: Wallet (지갑)
          GoRoute(
            path: '/wallet',
            builder: (context, state) => const WalletScreen(),
          ),
          // Support (old support flow, kept for compat)
          GoRoute(
            path: '/support/:receiverId',
            builder: (context, state) => SupportScreen(
              receiverId: state.pathParameters['receiverId']!,
            ),
          ),
          // Profile & Settings
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          // Bubble DM (secondary feature)
          GoRoute(
            path: '/bubble',
            builder: (context, state) => const BubbleListScreen(),
          ),
          // Deferred features
          GoRoute(
            path: '/date-tickets',
            builder: (context, state) => const DateTicketScreen(),
          ),
          GoRoute(
            path: '/ad-shop',
            builder: (context, state) => const AdShopScreen(),
          ),
          // CRM & Agency
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
          // Safety settings
          GoRoute(
            path: '/settings/spending-limits',
            builder: (context, state) => const SpendingLimitScreen(),
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
