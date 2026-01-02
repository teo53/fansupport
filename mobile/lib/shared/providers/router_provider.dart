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
import '../../features/bubble/screens/bubble_live_room_screen.dart';
import '../../features/agency/screens/agency_crm_dashboard_screen.dart';
import '../../features/idol/screens/idol_crm_dashboard_screen.dart';
import '../../features/advertising/screens/advertising_purchase_screen.dart';
import '../../features/posts/screens/idol_posts_feed_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/calendar/screens/genba_calendar_screen.dart';
import '../../shared/models/idol_model.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.value?.isLoggedIn ?? false;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/splash';

      // Allow splash screen to show
      if (isSplash) {
        return null;
      }

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
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
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
          GoRoute(
            path: '/bubble/live/:roomId',
            builder: (context, state) => BubbleLiveRoomScreen(
              roomId: state.pathParameters['roomId']!,
            ),
          ),
          GoRoute(
            path: '/agency/crm',
            builder: (context, state) => const AgencyCrmDashboardScreen(),
          ),
          GoRoute(
            path: '/idol/crm',
            builder: (context, state) => const IdolCrmDashboardScreen(),
          ),
          GoRoute(
            path: '/advertising',
            builder: (context, state) => const AdvertisingPurchaseScreen(),
          ),
          GoRoute(
            path: '/posts',
            builder: (context, state) => IdolPostsFeedScreen(
              idolId: state.uri.queryParameters['idolId'],
            ),
          ),
          GoRoute(
            path: '/calendar',
            builder: (context, state) => const GenbaCalendarScreen(),
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
