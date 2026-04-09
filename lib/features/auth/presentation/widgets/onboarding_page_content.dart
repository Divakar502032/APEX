import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

class OnboardingPageContent extends StatelessWidget {
  final dynamic data; // accepts _OnboardingData

  const OnboardingPageContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.p32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji illustration inside a glowing circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (data.accentColor as Color).withOpacity(0.15),
              boxShadow: [
                BoxShadow(
                  color: (data.accentColor as Color).withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                data.emoji as String,
                style: const TextStyle(fontSize: 52),
              ),
            ),
          )
              .animate()
              .scale(begin: const Offset(0.7, 0.7), duration: 500.ms, curve: Curves.elasticOut)
              .fadeIn(duration: 300.ms),

          const SizedBox(height: AppSpacing.p40),

          Text(
            data.title as String,
            style: AppTypography.title1.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: AppSpacing.p16),

          Text(
            data.subtitle as String,
            style: AppTypography.callout.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 250.ms, duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
