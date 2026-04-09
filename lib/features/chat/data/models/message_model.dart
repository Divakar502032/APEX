import 'package:flutter/foundation.dart';

enum MessageRole { user, assistant }

enum MessageStatus { sending, streaming, done, error }

@immutable
class MessageModel {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final MessageStatus status;
  final String agentType;
  final int totalTokens;
  final String? model;
  final int? latencyMs;
  final List<String> sources;

  const MessageModel({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.status = MessageStatus.done,
    this.agentType = 'general',
    this.totalTokens = 0,
    this.model,
    this.latencyMs,
    this.sources = const [],
  });

  MessageModel copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    MessageStatus? status,
    String? agentType,
    int? totalTokens,
    String? model,
    int? latencyMs,
    List<String>? sources,
  }) {
    return MessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      agentType: agentType ?? this.agentType,
      totalTokens: totalTokens ?? this.totalTokens,
      model: model ?? this.model,
      latencyMs: latencyMs ?? this.latencyMs,
      sources: sources ?? this.sources,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'role': role.name,
        'timestamp': timestamp.toIso8601String(),
        'status': status.name,
        'agentType': agentType,
        'totalTokens': totalTokens,
        'model': model,
        'latencyMs': latencyMs,
        'sources': sources,
      };

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String,
        content: json['content'] as String,
        role: MessageRole.values.byName(json['role'] as String),
        timestamp: DateTime.parse(json['timestamp'] as String),
        status: MessageStatus.values.byName(json['status'] as String? ?? 'done'),
        agentType: json['agentType'] as String? ?? 'general',
        totalTokens: json['totalTokens'] as int? ?? 0,
        model: json['model'] as String?,
        latencyMs: json['latencyMs'] as int?,
        sources: (json['sources'] as List<dynamic>?)?.cast<String>() ?? [],
      );
}
