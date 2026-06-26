import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dabbler_design_system/debug/theme_gallery.dart';
import 'package:dabbler_design_system/theme/dabbler_colors.dart';
import 'package:dabbler_design_system/theme/dabbler_material_scheme.dart';
import 'package:dabbler_design_system/theme/dabbler_theme_data.dart';
import 'package:dabbler_design_system/theme/theme_controller.dart';

const _white = Color(0xFFFFFFFF);
const _black = Color(0xFF000000);

void main() {
  group('resolveTheme', () {
    test('section defaults', () {
      expect(resolveTheme(DabblerSection.home), DabblerTheme.main);
      expect(resolveTheme(DabblerSection.sport), DabblerTheme.sport);
      expect(resolveTheme(DabblerSection.social), DabblerTheme.social);
      expect(resolveTheme(DabblerSection.active), DabblerTheme.active);
    });

    test('user override always wins', () {
      expect(
        resolveTheme(DabblerSection.home, userOverride: DabblerTheme.bright),
        DabblerTheme.bright,
      );
    });
  });

  group('dabblerThemeData', () {
    test('every theme × brightness keeps neutrals tinted (never pure b/w)', () {
      for (final theme in DabblerTheme.values) {
        for (final b in Brightness.values) {
          final data = dabblerThemeData(theme, b);
          final tokens = data.extension<DabblerColors>();
          expect(tokens, isNotNull, reason: '$theme/$b missing DabblerColors');

          for (final c in <Color>[
            data.scaffoldBackgroundColor,
            data.colorScheme.surface,
            data.colorScheme.onSurface,
            tokens!.bgPrimary,
            tokens.surfaceCard,
            tokens.textPrimary,
          ]) {
            expect(c, isNot(_white), reason: '$theme/$b has a pure-white neutral');
            expect(c, isNot(_black), reason: '$theme/$b has a pure-black neutral');
          }
          expect(data.useMaterial3, isTrue);
        }
      }
    });

    test('color themes seed primary from the photo palette', () {
      expect(
        dabblerColorScheme(DabblerTheme.main, Brightness.light).primary,
        const Color(0xFF7328CE),
      );
    });
  });

  group('ThemeController', () {
    Future<ProviderContainer> container() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      return ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
    }

    test('section drives the resolved theme', () async {
      final c = await container();
      addTearDown(c.dispose);
      final ctrl = c.read(themeControllerProvider.notifier);

      ctrl.setSection(DabblerSection.sport);
      expect(c.read(themeControllerProvider).resolvedTheme, DabblerTheme.sport);
    });

    test('override wins and persists', () async {
      final c = await container();
      addTearDown(c.dispose);
      final ctrl = c.read(themeControllerProvider.notifier);

      ctrl.setSection(DabblerSection.sport);
      await ctrl.setUserOverride(DabblerTheme.bright);
      expect(c.read(themeControllerProvider).resolvedTheme, DabblerTheme.bright);

      // A fresh controller built from the same prefs restores the override.
      final prefs = c.read(sharedPreferencesProvider);
      final c2 = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(c2.dispose);
      expect(c2.read(themeControllerProvider).userOverride, DabblerTheme.bright);
    });

    test('mode toggles and persists', () async {
      final c = await container();
      addTearDown(c.dispose);
      final ctrl = c.read(themeControllerProvider.notifier);
      await ctrl.setThemeMode(ThemeMode.dark);
      expect(c.read(themeControllerProvider).themeMode, ThemeMode.dark);
    });
  });

  testWidgets('Theme Gallery renders and switches theme/brightness',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ThemeGalleryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Theme Gallery'), findsOneWidget);
    expect(find.text('Primary CTA'), findsOneWidget);

    // Switch to the Bright theme (dark on-brand text path).
    await tester.tap(find.text('Bright'));
    await tester.pumpAndSettle();
    expect(find.text('Bright theme'), findsOneWidget);

    // Toggle to dark.
    await tester.tap(find.byTooltip('Toggle light / dark'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
