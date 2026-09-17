/// The gallery's two layout helpers, shared by every `*_gallery.dart`.
///
/// They exist so a component's gallery file is a list of specimens rather than
/// a pile of `Padding`/`Column`/`Text` — and so every entry in the gallery is
/// laid out the same way, which is the point of looking at them side by side.
///
/// This file is shared *read-only* by the component gallery files: it is never
/// edited to add a component, so it is not a collision surface the way
/// `main.dart`'s list was (KAN-259 AC2).
library;

import 'package:flutter/widgets.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';

/// One labelled specimen: a caption, then the thing itself.
class GallerySpecimen extends StatelessWidget {
  /// Creates a specimen.
  const GallerySpecimen({super.key, required this.label, required this.child});

  /// What this specimen is — the variant, the state, the size.
  final String label;

  /// The specimen.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: DabblerType.footnote
              .resolveForDirection(Directionality.of(context))
              .copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: DabblerSpacing.space2),
        child,
      ],
    );
  }
}

/// A vertical stack of specimens with the gallery's standard gap.
class GalleryStack extends StatelessWidget {
  /// Creates a stack.
  const GalleryStack({super.key, required this.children});

  /// The specimens, top to bottom.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < children.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: DabblerSpacing.space8),
          children[i],
        ],
      ],
    );
  }
}

/// A wrapping row of specimens, for variants that read best side by side.
class GalleryWrap extends StatelessWidget {
  /// Creates a wrap.
  const GalleryWrap({super.key, required this.children});

  /// The specimens.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DabblerSpacing.space6,
      runSpacing: DabblerSpacing.space6,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: children,
    );
  }
}
