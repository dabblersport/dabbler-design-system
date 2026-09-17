import 'package:flutter/material.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../interaction/press_scale.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// The tones a [DabblerBanner] can take, transcribed from
/// `components/feedback/Banner.d.ts`.
///
/// Four of the five are the semantic statuses of DS-102's
/// [DabblerStatusTone]. The fifth, [neutral], is **not** a status: the design
/// source's `statusTones.neutral` entry
/// (`components/foundations/overlay.jsx:161`) resolves to `--surface-card`,
/// `--ink` and `--outline-card` — the ordinary card roles — and
/// `statusHairline` special-cases it to `--outline-card` rather than a tinted
/// strong colour. It therefore has no `--color-status-*` triple and cannot be
/// a member of [DabblerStatusTone]; it is carried here instead, and
/// [DabblerBannerTone.status] returns `null` for it.
enum DabblerBannerTone {
  /// Card surface, primary ink, card outline. Carries no status meaning.
  neutral(null),

  /// `--color-status-success-*`.
  success(DabblerStatusTone.success),

  /// `--color-status-warning-*`.
  warning(DabblerStatusTone.warning),

  /// `--color-status-error-*`.
  error(DabblerStatusTone.error),

  /// `--color-status-info-*`.
  info(DabblerStatusTone.info);

  const DabblerBannerTone(this.status);

  /// The DS-102 status tone this maps onto, or `null` for [neutral].
  final DabblerStatusTone? status;

  /// Whether this tone interrupts.
  ///
  /// The source sets `role="alert"` for `error` and `warning` and
  /// `role="status"` otherwise (`Banner.jsx:29`) — *"interrupting is correct
  /// there"*. In Flutter the equivalent is [Semantics.liveRegion].
  bool get interrupts =>
      this == DabblerBannerTone.error || this == DabblerBannerTone.warning;
}

/// The label and callback of a [DabblerBanner]'s inline action.
///
/// Transcribed from `BannerAction` in `components/feedback/Banner.d.ts`.
@immutable
class DabblerBannerAction {
  /// Creates an inline banner action.
  const DabblerBannerAction({required this.label, this.onPressed});

  /// The button's text.
  final String label;

  /// Called when the button is pressed. A null callback renders the button
  /// visually unchanged but inert, matching the source, whose `onPress` is
  /// optional.
  final VoidCallback? onPressed;
}

/// Banner — a persistent, inline status message that stays until the
/// underlying condition changes.
///
/// Transcribed from `components/feedback/Banner.jsx`, `Banner.d.ts` and
/// `Banner.prompt.md`: *"verification needed"*, *"game cancelled"*, *"payout
/// on hold"*. A completed action is a Toast; a decision is a Dialog; one
/// field's validation is a TextField `errorText`.
///
/// ## Colour comes from the tone, never from a literal
///
/// The fill is the tone's [DabblerStatusColor.surface], the ink — title,
/// message, glyph, action label — is its [DabblerStatusColor.strong], and the
/// hairline is that same strong colour at **20%**, which is exactly what the
/// source's `statusHairline` computes
/// (`color-mix(in srgb, <strong> 20%, transparent)`,
/// `components/foundations/overlay.jsx:169-173`). The prompt is explicit that
/// the strong-on-surface pair is the one measured to clear 4.5:1 in light and
/// dark for every tone, and that the message must **never** be dropped to a
/// secondary text colour on a status surface.
///
/// [DabblerBannerTone.neutral] resolves to [DabblerColors.surfaceCard],
/// [DabblerColors.textPrimary] and [DabblerColors.borderDefault] — the card
/// roles the source's neutral entry names.
///
/// ## Flat
///
/// Fill, 1px hairline, [DabblerRadius.lg]. No shadow, no gradient, no blur:
/// [DabblerElevation] reserves the one legal shadow for Dialog.
///
/// ## Touch targets
///
/// Both the dismiss button and the action button are at least
/// [DabblerSizing.touchTargetMin] (45) on their constrained axis — the source's
/// `--touch-target-min`, which is base-3 and clears the 44pt floor that
/// `cpo` §5.2 Principle 3 requires. The dismiss button is a square of that
/// size, and its rendered hit target is measured by `test/feedback/banner_test.dart`.
class DabblerBanner extends StatelessWidget {
  /// Creates a banner. At least one of [title] and [message] is normally set,
  /// though the source permits either alone.
  const DabblerBanner({
    super.key,
    this.tone = DabblerBannerTone.info,
    this.title,
    this.message,
    this.icon,
    this.action,
    this.onDismiss,
    this.dismissSemanticLabel = defaultDismissSemanticLabel,
  });

