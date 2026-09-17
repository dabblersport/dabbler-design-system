/// The gallery's page language — the design's own specimen-page chrome,
/// rebuilt as widgets.
///
/// ## Why this file exists
///
/// The gallery used to be a Material `Scaffold` + `AppBar` + `ListTile` index
/// on a dark canvas. It looked like a Flutter sample, which is the one thing a
/// design system gallery must not look like: a reviewer judging the system was
/// judging Material's chrome with Dabbler components sitting inside it.
///
/// The design already publishes its own answer. Every `*.card.html` specimen
/// page in the design source is composed the same way, and these widgets are
/// that composition, one to one:
///
/// | design source | here |
/// |---|---|
/// | `body{background:var(--surface-page);padding:20px}` | [GalleryPaper] |
/// | `.hd` / `Group`'s label — 11px, `.08em`, uppercase, 700, `--muted` | [GalleryGroup] |
/// | `Group`'s body — `flex;gap:14;wrap` | [GalleryGroup.children] |
/// | `.usage` — 12px/1.5, `--ink-soft`, max-width 640 | [GalleryUsage] |
/// | `.usage b` — `--ink`, 600 | `**bold**` in [GalleryUsage.markup] |
/// | `.usage code` — `--surface-sunken`, radius 4, 12px mono | `` `code` `` in [GalleryUsage.markup] |
/// | `section{border-bottom:1px solid var(--outline-card)}` | [GalleryRule] |
///
/// ## Every colour comes from [DabblerColors]
///
/// Nothing here reads `Theme.of(context)` for paint (D-017), and nothing paints
/// a literal. The design's page chrome is itself built from the same neutral
/// ramp the components use, so the mapping is exact:
///
/// - `--surface-page` → [DabblerColors.bgPrimary]
/// - `--surface-card` → [DabblerColors.surfaceCard]
/// - `--surface-sunken` → [DabblerColors.surfaceSunken]
/// - `--outline-card` → [DabblerColors.borderDefault]
/// - `--ink` → [DabblerColors.textPrimary]
/// - `--ink-soft` → [DabblerColors.textSecondary]
/// - `--muted` → [DabblerColors.textTertiary]
///
/// That is what makes the chrome follow the theme switcher: the page repaints
/// under all fourteen `(theme, brightness)` pairs for free, where a hardcoded
/// cream page would have stayed cream in dark mode.
///
/// ## Spacing is snapped to the base-3 grid
///
/// The design's harness pages use raw CSS pixels for their own furniture —
/// `gap:26`, `gap:14`, `gap:10`, `padding:20` — none of which sit on the
/// system's base-3 grid. These widgets use the nearest [DabblerSpacing] step
/// (24 / 15 / 9 / 24) rather than reproducing off-grid values, because this is
/// the gallery's own chrome and not a component specimen. The largest
/// divergence is 2px.
library;

import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// The monospace stack the design's `code` and `.mono` rules ask for
/// (`ui-monospace,monospace`), spelled as a Flutter fallback chain.
const List<String> _monoFallback = <String>[
  'ui-monospace',
  'SFMono-Regular',
  'SF Mono',
  'Menlo',
  'Consolas',
  'monospace',
];

/// The page's inherited text style.
///
/// **Load-bearing, and the reason is not obvious.** A `Text` with no
/// [DefaultTextStyle] ancestor falls back to [DefaultTextStyle.fallback], whose
/// style carries `decoration: TextDecoration.underline` in a bright yellow —
/// Flutter's debug marker for unstyled text. `Scaffold` used to hide that,
/// because it builds a `Material`, and `Material` installs a
/// [DefaultTextStyle]. Dropping `Scaffold` for [GalleryPaper] dropped that too,
/// and every label on the gallery came back underlined in yellow, including
/// inside the components' own specimens.
///
/// So the gallery installs its own, from its own type ramp. Text inheritance is
/// a mechanism, not a Material appearance: the style below is [DabblerType] and
/// [DabblerColors], and nothing is read off `ThemeData`.
TextStyle galleryTextStyle(BuildContext context) => DabblerType.body
    .resolveForDirection(Directionality.of(context))
    .copyWith(
      color: DabblerColors.of(context).textPrimary,
      decoration: TextDecoration.none,
    );

