import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';

// Route names — use these constants everywhere, not raw strings
class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String personalization = '/personalization';
  static const String chat = '/chat';
  static const String memory = '/memory';
  static const String tasks = '/tasks';
  static const String settings = '/settings';
  static const String paywall = '/paywall';
  static const String agentSelector = '/agents';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) => const ChatScreen(),
      ),
    ],
    redirect: (context, state) {
      // Auth gate will be implemented when Firebase Auth is configured
      return null;
    },
  );
});
