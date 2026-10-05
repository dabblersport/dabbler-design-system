/// Sheet content scaffold — [DabblerSheetBody] and [DabblerSheetActions]
/// (KAN-434), the two parts a call site passes as a sheet's `builder` so it
/// supplies widgets only and never its own panel, background or padding.
///
/// ## The convention they carry
///
/// [DabblerSheet] owns the surface (one rounded card, one colour, a hairline),
/// the handle, the optional close button, the title row and the **content
/// padding** — [DabblerSpacing.space6] on every side of the scrolling body.
/// Content therefore starts at that inset already. A call site that pads its
/// own content again (`Padding`, `Container(padding:)`, `Card`, a filled
/// `DecoratedBox`) draws a second inset and, when it also paints, a second
/// panel inside the first: the "drawer inside a drawer" KAN-434 was opened
/// for. These parts add no inset, no fill and no border, so there is nothing
/// to nest.
library;

import 'package:flutter/widgets.dart';

import '../tokens/dabbler_geometry.dart';

/// The body of a sheet: its children stacked from the inline start, with a
/// uniform [spacing] and optional [actions] at the bottom.
///
/// Add no padding around it — the sheet's body already insets it by
/// [DabblerSpacing.space6]. It paints nothing.
///
/// ```dart
/// showDabblerSheet<void>(
///   context: context,
///   detent: DabblerSheetDetent.content,
///   builder: (BuildContext context) => DabblerSheetBody(
///     children: <Widget>[const DabblerIconTile.named('notification'), text],
///     actions: DabblerSheetActions(children: <Widget>[primary, secondary]),
///   ),
/// );
/// ```
class DabblerSheetBody extends StatelessWidget {
  /// Creates a sheet body.
  const DabblerSheetBody({
    super.key,
    required this.children,
    this.actions,
    this.spacing = DabblerSpacing.space4,
  });

  /// The content, top to bottom. Direction follows the ambient
  /// [Directionality]; children align to the inline start.
  final List<Widget> children;

  /// The bottom action stack, usually a [DabblerSheetActions].
  final Widget? actions;

  /// The gap between children (default [DabblerSpacing.space4], 12).
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: spacing,
          children: children,
        ),
        // Outside the children's column so the gap above the actions is the
        // actions' own, not [spacing] plus it.
        ?actions,
      ],
    );
  }
}

/// A sheet's action stack: full-width buttons one under another with the
/// design-system gap, set off from the content above by
/// [DabblerSpacing.space4].
///
/// The frames put the primary action first and the quieter ones below it, a
/// [DabblerSpacing.space3] (9) apart (`Home Feed.dc.html:722-724`). Pass
/// `DabblerButton`s with `fullWidth: true`; this part sets the rhythm and
/// nothing else. For actions that must stay reachable while a long body
/// scrolls, use the sheet's pinned `footer` instead.
class DabblerSheetActions extends StatelessWidget {
  /// Creates an action stack.
  const DabblerSheetActions({super.key, required this.children});

  /// The buttons, primary first.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: DabblerSpacing.space4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DabblerSpacing.space3,
        children: children,
      ),
    );
  }
}
