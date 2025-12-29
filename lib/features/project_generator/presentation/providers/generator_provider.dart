import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../ai_providers/ai_provider.dart';
import '../../../../ai_providers/provider_factory.dart';
import '../../../../core/config/ai_config.dart';
import '../../../../core/constants/tech_stacks.dart';
import '../../../../core/constants/ui_styles.dart';
import '../../../../core/errors/failures.dart';
import '../../data/repositories/generator_repository_impl.dart';
import '../../domain/entities/project_spec.dart';
import '../../domain/entities/generated_doc.dart';

/// 生成状态
sealed class GeneratorState {
  const GeneratorState();
}

class GeneratorInitial extends GeneratorState {
  const GeneratorInitial();
}

class GeneratorLoading extends GeneratorState {
  final String message;
  const GeneratorLoading({this.message = '正在生成文档...'});
}

class GeneratorSuccess extends GeneratorState {
  final GeneratedDocument document;
  const GeneratorSuccess(this.document);
}

class GeneratorError extends GeneratorState {
  final Failure failure;
  const GeneratorError(this.failure);
}

/// 设置状态
class SettingsState {
  final AIModelConfig selectedModel;
  /// 每个提供商独立的 API Key，key 为提供商 id
  final Map<String, String> apiKeys;
  /// 每个提供商选择的子模型，key 为提供商 id
  final Map<String, String> selectedSubModels;
  /// 自定义 API 地址
  final String customBaseUrl;
  /// 自定义模型名称
  final String customModel;
  /// 自定义 Max Tokens
  final int customMaxTokens;
  final List<AppPlatform> selectedPlatforms;
  final bool needsAdminPanel;
  /// 是否前后端分离
  final bool isSeparated;
  final TechStackSelection techStackSelection;
  final UIStyle? selectedUIStyle;
  
  const SettingsState({
    this.selectedModel = AIConfigs.openAI,
    this.apiKeys = const {},
    this.selectedSubModels = const {},
    this.customBaseUrl = '',
    this.customModel = '',
    this.customMaxTokens = 30000,
    this.selectedPlatforms = const [],
    this.needsAdminPanel = false,
    this.isSeparated = true,
    this.techStackSelection = const TechStackSelection(),
    this.selectedUIStyle,
  });
  
  /// 获取当前选中提供商的 API Key
  String get currentApiKey => apiKeys[selectedModel.id] ?? '';
  
  SettingsState copyWith({
    AIModelConfig? selectedModel,
    Map<String, String>? apiKeys,
    Map<String, String>? selectedSubModels,
    String? customBaseUrl,
    String? customModel,
    int? customMaxTokens,
    List<AppPlatform>? selectedPlatforms,
    bool? needsAdminPanel,
    bool? isSeparated,
    TechStackSelection? techStackSelection,
    UIStyle? selectedUIStyle,
    bool clearUIStyle = false,
  }) {
    return SettingsState(
      selectedModel: selectedModel ?? this.selectedModel,
      apiKeys: apiKeys ?? this.apiKeys,
      selectedSubModels: selectedSubModels ?? this.selectedSubModels,
      customBaseUrl: customBaseUrl ?? this.customBaseUrl,
      customModel: customModel ?? this.customModel,
      customMaxTokens: customMaxTokens ?? this.customMaxTokens,
      selectedPlatforms: selectedPlatforms ?? this.selectedPlatforms,
      needsAdminPanel: needsAdminPanel ?? this.needsAdminPanel,
      isSeparated: isSeparated ?? this.isSeparated,
      techStackSelection: techStackSelection ?? this.techStackSelection,
      selectedUIStyle: clearUIStyle ? null : (selectedUIStyle ?? this.selectedUIStyle),
    );
  }
  
  bool get isConfigured => currentApiKey.isNotEmpty;
  bool get isPlatformSelected => selectedPlatforms.isNotEmpty;
  bool get isTechStackValid => techStackSelection.isValid;
  bool get isAdminTechStackValid => !needsAdminPanel || techStackSelection.adminFrontend.isNotEmpty;
  bool get isAllValid => isPlatformSelected && isTechStackValid && isAdminTechStackValid;
}

