import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/chat_provider.dart';
import '../../data/models/message_model.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/reasoning_panel.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/agent_badge.dart';
import '../../../../features/auth/presentation/widgets/apex_logo.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ─────────────────────────────────────────────────────
            _TopBar(
              activeAgent: state.activeAgentType,
              isMemoryActive: state.isMemoryActive,
            ),

            // ── Messages ────────────────────────────────────────────────────
            Expanded(
              child: state.messages.isEmpty
                  ? _EmptyChatState(isDark: isDark)
                  : _MessageList(
                      messages: state.messages,
                      isThinking: state.isThinking,
                    ),
            ),

            // ── Reasoning Panel ─────────────────────────────────────────────
            const ReasoningPanel(),

            // ── Input Bar ───────────────────────────────────────────────────
            const ChatInputBar(),
          ],
        ),
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String activeAgent;
  final bool isMemoryActive;

  const _TopBar({required this.activeAgent, required this.isMemoryActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p16, vertical: AppSpacing.p8),
      child: Row(
        children: [
          const ApexLogo(size: 28),
          const Spacer(),
          AgentBadge(activeAgentType: activeAgent),
          const Spacer(),
          GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Icon(
              Icons.memory_outlined,
              color: isMemoryActive ? AppColors.apexPurple : AppColors.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.p8),
          GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: const Icon(Icons.more_horiz, color: AppColors.textSecondary, size: 22),
          ),
        ],
      ),
    );
  }
}

// ─── Message List ──────────────────────────────────────────────────────────────

class _MessageList extends StatefulWidget {
  final List<MessageModel> messages;
  final bool isThinking;

  const _MessageList({required this.messages, required this.isThinking});

  @override
  State<_MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<_MessageList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(_MessageList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Auto-scroll to bottom on new content
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.p16, vertical: AppSpacing.p8),
      itemCount: widget.messages.length + (widget.isThinking ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == widget.messages.length) return const TypingIndicator();
        return MessageBubble(message: widget.messages[i]);
      },
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────────

class _EmptyChatState extends StatelessWidget {
  final bool isDark;
  const _EmptyChatState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.apexPurple, AppColors.apexPurpleDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.apexPurple.withValues(alpha: 0.4),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Center(
              child: Text('⚡', style: TextStyle(fontSize: 36)),
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: AppSpacing.p24),
          Text(
            'How can I help you today?',
            style: AppTypography.title2.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: AppSpacing.p8),
          Text(
            'Ask anything — I\'ll use the best agent for your request.',
            style: AppTypography.callout.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: AppSpacing.p32),
          // Suggestion chips
          Wrap(
            spacing: AppSpacing.p8,
            runSpacing: AppSpacing.p8,
            alignment: WrapAlignment.center,
            children: const [
              _SuggestionChip('Explain quantum computing'),
              _SuggestionChip('Write a Python script'),
              _SuggestionChip('Summarize a research paper'),
              _SuggestionChip('Plan my week'),
            ],
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

class _SuggestionChip extends ConsumerWidget {
  final String label;
  const _SuggestionChip(this.label);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(chatProvider.notifier).sendMessage(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.p16, vertical: AppSpacing.p8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark2 : AppColors.surfaceLight2,
          borderRadius: BorderRadius.circular(AppRadii.full),
          border: Border.all(
            color: isDark ? AppColors.surfaceDark3 : AppColors.surfaceLight3,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.subhead.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
