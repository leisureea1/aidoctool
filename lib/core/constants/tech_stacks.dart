import 'package:flutter/material.dart';

/// 应用平台
enum AppPlatform {
  web('Web 应用', Icons.language),
  mobileApp('移动 App', Icons.phone_android),
  desktopApp('桌面应用', Icons.desktop_windows),
  miniProgram('小程序', Icons.widgets),
  crossPlatform('跨平台应用', Icons.devices);

  final String label;
  final IconData icon;
  
  const AppPlatform(this.label, this.icon);
}

/// 技术栈分类
enum TechCategory {
  frontend('前端技术栈', true),
  backend('后端技术栈', true),
  database('数据库', false),
  adminFrontend('后台管理前端', false);

  final String label;
  final bool required;
  
  const TechCategory(this.label, this.required);
}

/// 技术栈定义
class TechStack {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final TechCategory category;
  final List<String> tags;
  
  const TechStack({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.category,
    this.tags = const [],
  });
}

/// 预定义技术栈列表
class TechStacks {
  // ==================== 前端技术栈 ====================
  static const List<TechStack> frontend = [
    // Web 基础
    TechStack(
      id: 'html_css_js',
      name: 'HTML+CSS+JS',
      icon: Icons.language,
      description: '原生 Web 开发',
      category: TechCategory.frontend,
      tags: ['HTML5', 'CSS3', 'JavaScript', 'Web'],
    ),
    TechStack(
      id: 'jquery',
      name: 'jQuery',
      icon: Icons.code,
      description: 'JavaScript 库',
      category: TechCategory.frontend,
      tags: ['JavaScript', 'DOM', 'Ajax'],
    ),
    TechStack(
      id: 'bootstrap',
      name: 'Bootstrap',
      icon: Icons.grid_view,
      description: 'CSS 框架',
      category: TechCategory.frontend,
      tags: ['CSS', 'Responsive', 'UI'],
    ),
    TechStack(
      id: 'tailwindcss',
      name: 'Tailwind CSS',
      icon: Icons.style,
      description: '原子化 CSS 框架',
      category: TechCategory.frontend,
      tags: ['CSS', 'Utility-first', 'UI'],
    ),
    // 现代框架
    TechStack(
      id: 'vue2',
      name: 'Vue 2',
      icon: Icons.change_history,
      description: 'Vue.js 2.x',
      category: TechCategory.frontend,
      tags: ['JavaScript', 'MVVM', 'SPA'],
    ),
    TechStack(
      id: 'vue3',
      name: 'Vue 3',
      icon: Icons.change_history,
      description: 'Vue.js 3.x + Composition API',
      category: TechCategory.frontend,
      tags: ['TypeScript', 'Composition API', 'SPA'],
    ),
    TechStack(
      id: 'react',
      name: 'React',
      icon: Icons.all_inclusive,
      description: 'React 18+',
      category: TechCategory.frontend,
      tags: ['JavaScript', 'TypeScript', 'Hooks', 'SPA'],
    ),
    TechStack(
      id: 'angular',
      name: 'Angular',
      icon: Icons.architecture,
      description: 'Angular 15+',
      category: TechCategory.frontend,
      tags: ['TypeScript', 'RxJS', 'Enterprise'],
    ),
    TechStack(
      id: 'nextjs',
      name: 'Next.js',
      icon: Icons.arrow_forward,
      description: 'React 全栈框架',
      category: TechCategory.frontend,
      tags: ['React', 'SSR', 'Full-stack'],
    ),
    TechStack(
      id: 'nuxtjs',
      name: 'Nuxt.js',
      icon: Icons.change_history,
      description: 'Vue 全栈框架',
      category: TechCategory.frontend,
      tags: ['Vue', 'SSR', 'Full-stack'],
    ),
    // 移动端
    TechStack(
      id: 'flutter',
      name: 'Flutter',
      icon: Icons.flutter_dash,
      description: '跨平台 UI 框架',
      category: TechCategory.frontend,
      tags: ['Dart', 'Mobile', 'Desktop', 'Web'],
    ),
    TechStack(
      id: 'react_native',
      name: 'React Native',
      icon: Icons.phone_iphone,
      description: '跨平台移动开发',
      category: TechCategory.frontend,
      tags: ['JavaScript', 'Mobile', 'iOS', 'Android'],
    ),
    TechStack(
      id: 'uniapp',
      name: 'uni-app',
      icon: Icons.devices,
      description: '跨平台开发框架',
      category: TechCategory.frontend,
      tags: ['Vue', 'Mobile', '小程序', 'H5'],
    ),
    TechStack(
      id: 'taro',
      name: 'Taro',
      icon: Icons.devices_other,
      description: '多端统一开发框架',
      category: TechCategory.frontend,
      tags: ['React', 'Vue', '小程序', 'H5'],
    ),
    // 原生
    TechStack(
      id: 'swift_ui',
      name: 'SwiftUI',
      icon: Icons.apple,
      description: 'iOS/macOS 原生',
      category: TechCategory.frontend,
      tags: ['Swift', 'iOS', 'macOS'],
    ),
    TechStack(
      id: 'android_compose',
      name: 'Jetpack Compose',
      icon: Icons.android,
      description: 'Android 原生',
      category: TechCategory.frontend,
      tags: ['Kotlin', 'Android'],
    ),
    TechStack(
      id: 'electron',
      name: 'Electron',
      icon: Icons.desktop_mac,
      description: '桌面应用框架',
      category: TechCategory.frontend,
      tags: ['JavaScript', 'Desktop', 'Node.js'],
    ),
    TechStack(
      id: 'tauri',
      name: 'Tauri',
      icon: Icons.memory,
      description: '轻量桌面应用框架',
      category: TechCategory.frontend,
      tags: ['Rust', 'Desktop', 'Web'],
    ),
  ];

