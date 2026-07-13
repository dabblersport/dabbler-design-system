// =============================================================================
// Dabbler — Theme Gallery (debug on native · public showcase on web)
// -----------------------------------------------------------------------------
// Visual acceptance check + showcase for the colour + typography system.
// Switchers cover all 7 themes × light/dark × LTR/RTL, driving four views:
//   • All          — everything below, stacked in one scroll (default)
//   • Roles        — Material ColorScheme + Dabbler token swatch grid
//   • App Preview  — a realistic phone-style screen mockup
//   • Typography   — the full Apple ramp specimen (EN + AR), driven dynamically
//                    by the DabblerType definitions
//
// Everything reads from Theme.of(context).colorScheme or context.dabbler — no
// hardcoded colours (the one exception is the spotlight badge, whose white text
// is mandated by the spec) and no hardcoded font sizes (DabblerType only).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as f;

import '../components/dabbler_button.dart';
import '../components/dabbler_card.dart';
import '../components/dabbler_inputs.dart';
import '../components/dabbler_surface.dart';
import '../components/dabbler_text_field.dart';
import '../theme/dabbler_colors.dart';
import '../theme/dabbler_forui_theme.dart';
import '../theme/dabbler_spacing.dart';
import '../theme/dabbler_theme_data.dart';
import '../theme/dabbler_type.dart';

class ThemeGalleryScreen extends StatefulWidget {
  const ThemeGalleryScreen({super.key});

  static const routeName = '/debug/theme-gallery';

  @override
  State<ThemeGalleryScreen> createState() => _ThemeGalleryScreenState();
}

enum _GalleryView {
  all,
  roles,
  appPreview,
  typography,
  spacing,
  buttons,
  inputs,
  cards,
}

