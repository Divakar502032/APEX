import 'package:uuid/uuid.dart';
import '../data/models/message_model.dart';
import '../data/models/reasoning_step_model.dart';
import 'chat_state.dart';
import '../../../core/network/api_service.dart';

class ChatActions {
  static final _uuid = Uuid();

  static Future<void> handleSend({
    required MessageModel userMessage,
    required ChatState state,
    required ApiService apiService,
    required String userId,
    required String conversationId,
    required void Function(ChatState) onStateChange,
  }) async {
    // 1. Update state with user message and set thinking
    var current = state.copyWith(
      messages: [...state.messages, userMessage],
      isThinking: true,
      isStreaming: false,
      showReasoningPanel: true,
      reasoningSteps: [],
      error: null,
    );
    onStateChange(current);

    try {
      // 2. Prepare history for API
      final history = state.messages.map((m) => {
        'role': m.role.name,
        'content': m.content,
      }).toList();

      final assistantMsgId = _uuid.v4();
      MessageModel assistantMsg = MessageModel(
        id: assistantMsgId,
        content: '',
        role: MessageRole.assistant,
        timestamp: DateTime.now(),
        status: MessageStatus.streaming,
        agentType: state.activeAgentType,
      );

      bool hasAddedAssistant = false;
      String fullContent = '';

      // 3. Listen to SSE stream
      final stream = apiService.streamChat(
        message: userMessage.content,
        conversationId: conversationId,
        userId: userId,
        agentType: state.activeAgentType,
        history: history,
        memoryContext: null, // Phase 6
      );

      await for (final event in stream) {
        final eventType = event['event'] as String;
        final data = event['data'] as Map<String, dynamic>;

        switch (eventType) {
          case 'agent':
            current = current.copyWith(
              activeAgentType: data['agent'] as String,
            );
            onStateChange(current);
            break;

          case 'reasoning_step':
            final step = ReasoningStepModel(
              id: _uuid.v4(),
              content: data['step'] as String,
              type: _parseStepType(data['type'] as String),
              timestamp: DateTime.now(),
            );
            current = current.copyWith(
              reasoningSteps: [...current.reasoningSteps, step],
            );
            onStateChange(current);
            break;

          case 'token':
            if (!hasAddedAssistant) {
              current = current.copyWith(
                messages: [...current.messages, assistantMsg],
                isThinking: false,
                isStreaming: true,
              );
              hasAddedAssistant = true;
            }
            fullContent += data['content'] as String;
            
            // Update the last message in the list
            final updatedMessages = List<MessageModel>.from(current.messages);
            updatedMessages[updatedMessages.length - 1] = assistantMsg.copyWith(
              content: fullContent,
            );
            current = current.copyWith(messages: updatedMessages);
            onStateChange(current);
            break;

          case 'done':
            final updatedMessages = List<MessageModel>.from(current.messages);
            updatedMessages[updatedMessages.length - 1] = assistantMsg.copyWith(
              content: fullContent,
              status: MessageStatus.done,
              totalTokens: data['total_tokens'] as int? ?? 0,
              model: data['model'] as String?,
              latencyMs: data['latency_ms'] as int?,
            );
            current = current.copyWith(
              messages: updatedMessages,
              isStreaming: false,
              showReasoningPanel: false, // Collapse on done
            );
            onStateChange(current);
            break;

          case 'error':
            current = current.copyWith(
              error: data['message'] as String?,
              isThinking: false,
              isStreaming: false,
            );
            onStateChange(current);
            break;
        }
      }
    } catch (e) {
      onStateChange(current.copyWith(
        error: e.toString(),
        isThinking: false,
        isStreaming: false,
      ));
    }
  }

  static ReasoningStepType _parseStepType(String type) {
    switch (type) {
      case 'search': return ReasoningStepType.search;
      case 'reasoning': return ReasoningStepType.reasoning;
      case 'writing': return ReasoningStepType.writing;
      case 'verified': return ReasoningStepType.verified;
      default: return ReasoningStepType.reasoning;
    }
  }
}

