// =============================================================================
// Dabbler — Button component
// -----------------------------------------------------------------------------
// A flat, token-driven button. Every colour, size, radius, and weight is read
// from the design tokens (context.dabbler / DabblerType / DabblerSizing /
// DabblerRadius / DabblerSpacing) — nothing is hardcoded.
//
// Correctness note: label/icon colour on a brand or error surface is ALWAYS the
// matching on-token (onBrand / onError), never a literal white. Bright and Sport
// have LIGHT primaries whose onBrand is DARK, so hardcoding white would be
// illegible — reading the token is the only correct way.
//
// Flat by design: elevation is 0 everywhere. Press feedback is a tonal darken +
// a slight scale, never a shadow lift.
// =============================================================================

import 'package:flutter/material.dart';

import '../theme/dabbler_colors.dart';
import '../theme/dabbler_glass.dart';
import '../theme/dabbler_spacing.dart';
import '../theme/dabbler_type.dart';

/// Visual variants. `icon` is a square, tonal, icon-only button.
///
/// LAYERING LAW (see .claude/skills/dabbler-liquid-glass/SKILL.md): buttons that
/// live INSIDE content stay opaque — that is every variant below except the two
/// glass ones. [glass] / [glassActive] are ONLY for floating/chrome controls
/// (FABs, toolbar buttons, floating filter actions) rendered above content, on a
/// rich backdrop such as [DabblerGlassBackground]. If the button scrolls with
/// content, use an opaque variant.
enum DabblerButtonVariant {
  filled,
  tonal,
  outlined,
  text,
  destructive,
  icon,

  /// Floating glass control: blur 18 + saturation boost, gradient hairline,
  /// `raised` shadow, label = textPrimary. Chrome layer only.
  glass,

  /// Selected/engaged floating control: brandPrimary @ 85% + top-lit overlay,
  /// white @ 70% stroke, `active` shadow, label = onBrand (dark in Bright).
  glassActive,
}

/// Size steps — heights are base-3 (36 / 45 / 54); `medium` == touchTargetMin.
enum DabblerButtonSize { small, medium, large }

/// Public size metrics for each step — read by the docs' Specs table so it can
/// never drift from the component.
extension DabblerButtonMetrics on DabblerButtonSize {
  double get height => switch (this) {
        DabblerButtonSize.small => 36,
        DabblerButtonSize.medium => DabblerSizing.touchTargetMin, // 45
        DabblerButtonSize.large => 54,
      };

  double get horizontalPadding => switch (this) {
        DabblerButtonSize.small => DabblerSpacing.space4, // 12
        DabblerButtonSize.medium => DabblerSpacing.space6, // 18
        DabblerButtonSize.large => DabblerSpacing.space8, // 24
      };

  /// Label point size per step (15 / 17 / 17).
  double get labelSize => switch (this) {
        DabblerButtonSize.small => DabblerSpacing.space5, // 15
        DabblerButtonSize.medium => 17,
        DabblerButtonSize.large => 17,
      };
}

/// Resolved paint for one (variant × state) combination.
class _Paint {
  const _Paint({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;

  /// Border colour, or null for no border.
  final Color? border;
}

/// A token-driven button.
///
/// `onPressed == null` renders the disabled treatment and ignores taps.
/// `isLoading` swaps the content for an inline spinner (sized to the label),
/// keeps the button at its current layout width, and ignores taps.
///
/// ## Layering law (Liquid Glass)
/// Buttons inside scrolling content are **opaque** — use `filled`, `tonal`,
/// `outlined`, `text`, `destructive`, or `icon`. The `glass` / `glassActive`
/// variants are reserved for **floating chrome controls** (FABs, toolbar
/// actions, floating filters) rendered above content on a rich backdrop
/// ([DabblerGlassBackground]); they honour Reduce Transparency and
/// [DabblerGlassConfig.enabled] by falling back to an opaque bordered surface.
/// Rule of thumb: if it scrolls, it's opaque; if it floats, it's glass.
class DabblerButton extends StatefulWidget {
  const DabblerButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = DabblerButtonVariant.filled,
    this.size = DabblerButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = false,
  }) : icon = null;

  /// Square, icon-only button with the tonal treatment.
  const DabblerButton.icon({
    super.key,
    required IconData this.icon,
    this.onPressed,
    this.size = DabblerButtonSize.medium,
    this.isLoading = false,
  })  : label = '',
        variant = DabblerButtonVariant.icon,
        leadingIcon = null,
        trailingIcon = null,
        fullWidth = false;

  final String label;
  final VoidCallback? onPressed;
  final DabblerButtonVariant variant;
  final DabblerButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  /// Key on the painted surface, so tests can measure the visual button box
  /// (its height is exactly the size step: 36 / 45 / 54), independent of any
  /// extra tap-target padding wrapped around it.
  @visibleForTesting
  static const Key surfaceKey = ValueKey('dabbler_button_surface');

