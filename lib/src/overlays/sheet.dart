/// Sheet — the canonical bottom sheet, its route, and [showDabblerSheet].
///
/// **Why `part`, not separate libraries (KAN-265).** `sheet.dart` stood at 684
/// lines against the project's 500-line house rule, roughly 40% of it the
/// source-citation documentation this package's traceability discipline
/// requires and which therefore cannot be cut. [_DabblerSheetState] is
/// library-private and [DabblerSheetRoute] is tightly coupled to
/// [DabblerSheet]'s private state; a plain second-file split would have forced
/// private detail public, which this package does not do anywhere else.
/// `part`/`part of` keeps one logical library, keeps private access between
/// the pieces, changes no public API, and gets every resulting file under the
/// rule. No exemption was recorded — the rule holds and the file complies.
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../tokens/dabbler_motion.dart';
import '../interaction/scrim.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

part 'sheet_detent.dart';
part 'sheet_panel.dart';
part 'sheet_route.dart';

/// How a [DabblerSheet] presents itself, transcribed from the source's
/// `presentation` prop (`components/overlays/Sheet.d.ts:21`, unverified: file not mirrored).
enum DabblerSheetPresentation {
  /// Owns the viewport: scrim, bottom alignment, Escape and focus capture.
  modal,

  /// The panel only — no scrim, no positioning. The source restricts this to
  /// *"documentation cards and embedded previews only, never for a live
  /// modal"* (`Sheet.prompt.md:76`, unverified: file not mirrored).
  inline,
}

/// Sheet — the canonical bottom sheet.
///
/// Transcribed from `components/overlays/Sheet.jsx`, `Sheet.d.ts` and
/// `Sheet.prompt.md`. It is the phone-width presentation of a modal (its
/// wide-viewport counterpart is Dialog, DS-702) and the container Menu
/// (DS-700) falls back to below 480px.
///
/// ## What it composes, and what it does not restate
///
/// The wash is DS-200's [DabblerScrim] and nothing here re-declares its
/// colour, its opacity or its fade — `Sheet.prompt.md:34` (unverified: file not mirrored) and
/// `Dialog.prompt.md:34` (both unverified: files not mirrored) name the same `--color-scrim` token precisely so
/// there is one scrim, not three. Everything the scrim documents itself as
/// *not* doing — the panel, the positioning, the entry and exit transition,
/// drag-to-dismiss, Escape and focus capture — is owned here.
///
/// ## Flat
///
/// Opaque [DabblerColors.surfaceCard] fill, a 1px [DabblerColors.borderDefault]
/// hairline (`--outline-card`), top corners [DabblerRadius.xl], no shadow:
/// *"the scrim separates it"* (`Sheet.jsx:9`). [DabblerElevation.dialogFor] is
/// reserved for Dialog and is deliberately not referenced.
///
/// ## Detents and dragging
///
/// [detents] are fractions of the viewport height, sorted ascending
/// (`Sheet.jsx:32`). Dragging the handle moves the panel with a
/// [Transform.translate] and nothing else — the source is explicit that the
/// gesture must use *"`transform` only — never height, top or margin"*
/// (`Sheet.prompt.md:58`, unverified: file not mirrored) so it stays off the layout path. On release the
/// panel snaps to the nearest detent; dragging well past the smallest detent
/// dismisses when [dismissible]. Both thresholds are transcribed:
/// [dragResistance] (24) and [dismissFraction] (0.55).
///
/// ## Dismissal
///
/// Three routes, all gated on [dismissible]: `Escape`, a press on the scrim,
/// and the close affordance. The close button is
/// [DabblerSizing.touchTargetMin] (45) square — above the 44pt floor — and is
/// a **visible** affordance, which is a deliberate addition to the source,
/// whose web presentation relies on the pointer alone. The drag handle's row
/// is the same 45 tall (`Sheet.jsx:101`).
///
/// ## Route integration
///
/// [showDabblerSheet] pushes this as a [PopupRoute] and is what application
/// code should normally call; the widget is public for inline previews,
/// gallery entries, and for DS-700's Menu, which needs to compose the panel
/// itself rather than push a route.
class DabblerSheet extends StatefulWidget {
  /// Creates a sheet.
  const DabblerSheet({
    super.key,
    this.open = true,
    this.onClose,
    this.detents = const <double>[0.5],
    this.snapTo,
    this.dragHandle = true,
    this.title,
    this.titleSpan,
    this.titleWidget,
    this.titleStyle,
    this.headerAction,
    this.footer,
    this.child,
    this.dismissible = true,
    this.presentation = DabblerSheetPresentation.modal,
    this.closeLabel = defaultCloseLabel,
    this.scrimLabel = defaultScrimLabel,
    this.detent = DabblerSheetDetent.fractions,
    this.contentMaxFraction = defaultContentMaxFraction,
    this.pageBackground = false,
    this.hairlineOutside = false,
    this.showCloseButton = true,
    this.headerDivider = false,
  });

