import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// The calendar audit (`foundations/icons.md` → *Direction*, *Calendar*).
///
/// Measured by drawing `FlutterIconsax.ttf` (iconsax_flutter 1.0.1): at
/// linear, `calendar` draws a calendar carrying a day number ("8"), and
/// `calendar-1` draws the two-rows-of-three dot grid the web Iconsax set calls
/// `calendar` and the Home Feed create menu draws on *Create meetup*. These
/// pins fail if a package bump reshuffles the glyphs, which is the moment the
/// audit has to be redone by looking.
void main() {
  test('calendar-1 linear resolves to the dot-grid glyph', () {
    final DabblerIconResolution r = DabblerIconRegistry.resolve('calendar-1');
    expect(r.outcome, DabblerIconOutcome.resolved);
    expect(r.resolvedKey, 'calendar_1_copy');
    expect(r.glyph, Iconsax.calendar_1_copy);
  });

  test('calendar linear is a different glyph (the day number)', () {
    final DabblerIconResolution plain = DabblerIconRegistry.resolve(
      'calendar',
    );
    final DabblerIconResolution grid = DabblerIconRegistry.resolve(
      'calendar-1',
    );
    expect(plain.outcome, DabblerIconOutcome.resolved);
    expect(plain.glyph, Iconsax.calendar_copy);
    expect(plain.glyph!.codePoint, isNot(grid.glyph!.codePoint));
  });
}
