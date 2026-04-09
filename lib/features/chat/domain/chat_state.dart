import 'package:flutter/foundation.dart';
import '../data/models/message_model.dart';
import '../data/models/reasoning_step_model.dart';

@immutable
class ChatState {
  final List<MessageModel> messages;
  final bool isStreaming;
  final bool isThinking;
  final bool showReasoningPanel;
  final String activeAgentType;
  final List<ReasoningStepModel> reasoningSteps;
  final bool isMemoryActive;
  final String? error;

  const ChatState({
    required this.messages,
    required this.isStreaming,
    required this.isThinking,
    required this.showReasoningPanel,
    required this.activeAgentType,
    required this.reasoningSteps,
    required this.isMemoryActive,
    this.error,
  });

  factory ChatState.initial() => const ChatState(
        messages: [],
        isStreaming: false,
        isThinking: false,
        showReasoningPanel: false,
        activeAgentType: 'general',
        reasoningSteps: [],
        isMemoryActive: false,
        error: null,
      );

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isStreaming,
    bool? isThinking,
    bool? showReasoningPanel,
    String? activeAgentType,
    List<ReasoningStepModel>? reasoningSteps,
    bool? isMemoryActive,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      isThinking: isThinking ?? this.isThinking,
      showReasoningPanel: showReasoningPanel ?? this.showReasoningPanel,
      activeAgentType: activeAgentType ?? this.activeAgentType,
      reasoningSteps: reasoningSteps ?? this.reasoningSteps,
      isMemoryActive: isMemoryActive ?? this.isMemoryActive,
      error: error,
    );
  }
}
