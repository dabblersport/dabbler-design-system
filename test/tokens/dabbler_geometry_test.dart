import 'dart:io';

import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The design source the geometry is transcribed from. It lives outside this
/// package, so it is located by walking up from the package root rather than by
/// a fixed relative path (the package is checked out both directly and as a git
/// worktree at varying depths).
const String spacingCssSuffix =
    'dabbler-design-system-design/project/tokens/spacing.css';

File? _findSpacingCss() {
  Directory dir = Directory.current;
  for (int i = 0; i < 8; i++) {
    final File candidate = File('${dir.path}/$spacingCssSuffix');
    if (candidate.existsSync()) return candidate;
    final File nested = File('${dir.path}/Dabbler/$spacingCssSuffix');
    if (nested.existsSync()) return nested;
    if (dir.parent.path == dir.path) break;
    dir = dir.parent;
  }
  return null;
}

final RegExp _pxToken = RegExp(r'--([a-z0-9-]+):\s*([0-9.]+)px');

/// Every `--name: <n>px` declared anywhere in the source.
Map<String, double> _pxTokens(String css) => <String, double>{
      for (final RegExpMatch m in _pxToken.allMatches(css))
        m.group(1)!: double.parse(m.group(2)!),
    };

/// Asserts a shadow colour against the source's `rgba(r, g, b, a)` form.
void _expectRgba(Color color, int r, int g, int b, double alpha) {
  expect((color.r * 255).round(), r);
  expect((color.g * 255).round(), g);
  expect((color.b * 255).round(), b);
  expect(color.a, closeTo(alpha, 1 / 255));
}