/// The gallery's page surface: warm paper, edge to edge, scrolling.
///
/// This is what replaces `Scaffold`. It is deliberately not one: `Scaffold`
/// paints `ThemeData.scaffoldBackgroundColor` and brings Material's own
/// surface semantics with it, and the whole point of the rebuild is that the
/// page is the design's paper rather than Material's canvas.
class GalleryPaper extends StatelessWidget {
  /// Creates a page.
  const GalleryPaper({
    super.key,
    required this.child,
    this.header,
    this.scrollController,
  });

  /// The page body, laid out below [header].
  final Widget child;

  /// The fixed row above the scrolling body — the page's title and its
  /// controls. It does not scroll away, which is the one thing the old
  /// `AppBar` was doing that a reviewer actually wanted.
  final Widget? header;

  /// Optional controller, so a screen can restore scroll position.
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return DefaultTextStyle(
      style: galleryTextStyle(context),
      child: ColoredBox(
        color: colors.bgPrimary,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ?header,
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    DabblerSpacing.space8,
                    DabblerSpacing.space6,
                    DabblerSpacing.space8,
                    DabblerSpacing.space11,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.topStart,
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The page's title row: the specimen page's name and subtitle, with whatever
/// controls belong beside it.
///
/// The design source carries exactly these two strings on every specimen page,
/// in its `@dsCard name=… subtitle=…` header comment. They are set in the
/// display face at title-3, over a hairline — not in an `AppBar`.
class GalleryPageHeader extends StatelessWidget {
  /// Creates a header.
  const GalleryPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  /// The page's name.
  final String title;

  /// One line on what the page holds.
  final String? subtitle;

  /// Shown before [title] — the back affordance on an entry screen.
  final Widget? leading;

  /// Shown at the end of the row — the theme switcher.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgPrimary,
        border: Border(bottom: BorderSide(color: colors.borderDefault)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          DabblerSpacing.space8,
          DabblerSpacing.space6,
          DabblerSpacing.space8,
          DabblerSpacing.space6,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (leading != null) ...<Widget>[
              leading!,
              const SizedBox(width: DabblerSpacing.space4),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    title,
                    style: DabblerType.title3
                        .resolveForDirection(direction)
                        .copyWith(color: colors.textPrimary),
                  ),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: DabblerSpacing.space1),
                    Text(
                      subtitle!,
                      style: DabblerType.caption1
                          .resolveForDirection(direction)
                          .copyWith(color: colors.textTertiary, height: 1.5),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: DabblerSpacing.space4),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A labelled group of specimens — the design's `Group`.
///
/// The label is the treatment the design uses everywhere it names a band of
/// specimens (`SHELLS`, `KIT COMPOSITIONS`, `TICKET`, `BENTO TILES`): 11px,
/// `0.08em` tracking, uppercase, weight 700, in `--muted`.
class GalleryGroup extends StatelessWidget {
  /// Creates a group.
  const GalleryGroup({
    super.key,
    required this.name,
    required this.children,
    this.wrap = true,
  });

  /// The band's name. Rendered uppercase; pass it in natural case.
  final String name;

  /// The specimens.
  final List<Widget> children;

  /// Whether the specimens flow in a wrapping row (the design's default) or
  /// stack in a column, for specimens too wide to sit beside anything.
  final bool wrap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GallerySectionLabel(name),
        const SizedBox(height: DabblerSpacing.space3),
        if (wrap)
          Wrap(
            spacing: DabblerSpacing.space5,
            runSpacing: DabblerSpacing.space5,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: children,
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int i = 0; i < children.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(height: DabblerSpacing.space5),
                children[i],
              ],
            ],
          ),
      ],
    );
  }
}

/// The small letterspaced uppercase band label, on its own.
///
/// Exposed separately from [GalleryGroup] because the index uses it to head a
/// catalogue section that is not a row of specimens.
class GallerySectionLabel extends StatelessWidget {
  /// Creates a label.
  const GallerySectionLabel(this.text, {super.key});

  /// The label. Rendered uppercase.
  final String text;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Text(
      text.toUpperCase(),
      style: DabblerType.caption2
          .resolveForDirection(Directionality.of(context))
          .copyWith(
            color: colors.textTertiary,
            fontWeight: FontWeight.w700,
            // `.08em` at 11px.
            letterSpacing: 0.88,
          ),
    );
  }
}

