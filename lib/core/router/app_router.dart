import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/home/screens/main_screen.dart';
import '../../features/marketplace/screens/marketplace_screen.dart';
import '../../features/marketplace/screens/listing_detail_screen.dart';
import '../../features/marketplace/screens/create_listing_screen.dart';
import '../../features/ideas/screens/ideas_screen.dart';
import '../../features/ideas/screens/idea_detail_screen.dart';
import '../../features/ideas/screens/create_idea_screen.dart';
import '../../features/chat/screens/chat_list_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/admin/screens/admin_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/kyc/screens/kyc_screen.dart';
import '../../features/disputes/screens/disputes_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isSplash = state.matchedLocation == '/splash';
      final isAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      print('🔀 Router redirect check:');
      print('   - Current location: ${state.matchedLocation}');
      print('   - Is logged in: $isLoggedIn');
      print('   - Is splash: $isSplash');
      print('   - Is auth page: $isAuth');

      if (isSplash) return null;
      if (!isLoggedIn && !isAuth) {
        print('   -> Redirecting to /login');
        return '/login';
      }
      if (isLoggedIn && isAuth) {
        print('   -> Redirecting to /marketplace');
        return '/marketplace';
      }
      print('   -> No redirect');
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (_, __) => const MarketplaceScreen(),
          ),
          GoRoute(
            path: '/marketplace',
            builder: (_, __) => const MarketplaceScreen(),
            routes: [
              GoRoute(
                path: 'listing/:id',
                builder: (_, state) =>
                    ListingDetailScreen(id: int.parse(state.pathParameters['id']!)),
              ),
              GoRoute(
                path: 'create',
                builder: (_, __) => const CreateListingScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/ideas',
            builder: (_, __) => const IdeasScreen(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                builder: (_, state) =>
                    IdeaDetailScreen(id: int.parse(state.pathParameters['id']!)),
              ),
              GoRoute(
                path: 'create',
                builder: (_, __) => const CreateIdeaScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/chat',
            builder: (_, __) => const ChatListScreen(),
            routes: [
              GoRoute(
                path: ':userId',
                builder: (_, state) =>
                    ChatScreen(userId: int.parse(state.pathParameters['userId']!)),
              ),
            ],
          ),
          GoRoute(
            path: '/dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/admin',
            builder: (_, __) => const AdminScreen(),
          ),
          GoRoute(
            path: '/search',
            builder: (_, __) => const SearchScreen(),
          ),
          GoRoute(
            path: '/kyc',
            builder: (_, __) => const KycScreen(),
          ),
          GoRoute(
            path: '/disputes',
            builder: (_, __) => const DisputesScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationsScreen(),
          ),
        ],
      ),
    ],
  );
});
