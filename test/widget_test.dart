import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickstock/main.dart';

void main() {
  testWidgets('QuickStockPreviewApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: QuickStockPreviewApp()));
    await tester.pumpAndSettle();

    // Verify DevRoleShell renders
    expect(find.byType(QuickStockPreviewApp), findsOneWidget);
  });
}
