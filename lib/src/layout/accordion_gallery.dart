/// Gallery entries for [DabblerAccordion] and [DabblerCollapse].
///
/// Mirrors the left column of `components/layout/structure.card.html`: a plain
/// two-item accordion, then the bare `Collapse` under its own small
/// letterspaced caption, exactly as the specimen labels it.
library;

import 'package:flutter/widgets.dart';

import '../controls/button.dart';
import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_type.dart';
import 'accordion.dart';

/// Accordion's specimens.
const List<GalleryEntry> accordionGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    id: 'accordion',
    page: 'components/accordion',
    group: GalleryPurpose.contentContainers,
    title: 'Accordion — plain, card, and the Collapse under it',
    description:
        'Collapsible sections for content that is secondary but not hidden. '
        'Collapse is the system\'s one expand animation.',
    builder: _accordions,
  ),
];

List<DabblerAccordionItem> _items(BuildContext context) {
  final DabblerColors colors = DabblerColors.of(context);
  final TextStyle body = DabblerType.body
      .resolveForDirection(Directionality.of(context))
      .copyWith(color: colors.textSecondary);
  return <DabblerAccordionItem>[
    DabblerAccordionItem(
      id: 'rules',
      title: 'venue rules',
      icon: 'info-circle',
      content: Text('indoor shoes only. no studs on the court.', style: body),
    ),
    DabblerAccordionItem(
      id: 'refund',
      title: 'refunds',
      content:
          Text('free cancellation up to 6 hours before kick-off.', style: body),
    ),
  ];
}

Widget _accordions(BuildContext context) => GalleryStack(
      children: <Widget>[
        GallerySpecimen(
          label: 'plain',
          child: DabblerAccordion(items: _items(context)),
        ),
        GallerySpecimen(
          label: 'card',
          child: DabblerAccordion(
            items: _items(context),
            variant: DabblerAccordionVariant.card,
          ),
        ),
        const GallerySpecimen(
          label: 'Collapse — the system\'s one expand animation',
          child: _CollapseDemo(),
        ),
      ],
    );

class _CollapseDemo extends StatefulWidget {
  const _CollapseDemo();

  @override
  State<_CollapseDemo> createState() => _CollapseDemoState();
}

class _CollapseDemoState extends State<_CollapseDemo> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: <Widget>[
        // The specimen draws a compact pill sized to its label, not a
        // full-width bar; Align keeps the button at its intrinsic width.
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: DabblerButton(
            label: _open ? 'hide details' : 'show details',
            tone: DabblerButtonTone.outlined,
            size: DabblerButtonSize.small,
            onPressed: () => setState(() => _open = !_open),
          ),
        ),
        DabblerCollapse(
          open: _open,
          child: Text(
            'Any block can sit inside Collapse — Accordion and PanelCard both '
            'animate through it.',
            style: DabblerType.body
                .resolveForDirection(Directionality.of(context))
                .copyWith(color: colors.textSecondary),
          ),
        ),
      ],
    );
  }
}
