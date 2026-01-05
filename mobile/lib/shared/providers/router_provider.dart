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
import '../../features/booking/screens/event_calendar_screen.dart';
import '../../features/community/screens/community_feed_screen.dart';
import '../../features/ranking/screens/ranking_screen.dart';
import '../../features/bubble/screens/bubble_list_screen.dart';
import '../../features/bubble/screens/bubble_chat_screen.dart';
import '../../features/date_ticket/screens/date_ticket_screen.dart';
import '../../features/advertisement/screens/ad_shop_screen.dart';
import '../../features/crm/screens/idol_registration_screen.dart';
import '../../features/agency/screens/agency_dashboard_screen.dart';
import '../../features/idol/screens/idol_dashboard_screen.dart';
import '../../features/message/screens/message_creation_screen.dart';
import '../../features/community/screens/post_create_screen.dart';
import '../../features/community/screens/post_detail_screen.dart';
import '../../features/community/screens/unanswered_cheki_list_screen.dart';
import '../../features/bubble/screens/bubble_compose_screen.dart';
import '../../features/search/screens/unified_search_screen.dart';
import '../../features/notification/screens/notification_center_screen.dart';
import '../../features/payment/screens/subscription_payment_screen.dart';
import '../../shared/models/idol_model.dart';
import '../../shared/models/post_model.dart';
import '../../shared/widgets/error_page.dart';

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
            builder: (context, state) => const EventCalendarScreen(),
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
            path: '/bubble/:idolId/:idolName/:profileImage',
            builder: (context, state) => BubbleChatScreen(
              idolId: state.pathParameters['idolId']!,
              idolName: Uri.decodeComponent(state.pathParameters['idolName']!),
              idolProfileImage: Uri.decodeComponent(state.pathParameters['profileImage']!),
            ),
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
          // Community - Post Management
          GoRoute(
            path: '/community/post/create',
            builder: (context, state) => const PostCreateScreen(),
          ),
          GoRoute(
            path: '/community/post/:id',
            builder: (context, state) => PostDetailScreen(
              post: state.extra as Post,
            ),
          ),
          GoRoute(
            path: '/community/cheki/unanswered',
            builder: (context, state) => const UnansweredChekiListScreen(),
          ),
          // Bubble - Message Compose
          GoRoute(
            path: '/bubble/compose',
            builder: (context, state) => const BubbleComposeScreen(),
          ),
          // Search
          GoRoute(
            path: '/search',
            builder: (context, state) => const UnifiedSearchScreen(),
          ),
          // Notifications
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationCenterScreen(),
          ),
          // Payment - Subscription
          GoRoute(
            path: '/subscription/payment/:idolId',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return SubscriptionPaymentScreen(
                idolId: state.pathParameters['idolId']!,
                idolName: extra?['idolName'] ?? '',
                idolProfileImage: extra?['idolProfileImage'],
              );
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => ErrorPage(
      errorMessage: state.error?.toString(),
    ),
  );
});
