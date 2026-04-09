import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.p4),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p16, vertical: AppSpacing.p12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark2 : AppColors.surfaceLight2,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppRadii.large),
            topRight: Radius.circular(AppRadii.large),
            bottomLeft: Radius.circular(AppRadii.small),
            bottomRight: Radius.circular(AppRadii.large),
          ),
          border: Border.all(
            color: isDark ? AppColors.surfaceDark3 : AppColors.surfaceLight3,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return _Dot(index: i);
          }),
        ),
      ).animate().fadeIn(duration: 200.ms),
    );
  }
}

class _Dot extends StatelessWidget {
  final int index;
  const _Dot({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: AppColors.apexPurple,
        shape: BoxShape.circle,
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .fadeIn(delay: Duration(milliseconds: index * 180), duration: 300.ms)
        .then()
        .fadeOut(duration: 300.ms)
        .then()
        .fadeIn(duration: 300.ms);
  }
}