class _ThemeGalleryScreenState extends State<ThemeGalleryScreen> {
  DabblerTheme _theme = DabblerTheme.main;
  Brightness _brightness = Brightness.light;
  _GalleryView _view = _GalleryView.all;
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
    // direction, so the previews match a real Arabic screen.
    final previewTheme = dabblerThemeData(
      _theme,
      _brightness,
      locale: Locale(_rtl ? 'ar' : 'en'),
    );
    final label = _labels[_theme]!;

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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SegmentedButton<_GalleryView>(
              segments: const [
                ButtonSegment(value: _GalleryView.all, label: Text('All')),
                ButtonSegment(value: _GalleryView.roles, label: Text('Roles')),
                ButtonSegment(
                  value: _GalleryView.appPreview,
                  label: Text('App Preview'),
                ),
                ButtonSegment(
                  value: _GalleryView.typography,
                  label: Text('Typography'),
                ),
                ButtonSegment(
                  value: _GalleryView.spacing,
                  label: Text('Spacing & Layout'),
                ),
                ButtonSegment(
                  value: _GalleryView.buttons,
                  label: Text('Buttons'),
                ),
                ButtonSegment(
                  value: _GalleryView.inputs,
                  label: Text('Inputs'),
                ),
                ButtonSegment(
                  value: _GalleryView.cards,
                  label: Text('Cards & Lists'),
                ),
              ],
              selected: {_view},
              onSelectionChanged: (s) => setState(() => _view = s.first),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          // Rendered under its own Theme + FTheme + Directionality so every view
          // reflects exactly what an app screen would see for this combination.
          Expanded(
            child: Theme(
              data: previewTheme,
              child: f.FTheme(
                data: dabblerForuiThemeData(previewTheme),
                child: Directionality(
                  textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
                  child: Builder(
                    builder: (context) => switch (_view) {
                      _GalleryView.all => _AllPanel(themeLabel: label),
                      _GalleryView.roles => const _RolesPanel(),
                      _GalleryView.appPreview =>
                        _AppPreviewPanel(themeLabel: label),
                      _GalleryView.typography => const _TypePanel(),
                      _GalleryView.spacing => const _SpacingPanel(),
                      _GalleryView.buttons => const _ButtonsPanel(),
                      _GalleryView.inputs => const _InputsPanel(),
                      _GalleryView.cards => const _CardsPanel(),
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

// -----------------------------------------------------------------------------
// View · All — everything stacked in one scroll
// -----------------------------------------------------------------------------

class _AllPanel extends StatelessWidget {
  const _AllPanel({required this.themeLabel});

  final String themeLabel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('Roles'),
          const SizedBox(height: 8),
          ...rolesGroups(context),
          const SizedBox(height: 24),
          const _SectionHeader('App Preview'),
          const SizedBox(height: 12),
          Center(child: _AppPreviewCard(themeLabel: themeLabel)),
          const SizedBox(height: 24),
          const _SectionHeader('Typography'),
          const SizedBox(height: 12),
          ...typeTiles(context),
          const SizedBox(height: 24),
          const _SectionHeader('Spacing & Layout'),
          const SizedBox(height: 12),
          ...spacingSections(context),
          const SizedBox(height: 24),
          const _SectionHeader('Buttons'),
          const SizedBox(height: 12),
          // Omit the live spinner here so the aggregated view can settle.
          ...buttonSections(context, animated: false),
          const SizedBox(height: 24),
          const _SectionHeader('Inputs'),
          const SizedBox(height: 12),
          const _InputsShowcase(),
          const SizedBox(height: 24),
          const _SectionHeader('Cards & Lists'),
          const SizedBox(height: 12),
          const _CardsShowcase(),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: DabblerType.headline.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
        letterSpacing: 0.4,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// View · Roles — Material ColorScheme + Dabbler token swatch grid
// -----------------------------------------------------------------------------

class _RolesPanel extends StatelessWidget {
  const _RolesPanel();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: rolesGroups(context),
    );
  }
}

/// Shared between the Roles view and the All view.
List<Widget> rolesGroups(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  final d = context.dabbler;
  return [
    _RoleGroup('Material roles', [
      _Swatch('primary', cs.primary, cs.onPrimary),
      _Swatch('secondary', cs.secondary, cs.onSecondary),
      _Swatch('tertiary', cs.tertiary, cs.onTertiary),
      _Swatch('error', cs.error, cs.onError),
      _Swatch('surface', cs.surface, cs.onSurface),
      _Swatch('surfaceVariant', cs.surfaceContainerHighest, cs.onSurfaceVariant),
      _Swatch('inverseSurface', cs.inverseSurface, cs.onInverseSurface),
      _Swatch('outline', cs.outline, cs.surface),
    ]),
    const SizedBox(height: 16),
    _RoleGroup('Dabbler tokens', [
      _Swatch('brandPrimary', d.brandPrimary, d.onBrand),
      _Swatch('accent', d.accent, d.onAccent),
      _Swatch('spotlight', d.spotlight, const Color(0xFFFFFFFF)),
      _Swatch('bgPrimary', d.bgPrimary, d.textPrimary),
      _Swatch('surfaceCard', d.surfaceCard, d.textPrimary),
      _Swatch('bgTertiary', d.bgTertiary, d.textSecondary),
      _Swatch('success', d.successSurface, d.onSuccess),
      _Swatch('warning', d.warningSurface, d.onWarning),
      _Swatch('error', d.errorSurface, d.onError),
      _Swatch('info', d.infoSurface, d.onInfo),
    ]),
  ];
}

class _RoleGroup extends StatelessWidget {
  const _RoleGroup(this.title, this.swatches);

  final String title;
  final List<Widget> swatches;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: DabblerType.caption2.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: swatches),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.bg, this.fg);

  final String name;
  final Color bg;
  final Color fg;

  String get _hex {
    final v = bg.toARGB32() & 0xFFFFFF;
    return '#${v.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: context.dabbler.borderDefault, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: DabblerType.caption1.copyWith(color: fg)),
          const SizedBox(height: 2),
          Text(_hex, style: DabblerType.caption2.copyWith(color: fg)),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// View · App Preview — a realistic phone-style screen mockup
// -----------------------------------------------------------------------------

class _AppPreviewPanel extends StatelessWidget {
  const _AppPreviewPanel({required this.themeLabel});

  final String themeLabel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(child: _AppPreviewCard(themeLabel: themeLabel)),
    );
  }
}

class _AppPreviewCard extends StatelessWidget {
  const _AppPreviewCard({required this.themeLabel});

  final String themeLabel;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final s = _MockStrings(isRtl);
    final mode = Theme.of(context).brightness == Brightness.dark ? 'Dark' : 'Light';

    return SizedBox(
      width: 320,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: d.borderDefault, width: 0.5),
            borderRadius: const BorderRadius.all(Radius.circular(18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1 · App bar
              Container(
                color: d.brandPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Text('Dabbler',
                        style: DabblerType.headline.copyWith(color: d.onBrand)),
                    const Spacer(),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '$themeLabel · $mode',
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        style: DabblerType.footnote
                            .copyWith(color: d.onBrand.withValues(alpha: 0.85)),
                      ),
                    ),
                  ],
                ),
              ),
              // 2 · Body
              Container(
                color: d.bgPrimary,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 3 · Game card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: d.surfaceCard,
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                        border: Border.all(color: d.borderDefault, width: 0.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.title,
                              style: DabblerType.headline
                                  .copyWith(color: d.textPrimary)),
                          const SizedBox(height: 4),
                          Text(s.meta,
                              style: DabblerType.footnote
                                  .copyWith(color: d.textSecondary)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _MockButton(
                                  label: s.join,
                                  bg: d.brandPrimary,
                                  fg: d.onBrand,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _MockButton(
                                label: s.invite,
                                bg: d.accent,
                                fg: d.onAccent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 4 · Status chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusChip(s.chips[0], d.successSurface, d.onSuccess, d.success),
                        _StatusChip(s.chips[1], d.warningSurface, d.onWarning, d.warning),
                        _StatusChip(s.chips[2], d.errorSurface, d.onError, d.error),
                        _StatusChip(s.chips[3], d.infoSurface, d.onInfo, d.info),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 5 · Footer
                    Row(
                      children: [
                        Expanded(
                          child: Text(s.footer,
                              style: DabblerType.footnote
                                  .copyWith(color: d.textSecondary)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 10, 5),
                          decoration: BoxDecoration(
                            color: d.spotlight,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(999)),
                          ),
                          child: Text(
                            s.badge,
                            // White-on-spotlight is mandated by the spec.
                            style: DabblerType.caption1
                                .copyWith(color: const Color(0xFFFFFFFF)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MockButton extends StatelessWidget {
  const _MockButton({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Text(label, style: DabblerType.headline.copyWith(color: fg)),
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
      padding: const EdgeInsetsDirectional.fromSTEB(8, 5, 10, 5),
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
          const SizedBox(width: 6),
          Text(label, style: DabblerType.caption1.copyWith(color: onColor)),
        ],
      ),
    );
  }
}

class _MockStrings {
  const _MockStrings(this.ar);
  final bool ar;

  String get title => ar ? 'خماسي يوم الثلاثاء' : 'Tuesday 5-a-side';
  String get meta => ar
      ? 'الخليج التجاري · ٧:٠٠ م · مكانان متاحان'
      : 'Business Bay · 7:00 PM · 2 spots left';
  String get join => ar ? 'انضم للعبة' : 'Join game';
  String get invite => ar ? 'دعوة' : 'Invite';
  String get footer => ar ? 'مباراتك ٤٧ هذا الموسم' : '47th game this season';
  String get badge => ar ? 'إنجاز' : 'Milestone';
  List<String> get chips => ar
      ? ['مؤكد', 'أماكن قليلة', 'أُلغيت', 'تم التحديث']
      : ['Confirmed', 'Spots low', 'Cancelled', 'Updated'];
}

// -----------------------------------------------------------------------------
// View · Typography — dynamic specimen of the full Apple ramp (EN + AR)
// -----------------------------------------------------------------------------

enum _TypeCat { title, headline, body, caption }

class _TypeTier {
  const _TypeTier(this.name, this.style, this.cat);
  final String name;
  final TextStyle style;
  final _TypeCat cat;
}

// Driven by the DabblerType definitions: size/leading/weight are read off the
// styles, so this stays correct if the ramp changes.
final List<_TypeTier> _typeTiers = [
  _TypeTier('Large Title', DabblerType.largeTitle, _TypeCat.title),
  _TypeTier('Title 1', DabblerType.title1, _TypeCat.title),
  _TypeTier('Title 2', DabblerType.title2, _TypeCat.title),
  _TypeTier('Title 3', DabblerType.title3, _TypeCat.title),
  _TypeTier('Headline', DabblerType.headline, _TypeCat.headline),
  _TypeTier('Body', DabblerType.body, _TypeCat.body),
  _TypeTier('Callout', DabblerType.callout, _TypeCat.body),
  _TypeTier('Subheadline', DabblerType.subheadline, _TypeCat.body),
  _TypeTier('Footnote', DabblerType.footnote, _TypeCat.caption),
  _TypeTier('Caption 1', DabblerType.caption1, _TypeCat.caption),
  _TypeTier('Caption 2', DabblerType.caption2, _TypeCat.caption),
];

String _enSample(_TypeCat c) => switch (c) {
      _TypeCat.title => 'Sport belongs to everyone',
      _TypeCat.headline => 'Tuesday 5-a-side',
      _TypeCat.body =>
        'Two spots left — join before kickoff and meet the regulars.',
      _TypeCat.caption => 'Updated 2 min ago',
    };

String _arSample(_TypeCat c) => switch (c) {
      _TypeCat.title => 'الرياضة لكل من يحضر',
      _TypeCat.headline => 'خماسي يوم الثلاثاء',
      _TypeCat.body => 'بقي مكانان فقط — انضم قبل البداية وقابل اللاعبين.',
      _TypeCat.caption => 'آخر تحديث قبل دقيقتين',
    };

String _typeSpec(_TypeTier t) {
  final size = t.style.fontSize!.round();
  final leading = (t.style.height! * t.style.fontSize!).round();
  final weight = t.style.fontWeight!.value;
  return '${t.name} · $size/$leading · w$weight';
}

/// One specimen tile (spec label + EN sample + AR sample).
class _TypeTile extends StatelessWidget {
  const _TypeTile(this.tier);
  final _TypeTier tier;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_typeSpec(tier), style: DabblerType.caption2.copyWith(color: muted)),
        const SizedBox(height: 6),
        Text(_enSample(tier.cat),
            style: tier.style.copyWith(color: d.textPrimary)),
        const SizedBox(height: 2),
        Text(
          _arSample(tier.cat),
          textDirection: TextDirection.rtl,
          style: DabblerType.arabic(tier.style).copyWith(color: d.textSecondary),
        ),
      ],
    );
  }
}

/// Shared between the Typography view and the All view.
List<Widget> typeTiles(BuildContext context) {
  final tiles = <Widget>[];
  for (var i = 0; i < _typeTiers.length; i++) {
    if (i > 0) tiles.add(const Divider(height: 28));
    tiles.add(_TypeTile(_typeTiers[i]));
  }
  return tiles;
}

class _TypePanel extends StatelessWidget {
  const _TypePanel();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: typeTiles(context),
    );
  }
}

// -----------------------------------------------------------------------------
// View · Spacing & Layout — spacing / radius / elevation / sizing tokens
// -----------------------------------------------------------------------------

class _SpacingPanel extends StatelessWidget {
  const _SpacingPanel();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: spacingSections(context),
    );
  }
}

/// Shared between the Spacing view and the All view. Driven by the token
/// definitions (DabblerSpacing.scale / DabblerRadius.scale), not hardcoded.
List<Widget> spacingSections(BuildContext context) {
  final cs = Theme.of(context).colorScheme;
  final d = context.dabbler;

  return [
    // Spacing scale — labelled bars.
    const _SubHead('Spacing · base 3'),
    const SizedBox(height: DabblerSpacing.stackDefault),
    for (final (name, value) in DabblerSpacing.scale)
      Padding(
        padding: const EdgeInsets.only(bottom: DabblerSpacing.stackTight),
        child: Row(
          children: [
            SizedBox(
              width: DabblerSpacing.space11 * 2,
              child: Text('$name · ${value.toInt()}',
                  style: DabblerType.caption1.copyWith(color: d.textSecondary)),
            ),
            Container(
              width: value,
              height: DabblerSpacing.space3,
              decoration: BoxDecoration(
                color: d.brandPrimary,
                borderRadius: DabblerRadius.smRadius,
              ),
            ),
          ],
        ),
      ),
    const SizedBox(height: DabblerSpacing.sectionGap),

    // Radius scale — labelled swatches.
    const _SubHead('Radius · base 3'),
    const SizedBox(height: DabblerSpacing.stackDefault),
    Wrap(
      spacing: DabblerSpacing.stackDefault,
      runSpacing: DabblerSpacing.stackDefault,
      children: [
        for (final (name, value) in DabblerRadius.scale)
          _RadiusSwatch(name: name, value: value),
      ],
    ),
    const SizedBox(height: DabblerSpacing.sectionGap),

    // Elevation — three cards, only level 2 floats.
    const _SubHead('Elevation · flat (only level 2 casts a shadow)'),
    const SizedBox(height: DabblerSpacing.stackDefault),
    const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ElevationCard(label: 'level0', shadows: DabblerElevation.level0, bordered: false),
        SizedBox(width: DabblerSpacing.stackDefault),
        _ElevationCard(label: 'level1', shadows: DabblerElevation.level1, bordered: true),
        SizedBox(width: DabblerSpacing.stackDefault),
        _ElevationCard(label: 'level2', shadows: DabblerElevation.level2, bordered: true),
      ],
    ),
    const SizedBox(height: DabblerSpacing.sectionGap),

    // Sizing readout.
    const _SubHead('Sizing'),
    const SizedBox(height: DabblerSpacing.stackDefault),
    Row(
      children: [
        Container(
          width: DabblerSizing.touchTargetMin,
          height: DabblerSizing.touchTargetMin,
          decoration: BoxDecoration(
            color: d.bgTertiary,
            borderRadius: DabblerRadius.mdRadius,
            border: Border.all(color: d.borderStrong),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.touch_app_outlined,
              size: DabblerSizing.iconMd, color: cs.primary),
        ),
        const SizedBox(width: DabblerSpacing.stackDefault),
        Expanded(
          child: Text('touchTargetMin · ${DabblerSizing.touchTargetMin.toInt()}',
              style: DabblerType.footnote.copyWith(color: d.textSecondary)),
        ),
      ],
    ),
    const SizedBox(height: DabblerSpacing.stackDefault),
    _BorderRow('borderHairline', DabblerSizing.borderHairline, d.borderStrong, d.textSecondary),
    const SizedBox(height: DabblerSpacing.stackTight),
    _BorderRow('borderDefault', DabblerSizing.borderDefault, d.borderStrong, d.textSecondary),
    const SizedBox(height: DabblerSpacing.stackDefault),
    Row(
      children: [
        for (final (name, size) in const [
          ('iconSm · 18', DabblerSizing.iconSm),
          ('iconMd · 24', DabblerSizing.iconMd),
          ('iconLg · 30', DabblerSizing.iconLg),
        ])
          Padding(
            padding: const EdgeInsetsDirectional.only(end: DabblerSpacing.sectionGap),
            child: Column(
              children: [
                Icon(Icons.star_rounded, size: size, color: cs.primary),
                const SizedBox(height: DabblerSpacing.stackTight),
                Text(name,
                    style: DabblerType.caption2.copyWith(color: d.textTertiary)),
              ],
            ),
          ),
      ],
    ),
  ];
}

