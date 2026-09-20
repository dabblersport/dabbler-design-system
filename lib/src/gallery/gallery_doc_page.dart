/// The screen that turns a documentation asset path into a page a reader can
/// navigate to — `KAN-327`, `D-033`(e) / `D-042`.
///
/// **It assembles; it does not style.** Every piece of chrome here already
/// existed: [GalleryPaper], [GalleryPageHeader], and — inside
/// [DabblerDocPageView] — `GallerySectionLabel`, `GalleryUsage`,
/// `GalleryGroup` and `GalleryRule`. Nothing in `gallery_page.dart` is
/// restyled and no new appearance is decided (`D-041`(c)4). The type
/// treatments, the spacing ramp (`KAN-333`) and the markdown vocabulary
/// (`KAN-330`) all belong to their own tickets and are used as found.
///
/// **What this adds over [DabblerDocPageView]**, which `KAN-323` delivered:
/// that widget takes an already-parsed page. This one takes a *path*, runs the
/// [DabblerDocLoader], renders the `#` title through the header, and offers a
/// [route] so a reader can actually arrive here.
///
/// **`D-037`(c) is satisfied by construction, and the construction is the
/// point.** A `@specimen` figure is built by the resolved entry's own builder
/// on every build, so flipping the theme, brightness or direction rebuilds the
/// figure with it. Nothing here caches a built widget, and nothing memoises
/// across an appearance change — only the *parse* is held, and markdown does
/// not depend on the palette. A future that cached widgets instead of data
/// would defeat this silently, which is why the future is typed to
/// [DabblerDocPage].
///
/// **`D-040`(a) — the gallery's own chrome is never taught as product API.**
/// The header's theme/direction switcher is how we look at the system, not a
/// component a consuming app imports. That rule is *stated to the reader* on
/// `start-here.md`, which is the one page written for someone outside this
/// repository; it is authored content, not a sentence this widget injects.
library;

import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import 'docs/doc_loader.dart';
import 'docs/doc_page.dart';
import 'docs/doc_specimen_resolver.dart';
import 'docs/doc_view.dart';
import 'gallery_page.dart';
import 'gallery_theme_switcher.dart';

/// One documentation page, loaded from the bundle and rendered as a screen.
class GalleryDocPage extends StatefulWidget {
  /// Creates the screen for [page].
  const GalleryDocPage({
    super.key,
    required this.page,
    required this.resolver,
    this.loader = const DabblerDocLoader(),
    this.subtitle,
  });

  /// A corpus-relative path (`components/button.md`) or a full asset path.
  /// [DabblerDocLoader.assetPathFor] accepts either spelling.
  final String page;

  /// Resolves `@specimen` ids to live entries.
  final DabblerDocSpecimenResolver resolver;

  /// The loader. Injectable so a test can supply its own bundle; not a
  /// configuration point for consumers.
  final DabblerDocLoader loader;

  /// One line under the title, when the caller has one.
  final String? subtitle;

  /// A route onto this screen.
  ///
  /// Offered here rather than wired into a menu: the catalogue's navigation is
  /// `KAN-328`'s and its containment is `KAN-332`'s, and this ticket must not
  /// reach into either. A caller pushes this; nothing here decides where the
  /// affordance to push it lives.
  static Route<void> route({
    required String page,
    required DabblerDocSpecimenResolver resolver,
    DabblerDocLoader loader = const DabblerDocLoader(),
    String? subtitle,
  }) {
    return PageRouteBuilder<void>(
      settings: RouteSettings(name: DabblerDocLoader.assetPathFor(page)),
      pageBuilder: (BuildContext context, _, _) => GalleryDocPage(
        page: page,
        resolver: resolver,
        loader: loader,
        subtitle: subtitle,
      ),
    );
  }

  /// The title shown while the bundle read is still in flight.
  ///
  /// Not "Loading…": the corpus is in the bundle, so this is a frame or two,
  /// and a spinner that flashes is worse than a title that settles.
  static const String pendingTitle = 'Documentation';

  @override
  State<GalleryDocPage> createState() => _GalleryDocPageState();
}

class _GalleryDocPageState extends State<GalleryDocPage> {
  /// The parse, held once. **Data, never widgets** — see the library doc on
  /// `D-037`(c). Re-created only when the caller points at another page.
  late Future<DabblerDocPage> _page = widget.loader.load(widget.page);

  @override
  void didUpdateWidget(GalleryDocPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page || oldWidget.loader != widget.loader) {
      _page = widget.loader.load(widget.page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DabblerDocPage>(
      future: _page,
      builder: (BuildContext context, AsyncSnapshot<DabblerDocPage> snapshot) {
        final DabblerDocPage? page = snapshot.data;
        return GalleryPaper(
          header: GalleryPageHeader(
            // The page's `#` heading. A page that failed to load still has
            // one — `DabblerDocPage.unavailable` titles itself "Page not
            // available" — so the failure arrives as a page, not as a blank.
            title: page?.title ?? GalleryDocPage.pendingTitle,
            subtitle: widget.subtitle,
            // Only when there is something to pop: this screen is also pumped
            // directly by tests, with no route beneath it — the same reason
            // the entry screen guards its own back affordance.
            leading: Navigator.of(context).canPop()
                ? DabblerButton(
                    label: 'Back',
                    tone: DabblerButtonTone.outlined,
                    size: DabblerButtonSize.small,
                    semanticLabel: 'Back to the catalogue',
                    onPressed: () => Navigator.of(context).maybePop(),
                  )
                : null,
            trailing: const GalleryThemeSwitcher(),
          ),
          child: page == null
              ? const SizedBox.shrink()
              : DabblerDocPageView(page: page, resolver: widget.resolver),
        );
      },
    );
  }
}
