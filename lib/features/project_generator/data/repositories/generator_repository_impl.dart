import 'package:uuid/uuid.dart';
import '../../../../ai_providers/ai_provider.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../../../prompts/prompt_manager.dart';
import '../../domain/entities/project_spec.dart';
import '../../domain/entities/generated_doc.dart';
import '../../domain/repositories/generator_repository.dart';

/// 文档生成仓库实现
class GeneratorRepositoryImpl implements GeneratorRepository {
  final AIProvider _aiProvider;
  final Uuid _uuid = const Uuid();
  
  // 内存缓存（MVP 阶段）
  final List<GeneratedDocument> _history = [];
  
  GeneratorRepositoryImpl({
    required AIProvider aiProvider,
  }) : _aiProvider = aiProvider;
  
  @override
  Future<Result<GeneratedDocument>> generateDocument(ProjectSpec spec) async {
    try {
      // 构建 Prompt
      final messages = PromptManager.buildMessages(spec: spec);
      
      // 调用 AI
      final request = AIGenerateRequest(messages: messages);
      final result = await _aiProvider.generate(request);
      
      return result.when(
        success: (response) {
          final document = GeneratedDocument(
            id: _uuid.v4(),
            spec: spec,
            markdownContent: response.content,
            generatedAt: DateTime.now(),
            promptTokens: response.promptTokens,
            completionTokens: response.completionTokens,
          );
          
          // 自动保存到历史
          _history.insert(0, document);
          
          return Success(document);
        },
        failure: (failure) => Error(failure),
      );
    } catch (e) {
      return Error(UnknownFailure(e.toString()));
    }
  }
  
  @override
  Future<Result<void>> saveDocument(GeneratedDocument document) async {
    try {
      final index = _history.indexWhere((d) => d.id == document.id);
      if (index >= 0) {
        _history[index] = document;
      } else {
        _history.insert(0, document);
      }
      return const Success(null);
    } catch (e) {
      return Error(StorageFailure(e.toString()));
    }
  }
  
  @override
  Future<Result<List<GeneratedDocument>>> getHistory() async {
    return Success(List.unmodifiable(_history));
  }
  
  @override
  Future<Result<void>> deleteDocument(String id) async {
    try {
      _history.removeWhere((d) => d.id == id);
      return const Success(null);
    } catch (e) {
      return Error(StorageFailure(e.toString()));
    }
  }
}