void main() {
  final File? source = _findSpacingCss();

  group('transcription against tokens/spacing.css', () {
    late Map<String, double> css;

    setUpAll(() {
      // The source is a sibling checkout; when it is absent the source-backed
      // assertions cannot run, and the group is skipped rather than passing
      // vacuously.
      if (source != null) css = _pxTokens(source.readAsStringSync());
    });

    test('the base-3 scale matches --space-1 … --space-11', () {
      for (int i = 0; i < DabblerSpacing.scale.length; i++) {
        expect(
          DabblerSpacing.scale[i],
          css['space-${i + 1}'],
          reason: '--space-${i + 1}',
        );
      }
      expect(css.keys.where((String k) => k.startsWith('space-')), hasLength(11));
    });

    test('the radius ramp matches --radius-*', () {
      expect(DabblerRadius.sm, css['radius-sm']);
      expect(DabblerRadius.md, css['radius-md']);
      expect(DabblerRadius.lg, css['radius-lg']);
      expect(DabblerRadius.xl, css['radius-xl']);
      expect(DabblerRadius.xxl, css['radius-xxl']);
      expect(DabblerRadius.pill, css['radius-pill']);
    });

    test('sizing matches the source', () {
      expect(DabblerSizing.touchTargetMin, css['touch-target-min']);
      expect(DabblerSizing.borderHairline, css['border-hairline']);
      expect(DabblerSizing.borderDefault, css['border-default']);
      expect(DabblerSizing.iconSm, css['icon-sm']);
      expect(DabblerSizing.iconMd, css['icon-md']);
      expect(DabblerSizing.iconLg, css['icon-lg']);
    });

    test('--elevation-0 and --elevation-1 are none in the source', () {
      final String text = source!.readAsStringSync();
      expect(text, contains('--elevation-0: none;'));
      expect(text, contains('--elevation-1: none;'));
      expect(DabblerElevation.none, isEmpty);
      expect(DabblerElevation.flat, isEmpty);
    });

    test('--elevation-2 is the only shadow declared, in both modes', () {
      final String text = source!.readAsStringSync();
      final Iterable<RegExpMatch> shadows =
          RegExp(r'--elevation-\d: ([^;]+);').allMatches(text);
      final List<String> nonNone = <String>[
        for (final RegExpMatch m in shadows)
          if (m.group(1) != 'none') m.group(0)!,
      ];
      // Exactly two declarations carry a value: light and the dark override,
      // both of them --elevation-2.
      expect(nonNone, hasLength(2));
      expect(nonNone.every((String d) => d.startsWith('--elevation-2:')), isTrue);
    });
  }, skip: source == null ? 'tokens/spacing.css not found beside the package' : false);

  group('semantic aliases are steps of the scale', () {
    test('each alias equals the step the source points it at', () {
      expect(DabblerSpacing.cardPadding, DabblerSpacing.space6);
      expect(DabblerSpacing.screenGutter, DabblerSpacing.space8);
      expect(DabblerSpacing.sectionGap, DabblerSpacing.space9);
      expect(DabblerSpacing.stackTight, DabblerSpacing.space2);
      expect(DabblerSpacing.stackDefault, DabblerSpacing.space4);
      expect(DabblerSpacing.iconGap, DabblerSpacing.space2);
    });

    test('no alias introduces a value off the scale', () {
      for (final double value in <double>[
        DabblerSpacing.cardPadding,
        DabblerSpacing.screenGutter,
        DabblerSpacing.sectionGap,
        DabblerSpacing.stackTight,
        DabblerSpacing.stackDefault,
        DabblerSpacing.iconGap,
      ]) {
        expect(DabblerSpacing.scale, contains(value));
      }
    });
  });

  group('the grid itself', () {
    test('every spacing step is a multiple of 3 and strictly ascending', () {
      double previous = 0;
      for (final double step in DabblerSpacing.scale) {
        expect(step % 3, 0, reason: '$step is off the base-3 grid');
        expect(step, greaterThan(previous));
        previous = step;
      }
    });

    test('the structural values are multiples of both 3 and 4', () {
      for (final double step in <double>[12, 24, 36, 48]) {
        expect(DabblerSpacing.scale, contains(step));
        expect(step % 12, 0);
      }
    });

    test('the radius ramp ascends', () {
      double previous = 0;
      for (final double step in DabblerRadius.ramp) {
        expect(step, greaterThan(previous));
        previous = step;
      }
    });

    test('touch target clears the 44pt platform floor', () {
      expect(DabblerSizing.touchTargetMin, greaterThanOrEqualTo(44));
      expect(DabblerSizing.touchTargetMin % 3, 0);
    });
  });

  group('elevation — the one legal shadow', () {
    test('the light dialog shadow carries both source layers', () {
      expect(DabblerElevation.dialogLight, hasLength(2));
      expect(DabblerElevation.dialogLight[0].offset, const Offset(0, 9));
      expect(DabblerElevation.dialogLight[0].blurRadius, 24);
      _expectRgba(DabblerElevation.dialogLight[0].color, 23, 17, 35, 0.14);
      expect(DabblerElevation.dialogLight[1].offset, const Offset(0, 3));
      expect(DabblerElevation.dialogLight[1].blurRadius, 6);
      _expectRgba(DabblerElevation.dialogLight[1].color, 23, 17, 35, 0.08);
    });

    test('the dark dialog shadow carries both source layers', () {
      expect(DabblerElevation.dialogDark, hasLength(2));
      expect(DabblerElevation.dialogDark[0].offset, const Offset(0, 9));
      expect(DabblerElevation.dialogDark[0].blurRadius, 24);
      _expectRgba(DabblerElevation.dialogDark[0].color, 0, 0, 0, 0.28);
      expect(DabblerElevation.dialogDark[1].offset, const Offset(0, 3));
      expect(DabblerElevation.dialogDark[1].blurRadius, 6);
      _expectRgba(DabblerElevation.dialogDark[1].color, 0, 0, 0, 0.20);
    });

    test('no shadow uses a spread — flat surfaces, one floating exception', () {
      for (final BoxShadow shadow in <BoxShadow>[
        ...DabblerElevation.dialogLight,
        ...DabblerElevation.dialogDark,
      ]) {
        expect(shadow.spreadRadius, 0);
      }
    });

    test('dialogFor picks the mode', () {
      expect(
        DabblerElevation.dialogFor(Brightness.light),
        same(DabblerElevation.dialogLight),
      );
      expect(
        DabblerElevation.dialogFor(Brightness.dark),
        same(DabblerElevation.dialogDark),
      );
    });

    test(
      'no shadow-bearing token exists outside the dialog pair',
      () {
        // The reservation is enforceable only as far as this cut goes: DS-104
        // declares exactly one shadow value, under a name that says who may
        // use it. Nothing else in the geometry surface returns a BoxShadow.
        expect(DabblerElevation.none, isEmpty);
        expect(DabblerElevation.flat, isEmpty);
      },
    );
  });
}
