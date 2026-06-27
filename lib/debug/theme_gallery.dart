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

enum _GalleryView { all, roles, appPreview, typography }

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
