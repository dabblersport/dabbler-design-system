/// The gallery's theme and brightness control.
///
/// `DabblerColors.resolve` answers for **seven themes × two brightnesses =
/// fourteen distinct instances**, and a gallery that renders whichever one the
/// OS happens to ask for leaves thirteen of them unreviewable. This is the
/// control that reaches the other thirteen.
///
/// ## Why it is a widget, not a screen
///
/// It goes in the app bar of *every* screen — the index and each entry — for
/// the reason the brief gives: a component's own screen is exactly where a
/// reviewer wants to switch, so a control that lived only on the index would
/// be useless. It reads and writes [GalleryThemeScope], which sits above the
/// [MaterialApp], so one instance on the current screen changes the whole app.
///
/// ## Built from the system's own components (D-017)
///
/// Both pickers are a [DabblerMenu] with a [DabblerButton] trigger. A design
/// system gallery driven by Material's `PopupMenuButton` and `Switch` would be
/// advertising the wrong system. Nothing here reads `Theme.of(context)`; the
/// paint comes from [DabblerColors] through the components themselves.
///
/// Two menus rather than a menu plus a chip row: three [DabblerChip]s for the
/// brightness modes measure ~250 logical pixels next to the theme trigger, and
/// an app bar on a phone-width viewport has nowhere to put that. A menu is the
/// same control at a fixed ~100px.
library;

// `material.dart` for [ThemeMode] and nothing else: it is the mechanism
// MaterialApp takes its light/dark preference as, and D-017 permits the
// import for a mechanism. No Material appearance is read here — every
// colour below comes from DabblerColors through the components.
import 'package:flutter/material.dart';

import '../controls/button.dart';
import '../overlays/menu.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import 'gallery_theme_scope.dart';

/// The display name of a [DabblerTheme], as the design source's
/// `[data-theme]` blocks name it.
String galleryThemeLabel(DabblerTheme theme) => switch (theme) {
      DabblerTheme.main => 'Main',
      DabblerTheme.sport => 'Sport',
      DabblerTheme.social => 'Social',
      DabblerTheme.active => 'Active',
      DabblerTheme.bright => 'Bright',
      DabblerTheme.simple => 'Simple',
      DabblerTheme.shade => 'Shade',
    };

/// The display name of a [ThemeMode].
String galleryModeLabel(ThemeMode mode) => switch (mode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System',
    };

/// A theme picker and a brightness picker, for an app bar's `actions`.
class GalleryThemeSwitcher extends StatefulWidget {
  /// Creates the switcher.
  const GalleryThemeSwitcher({super.key});

  /// The `id` prefix that marks a menu entry as a theme choice.
  static const String themeEntryPrefix = 'theme.';

  /// The `id` prefix that marks a menu entry as a brightness choice.
  static const String modeEntryPrefix = 'mode.';

  @override
  State<GalleryThemeSwitcher> createState() => _GalleryThemeSwitcherState();
}

/// ## Why both menus are *controlled*
///
/// [DabblerMenu] opens an uncontrolled menu from a [GestureDetector] it wraps
/// around the trigger. That works for an inert trigger, but [DabblerButton] is
/// itself a gesture-handling widget and wins the arena, so the wrapper never
/// sees the tap — the menu simply would not open. The fix is the one the
/// component already supports and `Select` (DS-601) already uses: own `open`
/// here, and open it from the button's own `onPressed`.
class _GalleryThemeSwitcherState extends State<GalleryThemeSwitcher> {
  bool _themeOpen = false;
  bool _modeOpen = false;

  @override
  Widget build(BuildContext context) {
    // Absent outside the app: `test/gallery_test.dart` renders a
    // [GalleryEntryScreen] directly to check one component's specimen, with no
    // scope above it. A harness that is only exercising a specimen has nothing
    // to switch, so the control simply is not there — rather than asserting and
    // failing every one of those tests on a control they do not use. Its
    // presence in the real app is what `gallery_theme_switcher_test.dart`
    // pins.
    final GalleryThemeController? controller =
        GalleryThemeScope.maybeOf(context);
    if (controller == null) {
      return const SizedBox.shrink();
    }
    final GalleryAppearance appearance = controller.appearance;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: DabblerSpacing.space2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DabblerMenu(
            label: 'Theme',
            open: _themeOpen,
            onOpenChanged: (bool open) => setState(() => _themeOpen = open),
            items: <DabblerMenuEntry>[
              for (final DabblerTheme theme in DabblerTheme.values)
                DabblerMenuEntry(
                  id: '${GalleryThemeSwitcher.themeEntryPrefix}${theme.name}',
                  label: galleryThemeLabel(theme),
                  selected: theme == appearance.theme,
                ),
            ],
            onSelected: (DabblerMenuEntry entry) => controller.setTheme(
              DabblerTheme.values.byName(
                entry.id!.substring(
                  GalleryThemeSwitcher.themeEntryPrefix.length,
                ),
              ),
            ),
            trigger: DabblerButton(
              label: galleryThemeLabel(appearance.theme),
              tone: DabblerButtonTone.outlined,
              size: DabblerButtonSize.small,
              semanticLabel: 'Theme: ${galleryThemeLabel(appearance.theme)}',
              onPressed: () => setState(() => _themeOpen = !_themeOpen),
            ),
          ),
          const SizedBox(width: DabblerSpacing.space2),
          DabblerMenu(
            label: 'Brightness',
            open: _modeOpen,
            onOpenChanged: (bool open) => setState(() => _modeOpen = open),
            items: <DabblerMenuEntry>[
              for (final ThemeMode mode in ThemeMode.values)
                DabblerMenuEntry(
                  id: '${GalleryThemeSwitcher.modeEntryPrefix}${mode.name}',
                  label: galleryModeLabel(mode),
                  selected: mode == appearance.mode,
                ),
            ],
            onSelected: (DabblerMenuEntry entry) => controller.setMode(
              ThemeMode.values.byName(
                entry.id!.substring(
                  GalleryThemeSwitcher.modeEntryPrefix.length,
                ),
              ),
            ),
            trigger: DabblerButton(
              label: galleryModeLabel(appearance.mode),
              tone: DabblerButtonTone.outlined,
              size: DabblerButtonSize.small,
              semanticLabel: 'Brightness: ${galleryModeLabel(appearance.mode)}',
              onPressed: () => setState(() => _modeOpen = !_modeOpen),
            ),
          ),
        ],
      ),
    );
  }
}
