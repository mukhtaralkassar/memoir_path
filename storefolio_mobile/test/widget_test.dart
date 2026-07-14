import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:storefolio/app.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const StorefolioApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
