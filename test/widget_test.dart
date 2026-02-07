// Basic widget test for Shishu Suraksha AI app

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shishu_suraksha/main.dart';

void main() {
  testWidgets('App launches with opening animation', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that the app launches
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
