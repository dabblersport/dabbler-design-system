import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../foundations/icon.dart';
import '../interaction/focus_ring.dart';
import '../tokens/dabbler_colors.dart';
import '../navigation/step_progress.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_layout.dart';
import '../tokens/dabbler_type.dart';
import '../foundations/text.dart';
import 'page.dart';

/// FlowPage — the screen template of a one-way flow such as onboarding: an
/// optional back button, an optional segmented progress, a display title and
/// subtitle, a scrolling (or vertically centred) body, and a footer holding
/// one full-width primary action.
///
/// Every frame of `Auth and Onboarding.dc.html` between sign-in and the home
/// feed has this shape, and the design draws the same paddings in each:
///
/// | frame | source | what it uses |
/// |---|---|---|
/// | Steps 1-5 | `:329-452` | back, [stepCount]/[stepIndex]/[stepLabel], title, subtitle, body, banner, primary |
/// | New user welcome | `:301-326` | title ([DabblerType.largeTitle]), subtitle, body, primary |
/// | Welcome back | `:287-299` | [centered], [leading] avatar, title, subtitle, primary |
/// | Setup progress | `:456-492` | [centered], title, subtitle, body, no footer |
/// | Persona welcome | `:494-529` | [leading] header row, [spreadChildren], [background], primary |
///
/// ## Layout
///
/// Everything sits in a column that is at most [maxContentWidth] wide and
/// centred, so a wide window shows the phone layout rather than stretching it.
///
/// | band | padding (start, top, end, bottom) | source |
/// |---|---|---|
/// | back row | `space8` sides, `space2` top | `:330` — `6px 24px 0` |
/// | header (progress, title, subtitle) | `space8` sides, `space2` top | `:334` — `6px 24px 0` |
/// | body | `space8` sides, [bodyTopPadding] top | `:353` — `18px 24px 0` |
/// | footer | `space8` sides, `space6` top, [footerBottomPadding] bottom | `:442` — `18px 24px 24px` |
///
/// Children of the body are separated by [bodyGap] (`:353`, `gap:18px`).
///
/// ## Props that change the frame
///
/// * [centered] puts the title block, [leading] and the children in one
///   vertically centred column and gives them [bodyGap] between them — the
///   Welcome back and Setup progress frames.
/// * [spreadChildren] stretches the children over the full body height with
///   the space between them (`justify-content: space-between`, `:507`), so a
///   last card rests at the bottom while the page [background] shows between.
/// * [background] is painted behind everything, full bleed — the persona
///   welcome's sport artwork (`:495-497`).
///
/// ## Footer
///
/// The footer is a [DabblerButton] full width, loading while
/// [primaryLoading], disabled while [onPrimary] is null and not loading. A
/// [footerBanner] sits above it with `space3` between (`:443-446`);
/// [secondary] sits under it.
///
/// ## RTL
///
/// Nothing here is directional but the back arrow, which mirrors.
class DabblerFlowPage extends StatelessWidget {
  /// A flow page.
  const DabblerFlowPage({
    super.key,
    this.onBack,
    this.backLabel,
    this.stepCount,
    this.stepIndex,
    this.stepLabel,
    this.title,
    this.subtitle,
    this.titleStyle = DabblerType.title1,
    this.subtitleStyle = DabblerType.subheadline,
    this.titleGap = DabblerSpacing.space2,
    this.leading,
    this.content = const <Widget>[],
    this.centered = false,
    this.spreadChildren = false,
    this.bodyGap = DabblerSpacing.space6,
    this.bodyTopPadding = DabblerSpacing.space6,
    this.bodyBottomPadding = 0,
    this.footerBottomPadding = DabblerSpacing.space8,
    this.headerTopPadding,
    this.footerBanner,
    this.primaryLabel,
    this.onPrimary,
    this.primaryLoading = false,
    this.secondary,
    this.background,
  }) : assert(
         (stepCount == null) == (stepIndex == null),
         'give stepCount and stepIndex together',
       ),
       assert(
         onBack == null || backLabel != null,
         'a back button needs its accessible label',
       );