  // ==================== 后端技术栈 ====================
  static const List<TechStack> backend = [
    // Java
    TechStack(
      id: 'java_springboot',
      name: 'Java Spring Boot',
      icon: Icons.coffee,
      description: 'Spring Boot 3.x',
      category: TechCategory.backend,
      tags: ['Java', 'Spring', 'MyBatis', 'JPA'],
    ),
    TechStack(
      id: 'java_springmvc',
      name: 'Java Spring MVC',
      icon: Icons.coffee,
      description: 'Spring MVC + SSM',
      category: TechCategory.backend,
      tags: ['Java', 'Spring', 'MyBatis', 'JSP'],
    ),
    TechStack(
      id: 'java_springcloud',
      name: 'Java Spring Cloud',
      icon: Icons.cloud,
      description: '微服务架构',
      category: TechCategory.backend,
      tags: ['Java', 'Microservices', 'Nacos', 'Gateway'],
    ),
    // Python
    TechStack(
      id: 'python_django',
      name: 'Python Django',
      icon: Icons.data_object,
      description: 'Django 全栈框架',
      category: TechCategory.backend,
      tags: ['Python', 'ORM', 'Admin', 'MTV'],
    ),
    TechStack(
      id: 'python_flask',
      name: 'Python Flask',
      icon: Icons.science,
      description: 'Flask 轻量框架',
      category: TechCategory.backend,
      tags: ['Python', 'Lightweight', 'RESTful'],
    ),
    TechStack(
      id: 'python_fastapi',
      name: 'Python FastAPI',
      icon: Icons.bolt,
      description: '高性能异步框架',
      category: TechCategory.backend,
      tags: ['Python', 'Async', 'OpenAPI', 'Pydantic'],
    ),
    // Node.js
    TechStack(
      id: 'nodejs_express',
      name: 'Node.js Express',
      icon: Icons.javascript,
      description: 'Express.js 框架',
      category: TechCategory.backend,
      tags: ['JavaScript', 'Node.js', 'Middleware'],
    ),
    TechStack(
      id: 'nodejs_nestjs',
      name: 'Node.js NestJS',
      icon: Icons.pets,
      description: 'NestJS 企业级框架',
      category: TechCategory.backend,
      tags: ['TypeScript', 'Node.js', 'DI', 'Enterprise'],
    ),
    TechStack(
      id: 'nodejs_koa',
      name: 'Node.js Koa',
      icon: Icons.javascript,
      description: 'Koa.js 框架',
      category: TechCategory.backend,
      tags: ['JavaScript', 'Node.js', 'Async'],
    ),
    // Go
    TechStack(
      id: 'go_gin',
      name: 'Go Gin',
      icon: Icons.speed,
      description: 'Gin Web 框架',
      category: TechCategory.backend,
      tags: ['Go', 'High-performance', 'RESTful'],
    ),
    TechStack(
      id: 'go_echo',
      name: 'Go Echo',
      icon: Icons.speed,
      description: 'Echo Web 框架',
      category: TechCategory.backend,
      tags: ['Go', 'High-performance', 'Middleware'],
    ),
    TechStack(
      id: 'go_fiber',
      name: 'Go Fiber',
      icon: Icons.flash_on,
      description: 'Fiber 高性能框架',
      category: TechCategory.backend,
      tags: ['Go', 'Express-style', 'Fast'],
    ),
    // PHP
    TechStack(
      id: 'php_laravel',
      name: 'PHP Laravel',
      icon: Icons.php,
      description: 'Laravel 框架',
      category: TechCategory.backend,
      tags: ['PHP', 'Eloquent', 'Blade', 'Artisan'],
    ),
    TechStack(
      id: 'php_thinkphp',
      name: 'PHP ThinkPHP',
      icon: Icons.php,
      description: 'ThinkPHP 框架',
      category: TechCategory.backend,
      tags: ['PHP', '国产', 'MVC'],
    ),
    TechStack(
      id: 'php_symfony',
      name: 'PHP Symfony',
      icon: Icons.php,
      description: 'Symfony 框架',
      category: TechCategory.backend,
      tags: ['PHP', 'Enterprise', 'Components'],
    ),
    // .NET
    TechStack(
      id: 'dotnet_aspnet',
      name: 'ASP.NET Core',
      icon: Icons.window,
      description: '.NET 6/7/8',
      category: TechCategory.backend,
      tags: ['C#', '.NET', 'Entity Framework'],
    ),
    // Rust
    TechStack(
      id: 'rust_actix',
      name: 'Rust Actix',
      icon: Icons.memory,
      description: 'Actix Web 框架',
      category: TechCategory.backend,
      tags: ['Rust', 'High-performance', 'Actor'],
    ),
    TechStack(
      id: 'rust_axum',
      name: 'Rust Axum',
      icon: Icons.memory,
      description: 'Axum Web 框架',
      category: TechCategory.backend,
      tags: ['Rust', 'Tokio', 'Tower'],
    ),
    // Kotlin
    TechStack(
      id: 'kotlin_ktor',
      name: 'Kotlin Ktor',
      icon: Icons.hexagon,
      description: 'Ktor 框架',
      category: TechCategory.backend,
      tags: ['Kotlin', 'Coroutines', 'Async'],
    ),
  ];

