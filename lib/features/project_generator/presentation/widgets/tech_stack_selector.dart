import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/tech_stacks.dart';
import '../../domain/entities/project_spec.dart';
import '../providers/generator_provider.dart';

/// 平台选择器
class PlatformSelector extends ConsumerWidget {
  const PlatformSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPlatforms = ref.watch(settingsProvider).selectedPlatforms;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '应用平台',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '必选，可多选',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppPlatform.values.map((platform) {
            final isSelected = selectedPlatforms.contains(platform);
            return _PlatformChip(
              platform: platform,
              isSelected: isSelected,
              onTap: () {
                ref.read(settingsProvider.notifier).togglePlatform(platform, !isSelected);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PlatformChip extends StatelessWidget {
  final AppPlatform platform;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlatformChip({
    required this.platform,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(platform.icon, size: 18),
          const SizedBox(width: 4),
          Text(platform.label),
        ],
      ),
      onSelected: (_) => onTap(),
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.primary,
    );
  }
}

/// 后台管理开关
class AdminPanelSwitch extends ConsumerWidget {
  const AdminPanelSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needsAdmin = ref.watch(settingsProvider).needsAdminPanel;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.admin_panel_settings,
            color: needsAdmin 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '需要 Web 后台管理',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '生成后台管理系统的技术方案',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: needsAdmin,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setNeedsAdminPanel(value);
            },
          ),
        ],
      ),
    );
  }
}

/// 前后端分离开关
class SeparatedSwitch extends ConsumerWidget {
  const SeparatedSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSeparated = ref.watch(settingsProvider).isSeparated;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.call_split,
            color: isSeparated 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '前后端分离',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isSeparated ? '前端独立部署，通过 API 通信' : '前后端一体化部署',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isSeparated,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setIsSeparated(value);
            },
          ),
        ],
      ),
    );
  }
}

/// 技术栈选择器
class TechStackSelector extends ConsumerWidget {
  const TechStackSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needsAdmin = ref.watch(settingsProvider).needsAdminPanel;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 前端选择
        _CategorySection(
          category: TechCategory.frontend,
          title: '前端技术栈',
          subtitle: '必选，可多选',
          required: true,
        ),
        const SizedBox(height: 24),
        
        // 后端选择
        _CategorySection(
          category: TechCategory.backend,
          title: '后端技术栈',
          subtitle: '必选，可多选',
          required: true,
        ),
        const SizedBox(height: 24),
        
        // 数据库选择
        _CategorySection(
          category: TechCategory.database,
          title: '数据库',
          subtitle: '可选，可多选',
          required: false,
        ),
        
        // 后台管理前端（仅当需要后台管理时显示）
        if (needsAdmin) ...[
          const SizedBox(height: 24),
          _CategorySection(
            category: TechCategory.adminFrontend,
            title: '后台管理前端',
            subtitle: '必选，可多选',
            required: true,
          ),
        ],
      ],
    );
  }
}

class _CategorySection extends ConsumerWidget {
  final TechCategory category;
  final String title;
  final String subtitle;
  final bool required;

  const _CategorySection({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.required,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(settingsProvider).techStackSelection;
    final selectedIds = _getSelectedIds(selection);
    final stacks = TechStacks.getByCategory(category);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(width: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: stacks.map((stack) {
            final isSelected = selectedIds.contains(stack.id);
            return _TechStackChip(
              stack: stack,
              isSelected: isSelected,
              onTap: () => _toggleSelection(ref, stack, isSelected),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Set<String> _getSelectedIds(TechStackSelection selection) {
    final list = switch (category) {
      TechCategory.frontend => selection.frontend,
      TechCategory.backend => selection.backend,
      TechCategory.database => selection.database,
      TechCategory.adminFrontend => selection.adminFrontend,
    };
    return list.map((e) => e.id).toSet();
  }
  
  void _toggleSelection(WidgetRef ref, TechStack stack, bool isSelected) {
    final notifier = ref.read(settingsProvider.notifier);
    notifier.toggleTechStack(category, stack, !isSelected);
  }
}

class _TechStackChip extends StatelessWidget {
  final TechStack stack;
  final bool isSelected;
  final VoidCallback onTap;

  const _TechStackChip({
    required this.stack,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Material(
      color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected 
                  ? colorScheme.primary 
                  : colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.check_circle,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                ),
              Icon(
                stack.icon,
                size: 18,
                color: isSelected 
                    ? colorScheme.onPrimaryContainer 
                    : colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Text(
                stack.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected 
                      ? colorScheme.onPrimaryContainer 
                      : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 已选技术栈摘要显示
class SelectedSummary extends ConsumerWidget {
  const SelectedSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final selection = settings.techStackSelection;
    
    if (settings.selectedPlatforms.isEmpty && selection.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '已选配置',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (settings.selectedPlatforms.isNotEmpty)
            _buildRow(context, '平台', settings.selectedPlatforms.map((p) => p.label).join(', ')),
          if (selection.frontend.isNotEmpty)
            _buildRow(context, '前端', selection.frontend.map((e) => e.name).join(', ')),
          if (selection.backend.isNotEmpty)
            _buildRow(context, '后端', selection.backend.map((e) => e.name).join(', ')),
          if (selection.database.isNotEmpty)
            _buildRow(context, '数据库', selection.database.map((e) => e.name).join(', ')),
          if (settings.needsAdminPanel) ...[
            _buildRow(context, '后台管理', selection.adminFrontend.isNotEmpty 
                ? selection.adminFrontend.map((e) => e.name).join(', ')
                : '未选择'),
          ],
        ],
      ),
    );
  }
  
  Widget _buildRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
