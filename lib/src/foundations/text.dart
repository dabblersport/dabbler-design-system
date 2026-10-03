import 'package:flutter/widgets.dart';

import '../controls/text_link.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_type.dart';

/// The weight a [DabblerText] may override its style with — a named role,
/// never a raw [FontWeight]. App role, mapped onto the `--weight-*` steps
/// [DabblerType] transcribes from `tokens/typography.css`.
///
/// There is no 800: the type source stops at `--weight-bold` (700) and the
/// D-024 freeze forbids inventing a step, so [heavy] resolves to bold. The
/// app's `FontWeight.w800` call sites adopt [heavy] and render at 700.
enum DabblerTextWeight {
  /// `--weight-regular` (400).
  regular(DabblerType.regular),

  /// `--weight-medium` (500).
  medium(DabblerType.medium),

  /// `--weight-semibold` (600).
  semibold(DabblerType.semibold),

  /// `--weight-bold` (700).
  bold(DabblerType.bold),

  /// App role for the app's w800 emphasis — resolves to `--weight-bold`
  /// (700); see the enum's dartdoc.
  heavy(DabblerType.bold);

  const DabblerTextWeight(this.fontWeight);

  /// The resolved weight.
  final FontWeight fontWeight;
}

/// The colour role of a [DabblerText] — resolved from [DabblerColors] of the
/// enclosing theme, so the app never writes `color:`. App role over the
/// semantic colour API.
enum DabblerTextTone {
  /// [DabblerColors.textPrimary].
  primary,

  /// [DabblerColors.textSecondary] — secondary body text.
  secondary,

  /// [DabblerColors.textTertiary] — large text and de-emphasis only.
  tertiary,

  /// [DabblerColors.brandPrimary].
  brand,

  /// [DabblerColors.accent].
  accent,

  /// [DabblerColors.onBrand] — text on a brand fill.
  onBrand,

  /// [DabblerColors.onAccent] — text on an accent fill.
  onAccent,

  /// The success status ink, [DabblerStatusColor.strong].
  success,

  /// The warning status ink, [DabblerStatusColor.strong].
  warning,

  /// The error status ink, [DabblerStatusColor.strong].
  error,

  /// The info status ink, [DabblerStatusColor.strong].
  info,

  /// No colour of its own: takes the ambient [DefaultTextStyle] colour (inside
  /// a button, a chip, a [DabblerText.rich] parent).
  inherit;

  /// The colour for this tone in [colors]; null for [inherit].
  Color? colorIn(DabblerColors colors) => switch (this) {
    DabblerTextTone.primary => colors.textPrimary,
    DabblerTextTone.secondary => colors.textSecondary,
    DabblerTextTone.tertiary => colors.textTertiary,
    DabblerTextTone.brand => colors.brandPrimary,
    DabblerTextTone.accent => colors.accent,
    DabblerTextTone.onBrand => colors.onBrand,
    DabblerTextTone.onAccent => colors.onAccent,
    DabblerTextTone.success => colors.success.strong,
    DabblerTextTone.warning => colors.warning.strong,
    DabblerTextTone.error => colors.error.strong,
    DabblerTextTone.info => colors.info.strong,
    DabblerTextTone.inherit => null,
  };
}

/// One run of a [DabblerText.rich]. Each field left null inherits the
/// parent [DabblerText]'s; a non-null [onTap] renders the run as an inline
/// [DabblerTextLink].
@immutable
class DabblerTextSpan {
  /// A run of [text].
  const DabblerTextSpan(
    this.text, {
    this.weight,
    this.tone,
    this.onTap,
    this.semanticsLabel,
  });

  /// The run's text. Arabic-Indic digits are rewritten to Western.
  final String text;

  /// Weight override for this run.
  final DabblerTextWeight? weight;

  /// Tone override for this run.
  final DabblerTextTone? tone;

  /// Makes the run an inline link.
  final VoidCallback? onTap;

  /// What assistive technology reads for a link run.
  final String? semanticsLabel;
}

