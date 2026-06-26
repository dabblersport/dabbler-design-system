// =============================================================================
// Dabbler — Theme Gallery (debug only)
// -----------------------------------------------------------------------------
// Visual acceptance check for the colour system. Switchers cover all 7 themes ×
// light/dark; the preview shows an app bar, a primary CTA, a secondary button,
// success/warning/error/info chips, and nested card surfaces.
//
// Register behind a debug route only (see app.dart, guarded by kDebugMode).
//
// Everything in the preview reads from Theme.of(context).colorScheme or
// context.dabbler — there are no hardcoded colours. On-brand text always comes
// from the token (onBrand / onAccent), so Bright's primary and Sport/Social's
// accent correctly render dark-on-colour.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as f;

import '../theme/dabbler_colors.dart';
import '../theme/dabbler_forui_theme.dart';
import '../theme/dabbler_theme_data.dart';
import '../theme/dabbler_type.dart';

class ThemeGalleryScreen extends StatefulWidget {
  const ThemeGalleryScreen({super.key});

  static const routeName = '/debug/theme-gallery';

  @override
  State<ThemeGalleryScreen> createState() => _ThemeGalleryScreenState();
}

enum _GalleryView { components, typography }

class _ThemeGalleryScreenState extends State<ThemeGalleryScreen> {
  DabblerTheme _theme = DabblerTheme.main;
  Brightness _brightness = Brightness.light;
  _GalleryView _view = _GalleryView.components;
  bool _rtl = false;

  static const _labels = {
    DabblerTheme.main: 'Main',
    DabblerTheme.sport: 'Sport',
    DabblerTheme.social: 'Social',
    DabblerTheme.active: 'Active',
    DabblerTheme.bright: 'Bright',
    DabblerTheme.simple: 'Simple',
    DabblerTheme.shade: 'Shade',
  };

  @override
  Widget build(BuildContext context) {
    // RTL → drive the Arabic typography variant (taller leading) as well as
    // direction, so the preview matches a real Arabic screen.
    final previewTheme = dabblerThemeData(
      _theme,
      _brightness,
      locale: Locale(_rtl ? 'ar' : 'en'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Gallery'),
        actions: [
          IconButton(
            tooltip: _rtl ? 'Switch to LTR' : 'Switch to RTL',
            icon: const Icon(Icons.format_textdirection_r_to_l),
            isSelected: _rtl,
            onPressed: () => setState(() => _rtl = !_rtl),
          ),
          IconButton(
            tooltip: 'Toggle light / dark',
            icon: Icon(
              _brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () => setState(() {
              _brightness = _brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark;
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          _ThemeSwitcher(
            selected: _theme,
            labels: _labels,
            onSelected: (t) => setState(() => _theme = t),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SegmentedButton<_GalleryView>(
              segments: const [
                ButtonSegment(
                  value: _GalleryView.components,
                  label: Text('Components'),
                ),
                ButtonSegment(
                  value: _GalleryView.typography,
                  label: Text('Typography'),
                ),
              ],
              selected: {_view},
              onSelectionChanged: (s) => setState(() => _view = s.first),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          // The preview is rendered under its own Theme + FTheme so it reflects
          // exactly what an app screen would see for this (theme, brightness),
          // and its own Directionality so RTL can be previewed in isolation.
          Expanded(
            child: Theme(
              data: previewTheme,
              child: f.FTheme(
                data: dabblerForuiThemeData(previewTheme),
                child: Directionality(
                  textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
                  child: Builder(
                    builder: (context) => switch (_view) {
                      _GalleryView.components =>
                        _Preview(themeLabel: _labels[_theme]!),
                      _GalleryView.typography => const DabblerTypeSpecimen(),
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSwitcher extends StatelessWidget {
  const _ThemeSwitcher({
    required this.selected,
    required this.labels,
    required this.onSelected,
  });

  final DabblerTheme selected;
  final Map<DabblerTheme, String> labels;
  final ValueChanged<DabblerTheme> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          for (final t in DabblerTheme.values)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(labels[t]!),
                selected: selected == t,
                onSelected: (_) => onSelected(t),
              ),
            ),
        ],
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.themeLabel});

  final String themeLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tokens = context.dabbler;

    return Container(
      color: tokens.bgPrimary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Faux app bar -------------------------------------------------------
          _Surface(
            color: tokens.surfaceCard,
            border: tokens.borderDefault,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: tokens.brandPrimary,
                  child: Text(
                    themeLabel.substring(0, 1),
                    style: TextStyle(color: tokens.onBrand),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$themeLabel theme',
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'colorScheme + context.dabbler',
                        style: TextStyle(color: tokens.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.more_vert, color: tokens.textTertiary),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // CTAs ---------------------------------------------------------------
          const _SectionLabel('Actions'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                // Primary CTA — on-brand text from the token, so Bright renders
                // dark-on-orange instead of an illegible white-on-light.
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: tokens.brandPrimary,
                    foregroundColor: tokens.onBrand,
                  ),
                  child: const Text('Primary CTA'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                // Secondary / accent button — Sport & Social use dark onAccent.
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: tokens.accent,
                    foregroundColor: tokens.onAccent,
                  ),
                  child: const Text('Secondary'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.primary,
                  side: BorderSide(color: tokens.borderStrong),
                ),
                child: const Text('Outlined'),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(foregroundColor: colors.primary),
                child: const Text('Text'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status chips -------------------------------------------------------
          const _SectionLabel('Status'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip('Success', tokens.successSurface, tokens.onSuccess, tokens.success),
              _StatusChip('Warning', tokens.warningSurface, tokens.onWarning, tokens.warning),
              _StatusChip('Error', tokens.errorSurface, tokens.onError, tokens.error),
              _StatusChip('Info', tokens.infoSurface, tokens.onInfo, tokens.info),
            ],
          ),
          const SizedBox(height: 16),

          // Nested surfaces ----------------------------------------------------
          const _SectionLabel('Surfaces'),
          const SizedBox(height: 8),
          _Surface(
            color: tokens.bgSecondary,
            border: tokens.borderDefault,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('bgSecondary',
                    style: TextStyle(color: tokens.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                _Surface(
                  color: tokens.surfaceCard,
                  border: tokens.borderDefault,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Card on surfaceCard',
                        style: TextStyle(
                          color: tokens.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Neutrals are a faint tint of the primary — never pure '
                        'white or black.',
                        style: TextStyle(color: tokens.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tokens.bgTertiary,
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          border: Border.all(color: tokens.borderStrong),
                        ),
                        child: Text(
                          'bgTertiary + borderStrong',
                          style: TextStyle(color: tokens.textTertiary, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Material card (uses colorScheme roles) -----------------------------
          Card(
            child: ListTile(
              leading: Icon(Icons.palette_outlined, color: colors.primary),
              title: Text('Material Card', style: TextStyle(color: colors.onSurface)),
              subtitle: Text(
                'Driven by Theme.of(context).colorScheme',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Forui parity row ---------------------------------------------------
          const _SectionLabel('Forui parity'),
          const SizedBox(height: 8),
          f.FCard(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  f.FButton(
                    onPress: () {},
                    child: const Text('FButton'),
                  ),
                  const SizedBox(width: 12),
                  f.FBadge(child: const Text('FBadge')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: context.dabbler.textTertiary,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _Surface extends StatelessWidget {
  const _Surface({required this.color, required this.border, required this.child});

  final Color color;
  final Color border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.label, this.surface, this.onColor, this.dot);

  final String label;
  final Color surface;
  final Color onColor;
  final Color dot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 12, 6),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: onColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