/// The explanatory prose that sits under a band of specimens — the design's
/// `.usage` paragraph.
///
/// Takes the design's own two inline treatments as a tiny markup, so a call
/// site reads like the HTML it is replicating:
///
/// ```dart
/// GalleryUsage('**Card** — the merged card shell. Pass `onClick` for a tap.')
/// ```
///
/// `**…**` is `<b>` (ink, weight 600) and `` `…` `` is `<code>` (a sunken chip
/// in monospace). Nothing else is markup; a stray `*` or backtick renders as
/// itself.
class GalleryUsage extends StatelessWidget {
  /// Creates a usage paragraph.
  const GalleryUsage(this.markup, {super.key});

  /// The prose, in the two-token markup described above.
  final String markup;

  /// The design's `.usage{max-width:640px}`.
  static const double maxWidth = 640;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final TextStyle base = DabblerType.caption1
        .resolveForDirection(direction)
        .copyWith(color: colors.textSecondary, height: 1.5);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: maxWidth),
      child: Text.rich(
        TextSpan(children: _spans(markup, base, colors)),
        style: base,
      ),
    );
  }
}

/// Splits [markup] into the plain, bold and code runs the design draws.
List<InlineSpan> _spans(String markup, TextStyle base, DabblerColors colors) {
  final RegExp pattern = RegExp(r'\*\*(.+?)\*\*|`([^`]+)`');
  final List<InlineSpan> spans = <InlineSpan>[];
  int cursor = 0;

  for (final RegExpMatch match in pattern.allMatches(markup)) {
    if (match.start > cursor) {
      spans.add(TextSpan(text: markup.substring(cursor, match.start)));
    }
    final String? bold = match.group(1);
    if (bold != null) {
      spans.add(
        TextSpan(
          text: bold,
          style: base.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      spans.add(_codeChip(match.group(2)!, base, colors));
    }
    cursor = match.end;
  }
  if (cursor < markup.length) {
    spans.add(TextSpan(text: markup.substring(cursor)));
  }
  return spans;
}

/// `.usage code` — a sunken chip, radius 4, 1px/4px padding, 12px mono.
InlineSpan _codeChip(String code, TextStyle base, DabblerColors colors) {
  return WidgetSpan(
    alignment: PlaceholderAlignment.middle,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Text(
        code,
        style: base.copyWith(
          fontFamily: _monoFallback.first,
          fontFamilyFallback: _monoFallback.sublist(1),
          height: 1.2,
        ),
      ),
    ),
  );
}

/// Monospace metadata — the design's `.mono`: 11px mono in `--muted`.
class GalleryMono extends StatelessWidget {
  /// Creates a mono line.
  const GalleryMono(this.text, {super.key});

  /// The text.
  final String text;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Text(
      text,
      style: DabblerType.caption2
          .resolveForDirection(Directionality.of(context))
          .copyWith(
            color: colors.textTertiary,
            fontFamily: _monoFallback.first,
            fontFamilyFallback: _monoFallback.sublist(1),
          ),
    );
  }
}

/// The hairline the design puts between `section`s — 1px in `--outline-card`.
///
/// Not `Divider`: that is a Material appearance widget and reads the enclosing
/// `DividerTheme` for its colour and thickness.
class GalleryRule extends StatelessWidget {
  /// Creates a rule.
  const GalleryRule({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: ColoredBox(color: DabblerColors.of(context).borderDefault),
    );
  }
}

/// A vertical run of bands with the design's inter-group air, and the section
/// hairline where one is asked for.
class GallerySections extends StatelessWidget {
  /// Creates a run of sections.
  const GallerySections({
    super.key,
    required this.children,
    this.ruled = false,
  });

  /// The bands, top to bottom.
  final List<Widget> children;

  /// Whether to draw the design's `section` hairline between bands. The
  /// specimen pages leave it off; the guideline pages turn it on.
  final bool ruled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < children.length; i++) ...<Widget>[
          if (i > 0) ...<Widget>[
            const SizedBox(height: DabblerSpacing.space8),
            if (ruled) ...<Widget>[
              const GalleryRule(),
              const SizedBox(height: DabblerSpacing.space8),
            ],
          ],
          children[i],
        ],
      ],
    );
  }
}
