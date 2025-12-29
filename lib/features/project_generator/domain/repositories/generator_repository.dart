import '../../../../core/utils/result.dart';
import '../entities/project_spec.dart';
import '../entities/generated_doc.dart';

/// 文档生成仓库接口
abstract class GeneratorRepository {
  /// 生成项目文档
  Future<Result<GeneratedDocument>> generateDocument(ProjectSpec spec);
  
  /// 保存生成的文档
  Future<Result<void>> saveDocument(GeneratedDocument document);
  
  /// 获取历史文档列表
  Future<Result<List<GeneratedDocument>>> getHistory();
  
  /// 删除文档
  Future<Result<void>> deleteDocument(String id);
}
