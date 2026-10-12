import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickstock/core/auth/presentation/auth_gatekeeper.dart';
import 'package:quickstock/features/customer/presentation/screens/customer_storefront_screen.dart';
import 'package:quickstock/main.dart';

void main() {
  testWidgets('QuickStockPreviewApp smoke test renders AuthGatekeeper and CustomerStorefront',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: QuickStockPreviewApp()));
    await tester.pumpAndSettle();

    expect(find.byType(QuickStockPreviewApp), findsOneWidget);
    expect(find.byType(AuthGatekeeper), findsOneWidget);
    expect(find.byType(CustomerStorefrontScreen), findsOneWidget);
  });
}
