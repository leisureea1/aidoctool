import '../core/config/ai_config.dart';
import '../core/utils/result.dart';

/// AI 消息角色
enum MessageRole { system, user, assistant }

/// AI 消息
class AIMessage {
  final MessageRole role;
  final String content;
  
  const AIMessage({
    required this.role,
    required this.content,
  });
  
  Map<String, dynamic> toJson() => {
    'role': role.name,
    'content': content,
  };
}

/// AI 生成请求
class AIGenerateRequest {
  final List<AIMessage> messages;
  final int? maxTokens;
  final double? temperature;
  
  const AIGenerateRequest({
    required this.messages,
    this.maxTokens,
    this.temperature,
  });
}

/// AI 生成响应
class AIGenerateResponse {
  final String content;
  final int? promptTokens;
  final int? completionTokens;
  final String? finishReason;
  
  const AIGenerateResponse({
    required this.content,
    this.promptTokens,
    this.completionTokens,
    this.finishReason,
  });
}

/// AI Provider 抽象接口
/// 所有 AI 模型实现都必须实现此接口
abstract class AIProvider {
  /// 模型配置
  AIModelConfig get config;
  
  /// API Key
  String get apiKey;
  
  /// 生成内容
  Future<Result<AIGenerateResponse>> generate(AIGenerateRequest request);
  
  /// 流式生成（可选实现）
  Stream<String>? generateStream(AIGenerateRequest request) => null;
  
  /// 验证 API Key 是否有效
  Future<bool> validateApiKey();
}
