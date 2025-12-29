import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/generated_doc.dart';
import '../widgets/markdown_viewer.dart';
import '../providers/generator_provider.dart';

class ResultPage extends ConsumerWidget {
  final GeneratedDocument document;

  const ResultPage({
    super.key,
    required this.document,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('生成结果'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: '复制全部',
            onPressed: () => _copyToClipboard(context),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: '分享',
            onPressed: () => _shareDocument(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'export_md':
                  _exportMarkdown(context);
                  break;
                case 'regenerate':
                  _regenerate(context, ref);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_md',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('导出 Markdown'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'regenerate',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('重新生成'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 文档信息栏
          _buildInfoBar(context),
          // Markdown 内容
          Expanded(
            child: MarkdownViewer(content: document.markdownContent),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spec = document.spec;
    final techStacks = spec.techStacks;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 平台标签
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              ...spec.platforms.map((p) => _buildIconTag(context, p.icon, p.label, colorScheme.tertiaryContainer)),
              if (spec.needsAdminPanel)
                _buildIconTag(context, Icons.build, '后台管理', colorScheme.errorContainer),
            ],
          ),
          const SizedBox(height: 8),
          // 技术栈标签
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              ...techStacks.frontend.map((s) => _buildIconTag(context, s.icon, s.name, colorScheme.primaryContainer)),
              ...techStacks.backend.map((s) => _buildIconTag(context, s.icon, s.name, colorScheme.secondaryContainer)),
              ...techStacks.database.map((s) => _buildIconTag(context, s.icon, s.name, colorScheme.surfaceContainerHighest)),
              if (spec.needsAdminPanel)
                ...techStacks.adminFrontend.map((s) => _buildIconTag(context, s.icon, s.name, colorScheme.errorContainer.withOpacity(0.5))),
            ],
          ),
          const SizedBox(height: 8),
          // 项目描述
          Row(
            children: [
              Expanded(
                child: Text(
                  spec.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Token 使用量
              if (document.totalTokens != null) ...[
                const SizedBox(width: 12),
                Text(
                  '${document.totalTokens} tokens',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildIconTag(BuildContext context, IconData icon, String name, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            name,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: document.markdownContent));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已复制到剪贴板'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareDocument(BuildContext context) async {
    await Share.share(
      document.markdownContent,
      subject: '项目开发文档',
    );
  }

  Future<void> _exportMarkdown(BuildContext context) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'project_doc_${DateTime.now().millisecondsSinceEpoch}.md';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(document.markdownContent);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已保存到: ${file.path}'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '分享',
              onPressed: () => Share.shareXFiles([XFile(file.path)]),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('导出失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _regenerate(BuildContext context, WidgetRef ref) {
    Navigator.of(context).pop();
    ref.read(generatorProvider.notifier).generate(
      document.spec.projectName,
      document.spec.description,
    );
  }
}
