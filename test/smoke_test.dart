import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rutin/app.dart';

void main() {
  testWidgets('RutinApp builds a MaterialApp', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RutinApp()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
