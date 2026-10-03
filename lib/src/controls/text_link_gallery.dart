/// Gallery entries for [DabblerTextLink] (Alpha DS gaps 5, item 10).
///
/// Mirrors `Auth and Onboarding.dc.html`: the standalone "Log in" under the
/// form (`:129`) and the legal line with two inline links (`:131`).
library;

import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_type.dart';
import 'text_link.dart';

/// TextLink specimens.
const List<GalleryEntry> textLinkGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'text-link',
    page: 'components/text-link',
    group: GalleryPurpose.actions,
    title: 'TextLink — standalone and inside a sentence',
    description:
        'A standalone link on its 45px target, a disabled one, and the '
        'legal line with two inline links, in English and Arabic.',
    builder: _links,
  ),
];

const double _width = 260;

Widget _legal(BuildContext context, List<InlineSpan> parts) {
  final TextStyle style = DabblerType.footnote
      .resolveForDirection(Directionality.of(context))
      .copyWith(color: DabblerColors.of(context).textSecondary);
  return SizedBox(
    width: _width,
    child: Text.rich(
      TextSpan(
        style: style,
        children: <InlineSpan>[
          for (final InlineSpan p in parts)
            p is _Link
                ? DabblerTextLink.span(
                    label: p.label,
                    onPressed: () {},
                    style: style,
                  )
                : p,
        ],
      ),
    ),
  );
}

/// A marker so [_legal] can pass the sentence style into each link.
class _Link extends TextSpan {
  const _Link(this.label);
  final String label;
}

Widget _links(BuildContext context) => GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'standalone — 45px target',
      child: DabblerTextLink(label: 'Log in', onPressed: () {}),
    ),
    GallerySpecimen(
      label: 'section link — "Manage", no underline, trailing arrow',
      child: DabblerTextLink(
        label: 'Manage',
        underline: false,
        trailingIcon: 'arrow-right-3',
        style: DabblerType.footnote
            .resolveForDirection(Directionality.of(context))
            .copyWith(fontWeight: DabblerType.semibold),
        onPressed: () {},
      ),
    ),
    const GallerySpecimen(
      label: 'disabled',
      child: DabblerTextLink(label: 'Log in'),
    ),
    GallerySpecimen(
      label: 'inline — in the legal line',
      child: _legal(context, const <InlineSpan>[
        TextSpan(text: 'By continuing you agree to our '),
        _Link('Terms of Service'),
        TextSpan(text: ' and '),
        _Link('Privacy Policy'),
        TextSpan(text: '.'),
      ]),
    ),
    GallerySpecimen(
      label: 'inline — Arabic',
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Builder(
          builder: (BuildContext context) => _legal(context, const <InlineSpan>[
            TextSpan(text: 'بالمتابعة أنت توافق على '),
            _Link('شروط الخدمة'),
            TextSpan(text: '.'),
          ]),
        ),
      ),
    ),
  ],
);
