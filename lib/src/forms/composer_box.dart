import 'package:flutter/material.dart'
    show InputBorder, InputDecoration, Material, MaterialType, TextField;
import 'package:flutter/widgets.dart';

import '../feed/feed_atoms.dart';
import '../foundations/icon.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// One tool in a [DabblerComposerBox] toolbar.
@immutable
class DabblerComposerTool {
  /// A toolbar glyph.
  const DabblerComposerTool({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  /// The Iconsax glyph.
  final String icon;

  /// The accessible name.
  final String label;

  /// Called on tap.
  final VoidCallback? onTap;

  /// Whether the tool has something attached (bold, brand ink).
  final bool active;
}

/// ComposerBox — the post editor card: a multi-line field, a counter at its
/// end, optional tags and a toolbar of glyphs under a hairline.
///
/// Transcribed from `Home Feed.dc.html` (alpha-plan design set) lines
/// 499-519: card fill, 1px card hairline, `--radius-xl`; field `min-height
/// 132`, padding 15, 15/20; counter 12/16 `--subtle` at the end; toolbar
/// `space-around`, padding 9/15, hairline above, glyphs 20 in 6px circles.
///
/// ## Deviations
///
/// * **Targets.** Each glyph gets a 45px box.
/// * **Type.** 15/20 is `subheadline`, 12/16 `caption1`.
///
/// RTL: the counter trails at the inline end; the field aligns to the text
/// direction.
class DabblerComposerBox extends StatelessWidget {
  /// A composer box.
  const DabblerComposerBox({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.tools,
    this.focusNode,
    this.onChanged,
    this.counter,
    this.counterSemanticLabel,
    this.counterEmphasised = false,
    this.tags,
    this.minLines = 5,
    this.minFieldHeight,
  });

  /// The field's controller.
  final TextEditingController controller;

  /// The field's hint.
  final String placeholder;

  /// The toolbar glyphs.
  final List<DabblerComposerTool> tools;

  /// The field's focus node.
  final FocusNode? focusNode;

  /// Called as the text changes.
  final ValueChanged<String>? onChanged;

  /// The counter text (`0/2000`); null hides it.
  final String? counter;

  /// The counter's accessible name.
  final String? counterSemanticLabel;

  /// Draws the counter in the primary ink and bold (near the limit).
  final bool counterEmphasised;

  /// Tag badges drawn above the counter.
  final Widget? tags;

  /// The field's visible lines.
  final int minLines;

  /// The field's own minimum height, inside its padding. Additive (KAN-461),
  /// default null keeps the [minLines] sizing exactly as it was. The Home Feed
  /// textarea is `min-height: 132` with 15 padding each side, so an empty box
  /// field measures [designedHeight] (162): pass [designedFieldMinHeight]. The
  /// whole minimum area focuses the field on tap when a [focusNode] is given.
  /// [minLines] is ignored while this is set (the field still grows with its
  /// text).
  final double? minFieldHeight;

  /// The Home Feed textarea's `min-height` (`Home Feed.dc.html:499`).
  static const double designedFieldMinHeight = 132;

  /// The designed minimum height of the field area: [designedFieldMinHeight]
  /// plus [DabblerSpacing.space5] (15) padding above and below = 162.
  static const double designedHeight =
      designedFieldMinHeight + DabblerSpacing.space5 * 2;

  Widget _minHeight(Widget field) {
    final double? min = minFieldHeight;
    if (min == null) {
      return field;
    }
    return GestureDetector(
      key: const ValueKey<String>('dabbler-composer-field-area'),
      behavior: HitTestBehavior.opaque,
      onTap: focusNode?.requestFocus,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: min),
        child: Align(alignment: AlignmentDirectional.topStart, child: field),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection dir = Directionality.of(context);
    final TextStyle input = DabblerType.subheadline
        .resolveForDirection(dir)
        .copyWith(color: colors.textPrimary);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        borderRadius: DabblerRadius.xlAll,
        border: Border.all(
          color: colors.borderDefault,
          width: DabblerSizing.borderDefault,
        ),
      ),
      child: ClipRRect(
        borderRadius: DabblerRadius.xlAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(DabblerSpacing.space5),
              child: Material(
                type: MaterialType.transparency,
                child: _minHeight(
                  TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: onChanged,
                    minLines: minFieldHeight == null ? minLines : 1,
                    maxLines: null,
                    style: input,
                    cursorColor: colors.textPrimary,
                    decoration: InputDecoration(
                      isDense: true,
                      isCollapsed: true,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintText: placeholder,
                      hintStyle: input.copyWith(color: colors.textSecondary),
                    ),
                  ),
                ),
              ),
            ),
            if (counter != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: DabblerSpacing.space5,
                  end: DabblerSpacing.space5,
                  bottom: DabblerSpacing.space3,
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Semantics(
                    label: counterSemanticLabel,
                    excludeSemantics: counterSemanticLabel != null,
                    child: Text(
                      DabblerType.toWesternDigits(counter!),
                      maxLines: 1,
                      style: DabblerType.caption1
                          .resolveForDirection(dir)
                          .copyWith(
                            color: counterEmphasised
                                ? colors.textPrimary
                                : colors.textTertiary,
                            fontWeight: counterEmphasised
                                ? DabblerType.bold
                                : null,
                          ),
                    ),
                  ),
                ),
              ),
            if (tags != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: DabblerSpacing.space5,
                  end: DabblerSpacing.space5,
                  bottom: DabblerSpacing.space4,
                ),
                child: tags,
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: colors.bgTertiary,
                    width: DabblerSizing.borderDefault,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  for (final DabblerComposerTool t in tools)
                    DabblerFeedTappable(
                      onTap: t.onTap,
                      semanticLabel: t.label,
                      excludeChildSemantics: true,
                      borderRadius: DabblerRadius.pillAll,
                      child: SizedBox(
                        width: DabblerSizing.touchTargetMin,
                        height: DabblerSizing.touchTargetMin,
                        child: Center(
                          child: DabblerIcon(
                            t.icon,
                            size: 20,
                            weight: t.active
                                ? DabblerIconWeight.bold
                                : DabblerIconWeight.linear,
                            color: t.active
                                ? colors.brandPrimary
                                : colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
