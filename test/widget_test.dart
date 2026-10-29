import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:d_ai/app.dart';

void main() {
  testWidgets('DApp smoke test renders navigation shell', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: DApp(),
      ),
    );

    // Initial frame
    await tester.pumpAndSettle();

    // Verify navigation bar destinations exist
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
