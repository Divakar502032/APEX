import 'package:flutter/foundation.dart';

enum ReasoningStepType { search, reasoning, writing, verified }

@immutable
class ReasoningStepModel {
  final String id;
  final String content;
  final ReasoningStepType type;
  final DateTime timestamp;
  final bool isExpanded;

  const ReasoningStepModel({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isExpanded = false,
  });

  ReasoningStepModel copyWith({
    String? id,
    String? content,
    ReasoningStepType? type,
    DateTime? timestamp,
    bool? isExpanded,
  }) {
    return ReasoningStepModel(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

extension ReasoningStepTypeX on ReasoningStepType {
  String get emoji {
    switch (this) {
      case ReasoningStepType.search:    return '🔍';
      case ReasoningStepType.reasoning: return '🧠';
      case ReasoningStepType.writing:   return '📝';
      case ReasoningStepType.verified:  return '✅';
    }
  }

  String get label {
    switch (this) {
      case ReasoningStepType.search:    return 'Searching';
      case ReasoningStepType.reasoning: return 'Reasoning';
      case ReasoningStepType.writing:   return 'Writing';
      case ReasoningStepType.verified:  return 'Verified';
    }
  }
}