class _SubHead extends StatelessWidget {
  const _SubHead(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: DabblerType.caption2.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _RadiusSwatch extends StatelessWidget {
  const _RadiusSwatch({required this.name, required this.value});
  final String name;
  final double value;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: DabblerSpacing.space11 + DabblerSpacing.space5,
          height: DabblerSpacing.space11,
          decoration: BoxDecoration(
            color: d.surfaceCard,
            borderRadius: BorderRadius.all(Radius.circular(value)),
            border: Border.all(color: d.borderStrong, width: DabblerSizing.borderHairline),
          ),
        ),
        const SizedBox(height: DabblerSpacing.stackTight),
        Text('$name · ${value.toInt()}',
            style: DabblerType.caption2.copyWith(color: d.textTertiary)),
      ],
    );
  }
}

class _ElevationCard extends StatelessWidget {
  const _ElevationCard({
    required this.label,
    required this.shadows,
    required this.bordered,
  });

  final String label;
  final List<BoxShadow> shadows;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: DabblerSpacing.space11 * 2,
          height: DabblerSpacing.space8 * 3,
          decoration: BoxDecoration(
            color: d.surfaceCard,
            borderRadius: DabblerRadius.lgRadius,
            border: bordered
                ? Border.all(color: d.borderDefault, width: DabblerSizing.borderHairline)
                : null,
            boxShadow: shadows,
          ),
        ),
        const SizedBox(height: DabblerSpacing.stackTight),
        Text(label, style: DabblerType.caption2.copyWith(color: d.textTertiary)),
      ],
    );
  }
}

