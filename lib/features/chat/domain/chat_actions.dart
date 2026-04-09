import 'package:uuid/uuid.dart';
import '../data/models/message_model.dart';
import '../data/models/reasoning_step_model.dart';
import 'chat_state.dart';

/// ChatActions isolates all side-effect logic from chat_provider.dart.
/// This keeps the notifier clean and each action independently testable.
class ChatActions {
  static final _uuid = Uuid();

  static Future<void> handleSend({
    required MessageModel userMessage,
    required ChatState state,
    required void Function(ChatState) onStateChange,
  }) async {
    // 1. Add user message + set thinking
    final withUser = state.copyWith(
      messages: [...state.messages, userMessage],
      isThinking: true,
      isStreaming: false,
      showReasoningPanel: true,
      reasoningSteps: [],
      error: null,
    );
    onStateChange(withUser);

    // 2. Simulate reasoning steps (Phase 5 will replace with real SSE)
    await _simulateReasoningSteps(withUser, onStateChange);

    // 3. Stream mock response tokens
    await _simulateStreamResponse(
      prompt: userMessage.content,
      state: state,
      onStateChange: onStateChange,
    );
  }

  static Future<void> _simulateReasoningSteps(
    ChatState state,
    void Function(ChatState) onStateChange,
  ) async {
    final steps = [
      ReasoningStepModel(
        id: _uuid.v4(),
        content: 'Searching relevant context...',
        type: ReasoningStepType.search,
        timestamp: DateTime.now(),
      ),
      ReasoningStepModel(
        id: _uuid.v4(),
        content: 'Analyzing the best approach...',
        type: ReasoningStepType.reasoning,
        timestamp: DateTime.now(),
      ),
      ReasoningStepModel(
        id: _uuid.v4(),
        content: 'Composing response...',
        type: ReasoningStepType.writing,
        timestamp: DateTime.now(),
      ),
    ];

    for (final step in steps) {
      await Future.delayed(const Duration(milliseconds: 600));
      onStateChange(state.copyWith(
        reasoningSteps: [...state.reasoningSteps, step],
      ));
    }
  }

  static Future<void> _simulateStreamResponse({
    required String prompt,
    required ChatState state,
    required void Function(ChatState) onStateChange,
  }) async {
    final mockResponse =
        'I\'m **APEX AI**, your intelligent assistant. I\'ve analyzed your request and here\'s what I found:\n\n'
        '- This is a **mock streamed response** — the real backend will stream tokens via SSE in Phase 5\n'
        '- Your question: *"$prompt"*\n'
        '- Memory system will inject relevant context here once Phase 6 is complete\n\n'
        'Ask me anything and I\'ll have the full Gemini 3 Pro response ready once the backend is connected! 🚀';

    final assistantMsg = MessageModel(
      id: _uuid.v4(),
      content: '',
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      status: MessageStatus.streaming,
      agentType: state.activeAgentType,
    );

    // Start streaming
    var current = state.copyWith(
      messages: [...state.messages, assistantMsg],
      isStreaming: true,
      isThinking: false,
    );
    onStateChange(current);

    // Stream characters
    var streamed = '';
    for (final char in mockResponse.split('')) {
      await Future.delayed(const Duration(milliseconds: 18));
      streamed += char;
      final updatedMessages = List<MessageModel>.from(current.messages);
      updatedMessages[updatedMessages.length - 1] =
          assistantMsg.copyWith(content: streamed);
      current = current.copyWith(messages: updatedMessages);
      onStateChange(current);
    }

    // Done
    final doneMessages = List<MessageModel>.from(current.messages);
    doneMessages[doneMessages.length - 1] = assistantMsg.copyWith(
      content: streamed,
      status: MessageStatus.done,
      totalTokens: streamed.length ~/ 4,
      model: 'gemini-3-pro (mock)',
      latencyMs: 1243,
    );

    onStateChange(current.copyWith(
      messages: doneMessages,
      isStreaming: false,
      showReasoningPanel: false,
    ));
  }
}
