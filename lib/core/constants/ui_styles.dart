import 'package:flutter/material.dart';

/// UI 风格定义
enum UIStyle {
  clean('规范清爽', Icons.center_focus_strong, '简洁明了的界面设计，注重信息层次和可读性，使用清晰的视觉分隔'),
  business('高级商务', Icons.business_center, '专业稳重的商务风格，深色主题可选，强调数据可视化和专业感'),
  minimal('极简克制', Icons.crop_square, '极简主义设计，大量留白，去除冗余装饰，专注核心功能'),
  modern('现代活力', Icons.rocket_launch, '现代化设计语言，渐变色彩，圆角卡片，微动效交互'),
  material('Material Design', Icons.android, '遵循 Google Material Design 规范，标准化组件和交互'),
  antDesign('Ant Design', Icons.design_services, '遵循 Ant Design 设计规范，企业级产品设计体系'),
  glassmorphism('毛玻璃风格', Icons.blur_on, '半透明毛玻璃效果，模糊背景，现代感强'),
  darkMode('深色模式', Icons.dark_mode, '深色背景主题，护眼设计，适合长时间使用'),
  colorful('多彩活泼', Icons.palette, '丰富的色彩搭配，适合面向年轻用户的产品');

  final String label;
  final IconData icon;
  final String description;
  
  const UIStyle(this.label, this.icon, this.description);
}