  /// The default cap of a [DabblerSheetDetent.content] sheet: 0.8 of the
  /// viewport. The design's sheets cap at 80% and 78% (`Listings.dc.html`);
  /// 0.8 is the nearer-the-majority value and 0.78 is passable exactly.
  static const double defaultContentMaxFraction = 0.8;

  /// The frames' create drawers (create post, create game, create meet-up):
  /// `max-height: 94%`, `height: auto` (`Home Feed.dc.html` `sheetP94`, at
  /// `:472`, `:927`, `:1134`) — content-sized, capped at 0.94.
  static const double contentMaxFractionFull = 0.94;

  /// The vibes picker's cap: `max-height: 82%`, `height: auto`
  /// (`Home Feed.dc.html` `sheetP82`, `:650`).
  static const double contentMaxFractionTall = 0.82;

  /// The place picker's cap: `max-height: 74%`, `height: auto`
  /// (`Home Feed.dc.html` `sheetP74`, `:818`).
  static const double contentMaxFractionMedium = 0.74;

  /// The city sheet's cap: `max-height: 66%`, `height: auto`
  /// (`Home Feed.dc.html` `sheetP66`, `:763`).
  static const double contentMaxFractionCompact = 0.66;

  /// The default English semantics label for the close affordance. The package
  /// ships no localised strings; a host app passes its own.
  static const String defaultCloseLabel = 'Close';

  /// The default English semantics label for the scrim's dismiss gesture.
  static const String defaultScrimLabel = 'Dismiss';

  /// `max-width: 520` (`Sheet.jsx:83`). Full width below it, centred above.
  static const double maxPanelWidth = 520;

  /// `max-height: 96dvh` (`Sheet.jsx:85`), as a fraction.
  static const double maxHeightFraction = 0.96;

  /// The 40×4 grab bar (`Sheet.jsx:104`). Its radius is [DabblerRadius.pill].
  static const double handleWidth = 40;

  /// The grab bar's thickness — `height: 4` (`Sheet.jsx:104`).
  static const double handleHeight = 4;

  /// Upward drag is clamped to `Math.max(-24, …)` (`Sheet.jsx:57`): the panel
  /// resists being dragged above its detent instead of growing.
  static const double dragResistance = 24;

  /// A release below `stops[0] * 0.55` dismisses (`Sheet.jsx:65`).
  static const double dismissFraction = 0.55;

  /// Whether the sheet is shown. Toggling it slides and fades.
  final bool open;

  /// Called on every dismissal route. A null callback leaves the sheet
  /// undismissable in practice, matching the source's optional `onClose`.
  final VoidCallback? onClose;

  /// Heights as fractions of the viewport (0–1). Default `[0.5]`.
  final List<double> detents;

  /// Index into [detents] to snap to. Controlled snapping; null uses the
  /// largest detent, as `Sheet.jsx:33-35` does.
  final int? snapTo;

  /// Whether the draggable grab handle is shown. Default true.
  final bool dragHandle;

  /// The title line, rendered in [DabblerType.title3].
  final String? title;