/// 设置 Provider
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());
  
  void setModel(AIModelConfig model) {
    state = state.copyWith(selectedModel: model);
  }
  
  /// 为指定提供商设置 API Key
  void setApiKey(String providerId, String key) {
    final newKeys = Map<String, String>.from(state.apiKeys);
    if (key.isEmpty) {
      newKeys.remove(providerId);
    } else {
      newKeys[providerId] = key;
    }
    state = state.copyWith(apiKeys: newKeys);
  }
  
  /// 获取指定提供商的 API Key
  String getApiKey(String providerId) => state.apiKeys[providerId] ?? '';
  
  /// 设置子模型选择
  void setSubModels(Map<String, String> subModels) {
    state = state.copyWith(selectedSubModels: Map.from(subModels));
  }
  
  /// 设置自定义 API 配置
  void setCustomConfig(String baseUrl, String model, int maxTokens) {
    state = state.copyWith(
      customBaseUrl: baseUrl, 
      customModel: model,
      customMaxTokens: maxTokens,
    );
  }
  
  void togglePlatform(AppPlatform platform, bool selected) {
    final list = List<AppPlatform>.from(state.selectedPlatforms);
    if (selected) {
      if (!list.contains(platform)) list.add(platform);
    } else {
      list.remove(platform);
    }
    state = state.copyWith(selectedPlatforms: list);
  }
  
  void setNeedsAdminPanel(bool value) {
    state = state.copyWith(needsAdminPanel: value);
    if (!value) {
      final newSelection = state.techStackSelection.copyWith(adminFrontend: []);
      state = state.copyWith(techStackSelection: newSelection);
    }
  }
  
  void setIsSeparated(bool value) {
    state = state.copyWith(isSeparated: value);
  }
  
  void setUIStyle(UIStyle? style) {
    if (style == null) {
      state = state.copyWith(clearUIStyle: true);
    } else {
      state = state.copyWith(selectedUIStyle: style);
    }
  }
  
  void toggleTechStack(TechCategory category, TechStack stack, bool selected) {
    final current = state.techStackSelection;
    TechStackSelection newSelection;
    
    switch (category) {
      case TechCategory.frontend:
        final list = List<TechStack>.from(current.frontend);
        if (selected) list.add(stack); else list.removeWhere((e) => e.id == stack.id);
        newSelection = current.copyWith(frontend: list);
      case TechCategory.backend:
        final list = List<TechStack>.from(current.backend);
        if (selected) list.add(stack); else list.removeWhere((e) => e.id == stack.id);
        newSelection = current.copyWith(backend: list);
      case TechCategory.database:
        final list = List<TechStack>.from(current.database);
        if (selected) list.add(stack); else list.removeWhere((e) => e.id == stack.id);
        newSelection = current.copyWith(database: list);
      case TechCategory.adminFrontend:
        final list = List<TechStack>.from(current.adminFrontend);
        if (selected) list.add(stack); else list.removeWhere((e) => e.id == stack.id);
        newSelection = current.copyWith(adminFrontend: list);
    }
    state = state.copyWith(techStackSelection: newSelection);
  }
  
  void clearAll() {
    state = const SettingsState();
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);

/// AI Provider
final aiProviderProvider = Provider<AIProvider?>((ref) {
  final settings = ref.watch(settingsProvider);
  if (!settings.isConfigured) return null;
  return AIProviderFactory.create(config: settings.selectedModel, apiKey: settings.currentApiKey);
});

/// 生成器 Provider
class GeneratorNotifier extends StateNotifier<GeneratorState> {
  final Ref _ref;
  GeneratorNotifier(this._ref) : super(const GeneratorInitial());
  
  Future<void> generate(String projectName, String description) async {
    final settings = _ref.read(settingsProvider);
    final aiProvider = _ref.read(aiProviderProvider);
    
    if (aiProvider == null) {
      state = const GeneratorError(ConfigFailure('请先配置 API Key'));
      return;
    }
    if (projectName.trim().isEmpty) {
      state = const GeneratorError(ConfigFailure('请输入项目名称'));
      return;
    }
    if (!settings.isPlatformSelected) {
      state = const GeneratorError(ConfigFailure('请选择应用平台'));
      return;
    }
    if (!settings.isTechStackValid) {
      state = const GeneratorError(ConfigFailure('请至少选择一个前端和一个后端技术栈'));
      return;
    }
    if (!settings.isAdminTechStackValid) {
      state = const GeneratorError(ConfigFailure('请选择后台管理前端技术栈'));
      return;
    }
    if (description.trim().isEmpty) {
      state = const GeneratorError(ConfigFailure('请输入详细功能描述'));
      return;
    }
    
    state = const GeneratorLoading();
    
    final repository = GeneratorRepositoryImpl(aiProvider: aiProvider);
    final spec = ProjectSpec(
      id: const Uuid().v4(),
      projectName: projectName.trim(),
      platforms: settings.selectedPlatforms,
      needsAdminPanel: settings.needsAdminPanel,
      isSeparated: settings.isSeparated,
      techStacks: settings.techStackSelection,
      uiStyle: settings.selectedUIStyle,
      description: description.trim(),
      createdAt: DateTime.now(),
    );
    
    final result = await repository.generateDocument(spec);
    result.when(
      success: (document) => state = GeneratorSuccess(document),
      failure: (failure) => state = GeneratorError(failure),
    );
  }
  
  void reset() {
    state = const GeneratorInitial();
  }
}

final generatorProvider = StateNotifierProvider<GeneratorNotifier, GeneratorState>(
  (ref) => GeneratorNotifier(ref),
);
