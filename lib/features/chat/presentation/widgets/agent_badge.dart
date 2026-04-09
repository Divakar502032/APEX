import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';

const _agents = [
  (type: 'reasoning', label: 'Reasoning', emoji: '🧠'),
  (type: 'research',  label: 'Research',  emoji: '🔬'),
  (type: 'code',      label: 'Code',      emoji: '💻'),
  (type: 'domain',    label: 'Expert',    emoji: '🎓'),
  (type: 'general',   label: 'Auto',      emoji: '⚡'),
];

class AgentBadge extends StatelessWidget {
  final String activeAgentType;
  final bool pulsing;

  const AgentBadge({super.key, required this.activeAgentType, this.pulsing = false});

  @override
  Widget build(BuildContext context) {
    final agent = _agents.firstWhere(
      (a) => a.type == activeAgentType,
      orElse: () => _agents.last,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p12, vertical: AppSpacing.p4),
      decoration: BoxDecoration(
        color: AppColors.apexPurple.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.full),
        border: Border.all(color: AppColors.apexPurple.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(agent.emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            agent.label,
            style: AppTypography.caption.copyWith(
                color: AppColors.apexPurple, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ).animate(target: pulsing ? 1 : 0).scaleXY(begin: 1, end: 1.04, duration: 800.ms)
        .then().scaleXY(end: 1, duration: 800.ms);
  }
}

class MemoryIndicator extends StatelessWidget {
  final bool isActive;

  const MemoryIndicator({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(Icons.memory_outlined, color: AppColors.textSecondary, size: 22),
        if (isActive)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.apexPurple,
                shape: BoxShape.circle,
              ),
            ).animate(onPlay: (c) => c.repeat())
                .fadeIn(duration: 500.ms)
                .then()
                .fadeOut(duration: 500.ms),
          ),
      ],
    );
  }
}
