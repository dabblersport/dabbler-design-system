import 'package:flutter/widgets.dart';

import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// TextLink — a brand-coloured, underlined word or phrase that navigates.
///
/// Drawn from `Auth and Onboarding.dc.html`:
///
/// * `:22` — the page rule `a { color: var(--color-brand-primary) }`;
/// * `:129`, `:170`, `:201` — the standalone links under the auth forms
///   ("Log in", "Create an account"): `15px/21px`, weight 500,
///   `--color-brand-primary`, `text-decoration: underline`,
///   `text-underline-offset: 2px`;
/// * `:131`, `:172` — the inline links inside the legal line ("Terms of
///   Service", "Privacy Policy"): the sentence's own size, `--color-brand-primary`,
///   underlined.
///
/// ```dart
/// // Standalone, under a form:
/// DabblerTextLink(label: 'Log in', onPressed: toLogin)
///
/// // Inside a sentence:
/// Text.rich(TextSpan(style: legal, children: <InlineSpan>[
///   const TextSpan(text: 'By continuing you agree to our '),
///   DabblerTextLink.span(label: 'Terms of Service', onPressed: openTerms, style: legal),
///   const TextSpan(text: '.'),
/// ]))
/// ```
///
/// ## Two shapes
///
/// * **Standalone** ([DabblerTextLink.new]) — `.t-subheadline` at
///   [DabblerType.medium] by default, inside a hit area at least
///   [DabblerSizing.touchTargetMin] (45) tall and wide: the text is centred
///   and the extra is transparent padding (the "padding trick"), so the
///   painted link stays the source's size.
/// * **Inline** ([DabblerTextLink.span] / `inline: true`) — a [WidgetSpan]
///   aligned on the alphabetic baseline that takes the sentence's [style] and
///   only changes its colour and decoration.
///
/// **Deviation (inline hit target).** An inline link is **not** padded to 45:
/// padding a word inside a line would push the lines of the paragraph apart.
/// WCAG 2.2 SC 2.5.8 exempts targets *"in a sentence or block of text"*
/// (the Inline exception), which is the case this shape is for. Use the
/// standalone shape whenever the link is on a line of its own.
///
/// **Deviation (standalone leading).** The source is 15/21; the nearest ramp
/// step is `.t-subheadline`, 15/20. Taken at 20, no invented style.
///
/// **Limitation.** A [WidgetSpan] is one unbreakable box, so an inline label
/// does not wrap across a line end; keep inline labels short.
///
/// ## A lone section link ("Manage", "See all")
///
/// `Profiles.dc.html:153` draws a section-header "Manage" as `13px/18px`,
/// weight 600, `--color-brand-primary`, **no underline**, alone at the end
/// of the row; `Home Feed.dc.html:102` does the same for "See all" at weight
/// 400. That is this widget, standalone, with `underline: false` and
/// `style:` the footnote step (13/18) at the weight drawn. [trailingIcon]
/// optionally adds a glyph after the label (a chevron or arrow), at
/// [DabblerSizing.iconSm] in the link's colour, [DabblerSpacing.space1] from
/// the text, mirrored in RTL so it always points along the reading
/// direction. Neither design frame draws the glyph; it is optional and off by
/// default.
///
/// ```dart
/// DabblerTextLink(
///   label: 'Manage',
///   underline: false,
///   style: DabblerType.footnote.resolveForDirection(dir)
///       .copyWith(fontWeight: DabblerType.semibold),
///   trailingIcon: 'arrow-right-3',
///   onPressed: openManage,
/// )
/// ```
///
/// ## Colours
///
/// Enabled: [DabblerColors.brandPrimary], underlined in the same colour.
/// Disabled ([onPressed] null): [DabblerColors.textTertiary] — D-025's
/// inactive-component exemption — with the underline kept, and the disabled
/// state also carried by `Semantics(enabled: false)`, never by colour alone.
///
/// ## Focus, keyboard and accessibility
///
/// Focusable through [DabblerFocusRing] (keyboard focus only, `:focus-visible`),
/// activated by Enter or Space through the app's default [ActivateIntent]
/// shortcuts. Announced as a **link** (`Semantics(link: true)`) with [label]
/// (or [semanticsLabel]) as its name.
///
/// ## RTL
///
/// Nothing is positioned by hand: inline, the link flows with the paragraph's
/// direction; standalone, it is centred in its target. The style resolves for
/// the ambient direction ([DabblerTypeStyle.resolveForDirection]), so Arabic
/// takes the Arabic face and leading.
///
/// ## Reduced motion
///
/// No animation, so nothing to switch off.
class DabblerTextLink extends StatelessWidget {
  /// Creates a link. Standalone unless [inline].
  const DabblerTextLink({
    super.key,
    required this.label,
    this.onPressed,
    this.style,
    this.inline = false,
    this.semanticsLabel,
    this.focusNode,
    this.autofocus = false,
    this.underline = true,
    this.trailingIcon,
    this.muted = false,
  });