  /// The content never grows wider than this, `480`.
  static const double maxContentWidth = 480;

  /// The back arrow's glyph size — 24, drawn inside the standard 45px target
  /// (`Auth and Onboarding.dc.html:150`, `<Icon name="arrow-left" size="24">`;
  /// the same at `:183`, `:213`, `:332`). Was 20 (the icon-only default)
  /// until 2026-10-04 (KAN-426), when the design's flow frames were measured.
  static const double backGlyphSize = 24;

  /// Called by the back button. Null draws no back row.
  final VoidCallback? onBack;

  /// The back button's accessible label, already localised.
  final String? backLabel;

  /// How many segments the progress has. Null draws no progress.
  final int? stepCount;

  /// The zero-based step on screen.
  final int? stepIndex;

  /// The caption under the progress ("Step 3 of 5").
  final String? stepLabel;

  /// The display title.
  final String? title;

  /// The line under the title.
  final String? subtitle;

  /// Padding under the scrolling body, above the footer. Default `0`. The
  /// persona welcome frame pads the body bottom by `24` so its last card sits
  /// 42 above the primary button (`DabblerSpacing.space8`). Ignored by the
  /// [centered] layout, which is not a scrolling body.
  final double bodyBottomPadding;

  /// The title's type step. Default [DabblerType.title1].
  final DabblerTypeStyle titleStyle;

  /// The subtitle's type step. Default [DabblerType.subheadline].
  final DabblerTypeStyle subtitleStyle;

  /// The space between the title and the subtitle. Default `space2` (6); the
  /// email, log-in, code and welcome-back frames give `space3` (9)
  /// (`Auth and Onboarding.dc.html`, title block `gap:9px`).
  final double titleGap;

  /// A widget above the title block — an avatar or a header row.
  final Widget? leading;

  /// The body, separated by [bodyGap].
  final List<Widget> content;

  /// Whether the title block, [leading] and [content] sit in one vertically
  /// centred column instead of a scrolling body under the header.
  final bool centered;

  /// Whether [content] spread over the full body height.
  final bool spreadChildren;

  /// The space between the body's children.
  final double bodyGap;

  /// The space above the body.
  final double bodyTopPadding;

  /// The space under the footer.
  final double footerBottomPadding;

  /// The space above the header. Null is `space2` under a back row and
  /// `space6` without one; the email, log-in and code frames give `space4`
  /// (`Auth and Onboarding.dc.html:153`, `padding: 12px 24px 0`).
  final double? headerTopPadding;

  /// A widget above the primary action, usually a `DabblerBanner`.
  final Widget? footerBanner;

  /// The primary action's label. Null draws no footer action.
  final String? primaryLabel;

  /// The primary action. Null disables it.
  final VoidCallback? onPrimary;

  /// Whether the primary action shows its loading state.
  final bool primaryLoading;

  /// A widget under the primary action.
  final Widget? secondary;

  /// Full-bleed art painted behind the page.
  final Widget? background;

