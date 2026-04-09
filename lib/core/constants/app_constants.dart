class AppConstants {
  AppConstants._();

  static const String appName = 'APEX AI';
  static const String appVersion = '1.0.0';
  static const String bundleId = 'com.apexai.apexAi';

  static const int freeDailyMessageLimit = 20;
  static const Duration streamTimeout = Duration(seconds: 60);
  static const Duration memoryTtl = Duration(days: 365 * 10); // effectively forever
}

class AppStrings {
  AppStrings._();

  // Onboarding
  static const String onboardingTitle1 = 'Meet APEX AI';
  static const String onboardingSubtitle1 = 'Your next-generation AI assistant that actually understands you.';
  static const String onboardingTitle2 = 'Remembers Everything';
  static const String onboardingSubtitle2 = 'APEX learns from every conversation and grows smarter about you over time.';
  static const String onboardingTitle3 = 'Agent Specialists';
  static const String onboardingSubtitle3 = 'Switch between Reasoning, Research, Code, and Domain Expert agents instantly.';
  static const String onboardingTitle4 = 'Takes Real Action';
  static const String onboardingSubtitle4 = 'Dispatch multi-step autonomous tasks and let APEX execute them for you.';
  static const String signInWithApple = 'Continue with Apple';
  static const String signInWithGoogle = 'Continue with Google';
  static const String personalizationTitle = 'Make APEX yours';
  static const String personalizationSubtitle = 'Tell us a bit about yourself so APEX can tailor the experience.';
  static const String getStarted = 'Get Started';
  static const String continueLabel = 'Continue';

  // Error states
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection. Please check your network.';
  static const String authError = 'Sign in failed. Please try again.';

  // Memory
  static const String noMemoriesYet = 'No memories yet — APEX learns as you chat';

  // Chat
  static const String chatInputPlaceholder = 'Message APEX...';
  static const String thinking = 'Thinking...';
}
