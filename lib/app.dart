import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/project_generator/presentation/pages/home_page.dart';
import 'features/project_generator/presentation/providers/generator_provider.dart';

class AIDocGeneratorApp extends ConsumerStatefulWidget {
  const AIDocGeneratorApp({super.key});

  @override
  ConsumerState<AIDocGeneratorApp> createState() => _AIDocGeneratorAppState();
}

class _AIDocGeneratorAppState extends ConsumerState<AIDocGeneratorApp> {
  @override
  void initState() {
    super.initState();
    // 初始化设置，加载保存的配置
    Future.microtask(() {
      ref.read(settingsProvider.notifier).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Doc Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
