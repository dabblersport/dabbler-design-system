import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_neutral_status.dart';

/// The fill, ink and hairline one status tone paints — the Dart form of the
/// design source's `statusTones` + `statusHairline`
/// (`components/foundations/overlay.jsx:160-173`).
///
/// Toast, Banner and the navigation-integrated presentations
/// (`DabblerNavigationFeedback`) all resolve colour this way, and the card is
/// explicit that the navigation presentation *"reads `statusTones` and
/// `statusHairline` … exactly as Toast and Banner do"*
/// (`status-feedback.card.html` — *Navigation interaction preview*). It is one
/// definition so the three cannot drift apart:
///
/// | role | status tone | `neutral` (null) |
/// |---|---|---|
/// | [surface] | [DabblerStatusColor.surface] | [DabblerColors.surfaceCard] |
/// | [ink] | [DabblerStatusColor.strong] | [DabblerColors.textPrimary] |
/// | [hairline] | [ink] at [hairlineAlpha] | [DabblerColors.borderDefault] |
///
/// `neutral` comes from [dabblerNeutralStatus], the one shared definition of
/// the fifth, non-status value.
@immutable
class DabblerStatusToneColors {
  /// Creates a resolved triple. Normally built by [DabblerStatusToneColors.of].
  const DabblerStatusToneColors({
    required this.surface,
    required this.ink,
    required this.hairline,
  });

  /// Resolves [status] against [colors]; `null` is the source's `neutral`.
  factory DabblerStatusToneColors.of(
    DabblerColors colors,
    DabblerStatusTone? status,
  ) {
    if (status == null) {
      final DabblerStatusColor neutral = dabblerNeutralStatus(colors);
      return DabblerStatusToneColors(
        surface: neutral.surface,
        ink: neutral.strong,
        // `statusHairline` returns the bare `--outline-card` for neutral.
        hairline: neutral.base,
      );
    }
    final DabblerStatusColor tone = colors.status(status);
    return DabblerStatusToneColors(
      surface: tone.surface,
      ink: tone.strong,
      hairline: tone.strong.withValues(alpha: hairlineAlpha),
    );
  }

  /// `color-mix(in srgb, <strong> 20%, transparent)` — the share of the strong
  /// ink the hairline carries (`overlay.jsx:169-173`).
  static const double hairlineAlpha = 0.20;

  /// The tint fill — `--color-status-*-surface`.
  final Color surface;

  /// The ink on [surface] — `--color-status-*-strong`. Message, title, glyph
  /// and action label all take it; never a secondary text colour.
  final Color ink;

  /// The 1px outline.
  final Color hairline;

  @override
  bool operator ==(Object other) =>
      other is DabblerStatusToneColors &&
      other.surface == surface &&
      other.ink == ink &&
      other.hairline == hairline;

  @override
  int get hashCode => Object.hash(surface, ink, hairline);
}
