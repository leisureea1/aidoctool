import '../ai_providers/ai_provider.dart';
import '../features/project_generator/domain/entities/project_spec.dart';

/// Prompt 管理器
/// 采用分段式多 System Message 结构，确保输出工程化、可落地
class PromptManager {
  /// 生成 AI 润色功能描述的 Prompt
  static List<AIMessage> buildPolishMessages(String projectName) {
    return [
      const AIMessage(
        role: MessageRole.system,
        content: '''你是一个项目需求分析专家。用户会给你一个项目名称，你需要根据项目名称推测并生成该项目可能需要的详细功能列表。

要求：
1. 只输出功能列表，不要输出任何其他内容（如问候语、解释、总结等）
2. 使用简洁的列表形式，每行一个功能点
3. 功能点要具体、可实现，避免抽象描述
4. 按模块分组，每个模块 3-5 个功能点
5. 总共输出 15-25 个功能点
6. 使用中文输出

输出格式示例：
【用户模块】
- 用户注册（手机号/邮箱）
- 用户登录（密码/验证码）
- 个人信息管理
- 密码修改与找回

【商品模块】
- 商品列表展示
- 商品详情查看
- 商品搜索与筛选''',
      ),
      AIMessage(
        role: MessageRole.user,
        content: projectName,
      ),
    ];
  }

  /// 生成完整的 Prompt 消息列表
  static List<AIMessage> buildMessages({
    required ProjectSpec spec,
  }) {
    return [
      // 1. 核心角色定义（不可变）
      const AIMessage(
        role: MessageRole.system,
        content: _coreRolePrompt,
      ),
      // 2. 输出规则约束
      const AIMessage(
        role: MessageRole.system,
        content: _outputRulesPrompt,
      ),
      // 3. 技术栈注入
      AIMessage(
        role: MessageRole.system,
        content: _buildTechStackPrompt(spec),
      ),
      // 4. 输出结构定义
      AIMessage(
        role: MessageRole.system,
        content: _buildOutputStructurePrompt(spec),
      ),
      // 5. 各章节详细要求
      const AIMessage(
        role: MessageRole.system,
        content: _chapterRequirementsPrompt,
      ),
      // 6. 用户输入
      AIMessage(
        role: MessageRole.user,
        content: spec.description,
      ),
    ];
  }

  /// 核心角色定义（不可变）
  static const String _coreRolePrompt = '''
你是一名资深软件架构师和技术负责人，拥有 10 年以上跨语言、跨平台项目设计经验。

你的任务不是写示例代码，而是将「模糊的项目想法」转化为【结构清晰、工程可落地、可直接指导开发的项目开发文档】。

你的输出将直接用于：
- 项目立项
- 团队分工
- 实际编码
- 技术评审''';

  /// 输出规则约束
  static const String _outputRulesPrompt = '''
请严格遵守以下规则：

1. 输出内容必须工程化，避免空话、营销语、泛泛而谈
2. 所有设计必须符合所选技术栈的真实开发习惯和最佳实践
3. 不要解释你为什么这样设计
4. 不要输出任何与开发无关的内容
5. 不要使用抽象词汇（如"高效""智能""优化"），必须具体
6. 目录结构必须完整到文件级别，不得只给一层
7. API 设计必须包含完整的请求/响应示例
8. 所有输出使用 Markdown 格式''';

  /// 构建技术栈 Prompt
  static String _buildTechStackPrompt(ProjectSpec spec) {
    final techStacks = spec.techStacks;
    final platforms = spec.platforms.map((p) => p.label).join('、');
    final frontends = techStacks.frontend.map((e) => e.name).join('、');
    final backends = techStacks.backend.map((e) => e.name).join('、');
    final databases = techStacks.database.isNotEmpty 
        ? techStacks.database.map((e) => e.name).join('、')
        : '根据项目需求自动推荐';
    
    final buffer = StringBuffer();
    buffer.writeln('项目名称：${spec.projectName}');
    buffer.writeln('');
    buffer.writeln('项目技术要求如下：');
    buffer.writeln('');
    buffer.writeln('- 目标平台：$platforms');
    buffer.writeln('- 前端技术栈：$frontends');
    buffer.writeln('- 后端技术栈：$backends');
    buffer.writeln('- 数据库：$databases');
    buffer.writeln('- 是否前后端分离：${spec.isSeparated ? "是" : "否"}');
    
    if (spec.needsAdminPanel && techStacks.adminFrontend.isNotEmpty) {
      final adminFrontends = techStacks.adminFrontend.map((e) => e.name).join('、');
      buffer.writeln('- 后台管理系统：需要');
      buffer.writeln('- 后台管理前端：$adminFrontends');
    }
    
    // UI 风格
    if (spec.uiStyle != null) {
      buffer.writeln('');
      buffer.writeln('UI 设计风格要求：');
      buffer.writeln('- 风格：${spec.uiStyle!.label}');
      buffer.writeln('- 说明：${spec.uiStyle!.description}');
      buffer.writeln('- 请在技术架构设计和前端目录结构中体现该风格的设计规范');
    }
    
    return buffer.toString();
  }