  // ==================== 数据库 ====================
  static const List<TechStack> database = [
    // 关系型
    TechStack(
      id: 'mysql',
      name: 'MySQL',
      icon: Icons.storage,
      description: '关系型数据库',
      category: TechCategory.database,
      tags: ['SQL', 'ACID', 'InnoDB'],
    ),
    TechStack(
      id: 'postgresql',
      name: 'PostgreSQL',
      icon: Icons.storage,
      description: '高级关系型数据库',
      category: TechCategory.database,
      tags: ['SQL', 'ACID', 'JSON', 'Extension'],
    ),
    TechStack(
      id: 'mariadb',
      name: 'MariaDB',
      icon: Icons.storage,
      description: 'MySQL 分支',
      category: TechCategory.database,
      tags: ['SQL', 'ACID', 'MySQL兼容'],
    ),
    TechStack(
      id: 'sqlserver',
      name: 'SQL Server',
      icon: Icons.dns,
      description: '微软数据库',
      category: TechCategory.database,
      tags: ['SQL', 'Enterprise', 'Windows'],
    ),
    TechStack(
      id: 'oracle',
      name: 'Oracle',
      icon: Icons.circle,
      description: '企业级数据库',
      category: TechCategory.database,
      tags: ['SQL', 'Enterprise', 'PL/SQL'],
    ),
    TechStack(
      id: 'sqlite',
      name: 'SQLite',
      icon: Icons.inventory_2,
      description: '嵌入式数据库',
      category: TechCategory.database,
      tags: ['SQL', 'Embedded', 'Local'],
    ),
    // NoSQL
    TechStack(
      id: 'mongodb',
      name: 'MongoDB',
      icon: Icons.eco,
      description: '文档数据库',
      category: TechCategory.database,
      tags: ['NoSQL', 'Document', 'JSON'],
    ),
    TechStack(
      id: 'redis',
      name: 'Redis',
      icon: Icons.cached,
      description: '缓存/键值存储',
      category: TechCategory.database,
      tags: ['Cache', 'Key-Value', 'In-Memory'],
    ),
    TechStack(
      id: 'elasticsearch',
      name: 'Elasticsearch',
      icon: Icons.search,
      description: '搜索引擎',
      category: TechCategory.database,
      tags: ['Search', 'Analytics', 'NoSQL'],
    ),
    // 云数据库
    TechStack(
      id: 'firebase',
      name: 'Firebase',
      icon: Icons.local_fire_department,
      description: 'Google BaaS',
      category: TechCategory.database,
      tags: ['NoSQL', 'Realtime', 'Cloud'],
    ),
    TechStack(
      id: 'supabase',
      name: 'Supabase',
      icon: Icons.flash_on,
      description: 'PostgreSQL 云服务',
      category: TechCategory.database,
      tags: ['PostgreSQL', 'BaaS', 'Realtime'],
    ),
  ];