  /// The tone. Default `info`, as in `Banner.jsx:17`.
  final DabblerBannerTone tone;

  /// The headline line. Rendered in [DabblerType.headline].
  final String? title;

  /// The body line. Rendered in [DabblerType.subheadline].
  final String? message;

  /// The leading glyph, in a 24×24 ([DabblerSizing.iconMd]) slot.
  ///
  /// The source defaults this to the tone's Iconsax glyph (`tick-circle`,
  /// `warning-2`, `danger`, `info-circle`). **This package has no icon
  /// dependency yet** — adding one is a `cto` hand-off — so the default here is
  /// no glyph rather than a substituted one, and a caller that has an icon set
  /// passes it in. The slot and its spacing are already correct, so supplying
  /// the glyph later changes nothing else. The widget is given the tone's ink
  /// through [IconTheme], so a plain [Icon] inherits the right colour.
  final Widget? icon;

  /// An outlined action below the message, inline-start aligned.
  final DabblerBannerAction? action;

  /// Called when the dismiss button is pressed. **No dismiss button is
  /// rendered without it** (`Banner.d.ts`: *"When provided, renders a 45×45
  /// dismiss button"*).
  final VoidCallback? onDismiss;

  /// The accessible name of the dismiss button — the source's
  /// `aria-label="Dismiss"`. Exposed because it is user-facing copy the app
  /// localises; the design system does not own strings.
  final String dismissSemanticLabel;

  /// The source's literal `aria-label` value.
  static const String defaultDismissSemanticLabel = 'Dismiss';

  /// Identifies the dismiss button's touch target, so a test can measure the
  /// rendered box rather than trust a comment.
  static const Key dismissTargetKey = Key('DabblerBanner.dismissTarget');

  /// Identifies the action button's touch target.
  static const Key actionTargetKey = Key('DabblerBanner.actionTarget');

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final DabblerStatusTone? status = tone.status;
    final DabblerStatusColor? resolved =
        status == null ? null : colors.status(status);

    // `statusTones` / `statusHairline` in overlay.jsx:160-173.
    final Color surface = resolved?.surface ?? colors.surfaceCard;
    final Color ink = resolved?.strong ?? colors.textPrimary;
    final Color hairline = resolved == null
        ? colors.borderDefault
        : resolved.strong.withValues(alpha: 0.20);

    final TextDirection direction = Directionality.of(context);
    final List<Widget> column = <Widget>[];

