import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/report/presentation/pages/submit_report_page.dart';
import 'features/report/presentation/pages/report_detail_page.dart';
import 'features/tracking/presentation/pages/tracking_page.dart';
import 'features/tracking/presentation/pages/tracking_result_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/main/presentation/widgets/main_scaffold.dart';
import 'features/chat/presentation/pages/chat_page.dart';
import 'features/admin/presentation/widgets/admin_scaffold.dart';
import 'features/admin/presentation/pages/admin_home_page.dart';
import 'features/admin/presentation/pages/admin_reports_page.dart';
import 'features/admin/presentation/pages/admin_report_detail_page.dart';
import 'features/admin/presentation/pages/admin_chat_list_page.dart';
import 'features/admin/presentation/pages/admin_chat_page.dart';
import 'features/admin/presentation/pages/admin_send_notification_page.dart';
import 'features/admin/presentation/pages/admin_users_page.dart';
import 'features/notifications/presentation/pages/notifications_page.dart';
import 'core/constants/app_constants.dart';
import 'dart:async';

/// A [Listenable] that notifies when a [Stream] emits a value.
/// Used to bridge Riverpod [StreamProvider] to GoRouter [refreshListenable].
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(List<Stream<dynamic>> streams) {
    notifyListeners();
    for (final stream in streams) {
      final subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
      _subscriptions.add(subscription);
    }
  }

  final List<StreamSubscription<dynamic>> _subscriptions = [];

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ChangeNotifier();
  
  ref.listen(firebaseUserProvider, (_, __) {
    refreshListenable.notifyListeners();
  });
  
  ref.listen(isAdminProvider, (_, __) {
    refreshListenable.notifyListeners();
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final fbUser = ref.read(firebaseUserProvider).valueOrNull;
      final isLoggedIn = fbUser != null;
      
      // Synchronous whitelist check as fallback for immediate redirection
      final isWhitelisted = isLoggedIn && fbUser.email != null && 
          AppConstants.adminEmails.any((e) => e.toLowerCase() == fbUser.email!.toLowerCase());
      
      final isAdminState = ref.read(isAdminProvider);
      final isAdmin = (isAdminState.valueOrNull ?? false) || isWhitelisted;
      
      // If we are logged in but admin check is still loading, 
      // we wait if it's a potential admin to avoid flickering to /home
      if (isLoggedIn && isAdminState.isLoading && !isWhitelisted) return null;
      
      final subloc = state.uri.toString();
      
      if (subloc == '/splash') {
        if (isLoggedIn) {
          return isAdmin ? '/admin' : '/home';
        } else {
          return '/login';
        }
      }

      if (!isLoggedIn && subloc != '/login' && subloc != '/register') {
        return '/login';
      }

      if (isLoggedIn && (subloc == '/login' || subloc == '/register')) {
        return isAdmin ? '/admin' : '/home';
      }

      if (isLoggedIn && isAdmin && !subloc.startsWith('/admin') && subloc == '/home') {
        return '/admin';
      }
      
      if (isLoggedIn && !isAdmin && subloc.startsWith('/admin')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
      
      ShellRoute(
        builder: (_, __, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomePage()),
          GoRoute(path: '/submit-report', builder: (_, __) => const SubmitReportPage()),
          GoRoute(path: '/report-detail/:id', builder: (context, state) =>
              ReportDetailPage(reportId: state.pathParameters['id']!)),
          GoRoute(path: '/track', builder: (_, __) => const TrackingPage()),
          GoRoute(path: '/track/:trackId', builder: (context, state) =>
              TrackingResultPage(trackId: state.pathParameters['trackId']!)),
          GoRoute(path: '/chat/:reportId', builder: (_, state) =>
              ChatPage(reportId: state.pathParameters['reportId']!)),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsPage()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
        ],
      ),

      ShellRoute(
        builder: (_, __, child) => AdminScaffold(child: child),
        routes: [
          GoRoute(path: '/admin', builder: (_, __) => const AdminHomePage()),
          GoRoute(path: '/admin/reports', builder: (_, __) => const AdminReportsPage()),
          GoRoute(path: '/admin/reports/:id', builder: (context, state) =>
              AdminReportDetailPage(reportId: state.pathParameters['id']!)),
          GoRoute(path: '/admin/chats', builder: (_, __) => const AdminChatListPage()),
          GoRoute(path: '/admin/chats/:chatId', builder: (context, state) =>
              AdminChatPage(chatId: state.pathParameters['chatId']!)),
          GoRoute(path: '/admin/notify/:userId', builder: (context, state) =>
              AdminSendNotificationPage(userId: state.pathParameters['userId']!)),
          GoRoute(path: '/admin/users', builder: (_, __) => const AdminUsersPage()),
        ],
      ),
    ],
  );
});

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp.router(
          title: 'Lost & Found',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(lightDynamic),
          darkTheme: AppTheme.darkTheme(darkDynamic),
          routerConfig: router,
        );
      },
    );
  }
}
