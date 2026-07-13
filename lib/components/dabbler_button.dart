// =============================================================================
// Dabbler — Button component (Liquid Glass)
// -----------------------------------------------------------------------------
// A token-driven glass button. Every colour, size, radius, and weight is read
// from the design tokens (context.dabbler / DabblerGlass / DabblerType /
// DabblerSizing / DabblerRadius / DabblerSpacing) — nothing is hardcoded.
//
//   filled / destructive → the "selected chip" treatment: brand (or error) fill
//     @85% + a top-lit sheen + a white stroke + the selected glass shadow.
//   tonal / outlined     → glass surface + the gradient hairline.
//   text                 → unchanged (no surface, no shadow).
//   icon                 → a circular glass button (the design's arrow buttons).
//
// Correctness note: label/icon colour on a brand or error surface is ALWAYS the
// matching on-token (onBrand / onError), never a literal white. Bright and Sport
// have LIGHT primaries whose onBrand is DARK, so hardcoding white would be
// illegible — reading the token is the only correct way.
//
// Press feedback = deepen the glass shadow + a slight scale.
// =============================================================================

import 'package:flutter/material.dart';

import '../theme/dabbler_colors.dart';
import '../theme/dabbler_glass.dart';
import '../theme/dabbler_spacing.dart';
import '../theme/dabbler_type.dart';

/// Visual variants. `icon` is a circular, glass, icon-only button.
enum DabblerButtonVariant { filled, tonal, outlined, text, destructive, icon }

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
    required this.foreground,
    this.fill,
    this.overlay,
    this.borderColor,
    this.shadows,
    this.blur = DabblerGlass.blurSmall,
    this.glass = true,
    this.plainBackground,
  });

  /// Label / icon colour.
  final Color foreground;

  /// Glass path (when [glass] is true).
  final Color? fill; // null → DabblerGlass.fill for the brightness
  final Gradient? overlay; // top-lit sheen (selected treatment)
  final Color? borderColor; // null → the gradient hairline
  final List<BoxShadow>? shadows;
  final double blur;

  /// When false, render a plain (non-glass) container: the `text` variant and
  /// the disabled state.
  final bool glass;
  final Color? plainBackground;
}

/// A flat, token-driven button.
///
/// `onPressed == null` renders the disabled treatment and ignores taps.
/// `isLoading` swaps the content for an inline spinner (sized to the label),
/// keeps the button at its current layout width, and ignores taps.
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

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final brightness = Theme.of(context).brightness;
    final paint = _resolvePaint(d, brightness);

    // Content — icon-only, or leading/label/trailing row.
    Widget content = widget._isIcon
        ? Icon(widget.icon, size: DabblerSizing.iconMd, color: paint.foreground)
        : _buildRow(paint.foreground);

    if (widget.isLoading) content = _wrapLoading(content, paint.foreground);

    // The icon variant is circular (the design's arrow buttons); labelled
    // buttons keep the token button radius.
    final radius =
        widget._isIcon ? DabblerRadius.pillRadius : DabblerRadius.mdRadius;
    final contentPadding = widget._isIcon
        ? EdgeInsets.zero
        : EdgeInsetsDirectional.symmetric(
            horizontal: widget.size.horizontalPadding);

    // Painted surface — fixed height; press deepens the shadow (never lifts).
    final Widget painted;
    if (paint.glass) {
      final shadows = paint.shadows;
      painted = DabblerGlassSurface(
        key: DabblerButton.surfaceKey,
        height: widget.size.height,
        width: widget._isIcon ? widget.size.height : null,
        borderRadius: radius,
        blur: paint.blur,
        fill: paint.fill,
        overlay: paint.overlay,
        borderColor: paint.borderColor,
        shadows: _pressed && shadows != null
            ? DabblerGlass.deepen(shadows)
            : shadows,
        alignment: Alignment.center,
        padding: contentPadding,
        child: content,
      );
    } else {
      painted = Container(
        key: DabblerButton.surfaceKey,
        height: widget.size.height,
        width: widget._isIcon ? widget.size.height : null,
        alignment: Alignment.center,
        padding: contentPadding,
        decoration: BoxDecoration(
          color: paint.plainBackground,
          borderRadius: radius,
        ),
        child: content,
      );
    }

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

  /// Maps variant + state → glass treatment, all from tokens.
  _Paint _resolvePaint(DabblerColors d, Brightness b) {
    // Disabled overrides everything: solid fill → borderDefault, label →
    // textSecondary, no glass, no shadow (plus the 50% opacity wrapper).
    if (widget._isDisabled) {
      final filledLike = widget.variant != DabblerButtonVariant.text;
      return _Paint(
        glass: false,
        plainBackground:
            filledLike ? d.borderDefault : Colors.transparent,
        foreground: d.textSecondary,
      );
    }

    switch (widget.variant) {
      // The "selected chip" treatment from the design: near-opaque brand fill,
      // a top-lit sheen, a white stroke, and the selected glass shadow.
      case DabblerButtonVariant.filled:
        return _Paint(
          fill: DabblerGlass.selectedFill(d),
          overlay: DabblerGlass.selectedOverlay(d),
          borderColor: DabblerGlass.selectedStroke(),
          shadows: DabblerGlass.selectedShadows(d, b),
          blur: DabblerGlass.blurSelected,
          foreground: d.onBrand, // dark on Bright/Sport — never hardcode white
        );

      // Same treatment over the error colour.
      case DabblerButtonVariant.destructive:
        return _Paint(
          fill: DabblerGlass.selectedFill(d, base: d.error),
          overlay: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.5],
            colors: [
              Color.lerp(d.error, Colors.white, 0.5)!.withValues(alpha: 0.5),
              Color.lerp(d.error, Colors.white, 0.5)!.withValues(alpha: 0.0),
            ],
          ),
          borderColor: DabblerGlass.selectedStroke(),
          shadows: DabblerGlass.selectedShadows(d, b, base: d.error),
          blur: DabblerGlass.blurSelected,
          foreground: d.onError,
        );

      // Standard glass + the gradient hairline.
      case DabblerButtonVariant.tonal:
        return _Paint(
          shadows: DabblerGlass.raisedShadows(d, b),
          foreground: d.brandPrimary,
        );

      // Lighter glass density for the quieter option.
      case DabblerButtonVariant.outlined:
        return _Paint(
          fill: Colors.white
              .withValues(alpha: b == Brightness.dark ? 0.05 : 0.08),
          shadows: DabblerGlass.raisedShadows(d, b),
          foreground: d.brandPrimary,
        );

      // Circular glass arrow/icon button (blur = _Paint's blurSmall default).
      case DabblerButtonVariant.icon:
        return _Paint(
          shadows: DabblerGlass.raisedShadows(d, b),
          foreground: d.brandPrimary,
        );

      // Unchanged: no surface, no shadow.
      case DabblerButtonVariant.text:
        return _Paint(
          glass: false,
          plainBackground: _pressed
              ? d.brandPrimary.withValues(alpha: 0.08)
              : Colors.transparent,
          foreground: d.brandPrimary,
        );
    }
  }
}
