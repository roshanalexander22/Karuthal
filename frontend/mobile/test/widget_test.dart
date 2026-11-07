import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sahaayi/app/app.dart';

void main() {
  testWidgets('SahaayiApp smoke test - verifies initialization', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SahaayiApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('സഹായി'), findsWidgets);
  });
}
