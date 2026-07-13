// =============================================================================
// Dabbler Docs — content blocks
// -----------------------------------------------------------------------------
// The building blocks every page composes: prose, live-example frames, anatomy,
// captioned grids (variants / states), token-driven specs tables, do/don't
// guidance, and copyable code. All are styled with OUR tokens (DabblerType /
// context.dabbler / DabblerSpacing), so the docs are a live demo of the system.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/dabbler_colors.dart';
import '../theme/dabbler_spacing.dart';
import '../theme/dabbler_type.dart';
import 'doc_model.dart';

// --- small value types -------------------------------------------------------

/// One row of a Specs table. [source] names the token the value comes from.
class SpecRow {
  const SpecRow(this.property, this.value, this.source);
  final String property;
  final String value;
  final String source;
}

/// One labelled part in an Anatomy block.
class AnatomyPart {
  const AnatomyPart(this.name, this.description);
  final String name;
  final String description;
}

/// A captioned live example (for Variants / States grids).
class Captioned {
  const Captioned(this.caption, this.child);
  final String caption;
  final Widget child;
}

// --- prose -------------------------------------------------------------------

class DocProse extends StatelessWidget {
  const DocProse(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final style = (rtl ? DabblerType.arabic(DabblerType.body) : DabblerType.body)
        .copyWith(color: d.textSecondary);
    return Text(text, style: style);
  }
}

// --- live example frame ------------------------------------------------------

/// A bordered surface that holds a live example, visually separating it from the
/// prose. Flat (no shadow), tokens only.
class DocExampleFrame extends StatelessWidget {
  const DocExampleFrame({super.key, required this.child, this.align});
  final Widget child;
  final AlignmentGeometry? align;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DabblerSpacing.space8), // 24
      decoration: BoxDecoration(
        color: d.bgSecondary,
        borderRadius: DabblerRadius.lgRadius,
        border: Border.all(
          color: d.borderDefault,
          width: DabblerSizing.borderHairline,
        ),
      ),
      child: Align(
        alignment: align ?? AlignmentDirectional.centerStart,
        child: child,
      ),
    );
  }
}

// --- anatomy -----------------------------------------------------------------

class DocAnatomy extends StatelessWidget {
  const DocAnatomy(this.parts, {super.key});
  final List<AnatomyPart> parts;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final p in parts)
          Padding(
            padding:
                const EdgeInsets.only(bottom: DabblerSpacing.stackDefault),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsetsDirectional.only(
                      top: 6, end: DabblerSpacing.space3),
                  width: DabblerSpacing.space2,
                  height: DabblerSpacing.space2,
                  decoration:
                      BoxDecoration(color: d.brandPrimary, shape: BoxShape.circle),
                ),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: '${p.name} — ',
                        style: DabblerType.emphasized(DabblerType.callout)
                            .copyWith(color: d.textPrimary),
                      ),
                      TextSpan(
                        text: p.description,
                        style: DabblerType.callout.copyWith(color: d.textSecondary),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// --- captioned grid (variants / states) --------------------------------------

class DocCaptionedGrid extends StatelessWidget {
  const DocCaptionedGrid(this.items, {super.key});
  final List<Captioned> items;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    return Wrap(
      spacing: DabblerSpacing.sectionGap,
      runSpacing: DabblerSpacing.space8,
      children: [
        for (final item in items)
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              item.child,
              const SizedBox(height: DabblerSpacing.stackTight),
              Text(item.caption,
                  style: DabblerType.caption2.copyWith(color: d.textTertiary)),
            ],
          ),
      ],
    );
  }
}

// --- specs table (token-driven) ----------------------------------------------

class DocSpecsTable extends StatelessWidget {
  const DocSpecsTable(this.rows, {super.key});
  final List<SpecRow> rows;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final headStyle = DabblerType.caption1
        .copyWith(color: d.textTertiary, letterSpacing: 0.4);
    final propStyle =
        DabblerType.emphasized(DabblerType.footnote).copyWith(color: d.textPrimary);
    final valStyle = DabblerType.footnote.copyWith(color: d.textSecondary);
    final srcStyle = DabblerType.caption1.copyWith(color: d.textTertiary);

    TableRow row(List<Widget> cells) => TableRow(children: [
          for (final c in cells)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: DabblerSpacing.space3,
                horizontal: DabblerSpacing.space3,
              ),
              child: c,
            ),
        ]);

    return Container(
      decoration: BoxDecoration(
        borderRadius: DabblerRadius.mdRadius,
        border: Border.all(
            color: d.borderDefault, width: DabblerSizing.borderHairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(),
          2: FlexColumnWidth(1.4),
        },
        border: TableBorder(
          horizontalInside: BorderSide(
              color: d.borderDefault, width: DabblerSizing.borderHairline),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(color: d.bgTertiary),
            children: [
              for (final h in ['Property', 'Value', 'Token source'])
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: DabblerSpacing.space3,
                    horizontal: DabblerSpacing.space3,
                  ),
                  child: Text(h.toUpperCase(), style: headStyle),
                ),
            ],
          ),
          for (final r in rows)
            row([
              Text(r.property, style: propStyle),
              Text(r.value, style: valStyle),
              Text(r.source, style: srcStyle),
            ]),
        ],
      ),
    );
  }
}

