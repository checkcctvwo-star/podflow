import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:podflow/main.dart';

void main() {
  testWidgets('App builds with MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