class _BorderRow extends StatelessWidget {
  const _BorderRow(this.name, this.width, this.lineColor, this.textColor);
  final String name;
  final double width;
  final Color lineColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: DabblerSpacing.space11 * 2,
          child: Text('$name · $width',
              style: DabblerType.caption1.copyWith(color: textColor)),
        ),
        Expanded(child: Container(height: width, color: lineColor)),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// View · Buttons — every DabblerButton variant / size / state, enum-driven
// -----------------------------------------------------------------------------

class _ButtonsPanel extends StatelessWidget {
  const _ButtonsPanel();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: buttonSections(context),
    );
  }
}

/// A button with a small caption below it (state / variant / size name).
class _ButtonCell extends StatelessWidget {
  const _ButtonCell({required this.caption, required this.child});
  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: DabblerSpacing.stackTight),
        Text(
          caption,
          style: DabblerType.caption2
              .copyWith(color: context.dabbler.textTertiary),
        ),
      ],
    );
  }
}

/// Shared between the Buttons view and the All view. Everything is driven by the
/// [DabblerButtonVariant] / [DabblerButtonSize] enums, so new variants or sizes
/// appear here automatically.
///
/// [animated] gates the live loading spinner: the dedicated Buttons tab shows it
/// (true), while the aggregated "All" view omits it (false) so the screen can
/// settle for `pumpAndSettle` in tests.
List<Widget> buttonSections(BuildContext context, {bool animated = true}) {
  void noop() {}

  Wrap row(List<Widget> children) => Wrap(
        spacing: DabblerSpacing.stackDefault,
        runSpacing: DabblerSpacing.stackDefault,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      );

  return [
    // All variants at the default (medium) size.
    const _SubHead('Variants · default size'),
    const SizedBox(height: DabblerSpacing.stackDefault),
    row([
      for (final v in DabblerButtonVariant.values)
        _ButtonCell(
          caption: v.name,
          child: v == DabblerButtonVariant.icon
              ? DabblerButton.icon(icon: Icons.favorite_border, onPressed: noop)
              : DabblerButton(label: _titleCase(v.name), variant: v, onPressed: noop),
        ),
    ]),
    const SizedBox(height: DabblerSpacing.sectionGap),

    // All sizes (filled).
    const _SubHead('Sizes · filled'),
    const SizedBox(height: DabblerSpacing.stackDefault),
    row([
      for (final s in DabblerButtonSize.values)
        _ButtonCell(
          caption: s.name,
          child: DabblerButton(label: _titleCase(s.name), size: s, onPressed: noop),
        ),
    ]),
    const SizedBox(height: DabblerSpacing.sectionGap),

    // The four states. "Pressed" is transient — hold the button to see it.
    const _SubHead('States'),
    const SizedBox(height: DabblerSpacing.stackDefault),
    row([
      _ButtonCell(
        caption: 'default',
        child: DabblerButton(label: 'Default', onPressed: noop),
      ),
      _ButtonCell(
        caption: 'pressed (hold)',
        child: DabblerButton(label: 'Pressed', onPressed: noop),
      ),
      // onPressed defaults to null → disabled.
      const _ButtonCell(
        caption: 'disabled',
        child: DabblerButton(label: 'Disabled'),
      ),
      if (animated)
        _ButtonCell(
          caption: 'loading',
          child:
              DabblerButton(label: 'Loading', isLoading: true, onPressed: noop),
        ),
    ]),
    const SizedBox(height: DabblerSpacing.sectionGap),

    // Leading / trailing icons — placement mirrors under RTL (start/end).
    const _SubHead('With icons'),
    const SizedBox(height: DabblerSpacing.stackDefault),
    row([
      DabblerButton(label: 'Add', leadingIcon: Icons.add, onPressed: noop),
      DabblerButton(
        label: 'Next',
        trailingIcon: Icons.arrow_forward,
        variant: DabblerButtonVariant.tonal,
        onPressed: noop,
      ),
    ]),
    const SizedBox(height: DabblerSpacing.sectionGap),

    // Full-width CTA.
    const _SubHead('Full width'),
    const SizedBox(height: DabblerSpacing.stackDefault),
    DabblerButton(
      label: 'Join game',
      leadingIcon: Icons.sports_soccer,
      fullWidth: true,
      onPressed: noop,
    ),
  ];
}

