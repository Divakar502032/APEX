import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/chat_provider.dart';

class ChatInputBar extends ConsumerStatefulWidget {
  const ChatInputBar({super.key});

  @override
  ConsumerState<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends ConsumerState<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    _controller.clear();
    setState(() => _hasText = false);
    await ref.read(chatProvider.notifier).sendMessage(text);
  }

  void _stop() {
    HapticFeedback.mediumImpact();
    ref.read(chatProvider.notifier).stopStreaming();
  }

  @override
  Widget build(BuildContext context) {
    final isStreaming = ref.watch(isStreamingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputBg = isDark ? AppColors.surfaceDark3 : AppColors.surfaceLight2;

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.p12,
        right: AppSpacing.p12,
        top: AppSpacing.p8,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.p8,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.surfaceDark3 : AppColors.surfaceLight3,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Voice / attach button
          _IconBtn(
            icon: Icons.mic_none_outlined,
            onTap: () => HapticFeedback.lightImpact(),
          ),

          const SizedBox(width: AppSpacing.p8),

          // Text field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(AppRadii.xlarge),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: 6,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                style: AppTypography.body.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.chatInputPlaceholder,
                  hintStyle: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.p16, vertical: AppSpacing.p12),
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.p8),

          // Send / Stop button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isStreaming
                ? _IconBtn(
                    key: const ValueKey('stop'),
                    icon: Icons.stop_circle_outlined,
                    color: AppColors.error,
                    onTap: _stop,
                  )
                : _SendButton(
                    key: const ValueKey('send'),
                    enabled: _hasText,
                    onTap: _send,
                  ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.1, end: 0, duration: 300.ms);
  }
}

class _SendButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _SendButton({super.key, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled ? AppColors.apexPurple : AppColors.textSecondary.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  const _IconBtn({super.key, required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(icon, color: color ?? AppColors.textSecondary, size: 24),
      ),
    );
  }
}
