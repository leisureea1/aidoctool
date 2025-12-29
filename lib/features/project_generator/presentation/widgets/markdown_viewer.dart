import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownViewer extends StatelessWidget {
  final String content;
  final ScrollController? scrollController;

  const MarkdownViewer({
    super.key,
    required this.content,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Markdown(
      data: content,
      controller: scrollController,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
        h1: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        h2: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        h3: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        p: TextStyle(
          fontSize: 15,
          height: 1.6,
          color: colorScheme.onSurface,
        ),
        code: TextStyle(
          fontSize: 13,
          fontFamily: 'monospace',
          backgroundColor: colorScheme.surfaceContainerHighest,
          color: colorScheme.primary,
        ),
        codeblockDecoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: colorScheme.primary,
              width: 4,
            ),
          ),
        ),
        listBullet: TextStyle(
          color: colorScheme.primary,
        ),
      ),
      onTapLink: (text, href, title) {
        if (href != null) {
          // 可以添加链接处理逻辑
        }
      },
    );
  }
}

/// 带工具栏的 Markdown 查看器
class MarkdownViewerWithToolbar extends StatelessWidget {
  final String content;
  final VoidCallback? onCopy;
  final VoidCallback? onExport;
  final VoidCallback? onRegenerate;

  const MarkdownViewerWithToolbar({
    super.key,
    required this.content,
    this.onCopy,
    this.onExport,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 工具栏
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                '生成结果',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _ToolbarButton(
                icon: Icons.copy_outlined,
                label: '复制',
                onTap: () {
                  Clipboard.setData(ClipboardData(text: content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('已复制到剪贴板'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  onCopy?.call();
                },
              ),
              const SizedBox(width: 8),
              _ToolbarButton(
                icon: Icons.download_outlined,
                label: '导出',
                onTap: onExport,
              ),
              const SizedBox(width: 8),
              _ToolbarButton(
                icon: Icons.refresh_outlined,
                label: '重新生成',
                onTap: onRegenerate,
              ),
            ],
          ),
        ),
        // Markdown 内容
        Expanded(
          child: MarkdownViewer(content: content),
        ),
      ],
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