  /// A rich title, drawn instead of [title] when set — e.g. a count in a
  /// second colour. Its base style is [DabblerType.title3] in
  /// [DabblerColors.textPrimary]; spans override from there. The plain text
  /// of the span ([InlineSpan.toPlainText]) names the route for assistive
  /// technology when [title] is null.
  ///
  /// DS gaps 6 (item 2). Additive: null keeps the [title] line exactly as it
  /// was.
  final InlineSpan? titleSpan;

  /// A fully custom title widget, drawn instead of [title] and [titleSpan]
  /// when set. It takes the title slot's flexible inline extent. Supply
  /// [title] as well when the widget carries no text of its own, because the
  /// route's semantics name comes from [title] or [titleSpan] only.
  final Widget? titleWidget;

  /// The type step of [title] and [titleSpan], in place of the default
  /// [DabblerType.title3]. Additive (KAN-461), default null keeps the title
  /// exactly as it was. The Home Feed vibe sheet's title is 17/22 semibold
  /// (`Home Feed.dc.html:654`, weight 600): pass [DabblerType.headline].
  final DabblerTypeStyle? titleStyle;

  /// A trailing header action, drawn at the inline end of the title row —
  /// before the close affordance when that is shown.
  ///
  /// The Listings filter sheets put a small neutral `Button` reading *Reset*
  /// there, after a `flex: 1` title and a `gap: 12`
  /// (`Listings.dc.html:286-289`, repeated at 587-590, 838-841 and the Arabic
  /// copies at 1155-1158, 1456-1459, 1707-1710). Those sheets have no close
  /// button; pass `dismissible: false` or rely on the scrim when matching
  /// them exactly. The action keeps its own semantics (pass a
  /// `DabblerButton`, which is a named button), and the row is a [Row] in
  /// the ambient [Directionality], so it sits on the left under RTL.
  final Widget? headerAction;

  /// Pinned footer — actions. Safe-area padded, and separated by a `--faint`
  /// hairline. `Sheet.prompt.md:79` (unverified: file not mirrored) requires actions to live here rather than
  /// at the end of the scroll area so they stay reachable at every detent.
  final Widget? footer;

  /// The scrolling body. The sheet pads it by [DabblerSpacing.space6] on every
  /// side, so pass widgets only: no `Padding`, `Card`, filled `DecoratedBox` or
  /// padded scroll view around the content, which would draw a second inset and
  /// a second panel inside this one (KAN-434). [DabblerSheetBody] and
  /// [DabblerSheetActions] are the scaffold for the usual shapes.
  final Widget? child;

  /// Whether Escape, the scrim, the close button and drag-past dismiss.
  final bool dismissible;

  /// Modal (scrim + viewport) or inline (panel only).
  final DabblerSheetPresentation presentation;

  /// Semantics label for the close affordance.
  final String closeLabel;

  /// Semantics label handed to [DabblerScrim.dismissLabel].
  final String scrimLabel;

  /// How the height is chosen. [DabblerSheetDetent.fractions] (default) uses
  /// [detents]; [DabblerSheetDetent.content] sizes to the content.
  final DabblerSheetDetent detent;

  /// The cap of a [DabblerSheetDetent.content] sheet, as a fraction of the
  /// viewport (never above [maxHeightFraction]). Unused for
  /// [DabblerSheetDetent.fractions].
  final double contentMaxFraction;

  /// Paints the panel in the page colour instead of the card colour — the Home
  /// Feed design's sheets all override `background` to `--surface-page`
  /// (`Home Feed.dc.html:3051`, `sheetPAuto`).
  final bool pageBackground;

  /// Lays the panel's content out inside its 1px hairline, as the web frame's
  /// content-box sheet does (content starts 1 in and 1 down). Default false
  /// keeps the hairline painted inside the padding box.
  final bool hairlineOutside;

  /// Draws the header's close button. The Home Feed design's sheets draw none:
  /// they put their own Done / Cancel button in the body (`:763-770`). The scrim
  /// and the drag still dismiss.
  final bool showCloseButton;

  /// Draws a 1px `--faint` hairline under the header row — the Listings
  /// design's filter and location sheets (`Listings.dc.html:289`,
  /// `border-bottom: 1px solid var(--faint)`). Default false.
  final bool headerDivider;

  @override
  State<DabblerSheet> createState() => _DabblerSheetState();
}
