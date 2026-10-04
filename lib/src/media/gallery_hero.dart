import 'package:flutter/widgets.dart';

import '../surfaces/surface.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_motion.dart';
import '../tokens/dabbler_type.dart';
import 'image.dart';

/// One page of a [DabblerGalleryHero].
@immutable
class DabblerGallerySlide {
  /// A slide: a photograph at [imageUrl], and/or a [child] drawn centred over
  /// the ground, with an optional caption pill.
  const DabblerGallerySlide({this.imageUrl, this.child, this.label});

  /// The photograph's address. Null or blank leaves the sunken ground — the
  /// design's empty `image-slot`.
  final String? imageUrl;

  /// A widget drawn centred over the ground — a sport glyph standing in for a
  /// photograph that does not exist yet.
  final Widget? child;

  /// The caption pill at the inline-start bottom corner
  /// (`Details.dc.html:393`: "General", "Space 1").
  final String? label;
}

/// GalleryHero — the photo carousel that opens a detail screen: paged slides
/// under a row of round buttons, caption pills and a dot indicator.
///
/// Drawn from the venue frame (`Details.dc.html:386-418`): a 210px band of
/// full-width slides that snap, each with an ink caption pill at its inline
/// start (`left:18; bottom:42`), five dots centred 14 from the bottom (the
/// active one 18 wide in the page colour, the rest 5 wide at 55%), and — over
/// the photograph — back on the inline start with favourite and share on the
/// inline end, in page-coloured circles.
///
/// ```dart
/// DabblerGalleryHero(
///   slides: <DabblerGallerySlide>[
///     DabblerGallerySlide(imageUrl: url, label: 'General'),
///   ],
///   leading: DabblerOnColorIconButton(
///     onSurface: true,
///     icon: 'arrow-circle-left',
///     mirrorInRtl: true,
///     semanticLabel: 'Back',
///     onPressed: back,
///   ),
///   actions: <Widget>[ ... ],
/// )
/// ```
///
/// ## Why a new component
///
/// `DabblerImage` is a single-image frame and says so ("no carousel is
/// built"); `DabblerPageDots` is brand-coloured for a light page and would
/// vanish on a photograph. A hero that pages, captions and carries the
/// screen's own buttons is a different shape.
///
/// ## Behaviour
///
/// Paging is a [PageView] — swipe, with the position kept in the dots. It runs
/// in the reading direction, so the first slide is at the inline start and the
/// swipe reverses in Arabic. There is no auto-advance: the design scrolls by
/// hand. With one slide the dots are not drawn.
///
/// ## Safe area
///
/// The hero is [height] tall **plus** the top safe-area inset, and the buttons
/// sit [buttonsTop] below the status bar, so it can bleed under it; pair it
/// with a page whose top bar is empty ([DabblerDetailPage] does).
///
/// ## RTL
///
/// Slides, caption pill, dots and buttons all mirror: the caption sits at the
/// right edge in Arabic and [leading] at the right.
class DabblerGalleryHero extends StatefulWidget {
  /// A gallery hero.
  const DabblerGalleryHero({
    super.key,
    required this.slides,
    this.leading,
    this.actions = const <Widget>[],
    this.onPageChanged,
  }) : assert(slides.length > 0, 'a gallery has at least one slide');

  /// The pages, in reading order.
  final List<DabblerGallerySlide> slides;

  /// The inline-start button over the photograph — back.
  final Widget? leading;

  /// The inline-end buttons — favourite, share.
  final List<Widget> actions;

  /// Called with the new zero-based page when the swipe settles on it.
  final ValueChanged<int>? onPageChanged;

  /// The band's height below the status bar — `210`
  /// (`Details.dc.html:387`).
  static const double height = 210;

  /// The buttons' offset from the top of the band, below the safe area —
  /// [DabblerSpacing.space5] (15).
  static const double buttonsTop = DabblerSpacing.space5;

  /// The side inset of the buttons and the caption — [DabblerSpacing.space6].
  static const double inset = DabblerSpacing.space6;

  /// The caption's distance from the bottom — `42`.
  static const double captionBottom = 42;

  /// The dots' distance from the bottom — `14`.
  static const double dotsBottom = 14;

  /// An idle dot's width and every dot's height — `5`.
  static const double dotSize = 5;

  /// The active dot's width — `18`.
  static const double dotActiveWidth = DabblerSpacing.space6;

  /// An idle dot's opacity over the page colour — `0.55`.
  static const double dotIdleOpacity = 0.55;

  @override
  State<DabblerGalleryHero> createState() => _DabblerGalleryHeroState();
}

class _DabblerGalleryHeroState extends State<DabblerGalleryHero> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changed(int page) {
    setState(() => _index = page);
    widget.onPageChanged?.call(page);
  }

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final TextDirection direction = Directionality.of(context);
    final double top = MediaQuery.paddingOf(context).top;
    final List<DabblerGallerySlide> slides = widget.slides;

    return SizedBox(
      height: DabblerGalleryHero.height + top,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: PageView.builder(
              controller: _controller,
              itemCount: slides.length,
              onPageChanged: _changed,
              itemBuilder: (BuildContext context, int i) {
                final DabblerGallerySlide slide = slides[i];
                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    DabblerImage(
                      url: slide.imageUrl,
                      radius: BorderRadius.zero,
                    ),
                    if (slide.child != null) Center(child: slide.child),
                    if (slide.label != null)
                      PositionedDirectional(
                        start: DabblerGalleryHero.inset,
                        bottom: DabblerGalleryHero.captionBottom,
                        child: DabblerSurface(
                          fill: colors.textPrimary,
                          borderColor: colors.textPrimary,
                          radius: DabblerRadius.pill,
                          padding: const EdgeInsets.symmetric(
                            horizontal: DabblerSpacing.space3 + 1,
                            vertical: DabblerSpacing.space1 + 2,
                          ),
                          child: Text(
                            slide.label!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: DabblerType.caption2
                                .resolveForDirection(direction)
                                .copyWith(
                                  color: colors.bgPrimary,
                                  fontWeight: DabblerType.bold,
                                ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          if (slides.length > 1)
            PositionedDirectional(
              start: 0,
              end: 0,
              bottom: DabblerGalleryHero.dotsBottom,
              child: ExcludeSemantics(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for (int i = 0; i < slides.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DabblerSpacing.space1 / 2,
                        ),
                        child: AnimatedContainer(
                          duration: DabblerMotion.durationOf(
                            context,
                            DabblerMotion.base,
                          ),
                          curve: DabblerMotion.easeOut,
                          width: i == _index
                              ? DabblerGalleryHero.dotActiveWidth
                              : DabblerGalleryHero.dotSize,
                          height: DabblerGalleryHero.dotSize,
                          decoration: BoxDecoration(
                            borderRadius: DabblerRadius.pillAll,
                            color: i == _index
                                ? colors.bgPrimary
                                : colors.bgPrimary.withValues(
                                    alpha: DabblerGalleryHero.dotIdleOpacity,
                                  ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          PositionedDirectional(
            top: top + DabblerGalleryHero.buttonsTop,
            start: DabblerGalleryHero.inset,
            end: DabblerGalleryHero.inset,
            child: Row(
              children: <Widget>[
                ?widget.leading,
                const Spacer(),
                for (int i = 0; i < widget.actions.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(width: DabblerSpacing.space3),
                  widget.actions[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
