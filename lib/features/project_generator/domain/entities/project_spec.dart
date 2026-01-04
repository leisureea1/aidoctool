import '../../../../core/constants/tech_stacks.dart';
import '../../../../core/constants/ui_styles.dart';

/// 技术栈选择
class TechStackSelection {
  final List<TechStack> frontend;
  final List<TechStack> backend;
  final List<TechStack> database;
  final List<TechStack> adminFrontend;
  
  const TechStackSelection({
    this.frontend = const [],
    this.backend = const [],
    this.database = const [],
    this.adminFrontend = const [],
  });
  
  bool get isValid => frontend.isNotEmpty || backend.isNotEmpty;
  bool get isEmpty => frontend.isEmpty && backend.isEmpty && database.isEmpty && adminFrontend.isEmpty;
  List<TechStack> get all => [...frontend, ...backend, ...database, ...adminFrontend];
  
  String get displayText {
    final parts = <String>[];
    if (frontend.isNotEmpty) parts.add('前端: ${frontend.map((e) => e.name).join(', ')}');
    if (backend.isNotEmpty) parts.add('后端: ${backend.map((e) => e.name).join(', ')}');
    if (database.isNotEmpty) parts.add('数据库: ${database.map((e) => e.name).join(', ')}');
    if (adminFrontend.isNotEmpty) parts.add('后台管理: ${adminFrontend.map((e) => e.name).join(', ')}');
    return parts.join(' | ');
  }
  
  TechStackSelection copyWith({
    List<TechStack>? frontend,
    List<TechStack>? backend,
    List<TechStack>? database,
    List<TechStack>? adminFrontend,
  }) {
    return TechStackSelection(
      frontend: frontend ?? this.frontend,
      backend: backend ?? this.backend,
      database: database ?? this.database,
      adminFrontend: adminFrontend ?? this.adminFrontend,
    );
  }
}

/// 项目规格定义
class ProjectSpec {
  final String id;
  final String projectName;
  final List<AppPlatform> platforms;
  final bool needsAdminPanel;
  final bool isSeparated;
  final TechStackSelection techStacks;
  final UIStyle? uiStyle;
  final String description;
  final DateTime createdAt;
  
  const ProjectSpec({
    required this.id,
    required this.projectName,
    required this.platforms,
    required this.needsAdminPanel,
    required this.isSeparated,
    required this.techStacks,
    this.uiStyle,
    required this.description,
    required this.createdAt,
  });
  
  String get platformsText => platforms.map((p) => p.label).join(', ');
  
  ProjectSpec copyWith({
    String? id,
    String? projectName,
    List<AppPlatform>? platforms,
    bool? needsAdminPanel,
    bool? isSeparated,
    TechStackSelection? techStacks,
    UIStyle? uiStyle,
    String? description,
    DateTime? createdAt,
  }) {
    return ProjectSpec(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      platforms: platforms ?? this.platforms,
      needsAdminPanel: needsAdminPanel ?? this.needsAdminPanel,
      isSeparated: isSeparated ?? this.isSeparated,
      techStacks: techStacks ?? this.techStacks,
      uiStyle: uiStyle ?? this.uiStyle,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
