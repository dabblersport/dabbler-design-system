import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dabbler_design_system/debug/theme_gallery.dart';
import 'package:dabbler_design_system/theme/dabbler_colors.dart';
import 'package:dabbler_design_system/theme/dabbler_material_scheme.dart';
import 'package:dabbler_design_system/theme/dabbler_theme_data.dart';
import 'package:dabbler_design_system/theme/dabbler_type.dart';
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

    test('text theme is attached with the Dabbler font family', () {
      final data = dabblerThemeData(DabblerTheme.main, Brightness.light);
      expect(data.textTheme.bodyLarge, isNotNull);
      expect(data.textTheme.bodyLarge!.fontSize, 17);
      expect(data.textTheme.displayLarge!.fontSize, 34);
    });
  });

  group('dabblerTextTheme (Apple HIG ramp)', () {
    test('every M3 slot is populated', () {
      final t = dabblerTextTheme();
      final slots = <TextStyle?>[
        t.displayLarge, t.displayMedium, t.displaySmall,
        t.headlineLarge, t.headlineMedium, t.headlineSmall,
        t.titleLarge, t.titleMedium, t.titleSmall,
        t.bodyLarge, t.bodyMedium, t.bodySmall,
        t.labelLarge, t.labelMedium, t.labelSmall,
      ];
      for (final s in slots) {
        expect(s, isNotNull);
        expect(s!.fontFamily, kDabblerFontFamily);
      }
    });

    test('key sizes match the Apple ramp', () {
      final t = dabblerTextTheme();
      expect(t.bodyLarge!.fontSize, 17);
      expect(t.displayLarge!.fontSize, 34);
      expect(t.titleMedium!.fontSize, 17); // Headline (17/600)
      expect(t.titleMedium!.fontWeight, FontWeight.w600);
    });

    test('Arabic variant keeps sizes but increases leading', () {
      final latin = dabblerTextTheme();
      final arabic = dabblerTextTheme(arabic: true);
      expect(arabic.bodyLarge!.fontSize, latin.bodyLarge!.fontSize);
      expect(arabic.bodyLarge!.height, greaterThan(latin.bodyLarge!.height!));
      expect(arabic.bodyLarge!.height,
          closeTo(latin.bodyLarge!.height! * kArabicLeadingScale, 0.0001));
    });

    test('dabblerTextThemeFor switches on locale', () {
      expect(dabblerTextThemeFor(const Locale('en')).bodyLarge!.height,
          dabblerTextTheme().bodyLarge!.height);
      expect(dabblerTextThemeFor(const Locale('ar')).bodyLarge!.height,
          dabblerTextTheme(arabic: true).bodyLarge!.height);
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

    test('locale drives the Arabic text theme and persists', () async {
      final c = await container();
      addTearDown(c.dispose);
      final ctrl = c.read(themeControllerProvider.notifier);

      expect(c.read(themeControllerProvider).locale, const Locale('en'));
      await ctrl.setLocale(const Locale('ar'));

      final state = c.read(themeControllerProvider);
      expect(state.locale, const Locale('ar'));
      // Arabic leading is folded into the resolved ThemeData's text theme.
      expect(
        state.lightTheme.textTheme.bodyLarge!.height,
        dabblerTextTheme(arabic: true).bodyLarge!.height,
      );

      final prefs = c.read(sharedPreferencesProvider);
      final c2 = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(c2.dispose);
      expect(c2.read(themeControllerProvider).locale, const Locale('ar'));
    });
  });

  testWidgets('Theme Gallery: All view (default) shows every section',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ThemeGalleryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Theme Gallery'), findsOneWidget);
    // Default "All" view stacks Roles + App Preview + Typography together.
    expect(find.text('primary'), findsOneWidget); // Roles swatch
    expect(find.text('Dabbler'), findsOneWidget); // App Preview app bar
    expect(find.text('Large Title · 34/41 · w400'), findsOneWidget); // Typography

    await tester.tap(find.text('Bright'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Toggle light / dark'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Theme Gallery: App Preview mockup renders in EN and AR/RTL',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ThemeGalleryScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('App Preview'));
    await tester.pumpAndSettle();
    expect(find.text('Dabbler'), findsOneWidget);
    expect(find.text('Tuesday 5-a-side'), findsOneWidget);
    expect(find.text('Join game'), findsOneWidget);

    // RTL → mockup switches to the Arabic strings.
    await tester.tap(find.byTooltip('Switch to RTL'));
    await tester.pumpAndSettle();
    expect(find.text('خماسي يوم الثلاثاء'), findsOneWidget);
    expect(find.text('انضم للعبة'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Theme Gallery: Typography view is dynamic (EN + AR)',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ThemeGalleryScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Typography'));
    await tester.pumpAndSettle();
    // Spec label is derived from the DabblerType definitions (computed, not
    // hardcoded): "<name> · <size>/<leading> · w<weight>".
    expect(find.text('Large Title · 34/41 · w400'), findsOneWidget);
    expect(find.text('Sport belongs to everyone'), findsWidgets);
    expect(find.text('الرياضة لكل من يحضر'), findsWidgets);

    await tester.tap(find.byTooltip('Switch to RTL'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
