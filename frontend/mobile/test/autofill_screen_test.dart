import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sahaayi/features/smart_autofill/presentation/autofill_screen.dart';

void main() {
  testWidgets('AutofillScreen renders accessibility status and action button', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AutofillScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Smart Autofill'), findsOneWidget);
    expect(find.text('സ്ക്രീൻ പരിശോധിച്ച് ഫോം കണ്ടെത്തുക'), findsOneWidget);
  });
}

