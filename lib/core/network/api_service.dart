import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiServiceProvider = Provider((ref) => ApiService());

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8000/api', // Simulator localhost
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'text/event-stream',
    },
  ));

  Stream<Map<String, dynamic>> streamChat({
    required String message,
    required String conversationId,
    required String userId,
    String agentType = 'general',
    List<Map<String, String>> history = const [],
    String? memoryContext,
  }) async* {
    try {
      final response = await _dio.post(
        '/chat/stream',
        data: {
          'user_id': userId,
          'conversation_id': conversationId,
          'message': message,
          'agent_type': agentType,
          'history': history,
          'memory_context': memoryContext,
        },
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data.stream as Stream<List<int>>;

      String currentEvent = '';
      
      await for (final chunk in stream.transform(utf8.decoder).transform(const LineSplitter())) {
        if (chunk.startsWith('event:')) {
          currentEvent = chunk.substring(6).trim();
        } else if (chunk.startsWith('data:')) {
          final data = chunk.substring(5).trim();
          if (data.isNotEmpty) {
            try {
              final decoded = jsonDecode(data);
              yield {
                'event': currentEvent,
                'data': decoded,
              };
            } catch (e) {
              // Ignore partial JSON or malformed data
            }
          }
        } else if (chunk.isEmpty) {
          currentEvent = '';
        }
      }
    } catch (e) {
      yield {
        'event': 'error',
        'data': {'message': e.toString()},
      };
    }
  }

  Future<Map<String, dynamic>> extractMemories(String userId, String conversationId, List<Map<String, String>> messages) async {
    try {
      final response = await _dio.post('/memory/extract', data: {
        'user_id': userId,
        'conversation_id': conversationId,
        'messages': messages,
      });
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMemories(String userId) async {
    try {
      final response = await _dio.get('/memory/$userId');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteMemory(String userId, String memoryId) async {
    try {
      await _dio.delete('/memory/$userId/$memoryId');
    } catch (e) {
      rethrow;
    }
  }
}
