/// AI 模型配置
class AIModelConfig {
  final String id;
  final String name;
  final String baseUrl;
  final String model;
  final int maxTokens;
  final double temperature;
  final String? description;
  /// 可选模型列表（用于支持多模型的提供商）
  final List<String>? availableModels;
  
  const AIModelConfig({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.model,
    this.maxTokens = 4096,
    this.temperature = 0.7,
    this.description,
    this.availableModels,
  });
  
  /// 是否支持多模型选择
  bool get hasMultipleModels => availableModels != null && availableModels!.length > 1;
  
  AIModelConfig copyWith({
    String? id,
    String? name,
    String? baseUrl,
    String? model,
    int? maxTokens,
    double? temperature,
    String? description,
    List<String>? availableModels,
  }) {
    return AIModelConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      model: model ?? this.model,
      maxTokens: maxTokens ?? this.maxTokens,
      temperature: temperature ?? this.temperature,
      description: description ?? this.description,
      availableModels: availableModels ?? this.availableModels,
    );
  }
}

/// 预定义 AI 模型配置
class AIConfigs {
  /// OpenAI GPT-4
  static const openAI = AIModelConfig(
    id: 'openai',
    name: 'OpenAI GPT-4',
    baseUrl: 'https://api.openai.com/v1',
    model: 'gpt-4-turbo-preview',
    maxTokens: 30000,
    temperature: 0.7,
    description: 'OpenAI 官方 API',
  );
  
  /// Claude
  static const claude = AIModelConfig(
    id: 'claude',
    name: 'Claude 3',
    baseUrl: 'https://api.anthropic.com/v1',
    model: 'claude-3-sonnet-20240229',
    maxTokens: 30000,
    temperature: 0.7,
    description: 'Anthropic Claude API',
  );
  
  /// DeepSeek 官方
  static const deepSeek = AIModelConfig(
    id: 'deepseek',
    name: 'DeepSeek',
    baseUrl: 'https://api.deepseek.com/v1',
    model: 'deepseek-reasoner',
    maxTokens: 30000,
    temperature: 0.7,
    description: 'DeepSeek 官方 API',
  );
  
  /// 联通 DeepSeek R1
  static const unicomDeepSeek = AIModelConfig(
    id: 'unicom_deepseek',
    name: '联通 DeepSeek-R1',
    baseUrl: 'https://aigw-jnzs5.cucloud.cn:8443/v1',
    model: 'deepseek-ai/DeepSeek-R1',
    maxTokens: 4096,
    temperature: 0.7,
    description: '中国联通云 DeepSeek-R1',
  );
  
  /// 自定义 OpenAI 兼容 API
  static const customOpenAI = AIModelConfig(
    id: 'custom',
    name: '自定义 API',
    baseUrl: '',
    model: '',
    maxTokens: 30000,
    temperature: 0.7,
    description: '自定义 OpenAI 兼容 API，需手动填写地址和模型',
  );
  
  static const List<AIModelConfig> presets = [
    openAI, 
    claude, 
    deepSeek, 
    unicomDeepSeek,
    customOpenAI,
  ];
}