  /// 构建输出结构 Prompt
  static String _buildOutputStructurePrompt(ProjectSpec spec) {
    final buffer = StringBuffer();
    buffer.writeln('你必须严格按照以下结构输出完整文档，不得遗漏任何章节，章节标题必须完全一致：');
    buffer.writeln('');
    buffer.writeln('# 1. 项目概述');
    buffer.writeln('# 2. 核心功能需求分析');
    buffer.writeln('# 3. 技术架构设计');
    buffer.writeln('# 4. 项目目录结构设计');
    buffer.writeln('# 5. 核心模块设计说明');
    buffer.writeln('# 6. API 接口设计');
    buffer.writeln('# 7. 数据结构与模型设计');
    buffer.writeln('# 8. 开发流程与任务分解');
    buffer.writeln('# 9. 风险点与注意事项');
    
    if (spec.needsAdminPanel) {
      buffer.writeln('# 10. 后台管理系统设计');
    }
    
    return buffer.toString();
  }

  /// 各章节详细要求
  static const String _chapterRequirementsPrompt = '''
各章节详细要求（硬规范）：

## 1️⃣ 项目概述
- 用 3～5 句话说明项目目标
- 明确项目解决什么问题
- 说明适用场景和目标用户

## 2️⃣ 核心功能需求分析
- 使用列表形式，按模块分组
- 每一条功能必须是可实现的具体功能点
- 禁止使用抽象词（如"高效""智能""优化"）
- 标注功能优先级（P0/P1/P2）

## 3️⃣ 技术架构设计
- 使用 ASCII 图描述整体架构
- 明确各层职责（展示层/业务层/数据层）
- 说明核心技术选型理由
- 描述数据流向

## 4️⃣ 项目目录结构设计（必须完整）
- 前端项目完整目录结构（到文件级别）
- 后端项目完整目录结构（到文件级别）
- 必须符合所选技术栈的主流工程规范
- 每个目录/文件添加注释说明用途

示例格式：
```
src/
├── controller/          # 控制器层
│   ├── UserController.java
│   └── OrderController.java
├── service/             # 业务逻辑层
│   ├── UserService.java
│   └── impl/
│       └── UserServiceImpl.java
├── repository/          # 数据访问层
├── entity/              # 实体类
├── dto/                 # 数据传输对象
├── config/              # 配置类
└── utils/               # 工具类
```

## 5️⃣ 核心模块设计说明
- 至少列出 5 个核心模块
- 每个模块必须说明：
  - 模块职责（一句话）
  - 核心类/组件列表
  - 对外暴露的接口
  - 依赖的其他模块

## 6️⃣ API 接口设计
- 至少给出 8 个核心接口
- 每个接口必须包含：
  - 接口路径（RESTful 风格）
  - 请求方式（GET/POST/PUT/DELETE）
  - 请求参数（Query/Body/Path）
  - 请求示例（JSON）
  - 响应结构（JSON，包含成功和失败）
  - 权限要求

示例格式：
```
### POST /api/v1/users/login
**描述**：用户登录
**请求参数**：
| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| username | string | 是 | 用户名 |
| password | string | 是 | 密码 |

**请求示例**：
{
  "username": "admin",
  "password": "123456"
}

**响应示例**：
{
  "code": 200,
  "message": "success",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "userId": 1,
    "username": "admin"
  }
}
```

## 7️⃣ 数据结构与模型设计
- 列出所有核心实体
- 每个实体包含：
  - 字段名、类型、约束、说明
  - 与其他实体的关系（1:1, 1:N, N:N）
- 给出建表 SQL（如适用）

## 8️⃣ 开发流程与任务分解
- 推荐开发顺序（阶段划分）
- 每个阶段的具体任务清单
- 任务预估工时
- 可并行开发的模块标注
- 里程碑节点

## 9️⃣ 风险点与注意事项
- 性能风险及应对方案
- 安全风险及防护措施
- 技术选型风险
- 新手容易踩坑的地方（至少 5 条）
- 需要特别注意的边界情况''';
}
