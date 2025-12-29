import 'package:flutter/material.dart';

class DescriptionInput extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback? onSubmit;

  const DescriptionInput({
    super.key,
    required this.controller,
    this.errorText,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '项目描述',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '用一句话描述你想要构建的项目',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          maxLines: 3,
          maxLength: 500,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmit?.call(),
          decoration: InputDecoration(
            hintText: '例如：一个支持多人协作的在线白板应用',
            errorText: errorText,
            counterStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }
}
