import '../core/config/ai_config.dart';
import 'ai_provider.dart';
import 'openai_provider.dart';
import 'claude_provider.dart';

/// AI Provider 工厂
/// 根据配置创建对应的 Provider 实例
class AIProviderFactory {
  /// 创建 AI Provider
  static AIProvider create({
    required AIModelConfig config,
    required String apiKey,
  }) {
    return switch (config.id) {
      'claude' => ClaudeProvider(config: config, apiKey: apiKey),
      // OpenAI、DeepSeek 等使用 OpenAI 兼容接口
      _ => OpenAICompatibleProvider(config: config, apiKey: apiKey),
    };
  }
  
  /// 创建自定义 Provider（私有部署）
  static AIProvider createCustom({
    required String baseUrl,
    required String model,
    required String apiKey,
    String name = 'Custom Model',
    bool isClaudeCompatible = false,
  }) {
    final config = AIModelConfig(
      id: isClaudeCompatible ? 'claude' : 'custom',
      name: name,
      baseUrl: baseUrl,
      model: model,
    );
    
    return create(config: config, apiKey: apiKey);
  }
}
