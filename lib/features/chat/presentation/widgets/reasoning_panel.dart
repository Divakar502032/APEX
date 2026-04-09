import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/chat_provider.dart';

class ReasoningPanel extends ConsumerWidget {
  const ReasoningPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final steps = ref.watch(reasoningStepsProvider);
    final isVisible = ref.watch(chatProvider).showReasoningPanel;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!isVisible && steps.isEmpty) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isVisible ? null : 0,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
            AppSpacing.p16, 0, AppSpacing.p16, AppSpacing.p8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark2 : AppColors.surfaceLight2,
          borderRadius: BorderRadius.circular(AppRadii.large),
          border: Border.all(
            color: AppColors.apexPurple.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.p12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.apexPurple,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .fadeIn(duration: 600.ms)
                      .then()
                      .fadeOut(duration: 600.ms),
                  const SizedBox(width: AppSpacing.p8),
                  Text('Reasoning',
                      style: AppTypography.footnote
                          .copyWith(color: AppColors.apexPurple, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(chatProvider.notifier).toggleReasoningPanel();
                    },
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary, size: 20),
                  ),
                ],
              ),
            ),
            // Steps
            ...steps.map((step) => _ReasoningStepTile(step: step)),
            const SizedBox(height: AppSpacing.p8),
          ],
        ),
      ),
    );
  }
}

class _ReasoningStepTile extends StatelessWidget {
  final dynamic step;
  const _ReasoningStepTile({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p12, vertical: AppSpacing.p4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(step.type.emoji as String,
              style: const TextStyle(fontSize: 14)),
          const SizedBox(width: AppSpacing.p8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.type.label as String,
                    style: AppTypography.caption.copyWith(
                        color: AppColors.apexPurple, fontWeight: FontWeight.w600)),
                Text(step.content as String,
                    style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.05, end: 0);
  }
}
