import 'dabbler_colors.dart';

/// The design source's fifth status value, `neutral` — one definition.
///
/// ## Why this is not a `--color-status-neutral` token
///
/// The design source deliberately keeps `neutral` **outside** the
/// `--color-status-*` API. `components/foundations/overlay.jsx:161` declares it
/// separately, from the paper ramp rather than from a status ramp:
///
/// | role | source token | Dart |
/// |---|---|---|
/// | surface | `--surface-card` | [DabblerColors.surfaceCard] |
/// | strong ink | `--ink` | [DabblerColors.textPrimary] |
/// | base / hairline | `--outline-card` | [DabblerColors.borderDefault] |
///
/// That is why [DabblerStatusTone] has **four** entries and not five, and why
/// no fifth `--color-status-neutral` token exists in the token layer. **Do not
/// "correct" that by adding one** — the source does not declare it, and a
/// token invented here would diverge from `overlay.jsx` on the next sync.
///
/// `statusHairline` (`overlay.jsx:171`) likewise returns the bare
/// `--outline-card` for `neutral`, instead of the 20% mix of `strong` it
/// computes for the four real statuses.
///
/// ## Why it is shared rather than local (KAN-266)
///
/// `DabblerBadge.neutralStatusOf` and `DabblerToastTone.neutral` each derived
/// this identical triple independently from the same source line. Two call
/// sites wanting the same three values is the bar `DECISIONS.md` D-004 set for
/// `--accent-indigo`: at that point it is a **role**, and a role gets one
/// definition. Both now compose this one.
///
/// [DabblerStatusColor.solid] has no neutral counterpart in the source. It is
/// filled with the same ink as [DabblerStatusColor.strong] — the only value on
/// which white text clears AA. Neither Badge nor Toast reads it.
DabblerStatusColor dabblerNeutralStatus(DabblerColors colors) =>
    DabblerStatusColor(
      base: colors.borderDefault,
      surface: colors.surfaceCard,
      strong: colors.textPrimary,
      solid: colors.textPrimary,
    );