  bool get _isIcon => variant == DabblerButtonVariant.icon;
  bool get _isDisabled => onPressed == null;
  bool get _acceptsTaps => onPressed != null && !isLoading;

  @override
  State<DabblerButton> createState() => _DabblerButtonState();
}

class _DabblerButtonState extends State<DabblerButton> {
  bool _pressed = false;

  bool get _isGlassVariant =>
      widget.variant == DabblerButtonVariant.glass ||
      widget.variant == DabblerButtonVariant.glassActive;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final brightness = Theme.of(context).brightness;
    // Glass path only when enabled — a disabled glass button uses the shared
    // opaque disabled treatment below, like every other variant.
    final useGlass = _isGlassVariant && !widget._isDisabled;
    final paint = useGlass ? null : _resolvePaint(d, brightness);

    final foreground = useGlass
        ? (widget.variant == DabblerButtonVariant.glassActive
            ? d.onBrand // dark on Bright — NEVER hardcode white
            : d.textPrimary)
        : paint!.foreground;

    // Content — icon-only, or leading/label/trailing row.
    Widget content = widget._isIcon
        ? Icon(widget.icon, size: DabblerSizing.iconMd, color: foreground)
        : _buildRow(foreground);

    if (widget.isLoading) content = _wrapLoading(content, foreground);

    // Painted surface — fixed height, token radius (md, 9 — base-3).
    final Widget painted =
        useGlass ? _buildGlassSurface(d, content) : Container(
      key: DabblerButton.surfaceKey,
      height: widget.size.height,
      width: widget._isIcon ? widget.size.height : null, // square icon button
      alignment: Alignment.center,
      padding: widget._isIcon
          ? EdgeInsets.zero
          : EdgeInsetsDirectional.symmetric(
              horizontal: widget.size.horizontalPadding),
      decoration: BoxDecoration(
        color: paint?.background,
        borderRadius: DabblerRadius.mdRadius,
        border: paint?.border == null
            ? null
            : Border.all(
                color: paint!.border!,
                // ignore: avoid_redundant_argument_values  (token-driven, not a literal)
                width: DabblerSizing.borderDefault,
              ),
        // Opaque variants stay flat: no boxShadow.
      ),
      child: content,
    );