  // ==================== 后台管理前端 ====================
  static const List<TechStack> adminFrontend = [
    TechStack(
      id: 'vue_element',
      name: 'Vue + Element UI',
      icon: Icons.dashboard,
      description: 'Element UI/Plus',
      category: TechCategory.adminFrontend,
      tags: ['Vue', 'Element', 'Admin'],
    ),
    TechStack(
      id: 'vue_antd',
      name: 'Vue + Ant Design',
      icon: Icons.dashboard_customize,
      description: 'Ant Design Vue',
      category: TechCategory.adminFrontend,
      tags: ['Vue', 'Ant Design', 'Admin'],
    ),
    TechStack(
      id: 'vue_vben',
      name: 'Vben Admin',
      icon: Icons.view_quilt,
      description: 'Vue3 后台模板',
      category: TechCategory.adminFrontend,
      tags: ['Vue3', 'TypeScript', 'Vite'],
    ),
    TechStack(
      id: 'react_antd',
      name: 'React + Ant Design',
      icon: Icons.all_inclusive,
      description: 'Ant Design Pro',
      category: TechCategory.adminFrontend,
      tags: ['React', 'Ant Design', 'Admin'],
    ),
    TechStack(
      id: 'react_arco',
      name: 'React + Arco Design',
      icon: Icons.all_inclusive,
      description: '字节跳动 Arco',
      category: TechCategory.adminFrontend,
      tags: ['React', 'Arco', 'Admin'],
    ),
    TechStack(
      id: 'layui',
      name: 'Layui',
      icon: Icons.layers,
      description: '经典后台 UI',
      category: TechCategory.adminFrontend,
      tags: ['jQuery', 'Layui', 'Admin'],
    ),
    TechStack(
      id: 'bootstrap_admin',
      name: 'Bootstrap Admin',
      icon: Icons.grid_view,
      description: 'Bootstrap 后台',
      category: TechCategory.adminFrontend,
      tags: ['Bootstrap', 'jQuery', 'Admin'],
    ),
    TechStack(
      id: 'django_admin',
      name: 'Django Admin',
      icon: Icons.admin_panel_settings,
      description: 'Django 自带后台',
      category: TechCategory.adminFrontend,
      tags: ['Django', 'Python', 'Built-in'],
    ),
  ];

  static List<TechStack> getByCategory(TechCategory category) {
    return switch (category) {
      TechCategory.frontend => frontend,
      TechCategory.backend => backend,
      TechCategory.database => database,
      TechCategory.adminFrontend => adminFrontend,
    };
  }

  static TechStack? getById(String id) {
    final all = [...frontend, ...backend, ...database, ...adminFrontend];
    try {
      return all.firstWhere((stack) => stack.id == id);
    } catch (_) {
      return null;
    }
  }
}
