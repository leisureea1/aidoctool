import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/ai_config.dart';
import '../providers/generator_provider.dart';

class ApiKeyDialog extends ConsumerStatefulWidget {
  const ApiKeyDialog({super.key});

  @override
  ConsumerState<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends ConsumerState<ApiKeyDialog> {
  late String _selectedConfigId;
  late String _selectedModel;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _selectedSubModels = {};
  bool _obscureText = true;
  
  // 自定义 API 配置
  late TextEditingController _customBaseUrlController;
  late TextEditingController _customModelController;
  late TextEditingController _customMaxTokensController;
  
  AIModelConfig get _selectedConfig => 
      AIConfigs.presets.firstWhere((c) => c.id == _selectedConfigId);
  
  bool get _isCustom => _selectedConfigId == 'custom';

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _selectedConfigId = settings.selectedModel.id;
    _selectedModel = settings.selectedModel.model;
    
    // 为每个提供商创建独立的控制器
    for (final config in AIConfigs.presets) {
      _controllers[config.id] = TextEditingController(
        text: settings.apiKeys[config.id] ?? '',
      );
      _selectedSubModels[config.id] = config.model;
    }
    
    // 恢复之前选择的子模型
    if (settings.selectedSubModels.isNotEmpty) {
      _selectedSubModels.addAll(settings.selectedSubModels);
    }
    _selectedModel = _selectedSubModels[_selectedConfigId] ?? _selectedConfig.model;
    
    // 自定义 API 配置
    _customBaseUrlController = TextEditingController(text: settings.customBaseUrl);
    _customModelController = TextEditingController(text: settings.customModel);
    _customMaxTokensController = TextEditingController(
      text: settings.customMaxTokens.toString(),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _customBaseUrlController.dispose();
    _customModelController.dispose();
    _customMaxTokensController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentController = _controllers[_selectedConfigId]!;
    final hasKey = currentController.text.isNotEmpty;
    final config = _selectedConfig;
    
    return AlertDialog(
      title: const Text('配置 AI 模型'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 提供商选择
              Text('选择提供商', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedConfigId,
                isExpanded: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: AIConfigs.presets.map((c) {
                  final configured = (_controllers[c.id]?.text ?? '').isNotEmpty;
                  return DropdownMenuItem(
                    value: c.id,
                    child: Row(
                      children: [
                        Expanded(child: Text(c.name)),
                        if (configured)
                          Icon(Icons.check_circle, 
                              size: 16, 
                              color: Theme.of(context).colorScheme.primary),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedConfigId = value;
                      final newConfig = _selectedConfig;
                      _selectedModel = _selectedSubModels[value] ?? newConfig.model;
                    });
                  }
                },
              ),
              if (config.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  config.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              
              // 自定义 API 配置
              if (_isCustom) ...[
                Text('API 地址', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  controller: _customBaseUrlController,
                  decoration: const InputDecoration(
                    hintText: 'https://api.example.com/v1',
                  ),
                ),
                const SizedBox(height: 16),
                Text('模型名称', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  controller: _customModelController,
                  decoration: const InputDecoration(
                    hintText: 'gpt-4, claude-3-sonnet, deepseek-chat...',
                  ),
                ),
                const SizedBox(height: 16),
                Text('Max Tokens', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  controller: _customMaxTokensController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '30000',
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // 子模型选择（如果支持多模型）
              if (!_isCustom && config.hasMultipleModels) ...[
                Text('选择模型', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedModel,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: config.availableModels!.map((model) {
                    return DropdownMenuItem(
                      value: model,
                      child: Text(model, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedModel = value;
                        _selectedSubModels[_selectedConfigId] = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
              
              // 模型信息（非自定义时显示）
              if (!_isCustom)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(context, 'API 地址', config.baseUrl),
                      const SizedBox(height: 4),
                      _buildInfoRow(context, '模型', _selectedModel),
                      const SizedBox(height: 4),
                      _buildInfoRow(context, 'Max Tokens', config.maxTokens.toString()),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              
              // API Key 输入
              Row(
                children: [
                  Text('API Key', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(width: 8),
                  Text(
                    '(${config.name})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: currentController,
                obscureText: _obscureText,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '输入 API Key',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureText = !_obscureText),
                      ),
                      if (hasKey)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            currentController.clear();
                            setState(() {});
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // 已配置的提供商列表
              _buildConfiguredList(context),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: _saveAll,
          child: const Text('保存'),
        ),
      ],
    );
  }
  
  Widget _buildConfiguredList(BuildContext context) {
    final configured = AIConfigs.presets
        .where((c) => (_controllers[c.id]?.text ?? '').isNotEmpty)
        .toList();
    
    if (configured.isEmpty) {
      return Text(
        '尚未配置任何提供商的 API Key',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '已配置的提供商',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: configured.map((config) {
            final subModel = _selectedSubModels[config.id];
            final label = config.hasMultipleModels && subModel != null
                ? '${config.name} ($subModel)'
                : config.name;
            return Chip(
              label: Text(label, style: const TextStyle(fontSize: 11)),
              avatar: Icon(Icons.check, size: 14, color: Theme.of(context).colorScheme.primary),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  void _saveAll() {
    final notifier = ref.read(settingsProvider.notifier);
    
    // 保存所有提供商的 API Key
    for (final config in AIConfigs.presets) {
      final key = _controllers[config.id]?.text ?? '';
      notifier.setApiKey(config.id, key);
    }
    
    // 保存子模型选择
    notifier.setSubModels(_selectedSubModels);
    
    // 保存自定义 API 配置
    final customMaxTokens = int.tryParse(_customMaxTokensController.text.trim()) ?? 30000;
    // 清理 URL 中的不可见字符（如行分隔符 U+2028）
    final cleanBaseUrl = _cleanUrl(_customBaseUrlController.text.trim());
    final cleanModel = _customModelController.text.trim();
    
    notifier.setCustomConfig(cleanBaseUrl, cleanModel, customMaxTokens);
    
    // 设置当前选中的配置
    AIModelConfig finalConfig;
    if (_isCustom) {
      finalConfig = _selectedConfig.copyWith(
        baseUrl: cleanBaseUrl,
        model: cleanModel,
        maxTokens: customMaxTokens,
      );
    } else {
      finalConfig = _selectedConfig.copyWith(model: _selectedModel);
    }
    notifier.setModel(finalConfig);
    
    Navigator.of(context).pop();
  }
  
  /// 清理 URL 中的不可见字符
  String _cleanUrl(String url) {
    // 移除常见的不可见字符：
    // U+2028 (Line Separator), U+2029 (Paragraph Separator)
    // U+200B (Zero Width Space), U+FEFF (BOM)
    // 以及其他控制字符
    return url
        .replaceAll('\u2028', '')
        .replaceAll('\u2029', '')
        .replaceAll('\u200B', '')
        .replaceAll('\uFEFF', '')
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // 控制字符
        .trim();
  }
}

/// 显示 API Key 配置对话框
Future<void> showApiKeyDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => const ApiKeyDialog(),
  );
}
