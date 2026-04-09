import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/models/message_model.dart';
import '../data/models/reasoning_step_model.dart';
import 'chat_state.dart';
import 'chat_actions.dart';
import '../../../core/network/api_service.dart';

export 'chat_state.dart';
export 'chat_actions.dart';

// ─── Top-level providers (clean, minimal) ────────────────────────────────────

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ChatNotifier(apiService: apiService);
});

final isStreamingProvider = Provider<bool>((ref) {
  return ref.watch(chatProvider).isStreaming;
});

final activeAgentProvider = Provider<String>((ref) {
  return ref.watch(chatProvider).activeAgentType;
});

final reasoningStepsProvider = Provider<List<ReasoningStepModel>>((ref) {
  return ref.watch(chatProvider).reasoningSteps;
});

// ─── Notifier ─────────────────────────────────────────────────────────────────

class ChatNotifier extends StateNotifier<ChatState> {
  final ApiService apiService;
  
  // Placeholders — Phase 2/6 will replace with real Auth/Hive IDs
  static const String _tempUserId = 'user_123';
  static final String _tempConversationId = 'convo_${const Uuid().v4().substring(0, 8)}';

  ChatNotifier({required this.apiService}) : super(ChatState.initial());

  static final _uuid = Uuid();

  // ── Public actions ─────────────────────────────────────────────────────────

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isStreaming) return;

    final userMsg = MessageModel(
      id: _uuid.v4(),
      content: text.trim(),
      role: MessageRole.user,
      timestamp: DateTime.now(),
      status: MessageStatus.done,
      agentType: state.activeAgentType,
    );

    // Delegate side-effects to ChatActions
    await ChatActions.handleSend(
      userMessage: userMsg,
      state: state,
      apiService: apiService,
      userId: _tempUserId,
      conversationId: _tempConversationId,
      onStateChange: (newState) => state = newState,
    );
  }

  void setActiveAgent(String agentType) {
    state = state.copyWith(activeAgentType: agentType);
  }

  void toggleReasoningPanel() {
    state = state.copyWith(showReasoningPanel: !state.showReasoningPanel);
  }

  void stopStreaming() {
    state = state.copyWith(isStreaming: false, isThinking: false);
  }

  void clearChat() {
    state = ChatState.initial();
  }
}
