import 'package:flutter/material.dart';

import 'dabbler_palette.dart';

/// Whether the dark ramp in this file is provisional rather than signed off.
///
/// `true`, and it is expected to stay `true` until the dark variables are added
/// to the Figma file `Dabbler Design UI.fig` and re-exported. The design source
/// says so itself (`tokens/colors.css:195-201`): the Figma file defines no dark
/// mode, so the `[data-mode="dark"]` block is an **inferred neutral inversion**
/// of the light paper ramp. Its *structure* — token names, roles, contrast
/// intent — is final. Only the hex values are pending sign-off.
///
/// Anything that quotes a Dabbler dark value as a final design-system value
/// must check this flag first.
const bool dabblerDarkRampProvisional = true;

/// The provisional dark ramp: every hex value that only exists in dark mode.
///
/// This class is the **single file** in which a dark-mode hex literal may be
/// written. `test/tokens/dark_provisional_isolation_test.dart` fails the build
/// if any dark value appears anywhere else under `lib/`, which is what makes
/// the eventual Figma re-export a one-file change rather than a hunt.
///
/// Values transcribed from `tokens/colors.css`:
/// * `[data-mode="dark"]` (lines 202-224) — the shared neutral inversion and
///   the four dark status tints.
/// * `[data-theme="…"][data-mode="dark"]` (lines 227-256) — the per-theme dark
///   status overrides for sport, social and bright.
///
/// Dark values that are *not* new — `--t-bg:#141414` is [DabblerPalette.ink],
/// `--t-text:#F5F0E6` is [DabblerPalette.surfacePage], `--t-text-2:#B8B0A0` is
/// [DabblerPalette.subtle], `--t-text-3:#8C8C8C` is [DabblerPalette.muted] —
/// are re-exported here by reference rather than re-declared, so the dark ramp
/// still reads as one contiguous set without duplicating a primitive.
abstract final class DabblerProvisionalDark {
  const DabblerProvisionalDark._();

  // --- Shared neutral inversion (`[data-mode="dark"]`) ---

  /// `--t-bg` (dark) — `#141414`. The light [DabblerPalette.ink], reused as the
  /// dark page background; the inversion is deliberate, not a coincidence.
  static const Color bgPrimary = DabblerPalette.ink;

  /// `--t-bg-2` (dark) — `#1C1C1C`.
  static const Color bgSecondary = Color(0xFF1C1C1C);

  /// `--t-bg-3` (dark) — `#262626`.
  static const Color bgTertiary = Color(0xFF262626);

  /// `--t-surface` (dark) — `#1C1C1C`. Identical to [bgSecondary] by design:
  /// the flat system separates a dark card from the page by one step of the
  /// same ramp, never by a shadow.
  static const Color surfaceCard = bgSecondary;

  /// `--t-surface-sunken` (dark) — `#262626`.
  static const Color surfaceSunken = bgTertiary;

  /// `--t-surface-grey` (dark) — `#202020`.
  static const Color surfaceGrey = Color(0xFF202020);

  /// `--t-text` (dark) — `#F5F0E6`, the light `--surface-page` inverted to ink.
  static const Color textPrimary = DabblerPalette.surfacePage;

  /// `--t-text-2` (dark) — `#B8B0A0`, the light `--subtle`.
  static const Color textSecondary = DabblerPalette.subtle;

  /// `--t-text-3` (dark) — `#8C8C8C`, the light `--muted`.
  static const Color textTertiary = DabblerPalette.muted;

  /// `--t-border` (dark) — `#3A3A3A`.
  static const Color borderDefault = Color(0xFF3A3A3A);

  /// `--t-border-strong` (dark) — `#4F4F4F`.
  static const Color borderStrong = Color(0xFF4F4F4F);

  // --- Dark status tints. The *ink* inverts to the light 100 tint; only the
  //     surface is a new value. ---

  /// `--t-success-surface` (dark) — `#14332A`.
  static const Color successSurface = Color(0xFF14332A);

  /// `--t-warning-surface` (dark) — `#3A1E08`.
  static const Color warningSurface = Color(0xFF3A1E08);

  /// `--t-error-surface` (dark) — `#3A1717`.
  static const Color errorSurface = Color(0xFF3A1717);

  /// `--t-info-surface` (dark) — `#16243F`.
  static const Color infoSurface = Color(0xFF16243F);

  // --- Per-theme dark status overrides ---

  /// `[data-theme="sport"][data-mode="dark"] --t-success-surface` — `#0E3A2E`.
  static const Color sportSuccessSurface = Color(0xFF0E3A2E);

  /// `[data-theme="sport"][data-mode="dark"] --t-on-success` — `#CDEFE2`.
  static const Color sportSuccessInk = Color(0xFFCDEFE2);

  /// `[data-theme="social"][data-mode="dark"] --t-info-surface` — `#1E2150`.
  static const Color socialInfoSurface = Color(0xFF1E2150);

  /// `[data-theme="social"][data-mode="dark"] --t-on-info` — `#D7D8FB`.
  static const Color socialInfoInk = Color(0xFFD7D8FB);

  /// `[data-theme="bright"][data-mode="dark"] --t-warning-surface` — `#3A1A06`.
  static const Color brightWarningSurface = Color(0xFF3A1A06);

  /// `[data-theme="bright"][data-mode="dark"] --t-on-warning` — `#F6D9C2`.
  static const Color brightWarningInk = Color(0xFFF6D9C2);
}

/// The six per-theme status tints of the **light** theme layer.
///
/// These are **not provisional** — they are signed-off light values from
/// `tokens/colors.css:161-186`. They live in this file only because of where
/// the package draws its literal boundary: `DabblerPalette` transcribes the
/// `:root` block exactly (its test asserts one `Color(0x…)` literal per `:root`
/// token and no more), and these six are declared in the `[data-theme="…"]`
/// blocks instead, so the primitive layer has no home for them. This file is
/// the only other place under `lib/src/` where a literal is permitted.
///
/// **Hand-off:** the right fix is for the primitive layer to cover the theme
/// layer too, or for the literal allowlist to name a third file. Either is a
/// change to `lib/src/tokens/dabbler_palette.dart` /
/// `test/tokens/dabbler_palette_test.dart`, which belong to DS-101 and are not
/// this ticket's surfaces.
abstract final class DabblerThemeStatusTints {
  const DabblerThemeStatusTints._();

  /// `[data-theme="sport"] --t-success-surface` — `#D2EEE4`.
  static const Color sportSuccessSurface = Color(0xFFD2EEE4);

  /// `[data-theme="sport"] --t-on-success` — `#0B4A38`.
  static const Color sportSuccessInk = Color(0xFF0B4A38);

  /// `[data-theme="social"] --t-info-surface` — `#E0E1FB`.
  static const Color socialInfoSurface = Color(0xFFE0E1FB);

  /// `[data-theme="social"] --t-on-info` — `#3A3D9E`.
  static const Color socialInfoInk = Color(0xFF3A3D9E);

  /// `[data-theme="bright"] --t-warning-surface` — `#F7DCC8`.
  static const Color brightWarningSurface = Color(0xFFF7DCC8);

  /// `[data-theme="bright"] --t-on-warning` — `#7A2F06`.
  static const Color brightWarningInk = Color(0xFF7A2F06);
}
