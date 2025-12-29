import 'project_spec.dart';

/// 生成的文档
class GeneratedDocument {
  final String id;
  final ProjectSpec spec;
  final String markdownContent;
  final DateTime generatedAt;
  final int? promptTokens;
  final int? completionTokens;
  
  const GeneratedDocument({
    required this.id,
    required this.spec,
    required this.markdownContent,
    required this.generatedAt,
    this.promptTokens,
    this.completionTokens,
  });
  
  /// 总 token 数
  int? get totalTokens {
    if (promptTokens == null || completionTokens == null) return null;
    return promptTokens! + completionTokens!;
  }
  
  GeneratedDocument copyWith({
    String? id,
    ProjectSpec? spec,
    String? markdownContent,
    DateTime? generatedAt,
    int? promptTokens,
    int? completionTokens,
  }) {
    return GeneratedDocument(
      id: id ?? this.id,
      spec: spec ?? this.spec,
      markdownContent: markdownContent ?? this.markdownContent,
      generatedAt: generatedAt ?? this.generatedAt,
      promptTokens: promptTokens ?? this.promptTokens,
      completionTokens: completionTokens ?? this.completionTokens,
    );
  }
}