String _titleCase(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

// -----------------------------------------------------------------------------
// View · Inputs — text fields + selection controls, shown in EN and AR/RTL
// -----------------------------------------------------------------------------

class _InputsPanel extends StatelessWidget {
  const _InputsPanel();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: _InputsShowcase(),
    );
  }
}

/// Renders the whole input set twice — once LTR/English, once RTL/Arabic — so
/// mirroring (prefix/suffix side, clear/toggle side, cursor) is visible at a
/// glance regardless of the gallery's global direction toggle.
class _InputsShowcase extends StatelessWidget {
  const _InputsShowcase();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SubHead('English · LTR'),
        SizedBox(height: DabblerSpacing.stackDefault),
        Directionality(
          textDirection: TextDirection.ltr,
          child: _InputsBlock(strings: _InputStrings.en),
        ),
        SizedBox(height: DabblerSpacing.sectionGap),
        Divider(height: 1),
        SizedBox(height: DabblerSpacing.sectionGap),
        _SubHead('العربية · RTL'),
        SizedBox(height: DabblerSpacing.stackDefault),
        Directionality(
          textDirection: TextDirection.rtl,
          child: _InputsBlock(strings: _InputStrings.ar),
        ),
      ],
    );
  }
}

/// One localized copy of the inputs. Holds its own interactive state so the two
/// language copies don't share checkbox/switch/search values.
class _InputsBlock extends StatefulWidget {
  const _InputsBlock({required this.strings});
  final _InputStrings strings;

