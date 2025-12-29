import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../ai_providers/ai_provider.dart';
import '../../../../prompts/prompt_manager.dart';
import '../providers/generator_provider.dart';
import '../widgets/tech_stack_selector.dart';
import '../widgets/api_key_dialog.dart';
import '../widgets/markdown_viewer.dart';
import '../widgets/ui_style_selector.dart';
import 'about_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _projectNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _generatedContent;
  bool _hasProjectName = false;
  bool _hasDescription = false;
  bool _isPolishing = false;

  @override
  void initState() {
    super.initState();
    _projectNameController.addListener(_onProjectNameChanged);
    _descriptionController.addListener(_onDescriptionChanged);
  }

  @override
  void dispose() {
    _projectNameController.removeListener(_onProjectNameChanged);
    _descriptionController.removeListener(_onDescriptionChanged);
    _projectNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onProjectNameChanged() {
    final hasText = _projectNameController.text.trim().isNotEmpty;
    if (hasText != _hasProjectName) {
      setState(() => _hasProjectName = hasText);
    }
  }

  void _onDescriptionChanged() {
    final hasText = _descriptionController.text.trim().isNotEmpty;
    if (hasText != _hasDescription) {
      setState(() => _hasDescription = hasText);
    }
  }

  void _onGenerate() {
    ref.read(generatorProvider.notifier).generate(
      _projectNameController.text,
      _descriptionController.text,
    );
  }

  Future<void> _onPolish() async {
    final projectName = _projectNameController.text.trim();
    if (projectName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入项目名称'), duration: Duration(seconds: 2)),
      );
      return;
    }

    final aiProvider = ref.read(aiProviderProvider);
    if (aiProvider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先配置 API Key'), duration: Duration(seconds: 2)),
      );
      return;
    }

    setState(() => _isPolishing = true);

    try {
      final messages = PromptManager.buildPolishMessages(projectName);
      final request = AIGenerateRequest(messages: messages, maxTokens: 2000);
      final result = await aiProvider.generate(request);
      
      if (mounted) {
        result.when(
          success: (response) {
            setState(() {
              _descriptionController.text = response.content.trim();
              _isPolishing = false;
            });
          },
          failure: (failure) {
            setState(() => _isPolishing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('AI 润色失败: ${failure.message}'),
                backgroundColor: Theme.of(context).colorScheme.error,
                duration: const Duration(seconds: 3),
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPolishing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI 润色失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final generatorState = ref.watch(generatorProvider);

    ref.listen<GeneratorState>(generatorProvider, (previous, next) {
      if (next is GeneratorSuccess) {
        setState(() {
          _generatedContent = next.document.markdownContent;
        });
      } else if (next is GeneratorError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.failure.message),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });

    final isLoading = generatorState is GeneratorLoading;

    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.30,
            child: _buildLeftPanel(context, settings, isLoading),
          ),
          VerticalDivider(width: 1, thickness: 1, color: Theme.of(context).dividerColor),
          Expanded(
            child: _buildRightPanel(context, isLoading),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(BuildContext context, SettingsState settings, bool isLoading) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              children: [
                Icon(Icons.tune, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('项目配置', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.info_outline, size: 20), tooltip: '关于', onPressed: () => showAppAboutPage(context)),
                IconButton(
                  icon: Icon(settings.isConfigured ? Icons.check_circle : Icons.settings, color: settings.isConfigured ? Colors.green : null, size: 22),
                  tooltip: settings.isConfigured ? '已配置 API (${settings.selectedModel.name})' : '配置 API Key',
                  onPressed: () => showApiKeyDialog(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 项目名称
                  _buildProjectNameInput(context),
                  const SizedBox(height: 20),
                  
                  // 平台选择
                  const PlatformSelector(),
                  const SizedBox(height: 16),
                  
                  // 前后端分离开关
                  const SeparatedSwitch(),
                  const SizedBox(height: 12),
                  
                  // 后台管理开关
                  const AdminPanelSwitch(),
                  const SizedBox(height: 20),
                  
                  // UI 风格选择
                  const UIStyleSelector(),
                  const SizedBox(height: 20),
                  
                  // 技术栈选择
                  const TechStackSelector(),
                  const SizedBox(height: 20),
                  
                  // 详细功能描述
                  _buildDescriptionInput(context, settings),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: _buildGenerateButton(context, settings, isLoading),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectNameInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('项目名称', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Text('*', style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _projectNameController,
          decoration: const InputDecoration(
            hintText: '例如：在线商城系统、任务管理平台...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionInput(BuildContext context, SettingsState settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('详细功能', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Text('*', style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            TextField(
              controller: _descriptionController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: '描述项目的核心功能模块...\n\n可以点击右下角 AI 按钮自动生成',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.fromLTRB(12, 12, 48, 12),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: _isPolishing
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : IconButton(
                      icon: Icon(Icons.auto_fix_high, color: settings.isConfigured && _hasProjectName ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                      tooltip: 'AI 智能生成功能描述',
                      onPressed: settings.isConfigured && _hasProjectName ? _onPolish : null,
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRightPanel(BuildContext context, bool isLoading) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: Row(
            children: [
              Icon(Icons.description_outlined, size: 20, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text('生成结果', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              if (_generatedContent != null) ...[
                IconButton(icon: const Icon(Icons.copy, size: 20), tooltip: '复制', onPressed: _copyToClipboard),
                IconButton(icon: const Icon(Icons.download, size: 20), tooltip: '保存文件', onPressed: _saveToFile),
                IconButton(icon: const Icon(Icons.share, size: 20), tooltip: '分享', onPressed: _shareDocument),
              ],
            ],
          ),
        ),
        Expanded(child: _buildContentArea(context, isLoading)),
      ],
    );
  }

  Widget _buildContentArea(BuildContext context, bool isLoading) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text('正在生成文档...', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('这可能需要 30-60 秒，请耐心等待', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          ],
        ),
      );
    }

    if (_generatedContent == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 80, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text('配置项目参数后点击生成', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
            const SizedBox(height: 8),
            Text('生成的文档将在此处显示', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
          ],
        ),
      );
    }

    return MarkdownViewer(content: _generatedContent!);
  }

  Widget _buildGenerateButton(BuildContext context, SettingsState settings, bool isLoading) {
    String buttonText = '生成开发文档';
    String? hint;
    
    if (!settings.isConfigured) {
      hint = '请先配置 API Key';
    } else if (!_hasProjectName) {
      hint = '请输入项目名称';
    } else if (!settings.isPlatformSelected) {
      hint = '请选择应用平台';
    } else if (!settings.isTechStackValid) {
      hint = '请选择前端和后端技术栈';
    } else if (!settings.isAdminTechStackValid) {
      hint = '请选择后台管理前端';
    } else if (!_hasDescription) {
      hint = '请输入详细功能描述';
    } else if (isLoading) {
      buttonText = '生成中...';
    }

    final isReady = settings.isConfigured && _hasProjectName && settings.isAllValid && _hasDescription;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hint != null && settings.isConfigured)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(hint, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error)),
          ),
        FilledButton.icon(
          onPressed: isLoading ? null : (isReady ? _onGenerate : null),
          icon: isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome, size: 18),
          label: Text(buttonText),
        ),
        if (!settings.isConfigured)
          TextButton(onPressed: () => showApiKeyDialog(context), child: const Text('配置 API Key')),
      ],
    );
  }

  void _copyToClipboard() {
    if (_generatedContent != null) {
      Clipboard.setData(ClipboardData(text: _generatedContent!));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制到剪贴板'), duration: Duration(seconds: 2)));
    }
  }

  Future<void> _saveToFile() async {
    if (_generatedContent == null) return;
    try {
      final projectName = _projectNameController.text.trim();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final defaultFileName = projectName.isNotEmpty ? '${projectName}_$timestamp.md' : 'project_doc_$timestamp.md';
      
      final result = await FilePicker.platform.saveFile(dialogTitle: '保存文档', fileName: defaultFileName, type: FileType.custom, allowedExtensions: ['md']);
      
      if (result != null) {
        final file = File(result);
        await file.writeAsString(_generatedContent!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('已保存到: $result'), duration: const Duration(seconds: 3)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存失败: $e'), backgroundColor: Theme.of(context).colorScheme.error, duration: const Duration(seconds: 3)));
      }
    }
  }

  Future<void> _shareDocument() async {
    if (_generatedContent != null) {
      await Share.share(_generatedContent!, subject: '项目开发文档');
    }
  }
}