    if (title != null) {
      column.add(
        Text(
          title!,
          style: DabblerType.headline
              .resolveForDirection(direction)
              .copyWith(color: ink),
        ),
      );
    }
    if (message != null) {
      if (column.isNotEmpty) {
        // `gap: var(--space-1)` on the content column, Banner.jsx:38.
        column.add(const SizedBox(height: DabblerSpacing.space1));
      }
      column.add(
        Text(
          message!,
          style: DabblerType.subheadline
              .resolveForDirection(direction)
              .copyWith(color: ink),
        ),
      );
    }
    if (action != null) {
      if (column.isNotEmpty) {
        // `marginBlockStart: var(--space-2)` on the action, Banner.jsx:45.
        column.add(const SizedBox(height: DabblerSpacing.space2));
      }
      column.add(
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: _buildAction(context, ink: ink, hairline: hairline),
        ),
      );
    }

    final Widget body = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DabblerSpacing.space5),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: DabblerRadius.lgAll,
        border: Border.all(
          color: hairline,
          width: DabblerSizing.borderDefault,
        ),
        // No boxShadow and no gradient: the system is flat.
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            SizedBox(
              width: DabblerSizing.iconMd,
              height: DabblerSizing.iconMd,
              child: IconTheme.merge(
                data: IconThemeData(color: ink, size: DabblerSizing.iconMd),
                child: icon!,
              ),
            ),
            // `gap: var(--space-4)` on the row, Banner.jsx:31.
            const SizedBox(width: DabblerSpacing.space4),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: column,
            ),
          ),
          if (onDismiss != null) _buildDismiss(context, ink: ink),
        ],
      ),
    );

    return Semantics(
      container: true,
      // role="alert" for error and warning, role="status" otherwise.
      liveRegion: tone.interrupts,
      child: body,
    );
  }

  /// The outlined inline action: 45 tall, inline padding [DabblerSpacing.space4],
  /// [DabblerRadius.md], a hairline border and the tone's ink at weight 600.
  Widget _buildAction(
    BuildContext context, {
    required Color ink,
    required Color hairline,
  }) {
    final TextStyle style = DabblerType.subheadline
        .resolveForDirection(Directionality.of(context))
        .copyWith(color: ink, fontWeight: DabblerType.semibold);

    return Semantics(
      container: true,
      button: true,
      enabled: action!.onPressed != null,
      label: action!.label,
      excludeSemantics: true,
      onTap: action!.onPressed,
      child: _interactive(
        enabled: action!.onPressed != null,
        child: GestureDetector(
          key: actionTargetKey,
          behavior: HitTestBehavior.opaque,
          onTap: action!.onPressed,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: DabblerSizing.touchTargetMin,
            ),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: DabblerSpacing.space4,
            ),
            alignment: AlignmentDirectional.center,
            decoration: BoxDecoration(
              borderRadius: DabblerRadius.mdAll,
              border: Border.all(
                color: hairline,
                width: DabblerSizing.borderDefault,
              ),
            ),
            child: Text(action!.label, style: style),
          ),
        ),
      ),
    );
  }

  /// The dismiss button: a [DabblerSizing.touchTargetMin] square carrying an 18px
  /// glyph, at the inline end.
  Widget _buildDismiss(BuildContext context, {required Color ink}) {
    return Semantics(
      container: true,
      button: true,
      label: dismissSemanticLabel,
      // The GestureDetector publishes a tap action of its own; without
      // excludeSemantics the two nodes sit side by side and the label never
      // reaches the tappable one.
      excludeSemantics: true,
      onTap: onDismiss,
      child: _interactive(
        enabled: onDismiss != null,
        child: GestureDetector(
          key: dismissTargetKey,
          behavior: HitTestBehavior.opaque,
          onTap: onDismiss,
          child: SizedBox(
            width: DabblerSizing.touchTargetMin,
            height: DabblerSizing.touchTargetMin,
            child: Center(
              // The source's Iconsax `close-circle`, drawn for real since
              // T-083 adopted `iconsax_flutter` and DS-300 (KAN-235) shipped
              // the registry. It was `Icons.cancel_outlined` as a documented
              // stand-in until KAN-262; the hand-off has happened, so the
              // stand-in and its caveat are gone.
              child: DabblerIcon(
                'close-circle',
                size: DabblerSizing.iconSm,
                color: ink,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Wraps one of the banner's two targets in DS-200's shared interaction
  /// primitives (KAN-258).
  ///
  /// Both targets were bare [GestureDetector]s, written in parallel with
  /// DS-200 rather than after it, so neither showed the focus ring or the
  /// press scale every other control in the cut has. The source marks both
  /// `.dbl-focus .dbl-press`.
  ///
  /// The wrap is inside the caller's [Semantics], which carries
  /// `excludeSemantics: true`: [DabblerFocusRing] inserts a [Focus] and
  /// [DabblerPressScale.gesture] a [Listener], neither of which publishes a
  /// semantics node, so each target still exposes exactly one tappable node.
  /// [DabblerPressScale.gesture] uses a [Listener] rather than a
  /// [GestureDetector], so it never competes in the gesture arena with the tap
  /// recogniser below it.
  ///
  /// Neither primitive lays anything out — the ring is painted outside the
  /// child's bounds and the scale is a transform — so the targets' measured
  /// [DabblerSizing.touchTargetMin] boxes are untouched.
  static Widget _interactive({
    required bool enabled,
    required Widget child,
  }) {
    return DabblerFocusRing(
      enabled: enabled,
      canRequestFocus: enabled,
      // Both targets are drawn on --radius-md: the action by its own outlined
      // Container, the dismiss by the round `close-circle` glyph it carries.
      borderRadius: DabblerRadius.mdAll,
      child: DabblerPressScale.gesture(
        enabled: enabled,
        child: child,
      ),
    );
  }
}
