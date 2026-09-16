import 'package:dabbler_design_system/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('gallery app boots and shows its title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GalleryApp());

    expect(find.byType(GalleryHomeScreen), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Dabbler Design System'), findsOneWidget);
  });

  testWidgets('empty gallery index shows the placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GalleryApp());

    expect(find.textContaining('No components yet.'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
  });
}
