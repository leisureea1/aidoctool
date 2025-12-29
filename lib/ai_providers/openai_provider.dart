import 'package:dio/dio.dart';
import '../core/config/ai_config.dart';
import '../core/errors/failures.dart';
import '../core/utils/result.dart';
import 'ai_provider.dart';

/// OpenAI 兼容 API Provider
/// 支持 OpenAI、DeepSeek 等兼容 OpenAI API 格式的服务
class OpenAICompatibleProvider implements AIProvider {
  @override
  final AIModelConfig config;
  
  @override
  final String apiKey;
  
  final Dio _dio;
  
  OpenAICompatibleProvider({
    required this.config,
    required this.apiKey,
    Dio? dio,
  }) : _dio = dio ?? Dio();
  
  @override
  Future<Result<AIGenerateResponse>> generate(AIGenerateRequest request) async {
    try {
      final response = await _dio.post(
        '${config.baseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 120),
        ),
        data: {
          'model': config.model,
          'messages': request.messages.map((m) => m.toJson()).toList(),
          'max_tokens': request.maxTokens ?? config.maxTokens,
          'temperature': request.temperature ?? config.temperature,
        },
      );
      
      final data = response.data;
      final choices = data['choices'] as List?;
      
      if (choices == null || choices.isEmpty) {
        return const Error(AIApiFailure('AI 返回结果为空'));
      }
      
      final content = choices[0]['message']['content'] as String? ?? '';
      final usage = data['usage'] as Map<String, dynamic>?;
      
      return Success(AIGenerateResponse(
        content: content,
        promptTokens: usage?['prompt_tokens'] as int?,
        completionTokens: usage?['completion_tokens'] as int?,
        finishReason: choices[0]['finish_reason'] as String?,
      ));
    } on DioException catch (e) {
      return Error(_handleDioError(e));
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Stream<String>? generateStream(AIGenerateRequest request) {
    // 流式实现（MVP 阶段可选）
    return null;
  }
  
  @override
  Future<bool> validateApiKey() async {
    try {
      final response = await _dio.get(
        '${config.baseUrl}/models',
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
        ),
      );
      return response.statusCode == 200;
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
        final message = _parseErrorMessage(e.response?.data);
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
  
  String _parseErrorMessage(dynamic data) {
    if (data == null) return '未知错误';
    if (data is String) return data;
    if (data is Map) {
      return data['error']?['message'] as String? ?? 
             data['message'] as String? ?? 
             '未知错误';
    }
    return '未知错误';
  }
}