  Widget _titleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (title != null) DabblerText(title!, style: titleStyle),
        if (title != null && subtitle != null) DabblerGap.v(titleGap),
        if (subtitle != null)
          DabblerText(
            subtitle!,
            style: subtitleStyle,
            tone: DabblerTextTone.secondary,
          ),
      ],
    );
  }

  List<Widget> _spaced(List<Widget> items, double gap) => <Widget>[
    for (int i = 0; i < items.length; i++) ...<Widget>[
      if (i > 0) DabblerGap.v(gap),
      items[i],
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final bool hasTitle = title != null || subtitle != null;
    final EdgeInsetsGeometry sides = const EdgeInsetsDirectional.symmetric(
      horizontal: DabblerSpacing.space8,
    );

    Widget header = const SizedBox.shrink();
    if (!centered) {
      final List<Widget> parts = <Widget>[
        if (stepCount != null)
          DabblerStepProgress(
            count: stepCount!,
            current: stepIndex!,
            label: stepLabel,
          ),
        if (stepCount != null && hasTitle)
          const DabblerGap.v(DabblerSpacing.space5),
        if (hasTitle) _titleBlock(),
      ];
      header = Padding(
        padding: EdgeInsetsDirectional.only(
          start: DabblerSpacing.space8,
          end: DabblerSpacing.space8,
          top:
              headerTopPadding ??
              (onBack != null ? DabblerSpacing.space2 : DabblerSpacing.space6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[?leading, ...parts],
        ),
      );
    }

    final List<Widget> bodyItems = centered
        ? <Widget>[?leading, if (hasTitle) _titleBlock(), ...content]
        : content;

    Widget body;
    if (centered) {
      body = Padding(
        padding: sides,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _spaced(bodyItems, bodyGap),
        ),
      );
    } else if (spreadChildren) {
      body = LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            padding: EdgeInsetsDirectional.only(
              start: DabblerSpacing.space8,
              end: DabblerSpacing.space8,
              top: bodyTopPadding,
              bottom: bodyBottomPadding,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    constraints.maxHeight - bodyTopPadding - bodyBottomPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: bodyItems,
              ),
            ),
          );
        },
      );
    } else {
      body = bodyItems.isEmpty
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              padding: EdgeInsetsDirectional.only(
                start: DabblerSpacing.space8,
                end: DabblerSpacing.space8,
                top: bodyTopPadding,
                bottom: bodyBottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _spaced(bodyItems, bodyGap),
              ),
            );
    }

    final bool hasFooter =
        primaryLabel != null || footerBanner != null || secondary != null;

    final Widget column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (onBack != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(
              start: DabblerSpacing.space4,
              top: DabblerSpacing.space2,
              end: DabblerSpacing.space8,
            ),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _FlowBackButton(label: backLabel!, onPressed: onBack!),
            ),
          ),
        if (!centered) header,
        Expanded(child: body),
        if (hasFooter)
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: DabblerSpacing.space8,
              end: DabblerSpacing.space8,
              top: DabblerSpacing.space6,
              bottom: footerBottomPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (footerBanner != null) ...<Widget>[
                  footerBanner!,
                  const DabblerGap.v(DabblerSpacing.space3),
                ],
                if (primaryLabel != null)
                  DabblerButton(
                    label: primaryLabel!,
                    size: DabblerButtonSize.full,
                    fullWidth: true,
                    loading: primaryLoading,
                    disabled: onPrimary == null && !primaryLoading,
                    onPressed: onPrimary,
                  ),
                if (secondary != null) ...<Widget>[
                  const DabblerGap.v(DabblerSpacing.space3),
                  secondary!,
                ],
              ],
            ),
          ),
      ],
    );

    final Widget constrained = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: column,
      ),
    );

    if (background == null) return DabblerPage(body: constrained);

    // The art is full bleed, under the status bar and the home indicator; the
    // content keeps the safe area.
    return ColoredBox(
      color: DabblerColors.of(context).bgPrimary,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          background!,
          SafeArea(child: constrained),
        ],
      ),
    );
  }
}

/// The flow page's back control: exactly a 45x45 square (the frame's
/// `width:45px;height:45px`) holding the 24px `arrow-circle-left`, with no
/// horizontal padding, so the glyph is centred 22.5 in from the box edge. The
/// page seats the box 12 from the screen edge (the frame's `margin-left:-12px`
/// inside its 24px gutter). It replaces the icon [DabblerButton], whose box
/// was 64 wide.
class _FlowBackButton extends StatelessWidget {
  const _FlowBackButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: DabblerFocusRing(
        enabled: true,
        canRequestFocus: true,
        borderRadius: DabblerRadius.pillAll,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onPressed,
          child: SizedBox(
            width: DabblerSizing.touchTargetMin,
            height: DabblerSizing.touchTargetMin,
            child: Center(
              child: DabblerIcon(
                'arrow-circle-left',
                mirrorInRtl: true,
                size: DabblerFlowPage.backGlyphSize,
                color: DabblerColors.of(context).textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