  @override
  State<_InputsBlock> createState() => _InputsBlockState();
}

class _InputsBlockState extends State<_InputsBlock> {
  late final TextEditingController _filled =
      TextEditingController(text: widget.strings.sampleValue);
  late final TextEditingController _search =
      TextEditingController(text: widget.strings.sampleValue);

  bool _checkbox = false;
  int _radio = 0;
  bool _switch = true;

  @override
  void dispose() {
    _filled.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;

    Widget gap() => const SizedBox(height: DabblerSpacing.stackDefault);

    // A field per variant — driven by the enum so new variants appear here.
    Widget variantField(DabblerTextFieldVariant v) => switch (v) {
          DabblerTextFieldVariant.standard =>
            DabblerTextField(label: s.name, hint: s.nameHint, helperText: s.helper),
          DabblerTextFieldVariant.multiline => DabblerTextField(
              variant: DabblerTextFieldVariant.multiline,
              label: s.notes,
              hint: s.notesHint,
              minLines: 3,
              maxLines: 5,
            ),
          DabblerTextFieldVariant.search =>
            DabblerTextField.search(hint: s.searchHint, controller: _search),
          DabblerTextFieldVariant.password =>
            DabblerTextField.password(label: s.password, hint: s.passwordHint),
        };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Variants.
        _MiniHead(s.variants),
        gap(),
        for (final v in DabblerTextFieldVariant.values) ...[
          variantField(v),
          gap(),
        ],
        const SizedBox(height: DabblerSpacing.stackDefault),

        // States.
        _MiniHead(s.states),
        gap(),
        DabblerTextField(label: s.stateDefault, hint: s.nameHint),
        gap(),
        DabblerTextField(label: s.stateFilled, controller: _filled),
        gap(),
        DabblerTextField(label: s.stateError, hint: s.nameHint, errorText: s.error),
        gap(),
        DabblerTextField(label: s.stateDisabled, hint: s.nameHint, enabled: false),
        const SizedBox(height: DabblerSpacing.stackDefault),

        // Prefix + suffix.
        _MiniHead(s.prefixSuffix),
        gap(),
        DabblerTextField(
          label: s.name,
          hint: s.nameHint,
          prefixIcon: Icons.person_outline,
          suffixIcon: Icons.info_outline,
          onSuffixTap: () {},
        ),
        const SizedBox(height: DabblerSpacing.stackDefault),

        // Selection controls.
        _MiniHead(s.selection),
        gap(),
        Wrap(
          spacing: DabblerSpacing.sectionGap,
          runSpacing: DabblerSpacing.stackDefault,
          children: [
            _labeled(s.checkbox, [
              DabblerCheckbox(
                value: _checkbox,
                onChanged: (v) => setState(() => _checkbox = v),
              ),
              DabblerCheckbox(value: true, onChanged: (_) {}),
              const DabblerCheckbox(value: true), // disabled
            ]),
            _labeled(s.radio, [
              for (var i = 0; i < 3; i++)
                DabblerRadio<int>(
                  value: i,
                  groupValue: _radio,
                  onChanged: i == 2 ? null : (v) => setState(() => _radio = v),
                ),
            ]),
            _labeled(s.switchLabel, [
              DabblerSwitch(
                value: _switch,
                onChanged: (v) => setState(() => _switch = v),
              ),
              DabblerSwitch(value: false, onChanged: (_) {}),
              const DabblerSwitch(value: true), // disabled
            ]),
          ],
        ),
      ],
    );
  }

  Widget _labeled(String caption, List<Widget> controls) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          caption,
          style: DabblerType.caption2.copyWith(color: context.dabbler.textTertiary),
        ),
        const SizedBox(height: DabblerSpacing.stackTight),
        Row(mainAxisSize: MainAxisSize.min, children: controls),
      ],
    );
  }
}

class _MiniHead extends StatelessWidget {
  const _MiniHead(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: DabblerType.subheadline
          .copyWith(color: context.dabbler.textSecondary),
    );
  }
}

