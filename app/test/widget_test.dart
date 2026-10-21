import 'package:bakery_pos/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final mode in AppMode.values) {
    testWidgets('BakeryPosApp renders in ${mode.name} mode', (tester) async {
      await tester.pumpWidget(ProviderScope(child: BakeryPosApp(mode: mode)));
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byKey(const Key('mode-label')), findsOneWidget);
    });
  }
}
