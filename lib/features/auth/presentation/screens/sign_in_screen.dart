import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/apex_logo.dart';
import 'personalization_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoadingApple = false;
  bool _isLoadingGoogle = false;

  Future<void> _signInWithApple() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoadingApple = true);
    try {
      // Firebase Auth: Sign in with Apple
      // Will be wired once flutterfire configure is run
      // final credential = await SignInWithApple.getAppleIDCredential(...)
      // final authResult = await FirebaseAuth.instance.signInWithCredential(...)
      await Future.delayed(const Duration(seconds: 1)); // placeholder
      if (mounted) _goToPersonalization();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.authError, style: AppTypography.callout.copyWith(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingApple = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoadingGoogle = true);
    try {
      // Firebase Auth: Sign in with Google
      // Will be wired once flutterfire configure is run
      await Future.delayed(const Duration(seconds: 1)); // placeholder
      if (mounted) _goToPersonalization();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.authError, style: AppTypography.callout.copyWith(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingGoogle = false);
    }
  }

  void _goToPersonalization() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const PersonalizationScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p24),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.p48),

              // Logo
              const Center(child: ApexLogo(size: 48))
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.8, 0.8)),

              const SizedBox(height: AppSpacing.p40),

              // Headline
              Text(
                'Welcome to APEX',
                style: AppTypography.title1.copyWith(color: textColor),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: AppSpacing.p12),

              Text(
                'Sign in to unlock the future of\nAI-powered productivity.',
                style: AppTypography.callout.copyWith(color: AppColors.textSecondary, height: 1.6),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),

              const Spacer(),

              // Sign in with Apple (primary)
              _SignInButton(
                label: AppStrings.signInWithApple,
                icon: Icons.apple,
                isLoading: _isLoadingApple,
                isPrimary: true,
                onTap: _signInWithApple,
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppSpacing.p12),

              // Sign in with Google (secondary)
              _SignInButton(
                label: AppStrings.signInWithGoogle,
                icon: Icons.g_mobiledata,
                isLoading: _isLoadingGoogle,
                isPrimary: false,
                onTap: _signInWithGoogle,
              ).animate().fadeIn(delay: 380.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: AppSpacing.p32),

              // Privacy note
              Text(
                'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 450.ms),

              const SizedBox(height: AppSpacing.p40),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final bool isPrimary;
  final VoidCallback onTap;

  const _SignInButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: isPrimary
          ? ElevatedButton.icon(
              onPressed: isLoading ? null : onTap,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Icon(icon, color: Colors.white, size: 22),
              label: Text(
                label,
                style: AppTypography.headline.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xlarge)),
                elevation: 0,
              ),
            )
          : OutlinedButton.icon(
              onPressed: isLoading ? null : onTap,
              icon: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      icon,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      size: 26,
                    ),
              label: Text(
                label,
                style: AppTypography.headline.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark ? AppColors.surfaceDark3 : AppColors.surfaceLight3,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.xlarge)),
              ),
            ),
    );
  }
}