    final surface = AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 80),
      curve: Curves.easeOut,
      child: painted,
    );

    // Guarantee a >= touchTargetMin hit area even for the small step, without
    // changing the measured surface height.
    Widget tappable = surface;
    final extra = DabblerSizing.touchTargetMin - widget.size.height;
    if (extra > 0) {
      tappable = Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: extra / 2),
        child: surface,
      );
    }

    Widget button = MouseRegion(
      cursor: widget._acceptsTaps
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget._acceptsTaps ? widget.onPressed : null,
        onTapDown: widget._acceptsTaps ? (_) => _setPressed(true) : null,
        onTapUp: widget._acceptsTaps ? (_) => _setPressed(false) : null,
        onTapCancel: widget._acceptsTaps ? () => _setPressed(false) : null,
        child: tappable,
      ),
    );

    // Disabled: half-opacity and non-interactive.
    if (widget._isDisabled) {
      button = Opacity(
        opacity: 0.5,
        child: IgnorePointer(child: button),
      );
    } else if (widget.isLoading) {
      // Loading keeps full styling but swallows taps.
      button = IgnorePointer(child: button);
    }

    if (widget.fullWidth && !widget._isIcon) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return Semantics(
      button: true,
      enabled: !widget._isDisabled,
      label: widget._isIcon ? null : widget.label,
      child: button,
    );
  }

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  /// The floating-control glass treatments (skill recipe: blur + saturation
  /// boost + tinted overlay/highlight stroke). Pressed deepens the shadow cast;
  /// the slight scale is applied by the shared AnimatedScale.
  Widget _buildGlassSurface(DabblerColors d, Widget content) {
    final active = widget.variant == DabblerButtonVariant.glassActive;
    final shadows = active
        ? DabblerGlassShadows.active(d)
        : DabblerGlassShadows.raised(d);

    return SizedBox(
      key: DabblerButton.surfaceKey,
      height: widget.size.height,
      width: widget._isIcon ? widget.size.height : null,
      child: DabblerGlass(
        // Skill blur radii: floating control 18, selected/active control 16.
        blur: active ? 16 : 18,
        borderRadius: DabblerRadius.mdRadius, // 9 — base-3 button radius
        tint: active ? d.brandPrimary.withValues(alpha: 0.85) : null,
        overlay: active
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  dabblerBrandLight(d).withValues(alpha: 0.5),
                  dabblerBrandLight(d).withValues(alpha: 0.0),
                ],
              )
            : null,
        strokeColor: active ? Colors.white.withValues(alpha: 0.7) : null,
        shadows:
            _pressed ? DabblerGlassShadows.deepen(shadows) : shadows,
        child: Container(
          alignment: Alignment.center,
          padding: widget._isIcon
              ? EdgeInsets.zero
              : EdgeInsetsDirectional.symmetric(
                  horizontal: widget.size.horizontalPadding),
          child: content,
        ),
      ),
    );
  }

  /// Leading icon · label · trailing icon. Row honours the ambient
  /// [Directionality], so `start`/`end` (not left/right) placement is automatic
  /// and RTL-safe.
  Widget _buildRow(Color fg) {
    final labelStyle = DabblerType.headline.copyWith(
      fontSize: widget.size.labelSize,
      color: fg,
    );
    return Row(
      mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leadingIcon != null) ...[
          Icon(widget.leadingIcon, size: DabblerSizing.iconMd, color: fg),
          const SizedBox(width: DabblerSpacing.iconGap),
        ],
        Flexible(
          child: Text(
            widget.label,
            style: labelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: DabblerSpacing.iconGap),
          Icon(widget.trailingIcon, size: DabblerSizing.iconMd, color: fg),
        ],
      ],
    );
  }

  /// Overlay an inline spinner sized to the label, keeping the content's width
  /// (the label stays in the tree at zero opacity) so the button doesn't resize.
  Widget _wrapLoading(Widget content, Color fg) {
    final spinnerSize = widget._isIcon
        ? DabblerSizing.iconMd
        : widget.size.labelSize;
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: 0, child: content),
        SizedBox(
          width: spinnerSize,
          height: spinnerSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(fg),
          ),
        ),
      ],
    );
  }

  /// Maps variant + state → background / foreground / border, all from tokens.
  _Paint _resolvePaint(DabblerColors d, Brightness brightness) {
    // Disabled overrides everything: fill → borderDefault, label → textSecondary.
    if (widget._isDisabled) {
      final filledLike = widget.variant != DabblerButtonVariant.outlined &&
          widget.variant != DabblerButtonVariant.text;
      return _Paint(
        background: filledLike ? d.borderDefault : Colors.transparent,
        foreground: d.textSecondary,
        border: filledLike ? null : d.borderDefault,
      );
    }

    switch (widget.variant) {
      // Enabled glass variants take the _buildGlassSurface path and never reach
      // this switch; these cases exist for exhaustiveness only.
      case DabblerButtonVariant.glass:
        return _Paint(
          background: Colors.transparent,
          foreground: d.textPrimary,
          border: null,
        );
      case DabblerButtonVariant.glassActive:
        return _Paint(
          background: Colors.transparent,
          foreground: d.onBrand,
          border: null,
        );

      case DabblerButtonVariant.filled:
        return _Paint(
          background: _maybePress(d.brandPrimary),
          foreground: d.onBrand, // dark on Bright/Sport — never hardcode white
          border: null,
        );

      case DabblerButtonVariant.destructive:
        return _Paint(
          background: _maybePress(d.error),
          foreground: d.onError,
          border: null,
        );

      case DabblerButtonVariant.tonal:
      case DabblerButtonVariant.icon:
        final tint = _tonalTint(d, brightness);
        return _Paint(
          background: _maybePress(tint),
          foreground: _readableBrandTone(d, tint),
          border: null,
        );

      case DabblerButtonVariant.outlined:
        return _Paint(
          background: _pressed
              ? d.brandPrimary.withValues(alpha: 0.08)
              : Colors.transparent,
          foreground: d.brandPrimary,
          border: d.borderDefault,
        );

      case DabblerButtonVariant.text:
        return _Paint(
          background: _pressed
              ? d.brandPrimary.withValues(alpha: 0.08)
              : Colors.transparent,
          foreground: d.brandPrimary,
          border: null,
        );
    }
  }

  /// Darken a fill by ~12% (brightness × 0.88) while pressed — the flat, tonal
  /// press feedback. No-op when not pressed.
  Color _maybePress(Color c) {
    if (!_pressed) return c;
    final hsv = HSVColor.fromColor(c);
    return hsv.withValue((hsv.value * 0.88).clamp(0.0, 1.0)).toColor();
  }

  /// Tonal background: a tint of brandPrimary toward the page surface.
  Color _tonalTint(DabblerColors d, Brightness brightness) {
    final t = brightness == Brightness.dark ? 0.72 : 0.86;
    return Color.lerp(d.brandPrimary, d.bgPrimary, t)!;
  }

  /// A readable, brand-derived label tone for the tonal surface: whichever of
  /// the brand tones (or the brand-tinted textPrimary) contrasts best against
  /// [bg]. This keeps tonal labels brand-coloured where legible (e.g. dark mode)
  /// and falls back to textPrimary where a light primary would be washed out
  /// (e.g. Bright).
  Color _readableBrandTone(DabblerColors d, Color bg) {
    final candidates = <Color>[d.brandPrimary, d.brandPrimaryHover, d.textPrimary];
    candidates.sort((a, b) => _contrast(b, bg).compareTo(_contrast(a, bg)));
    return candidates.first;
  }

  static double _contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }
}
