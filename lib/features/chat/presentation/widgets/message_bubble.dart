import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;

  const MessageBubble({super.key, required this.message});

  bool get _isUser => message.role == MessageRole.user;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showActions(context);
      },
      child: Align(
        alignment: _isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          child: Column(
            crossAxisAlignment:
                _isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              _buildBubble(context, isDark),
              if (message.status == MessageStatus.done && !_isUser)
                _buildMeta(isDark),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.08, end: 0);
  }

  Widget _buildBubble(BuildContext context, bool isDark) {
    final userBg = AppColors.apexPurple;
    final aiBg = isDark ? AppColors.surfaceDark2 : AppColors.surfaceLight2;
    final aiBorder =
        isDark ? AppColors.surfaceDark3 : AppColors.surfaceLight3;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.p4),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p16, vertical: AppSpacing.p12),
      decoration: BoxDecoration(
        color: _isUser ? userBg : aiBg,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppRadii.large),
          topRight: const Radius.circular(AppRadii.large),
          bottomLeft: Radius.circular(_isUser ? AppRadii.large : AppRadii.small),
          bottomRight: Radius.circular(_isUser ? AppRadii.small : AppRadii.large),
        ),
        border: _isUser
            ? null
            : Border.all(color: aiBorder, width: 1),
      ),
      child: _isUser
          ? Text(
              message.content,
              style: AppTypography.body.copyWith(color: Colors.white),
            )
          : MarkdownBody(
              data: message.content.isEmpty ? '  ' : message.content,
              styleSheet: MarkdownStyleSheet(
                p: AppTypography.body.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  height: 1.55,
                ),
                code: AppTypography.footnote.copyWith(
                  fontFamily: 'Courier',
                  backgroundColor: isDark
                      ? AppColors.surfaceDark3
                      : AppColors.surfaceLight3,
                ),
                codeblockDecoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark3 : AppColors.surfaceLight3,
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                ),
                strong: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ),
    );
  }

  Widget _buildMeta(bool isDark) {
    if (message.model == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.p8, bottom: AppSpacing.p4),
      child: Text(
        '${message.model} · ${message.latencyMs}ms · ${message.totalTokens} tokens',
        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MessageActionsSheet(message: message),
    );
  }
}

class _MessageActionsSheet extends StatelessWidget {
  final MessageModel message;
  const _MessageActionsSheet({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.all(AppSpacing.p16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark2 : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadii.xlarge),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.p8),
          _ActionTile(
            icon: Icons.copy_outlined,
            label: 'Copy',
            onTap: () {
              Clipboard.setData(ClipboardData(text: message.content));
              Navigator.pop(context);
            },
          ),
          _ActionTile(
            icon: Icons.bookmark_outline,
            label: 'Save to Memory',
            onTap: () => Navigator.pop(context),
          ),
          _ActionTile(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: AppSpacing.p8),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.apexPurple),
      title: Text(label, style: AppTypography.callout),
      onTap: onTap,
    );
  }
}