// --- do / don't --------------------------------------------------------------

class DocDoDont extends StatelessWidget {
  const DocDoDont({super.key, required this.dos, required this.donts});
  final List<String> dos;
  final List<String> donts;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 560;
      final doCol = _GuidanceColumn(
        title: 'Do',
        accent: d.success,
        onAccent: d.onSuccess,
        surface: d.successSurface,
        rules: dos,
      );
      final dontCol = _GuidanceColumn(
        title: "Don't",
        accent: d.error,
        onAccent: d.onError,
        surface: d.errorSurface,
        rules: donts,
      );
      if (!wide) {
        return Column(children: [
          doCol,
          const SizedBox(height: DabblerSpacing.stackDefault),
          dontCol,
        ]);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: doCol),
          const SizedBox(width: DabblerSpacing.stackDefault),
          Expanded(child: dontCol),
        ],
      );
    });
  }
}

class _GuidanceColumn extends StatelessWidget {
  const _GuidanceColumn({
    required this.title,
    required this.accent,
    required this.onAccent,
    required this.surface,
    required this.rules,
  });

  final String title;
  final Color accent;
  final Color onAccent;
  final Color surface;
  final List<String> rules;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    return Container(
      padding: const EdgeInsets.all(DabblerSpacing.cardPadding),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: DabblerRadius.lgRadius,
        border: Border.all(
            color: d.borderDefault, width: DabblerSizing.borderHairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: DabblerType.emphasized(DabblerType.headline)
                  .copyWith(color: onAccent)),
          const SizedBox(height: DabblerSpacing.stackDefault),
          for (final r in rules)
            Padding(
              padding: const EdgeInsets.only(bottom: DabblerSpacing.stackTight),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    title == 'Do' ? Icons.check_rounded : Icons.close_rounded,
                    size: DabblerSizing.iconSm,
                    color: accent,
                  ),
                  const SizedBox(width: DabblerSpacing.space2),
                  Expanded(
                    child: Text(r,
                        style: DabblerType.footnote
                            .copyWith(color: d.textPrimary)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// --- code block (copyable) ---------------------------------------------------

class DocCodeBlock extends StatefulWidget {
  const DocCodeBlock(this.code, {super.key});
  final String code;

  @override
  State<DocCodeBlock> createState() => _DocCodeBlockState();
}

class _DocCodeBlockState extends State<DocCodeBlock> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: d.bgTertiary,
        borderRadius: DabblerRadius.mdRadius,
        border: Border.all(
            color: d.borderDefault, width: DabblerSizing.borderHairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: widget.code));
                if (context.mounted) setState(() => _copied = true);
              },
              icon: Icon(_copied ? Icons.check : Icons.copy,
                  size: DabblerSizing.iconSm),
              label: Text(_copied ? 'Copied' : 'Copy'),
              style: TextButton.styleFrom(foregroundColor: d.textSecondary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DabblerSpacing.space4,
              0,
              DabblerSpacing.space4,
              DabblerSpacing.space4,
            ),
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  widget.code,
                  // Code stays LTR even in RTL pages.
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontFamilyFallback: ['Menlo', 'Consolas', 'monospace'],
                    fontSize: 13,
                    height: 1.5,
                  ).copyWith(color: d.textPrimary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- page renderer -----------------------------------------------------------

/// Renders a [DocPage]: title + one-sentence definition, then each template
/// section (heading + content) in order.
class DocPageView extends StatelessWidget {
  const DocPageView(this.page, {super.key});
  final DocPage page;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    TextStyle a(TextStyle s) => rtl ? DabblerType.arabic(s) : s;

    final sections = page.placeholder || page.builder == null
        ? <DocSection>[
            DocSection(
              'Overview',
              DocProse(
                'This page is a placeholder. ${page.title} is on the roadmap; '
                'its full reference — anatomy, variants, specs, and guidance — '
                'will appear here once the piece is built.',
              ),
            ),
          ]
        : page.builder!(context);

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: DabblerSpacing.space9,
        vertical: DabblerSpacing.space9,
      ),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(page.group.label.toUpperCase(),
                  style: DabblerType.caption1
                      .copyWith(color: d.brandPrimary, letterSpacing: 0.6)),
              const SizedBox(height: DabblerSpacing.stackTight),
              Text(page.title,
                  style: a(DabblerType.largeTitle).copyWith(color: d.textPrimary)),
              const SizedBox(height: DabblerSpacing.stackDefault),
              Text(page.definition,
                  style: a(DabblerType.title3).copyWith(color: d.textSecondary)),
              const SizedBox(height: DabblerSpacing.sectionGap),
              for (final s in sections) ...[
                Text(s.heading,
                    style: a(DabblerType.title2).copyWith(color: d.textPrimary)),
                const SizedBox(height: DabblerSpacing.stackDefault),
                s.child,
                const SizedBox(height: DabblerSpacing.sectionGap),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
