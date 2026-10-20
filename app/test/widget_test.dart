import 'package:bakery_pos/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final mode in AppMode.values) {
    testWidgets('BakeryPosApp renders in ${mode.name} mode', (tester) async {
      await tester.pumpWidget(BakeryPosApp(mode: mode));

      expect(find.byType(MaterialApp), findsOneWidget);
      final label = tester.widget<Text>(find.byKey(const Key('mode-label')));
      expect(label.data, mode.name);
    });
  }
}
