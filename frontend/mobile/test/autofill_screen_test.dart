import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sahaayi/features/smart_autofill/presentation/autofill_screen.dart';

void main() {
  testWidgets('AutofillScreen renders accessibility status and action button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AutofillScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Smart Autofill'), findsOneWidget);
    expect(find.textContaining('സ്ക്രീൻ പരിശോധിച്ച്'), findsOneWidget);
  });
}

