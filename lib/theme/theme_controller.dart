// =============================================================================
// Dabbler — Theme controller (Riverpod)
// -----------------------------------------------------------------------------
// Single source of truth for which theme is on screen. It holds:
//   • the current DabblerSection   (driven by navigation)
//   • an optional user override     (a DabblerTheme the user picked by hand)
//   • the ThemeMode                 (system / light / dark)
//
// It resolves the active theme with resolveTheme(section, userOverride) — a
// user override always wins, but it never changes a theme's semantic meaning.
// The override + ThemeMode are persisted through the ThemePreferences seam.
//
// Wire into MaterialApp:
//   final state = ref.watch(themeControllerProvider);
//   MaterialApp(
//     theme:     state.lightTheme,
//     darkTheme: state.darkTheme,
//     themeMode: state.themeMode,
//     ...
//   );
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dabbler_colors.dart';
import 'dabbler_theme_data.dart';

// -----------------------------------------------------------------------------
// Persistence seam
// -----------------------------------------------------------------------------

/// Holds the [SharedPreferences] instance. Override it in `main()` with the
/// resolved instance so the controller can read synchronously at startup:
///
/// ```dart
/// final prefs = await SharedPreferences.getInstance();
/// runApp(ProviderScope(
///   overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
///   child: const DabblerApp(),
/// ));
/// ```
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  ),
);

/// Storage seam for the user's theme override + [ThemeMode].
///
/// Backed by [SharedPreferences] locally. This is the exact interface to
/// implement against Supabase when remote sync is added — swap the provider
/// below and nothing else in the app changes.
abstract interface class ThemePreferences {
  DabblerTheme? readOverride();
  ThemeMode readThemeMode();
  Locale readLocale();
  Future<void> writeOverride(DabblerTheme? theme);
  Future<void> writeThemeMode(ThemeMode mode);
  Future<void> writeLocale(Locale locale);
}

/// [SharedPreferences]-backed implementation of [ThemePreferences].
class SharedPreferencesThemePreferences implements ThemePreferences {
  SharedPreferencesThemePreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _overrideKey = 'dabbler.theme.override';
  static const _modeKey = 'dabbler.theme.mode';
  static const _localeKey = 'dabbler.theme.locale';

  /// Locales the design system ships typography for (EN + AR).
  static const _supported = ['en', 'ar'];

  @override
  DabblerTheme? readOverride() {
    final name = _prefs.getString(_overrideKey);
    if (name == null) return null;
    for (final t in DabblerTheme.values) {
      if (t.name == name) return t;
    }
    return null;
  }

  @override
  ThemeMode readThemeMode() {
    final name = _prefs.getString(_modeKey);
    for (final m in ThemeMode.values) {
      if (m.name == name) return m;
    }
    return ThemeMode.system;
  }

  @override
  Locale readLocale() {
    final code = _prefs.getString(_localeKey);
    if (code != null && _supported.contains(code)) return Locale(code);
    return const Locale('en');
  }

  @override
  Future<void> writeOverride(DabblerTheme? theme) async {
    if (theme == null) {
      await _prefs.remove(_overrideKey);
    } else {
      await _prefs.setString(_overrideKey, theme.name);
    }
  }

  @override
  Future<void> writeThemeMode(ThemeMode mode) =>
      _prefs.setString(_modeKey, mode.name);

  @override
  Future<void> writeLocale(Locale locale) =>
      _prefs.setString(_localeKey, locale.languageCode);
}

final themePreferencesProvider = Provider<ThemePreferences>(
  (ref) => SharedPreferencesThemePreferences(ref.watch(sharedPreferencesProvider)),
);

// -----------------------------------------------------------------------------
// State
// -----------------------------------------------------------------------------

@immutable
class ThemeState {
  const ThemeState({
    required this.section,
    required this.userOverride,
    required this.themeMode,
    required this.locale,
  });

  /// The active navigation section (home / sport / social / active).
  final DabblerSection section;

  /// A theme the user picked by hand; when set it wins over the section default.
  final DabblerTheme? userOverride;

  final ThemeMode themeMode;

  /// The active app locale. Drives the typography variant (Arabic → taller
  /// leading). Feed into MaterialApp.locale.
  final Locale locale;

  /// The theme actually on screen: user override if any, else the section's map.
  DabblerTheme get resolvedTheme =>
      resolveTheme(section, userOverride: userOverride);

  /// Ready-to-use Material 3 [ThemeData] for the light + dark variants of the
  /// resolved theme — typography bound to [locale]. Feed straight into
  /// MaterialApp.theme / .darkTheme.
  ThemeData get lightTheme =>
      dabblerThemeData(resolvedTheme, Brightness.light, locale: locale);
  ThemeData get darkTheme =>
      dabblerThemeData(resolvedTheme, Brightness.dark, locale: locale);

  ThemeState copyWith({
    DabblerSection? section,
    DabblerTheme? userOverride,
    bool clearOverride = false,
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return ThemeState(
      section: section ?? this.section,
      userOverride: clearOverride ? null : (userOverride ?? this.userOverride),
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

// -----------------------------------------------------------------------------
// Controller
// -----------------------------------------------------------------------------

class ThemeController extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    final prefs = ref.watch(themePreferencesProvider);
    return ThemeState(
      section: DabblerSection.home,
      userOverride: prefs.readOverride(),
      themeMode: prefs.readThemeMode(),
      locale: prefs.readLocale(),
    );
  }

  ThemePreferences get _prefs => ref.read(themePreferencesProvider);

  /// Call from navigation when the active section changes. Not persisted —
  /// the section follows the user around the app, it is not a preference.
  void setSection(DabblerSection section) {
    if (state.section == section) return;
    state = state.copyWith(section: section);
  }

  /// The user explicitly picks a theme. Pass `null` to clear the override and
  /// fall back to the section default. Persisted.
  Future<void> setUserOverride(DabblerTheme? theme) async {
    state = state.copyWith(userOverride: theme, clearOverride: theme == null);
    await _prefs.writeOverride(theme);
  }

  /// Clears any user override (back to section-driven theming). Persisted.
  Future<void> clearUserOverride() => setUserOverride(null);

  /// Sets the app locale (drives the typography variant). Persisted. Rebuilding
  /// the theme on locale change is automatic — MaterialApp reads lightTheme /
  /// darkTheme which fold the locale into the text theme.
  Future<void> setLocale(Locale locale) async {
    if (state.locale.languageCode == locale.languageCode) return;
    state = state.copyWith(locale: locale);
    await _prefs.writeLocale(locale);
  }

  /// Sets system / light / dark. Persisted.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (state.themeMode == mode) return;
    state = state.copyWith(themeMode: mode);
    await _prefs.writeThemeMode(mode);
  }
}

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeState>(ThemeController.new);