/// Text set in the Dabbler type ramp — the DS replacement for `Text(…)`,
/// `Text.rich(…)` and every `TextStyle(…)` in the app. App role.
///
/// It reuses the one text pipeline the components use
/// (`DabblerButton.labelStyleFor`, `DabblerTextLink`): a [DabblerTypeStyle]
/// resolved for the ambient [Directionality]
/// ([DabblerTypeStyle.resolveForDirection]) — so RTL picks the Arabic face,
/// the Arabic size (Latin − 0.9) and the Arabic leading — with colour from
/// [DabblerColors.of] and weight from a [DabblerTextWeight] role. Numerals are
/// always Western (`DabblerType.toWesternDigits` on the string, plus
/// `DabblerType.numeralFeatures` on the style).
///
/// Sizes come only from the ramp. A size the ramp lacks (e.g. 14) is not
/// expressible here by design: the D-024 freeze forbids a one-off step.
class DabblerText extends StatelessWidget {
  /// A single run of [data].
  const DabblerText(
    String this.data, {
    super.key,
    this.style = DabblerType.body,
    this.weight,
    this.tone = DabblerTextTone.primary,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.softWrap,
    this.semanticsLabel,
  }) : spans = null;

  /// Several runs sharing [style], each able to override weight and tone, or
  /// be a link.
  const DabblerText.rich(
    List<DabblerTextSpan> this.spans, {
    super.key,
    this.style = DabblerType.body,
    this.weight,
    this.tone = DabblerTextTone.primary,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.softWrap,
    this.semanticsLabel,
  }) : data = null;

  /// The text of a single-run instance.
  final String? data;

  /// The runs of a [DabblerText.rich] instance.
  final List<DabblerTextSpan>? spans;

  /// The ramp step. Defaults to [DabblerType.body].
  final DabblerTypeStyle style;

  /// Weight override; null keeps [style]'s own weight.
  final DabblerTextWeight? weight;

  /// Colour role. Defaults to [DabblerTextTone.primary].
  final DabblerTextTone tone;

  /// Passed to [Text.maxLines].
  final int? maxLines;

  /// Passed to [Text.overflow].
  final TextOverflow? overflow;

  /// Passed to [Text.textAlign].
  final TextAlign? textAlign;

  /// Passed to [Text.softWrap].
  final bool? softWrap;

  /// Passed to [Text.semanticsLabel].
  final String? semanticsLabel;

  /// The resolved [TextStyle] for [style], [weight] and [tone] in [context].
  ///
  /// Exposed so a component that must hand a style to a non-text API (an
  /// input's hint, a painter) stays on the same pipeline.
  static TextStyle resolveStyle(
    BuildContext context, {
    DabblerTypeStyle style = DabblerType.body,
    DabblerTextWeight? weight,
    DabblerTextTone tone = DabblerTextTone.primary,
  }) {
    final TextDirection direction =
        Directionality.maybeOf(context) ?? TextDirection.ltr;
    final Color? color = tone == DabblerTextTone.inherit
        ? DefaultTextStyle.of(context).style.color
        : tone.colorIn(DabblerColors.of(context));
    return style
        .resolveForDirection(direction)
        .copyWith(color: color, fontWeight: weight?.fontWeight);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle base = resolveStyle(
      context,
      style: style,
      weight: weight,
      tone: tone,
    );
    final List<DabblerTextSpan>? runs = spans;
    if (runs == null) {
      return Text(
        DabblerType.toWesternDigits(data!),
        style: base,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        softWrap: softWrap,
        semanticsLabel: semanticsLabel,
      );
    }
    final bool needsColors = runs.any(
      (DabblerTextSpan r) =>
          r.tone != null && r.tone != DabblerTextTone.inherit,
    );
    final DabblerColors? colors = needsColors
        ? DabblerColors.of(context)
        : null;
    return Text.rich(
      TextSpan(
        style: base,
        children: <InlineSpan>[
          for (final DabblerTextSpan run in runs) _span(run, base, colors),
        ],
      ),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      softWrap: softWrap,
      semanticsLabel: semanticsLabel,
    );
  }

  InlineSpan _span(DabblerTextSpan run, TextStyle base, DabblerColors? colors) {
    final DabblerTextTone? runTone = run.tone;
    final TextStyle style = base.copyWith(
      fontWeight: run.weight?.fontWeight,
      color: runTone == null || runTone == DabblerTextTone.inherit
          ? null
          : runTone.colorIn(colors!),
    );
    final String text = DabblerType.toWesternDigits(run.text);
    if (run.onTap != null) {
      return DabblerTextLink.span(
        label: text,
        onPressed: run.onTap,
        style: style,
        semanticsLabel: run.semanticsLabel,
      );
    }
    return TextSpan(text: text, style: style);
  }
}
