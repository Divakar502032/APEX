import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/onboarding_page_content.dart';
import '../widgets/apex_logo.dart';
import 'sign_in_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      emoji: '⚡',
      title: 'Meet APEX AI',
      subtitle: 'Your next-generation AI assistant that actually understands you — and gets smarter over time.',
      accentColor: AppColors.apexPurple,
    ),
    _OnboardingData(
      emoji: '🧠',
      title: 'Remembers Everything',
      subtitle: 'APEX builds a rich memory of your projects, preferences, and goals across every conversation.',
      accentColor: Color(0xFF5AC8FA),
    ),
    _OnboardingData(
      emoji: '🤖',
      title: 'Specialist Agents',
      subtitle: 'Switch between Reasoning, Research, Code, and Domain Expert agents — or let APEX choose.',
      accentColor: Color(0xFF30D158),
    ),
    _OnboardingData(
      emoji: '🚀',
      title: 'Takes Real Action',
      subtitle: 'Dispatch multi-step autonomous tasks and watch APEX plan, execute, and report back.',
      accentColor: Color(0xFFFFD60A),
    ),
  ];

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _goToSignIn();
    }
  }

  void _goToSignIn() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SignInScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Logo bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24, vertical: AppSpacing.p16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const ApexLogo(size: 32),
                  TextButton(
                    onPressed: _goToSignIn,
                    child: Text(
                      'Skip',
                      style: AppTypography.callout.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) => OnboardingPageContent(data: _pages[i]),
              ),
            ),

            // Page indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.p16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.apexPurple : AppColors.textSecondary.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(AppRadii.full),
                    ),
                  );
                }),
              ),
            ),

            // CTA Button
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.p24, 0, AppSpacing.p24, AppSpacing.p40),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.apexPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.xlarge),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? AppStrings.getStarted : AppStrings.continueLabel,
                    style: AppTypography.headline.copyWith(color: Colors.white),
                  ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accentColor;

  const _OnboardingData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });
}
