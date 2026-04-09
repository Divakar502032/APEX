import 'package:flutter/foundation.dart';
import 'message_model.dart';

@immutable
class ConversationModel {
  final String id;
  final DateTime createdAt;
  final String title;
  final List<MessageModel> messages;
  final String activeAgentType;

  const ConversationModel({
    required this.id,
    required this.createdAt,
    this.title = 'New Conversation',
    this.messages = const [],
    this.activeAgentType = 'general',
  });

  ConversationModel copyWith({
    String? id,
    DateTime? createdAt,
    String? title,
    List<MessageModel>? messages,
    String? activeAgentType,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      activeAgentType: activeAgentType ?? this.activeAgentType,
    );
  }
}
