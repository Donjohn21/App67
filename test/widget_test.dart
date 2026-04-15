import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app67/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App67App());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