  /// `text-underline-offset: 2px` (`Auth and Onboarding.dc.html:129`) has no
  /// Flutter equivalent; the underline is the text's own decoration.
  static const TextDecoration decoration = TextDecoration.underline;

  /// The inline link inside a sentence: a [WidgetSpan] on the alphabetic
  /// baseline. Pass the sentence's [style] so the link matches its size.
  static WidgetSpan span({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    TextStyle? style,
    String? semanticsLabel,
  }) => WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: DabblerTextLink(
      key: key,
      label: label,
      onPressed: onPressed,
      style: style,
      inline: true,
      semanticsLabel: semanticsLabel,
    ),
  );

  /// The visible text.
  final String label;

  /// Fired on tap, Enter or Space. Null disables the link.
  final VoidCallback? onPressed;

  /// Base style. Inline: the sentence's style (falls back to the ambient
  /// [DefaultTextStyle]). Standalone: replaces `.t-subheadline` medium. The
  /// colour and decoration are always the link's own.
  final TextStyle? style;

  /// Inline shape — no 45px padding (see the class doc's deviation).
  final bool inline;

  /// The accessible name, when it should differ from [label].
  final String? semanticsLabel;

  /// An external focus node.
  final FocusNode? focusNode;

  /// Focuses the link on mount.
  final bool autofocus;

  /// Whether the label is underlined. Default `true` (the auth links); pass
  /// `false` for a section-header link such as "Manage".
  final bool underline;

  /// Draws the label in the secondary ink instead of the brand colour — the
  /// muted "Clear all" of `Listings.dc.html:106` (`color: var(--muted)`).
  /// A disabled link is still the tertiary ink. Default false.
  final bool muted;

  /// An optional glyph after the label (standalone only; ignored inline),
  /// mirrored in RTL. Decorative — it adds nothing to the accessible name.
  final String? trailingIcon;

  /// The resolved text style for [colors] and [direction].
  TextStyle resolveStyle(
    BuildContext context,
    DabblerColors colors,
    TextDirection direction,
  ) {
    final TextStyle base = inline
        ? DefaultTextStyle.of(context).style.merge(style)
        : (style ??
              DabblerType.subheadline
                  .resolveForDirection(direction)
                  .copyWith(fontWeight: DabblerType.medium));
    final Color color = onPressed == null
        ? colors.textTertiary
        : muted
        ? colors.textSecondary
        : colors.brandPrimary;
    return base.copyWith(
      color: color,
      decoration: underline ? decoration : TextDecoration.none,
      decorationColor: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final bool enabled = onPressed != null;

    Widget text = Text(
      label,
      style: resolveStyle(context, colors, direction),
      maxLines: inline ? 1 : null,
      softWrap: !inline,
    );
    final String? glyph = trailingIcon;
    if (!inline && glyph != null) {
      text = Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(child: text),
          const SizedBox(width: DabblerSpacing.space1),
          DabblerIcon(
            glyph,
            size: DabblerSizing.iconSm,
            color: enabled ? colors.brandPrimary : colors.textTertiary,
            mirrorInRtl: true,
          ),
        ],
      );
    }
    if (!inline) {
      text = ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: DabblerSizing.touchTargetMin,
          minWidth: DabblerSizing.touchTargetMin,
        ),
        child: Align(widthFactor: 1, heightFactor: 1, child: text),
      );
    }

    return Semantics(
      link: true,
      enabled: enabled,
      label: semanticsLabel ?? label,
      excludeSemantics: true,
      onTap: onPressed,
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (ActivateIntent _) {
              onPressed?.call();
              return null;
            },
          ),
        },
        child: DabblerFocusRing(
          borderRadius: DabblerRadius.smAll,
          enabled: enabled,
          canRequestFocus: enabled,
          focusNode: focusNode,
          autofocus: autofocus,
          child: MouseRegion(
            cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onPressed,
              child: text,
            ),
          ),
        ),
      ),
    );
  }
}
