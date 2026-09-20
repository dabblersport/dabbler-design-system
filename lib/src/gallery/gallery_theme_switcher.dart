/// The gallery's theme, brightness and direction control.
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
/// Menus rather than chip rows: three [DabblerChip]s for the brightness modes
/// measure ~250 logical pixels next to the theme trigger, and an app bar on a
/// phone-width viewport has nowhere to put that. A menu is the same control at
/// a fixed ~100px, and the direction picker is the third of them for exactly
/// the same reason — it is a third axis, not a bolted-on toggle.
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

/// The display name of a [TextDirection], as the gallery labels the axis.
///
/// The short forms are deliberate: 'Left to right' and 'Right to left' are
/// nearly twice the width of the widest theme label and would be the only
/// triggers in the row that set the app bar's height on a phone.
String galleryDirectionLabel(TextDirection direction) => switch (direction) {
      TextDirection.ltr => 'LTR',
      TextDirection.rtl => 'RTL',
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

  /// The `id` prefix that marks a menu entry as a direction choice.
  static const String directionEntryPrefix = 'direction.';

  @override
  State<GalleryThemeSwitcher> createState() => _GalleryThemeSwitcherState();
}

/// ## Why these menus are *controlled*
///
/// Because this widget reads the open state back — the trigger's
/// `semanticLabel` and the checked row both depend on it — not because the
/// uncontrolled path does not work.
///
/// It did not, once: [DabblerMenu] wrapped its trigger in a [GestureDetector]
/// that a [DabblerButton] beat in the gesture arena, so the tap never reached
/// it. This file worked around that by toggling from the button's own
/// `onPressed`. KAN-286 fixed the wrapper — it is a [Listener] now, which does
/// not enter the arena — and the workaround came out with it: the wrapper
/// reports every trigger tap through `onOpenChanged`, so toggling here as well
/// would fire twice per click and cancel out.
class _GalleryThemeSwitcherState extends State<GalleryThemeSwitcher> {
  bool _themeOpen = false;
  bool _modeOpen = false;
  bool _directionOpen = false;

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
              // Opening is the menu wrapper's; see the class doc.
              onPressed: () {},
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
              onPressed: () {},
            ),
          ),
          const SizedBox(width: DabblerSpacing.space2),
          DabblerMenu(
            label: 'Direction',
            open: _directionOpen,
            onOpenChanged: (bool open) =>
                setState(() => _directionOpen = open),
            items: <DabblerMenuEntry>[
              for (final TextDirection direction in TextDirection.values)
                DabblerMenuEntry(
                  id: '${GalleryThemeSwitcher.directionEntryPrefix}'
                      '${direction.name}',
                  label: galleryDirectionLabel(direction),
                  selected: direction == appearance.direction,
                ),
            ],
            onSelected: (DabblerMenuEntry entry) => controller.setDirection(
              TextDirection.values.byName(
                entry.id!.substring(
                  GalleryThemeSwitcher.directionEntryPrefix.length,
                ),
              ),
            ),
            trigger: DabblerButton(
              label: galleryDirectionLabel(appearance.direction),
              tone: DabblerButtonTone.outlined,
              size: DabblerButtonSize.small,
              semanticLabel:
                  'Direction: ${galleryDirectionLabel(appearance.direction)}',
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}