/// Localized specimen strings for the inputs block.
class _InputStrings {
  const _InputStrings({
    required this.variants,
    required this.states,
    required this.prefixSuffix,
    required this.selection,
    required this.name,
    required this.nameHint,
    required this.helper,
    required this.error,
    required this.notes,
    required this.notesHint,
    required this.searchHint,
    required this.password,
    required this.passwordHint,
    required this.sampleValue,
    required this.stateDefault,
    required this.stateFilled,
    required this.stateError,
    required this.stateDisabled,
    required this.checkbox,
    required this.radio,
    required this.switchLabel,
  });

  final String variants,
      states,
      prefixSuffix,
      selection,
      name,
      nameHint,
      helper,
      error,
      notes,
      notesHint,
      searchHint,
      password,
      passwordHint,
      sampleValue,
      stateDefault,
      stateFilled,
      stateError,
      stateDisabled,
      checkbox,
      radio,
      switchLabel;

  static const en = _InputStrings(
    variants: 'Variants',
    states: 'States',
    prefixSuffix: 'Prefix + suffix',
    selection: 'Selection controls',
    name: 'Full name',
    nameHint: 'Enter your name',
    helper: 'As printed on your ID',
    error: 'This field is required',
    notes: 'Notes',
    notesHint: 'Add any details…',
    searchHint: 'Search games',
    password: 'Password',
    passwordHint: 'Your password',
    sampleValue: 'Ada Lovelace',
    stateDefault: 'Default',
    stateFilled: 'Filled',
    stateError: 'Error',
    stateDisabled: 'Disabled',
    checkbox: 'Checkbox',
    radio: 'Radio',
    switchLabel: 'Switch',
  );

  static const ar = _InputStrings(
    variants: 'الأنواع',
    states: 'الحالات',
    prefixSuffix: 'أيقونة بادئة ولاحقة',
    selection: 'عناصر الاختيار',
    name: 'الاسم الكامل',
    nameHint: 'أدخل اسمك',
    helper: 'كما هو مكتوب في الهوية',
    error: 'هذا الحقل مطلوب',
    notes: 'ملاحظات',
    notesHint: 'أضف أي تفاصيل…',
    searchHint: 'ابحث عن مباريات',
    password: 'كلمة المرور',
    passwordHint: 'كلمة المرور',
    sampleValue: 'آدا لوفلايس',
    stateDefault: 'افتراضي',
    stateFilled: 'ممتلئ',
    stateError: 'خطأ',
    stateDisabled: 'معطّل',
    checkbox: 'مربع اختيار',
    radio: 'زر اختيار',
    switchLabel: 'مفتاح',
  );
}

// -----------------------------------------------------------------------------
// View · Cards & Lists — cards, sections, and list tiles in EN and AR/RTL
// -----------------------------------------------------------------------------

class _CardsPanel extends StatelessWidget {
  const _CardsPanel();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: _CardsShowcase(),
    );
  }
}

/// The whole card/list set, rendered once LTR/English and once RTL/Arabic so the
/// divider inset and chevron mirroring are visible at a glance.
class _CardsShowcase extends StatelessWidget {
  const _CardsShowcase();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SubHead('English · LTR'),
        SizedBox(height: DabblerSpacing.stackDefault),
        Directionality(
          textDirection: TextDirection.ltr,
          child: _CardsBlock(ar: false),
        ),
        SizedBox(height: DabblerSpacing.sectionGap),
        Divider(height: 1),
        SizedBox(height: DabblerSpacing.sectionGap),
        _SubHead('العربية · RTL'),
        SizedBox(height: DabblerSpacing.stackDefault),
        Directionality(
          textDirection: TextDirection.rtl,
          child: _CardsBlock(ar: true),
        ),
      ],
    );
  }
}

class _CardsBlock extends StatefulWidget {
  const _CardsBlock({required this.ar});
  final bool ar;

  @override
  State<_CardsBlock> createState() => _CardsBlockState();
}

class _CardsBlockState extends State<_CardsBlock> {
  bool _switch = true;

  String _t(String en, String ar) => widget.ar ? ar : en;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;

    Widget gap() => const SizedBox(height: DabblerSpacing.stackDefault);

    String variantName(DabblerCardVariant v) => switch (v) {
          DabblerCardVariant.standard => _t('Standard', 'قياسي'),
          DabblerCardVariant.interactive => _t('Interactive (tap)', 'تفاعلي (اضغط)'),
          DabblerCardVariant.outlined => _t('Outlined', 'محدّد'),
          DabblerCardVariant.filled => _t('Filled', 'ممتلئ'),
          DabblerCardVariant.selected => _t('Selected', 'محدَّد'),
        };

