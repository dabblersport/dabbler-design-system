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
import '../interaction/scrim.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

part 'sheet_panel.dart';
part 'sheet_route.dart';

/// How a [DabblerSheet] presents itself, transcribed from the source's
/// `presentation` prop (`components/overlays/Sheet.d.ts:21`).
enum DabblerSheetPresentation {
  /// Owns the viewport: scrim, bottom alignment, Escape and focus capture.
  modal,

  /// The panel only — no scrim, no positioning. The source restricts this to
  /// *"documentation cards and embedded previews only, never for a live
  /// modal"* (`Sheet.prompt.md:76`).
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
/// colour, its opacity or its fade — `Sheet.prompt.md:34` and
/// `Dialog.prompt.md:34` name the same `--color-scrim` token precisely so
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
/// (`Sheet.jsx:30`). Dragging the handle moves the panel with a
/// [Transform.translate] and nothing else — the source is explicit that the
/// gesture must use *"`transform` only — never height, top or margin"*
/// (`Sheet.prompt.md:58`) so it stays off the layout path. On release the
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
/// is the same 45 tall (`Sheet.jsx:104`).
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
    this.footer,
    this.child,
    this.dismissible = true,
    this.presentation = DabblerSheetPresentation.modal,
    this.closeLabel = defaultCloseLabel,
    this.scrimLabel = defaultScrimLabel,
  });

  /// The default English semantics label for the close affordance. The package
  /// ships no localised strings; a host app passes its own.
  static const String defaultCloseLabel = 'Close';

  /// The default English semantics label for the scrim's dismiss gesture.
  static const String defaultScrimLabel = 'Dismiss';

  /// `max-width: 520` (`Sheet.jsx:80`). Full width below it, centred above.
  static const double maxPanelWidth = 520;

  /// `max-height: 96dvh` (`Sheet.jsx:82`), as a fraction.
  static const double maxHeightFraction = 0.96;

  /// The 40×4 grab bar (`Sheet.jsx:112`). Its radius is [DabblerRadius.pill].
  static const double handleWidth = 40;

  /// The grab bar's thickness — `height: 4` (`Sheet.jsx:112`).
  static const double handleHeight = 4;

  /// Upward drag is clamped to `Math.max(-24, …)` (`Sheet.jsx:60`): the panel
  /// resists being dragged above its detent instead of growing.
  static const double dragResistance = 24;

  /// A release below `stops[0] * 0.55` dismisses (`Sheet.jsx:68`).
  static const double dismissFraction = 0.55;

  /// Whether the sheet is shown. Toggling it slides and fades.
  final bool open;

  /// Called on every dismissal route. A null callback leaves the sheet
  /// undismissable in practice, matching the source's optional `onClose`.
  final VoidCallback? onClose;

  /// Heights as fractions of the viewport (0–1). Default `[0.5]`.
  final List<double> detents;

  /// Index into [detents] to snap to. Controlled snapping; null uses the
  /// largest detent, as `Sheet.jsx:33` does.
  final int? snapTo;

  /// Whether the draggable grab handle is shown. Default true.
  final bool dragHandle;

  /// The title line, rendered in [DabblerType.title3].
  final String? title;

  /// Pinned footer — actions. Safe-area padded, and separated by a `--faint`
  /// hairline. `Sheet.prompt.md:79` requires actions to live here rather than
  /// at the end of the scroll area so they stay reachable at every detent.
  final Widget? footer;

  /// The scrolling body.
  final Widget? child;

  /// Whether Escape, the scrim, the close button and drag-past dismiss.
  final bool dismissible;

  /// Modal (scrim + viewport) or inline (panel only).
  final DabblerSheetPresentation presentation;

  /// Semantics label for the close affordance.
  final String closeLabel;

  /// Semantics label handed to [DabblerScrim.dismissLabel].
  final String scrimLabel;

  @override
  State<DabblerSheet> createState() => _DabblerSheetState();
}
