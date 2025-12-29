# AI Doc Generator

AI 驱动的项目文档生成器，支持 Windows、macOS、iOS、Android。

## 快速开始

```bash
# 安装依赖
flutter pub get

# 运行应用
flutter run
```

## 配置 API Key

1. 点击右上角设置图标
2. 选择 AI 模型（OpenAI / Claude / DeepSeek）
3. 输入对应的 API Key
4. 保存

## 使用方法

1. 选择技术栈
2. 输入一句话项目描述
3. 点击"生成文档"
4. 等待 AI 生成完整的项目开发文档
5. 复制或导出 Markdown 文件

## 支持的 AI 模型

- OpenAI GPT-4
- Claude 3
- DeepSeek
- 自定义/私有部署（OpenAI 兼容接口）

## 项目结构

```
lib/
├── main.dart                 # 入口
├── app.dart                  # App 配置
├── core/                     # 核心基础设施
├── features/                 # 功能模块
├── prompts/                  # Prompt 模板
└── ai_providers/             # AI 提供商
```