    Widget variantCard(DabblerCardVariant v) => DabblerCard(
          variant: v,
          onTap: v == DabblerCardVariant.interactive ? () {} : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(variantName(v),
                  style: DabblerType.headline.copyWith(color: d.textPrimary)),
              const SizedBox(height: DabblerSpacing.stackTight),
              Text(
                _t('Separation via tint + border, no shadow.',
                    'الفصل عبر التدرّج والحدود، بلا ظل.'),
                style: DabblerType.footnote.copyWith(color: d.textSecondary),
              ),
            ],
          ),
        );

    Widget badge(String text) => Container(
          padding: const EdgeInsetsDirectional.symmetric(
            horizontal: DabblerSpacing.space2, // 6
            vertical: DabblerSpacing.space1, // 3
          ),
          decoration: BoxDecoration(
            color: d.brandPrimary,
            borderRadius: DabblerRadius.pillRadius,
          ),
          // Mark colour is onBrand (dark in Bright/Sport), never hardcoded white.
          child: Text(text,
              style: DabblerType.caption2.copyWith(color: d.onBrand)),
        );

    Widget avatar(String initials) => CircleAvatar(
          radius: DabblerSpacing.space9 / 2, // 15 → fits the 30 leading lane
          backgroundColor: d.bgTertiary,
          child: Text(initials,
              style: DabblerType.caption1.copyWith(color: d.textSecondary)),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Variants — driven by the enum.
        _MiniHead(_t('Card variants', 'أنواع البطاقات')),
        gap(),
        for (final v in DabblerCardVariant.values) ...[
          variantCard(v),
          gap(),
        ],
        const SizedBox(height: DabblerSpacing.stackDefault),

        // Nested tonal ladder — filled card inside a standard card, no shadow.
        _MiniHead(_t('Nested surfaces (flat ladder)', 'أسطح متداخلة (تدرّج مسطّح)')),
        gap(),
        DabblerCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_t('Standard card', 'بطاقة قياسية'),
                  style: DabblerType.headline.copyWith(color: d.textPrimary)),
              gap(),
              DabblerCard(
                variant: DabblerCardVariant.filled,
                child: Text(
                  _t('Filled card nested inside — reads as a distinct layer.',
                      'بطاقة ممتلئة بالداخل — تظهر كطبقة مستقلة.'),
                  style: DabblerType.footnote.copyWith(color: d.textSecondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DabblerSpacing.sectionGap),

        // Section with a title + "See all" action.
        DabblerSurfaceSection(
          title: _t('Upcoming games', 'المباريات القادمة'),
          subtitle: _t('This week', 'هذا الأسبوع'),
          action: DabblerButton(
            label: _t('See all', 'عرض الكل'),
            variant: DabblerButtonVariant.text,
            size: DabblerButtonSize.small,
            onPressed: () {},
          ),
          children: [
            DabblerCard(
              variant: DabblerCardVariant.interactive,
              onTap: () {},
              padding: EdgeInsets.zero,
              child: DabblerListTile(
                leading: Icon(Icons.sports_soccer,
                    size: DabblerSizing.iconMd, color: d.textSecondary),
                title: _t('Tuesday 5-a-side', 'خماسي الثلاثاء'),
                subtitle: _t('Business Bay · 7:00 PM', 'الخليج التجاري · ٧:٠٠ م'),
                trailing: const DabblerChevron(),
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: DabblerSpacing.sectionGap),

        // List tiles — leading / trailing variety + dense.
        _MiniHead(_t('List tiles', 'عناصر القائمة')),
        gap(),
        DabblerCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              DabblerListTile(
                leading: Icon(Icons.event,
                    size: DabblerSizing.iconMd, color: d.textSecondary),
                title: _t('With icon + chevron', 'أيقونة + سهم'),
                subtitle: _t('Leading icon, trailing chevron', 'أيقونة بادئة وسهم لاحق'),
                trailing: const DabblerChevron(),
                onTap: () {},
                showDivider: true,
              ),
              DabblerListTile(
                leading: avatar(widget.ar ? 'أ' : 'AL'),
                title: _t('With avatar + badge', 'صورة + شارة'),
                subtitle: _t('Leading avatar', 'صورة بادئة'),
                trailing: badge('3'),
                onTap: () {},
                showDivider: true,
              ),
              DabblerListTile(
                leading: Icon(Icons.notifications_outlined,
                    size: DabblerSizing.iconMd, color: d.textSecondary),
                title: _t('With switch', 'مع مفتاح'),
                trailing: DabblerSwitch(
                  value: _switch,
                  onChanged: (v) => setState(() => _switch = v),
                ),
              ),
            ],
          ),
        ),
        gap(),
        _MiniHead(_t('Dense · selected · disabled', 'كثيف · محدَّد · معطّل')),
        gap(),
        DabblerCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              DabblerListTile(
                dense: true,
                leading: Icon(Icons.tag,
                    size: DabblerSizing.iconMd, color: d.textSecondary),
                title: _t('Dense tile', 'عنصر كثيف'),
                trailing: const DabblerChevron(),
                onTap: () {},
                showDivider: true,
              ),
              DabblerListTile(
                selected: true,
                leading: Icon(Icons.check_circle_outline,
                    size: DabblerSizing.iconMd, color: d.brandPrimary),
                title: _t('Selected tile', 'عنصر محدَّد'),
                trailing: const DabblerChevron(),
                onTap: () {},
                showDivider: true,
              ),
              DabblerListTile(
                enabled: false,
                leading: Icon(Icons.block,
                    size: DabblerSizing.iconMd, color: d.textSecondary),
                title: _t('Disabled tile', 'عنصر معطّل'),
                trailing: const DabblerChevron(),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}
