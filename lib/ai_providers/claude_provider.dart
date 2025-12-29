import 'package:dio/dio.dart';
import '../core/config/ai_config.dart';
import '../core/errors/failures.dart';
import '../core/utils/result.dart';
import 'ai_provider.dart';

/// Claude API Provider
class ClaudeProvider implements AIProvider {
  @override
  final AIModelConfig config;
  
  @override
  final String apiKey;
  
  final Dio _dio;
  
  ClaudeProvider({
    required this.config,
    required this.apiKey,
    Dio? dio,
  }) : _dio = dio ?? Dio();
  
  @override
  Future<Result<AIGenerateResponse>> generate(AIGenerateRequest request) async {
    try {
      // 分离 system message 和其他 messages
      String? systemPrompt;
      final messages = <Map<String, dynamic>>[];
      
      for (final msg in request.messages) {
        if (msg.role == MessageRole.system) {
          systemPrompt = msg.content;
        } else {
          messages.add({
            'role': msg.role.name,
            'content': msg.content,
          });
        }
      }
      
      final response = await _dio.post(
        '${config.baseUrl}/messages',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 120),
        ),
        data: {
          'model': config.model,
          'max_tokens': request.maxTokens ?? config.maxTokens,
          if (systemPrompt != null) 'system': systemPrompt,
          'messages': messages,
        },
      );
      
      final data = response.data;
      final content = data['content'] as List?;
      
      if (content == null || content.isEmpty) {
        return const Error(AIApiFailure('AI 返回结果为空'));
      }
      
      final textContent = content
          .where((c) => c['type'] == 'text')
          .map((c) => c['text'] as String)
          .join('\n');
      
      final usage = data['usage'] as Map<String, dynamic>?;
      
      return Success(AIGenerateResponse(
        content: textContent,
        promptTokens: usage?['input_tokens'] as int?,
        completionTokens: usage?['output_tokens'] as int?,
        finishReason: data['stop_reason'] as String?,
      ));
    } on DioException catch (e) {
      return Error(_handleDioError(e));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Stream<String>? generateStream(AIGenerateRequest request) => null;
  
  @override
  Future<bool> validateApiKey() async {
    // Claude 没有专门的验证端点，通过发送简单请求验证
    try {
      final result = await generate(const AIGenerateRequest(
        messages: [AIMessage(role: MessageRole.user, content: 'Hi')],
        maxTokens: 10,
      ));
      return result.isSuccess;
    } catch (_) {
      return false;
    }
  }
  
  Failure _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('请求超时，请检查网络连接');
      case DioExceptionType.connectionError:
        return const NetworkFailure('网络连接失败');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        final message = data?['error']?['message'] as String? ?? '未知错误';
        return switch (statusCode) {
          401 => AIApiFailure('API Key 无效', errorCode: '401', details: message),
          429 => AIApiFailure('请求过于频繁，请稍后重试', errorCode: '429', details: message),
          500 || 502 || 503 => AIApiFailure('AI 服务暂时不可用', errorCode: '$statusCode', details: message),
          _ => NetworkFailure('请求失败: $message', statusCode: statusCode),
        };
      default:
        return UnknownFailure(e.message ?? '未知错误');
    }
  }
}
