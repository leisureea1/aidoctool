import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_doc_generator/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AIDocGeneratorApp()),
    );
    
    // 验证应用标题存在
    expect(find.text('AI 项目文档生成器'), findsOneWidget);
  });
}
