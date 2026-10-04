import 'package:flutter/widgets.dart';

import '../tokens/dabbler_geometry.dart';
import 'page.dart';

/// DetailPage — the scaffold of a detail screen: a header that bleeds under the
/// status bar, a gutter-padded stack of sections that scrolls with it, and an
/// optional bar pinned to the bottom.
///
/// Drawn from the three Details frames (`Details.dc.html:44-190`, `:224-366`,
/// `:384-529`): one scroll column whose first child is the full-bleed header
/// (a [DabblerDetailHeader] band or a [DabblerGalleryHero]), followed by a body
/// padded `18 18 …` whose sections are stacked 15 apart, over a bar pinned to
/// the bottom of the screen.
///
/// ```dart
/// DabblerDetailPage(
///   header: DabblerDetailHeader(title: 'Tuesday 5-a-side', ...),
///   bottomBar: DabblerActionBar(price: 'AED 40', primary: join),
///   children: <Widget>[
///     DabblerHeadcount(...),
///     DabblerStatGrid(...),
///   ],
/// )
/// ```
///
/// ## What it owns
///
/// * the page — [DabblerPage] with an empty top bar, which turns its own top
///   inset off so the header can bleed under the status bar and pad it itself;
/// * the scroll — a bouncing [CustomScrollView], driven by [controller] when
///   one is given (deep-link scrolling to a section);
/// * the gutter — [DabblerSpacing.space6] (18) at the sides and the top of the
///   body, [DabblerSpacing.space8] (24) closing it;
/// * the rhythm — [DabblerSpacing.space5] (15) between sections;
/// * the width — the body and [banner] are held to [maxContentWidth] and
///   centred on a wide screen.
///
/// ## Slots
///
/// * [banner] — a strip above the header (the mobile-web "open in the app"
///   banner). It is not part of the design frame; it is the one place a screen
///   may add something above it.
/// * [header] — full width, not padded.
/// * [children] — the sections.
/// * [bottomBar] — normally a [DabblerActionBar]; the page shrinks the body
///   above it.
///
/// ## RTL
///
/// Nothing here is directional beyond the gutter, which is symmetrical.
class DabblerDetailPage extends StatelessWidget {
  /// A detail page.
  const DabblerDetailPage({
    super.key,
    required this.header,
    required this.children,
    this.bottomBar,
    this.banner,
    this.controller,
  });

  /// The full-bleed header.
  final Widget header;

  /// The sections under the header, stacked [sectionGap] apart.
  final List<Widget> children;

  /// The bar pinned to the bottom of the screen.
  final Widget? bottomBar;

  /// A strip above the header.
  final Widget? banner;

  /// Drives the scroll; null uses an internal one.
  final ScrollController? controller;

  /// The body's side and top padding — [DabblerSpacing.space6] (18).
  static const double gutter = DabblerSpacing.space6;

  /// The gap between sections — [DabblerSpacing.space5] (15).
  static const double sectionGap = DabblerSpacing.space5;

  /// The body's closing padding — [DabblerSpacing.space8] (24).
  static const double closing = DabblerSpacing.space8;

  /// The widest the body grows before it is centred — `700`.
  static const double maxContentWidth = 700;

  @override
  Widget build(BuildContext context) {
    final Widget body = Align(
      alignment: AlignmentDirectional.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            gutter,
            gutter,
            gutter,
            closing,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: sectionGap,
            children: children,
          ),
        ),
      ),
    );

    return DabblerPage(
      // The header bleeds under the status bar, so the page must not inset the
      // top itself: a top bar, even an empty one, turns that inset off.
      topBar: const SizedBox.shrink(),
      bottomBar: bottomBar,
      body: CustomScrollView(
        controller: controller,
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          if (banner != null)
            // The banner takes the status-bar inset; the header below it then
            // has none left to pad.
            SliverToBoxAdapter(child: SafeArea(bottom: false, child: banner!)),
          SliverToBoxAdapter(
            child: banner == null
                ? header
                : MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: header,
                  ),
          ),
          SliverToBoxAdapter(child: body),
        ],
      ),
    );
  }
}
