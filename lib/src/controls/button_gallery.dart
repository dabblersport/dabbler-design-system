/// Gallery entries for [DabblerButton] (KAN-259 AC2).
///
/// Colocated with the component, so adding or changing Button's specimens
/// touches this file and nothing else.
///
/// ## These specimens mirror the design's own page, not a generic variant dump
///
/// `components/controls/buttons.card.html` lays Button out as a **tones ×
/// states matrix** — eight tone rows against six state columns — followed by a
/// row for the icon tone and leading icons, then the three `full` buttons. The
/// earlier version of this file rendered a `Wrap` of tone swatches and a
/// `fullWidth` bar, which gave the wrong impression of the component twice
/// over: it never showed the interaction states side by side, and the
/// full-width bar read as Button's default shape when the design's default is a
/// compact pill sized to its label.
///
/// The labels are the design's own (`join`, `joining`, `create a game`,
/// `share`, `start free trial`) and are lowercase because the specimen writes
/// them that way.
library;

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../gallery/gallery_entry.dart';
import '../gallery/gallery_specimen.dart';
import '../interaction/focus_ring.dart';
import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_type.dart';
import 'button.dart';

/// Button's specimens.
const List<GalleryEntry> buttonGalleryEntries = <GalleryEntry>[
  GalleryEntry(
    title: 'Button — tones × states',
    description: 'Every tone against rest, small, pressed, focus, loading and '
        'disabled — the matrix the design page draws.',
    builder: _matrix,
  ),
  GalleryEntry(
    title: 'Button — sizes, icons & full width',
    description: 'The icon tone, leading icons, and the 320×52 full size.',
    builder: _sizesAndIcons,
  ),
];

/// The tone rows the design's matrix draws, in its order.
///
/// [DabblerButtonTone.icon] is deliberately absent: the specimen's grid is
/// `TONES = ['primary', … ,'iconLabel']` and shows the icon tone in the next
/// section instead, because it has no label to put in a `join` cell.
const List<DabblerButtonTone> _matrixTones = <DabblerButtonTone>[
  DabblerButtonTone.primary,
  DabblerButtonTone.secondary,
  DabblerButtonTone.accent,
  DabblerButtonTone.neutral,
  DabblerButtonTone.filled,
  DabblerButtonTone.outlined,
  DabblerButtonTone.destructive,
  DabblerButtonTone.iconLabel,
];

/// The state columns, in the specimen's order.
const List<String> _matrixColumns = <String>[
  'rest',
  'small',
  'pressed',
  'focus',
  'loading',
  'disabled',
];

/// The grid's gutters — `gap: '10px 16px'` on the specimen's CSS grid.
const double _rowGap = 10;
const double _columnGap = 16;

/// The specimen's `.lbl` rule: 10px, `letter-spacing: .08em`, uppercase, 700.
///
/// Transcribed literally. 10px is below [DabblerType.caption2] (11) and the
/// tracking is not a token — the page states both as raw CSS, so they are
/// stated as raw numbers here rather than snapped to the nearest ramp step.
Widget _label(BuildContext context, String text, {required Color color}) => Text(
  text.toUpperCase(),
  style: DabblerType.caption2
      .resolveForDirection(Directionality.of(context))
      .copyWith(
        fontSize: 10,
        height: 1.4,
        letterSpacing: 0.8,
        fontWeight: DabblerType.bold,
        color: color,
      ),
);

Widget _matrix(BuildContext context) {
  final DabblerColors colors = DabblerColors.of(context);
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: <TableRow>[
        TableRow(
          children: <Widget>[
            const _Cell(child: SizedBox.shrink()),
            for (final String column in _matrixColumns)
              _Cell(
                child: _label(context, column, color: colors.textTertiary),
              ),
          ],
        ),
        for (final DabblerButtonTone tone in _matrixTones)
          TableRow(
            children: <Widget>[
              _Cell(
                child: _label(context, tone.name, color: colors.textSecondary),
              ),
              _Cell(child: DabblerButton(label: 'join', tone: tone, onPressed: _noop)),
              _Cell(
                child: DabblerButton(
                  label: 'join',
                  tone: tone,
                  size: DabblerButtonSize.small,
                  onPressed: _noop,
                ),
              ),
              _Cell(
                child: _Pressed(
                  child: DabblerButton(label: 'join', tone: tone, onPressed: _noop),
                ),
              ),
              _Cell(
                child: DabblerFocusRing.visible(
                  visible: true,
                  borderRadius: DabblerRadius.pillAll,
                  child: DabblerButton(label: 'join', tone: tone, onPressed: _noop),
                ),
              ),
              _Cell(
                child: DabblerButton(label: 'joining', tone: tone, loading: true),
              ),
              _Cell(
                child: DabblerButton(label: 'join', tone: tone, disabled: true),
              ),
            ],
          ),
      ],
    ),
  );
}

Widget _sizesAndIcons(BuildContext context) => const GalleryStack(
  children: <Widget>[
    GallerySpecimen(
      label: 'icon tone · leading icon',
      child: GalleryWrap(
        children: <Widget>[
          DabblerButton.icon(
            icon: 'more',
            semanticLabel: 'More',
            tone: DabblerButtonTone.icon,
            onPressed: _noop,
          ),
          DabblerButton.icon(
            icon: 'more',
            semanticLabel: 'More',
            tone: DabblerButtonTone.icon,
            disabled: true,
          ),
          DabblerButton(
            label: 'create a game',
            icon: 'add',
            onPressed: _noop,
          ),
          DabblerButton(
            label: 'share',
            icon: 'share',
            tone: DabblerButtonTone.outlined,
            onPressed: _noop,
          ),
        ],
      ),
    ),
    GallerySpecimen(
      label: 'full — 320×52',
      child: GalleryWrap(
        children: <Widget>[
          DabblerButton(
            label: 'start free trial',
            size: DabblerButtonSize.full,
            onPressed: _noop,
          ),
          DabblerButton(
            label: 'explore premium',
            size: DabblerButtonSize.full,
            tone: DabblerButtonTone.secondary,
            onPressed: _noop,
          ),
          DabblerButton(
            label: 'start free trial',
            size: DabblerButtonSize.full,
            disabled: true,
          ),
        ],
      ),
    ),
  ],
);

/// One matrix cell, carrying the grid's trailing gutters.
class _Cell extends StatelessWidget {
  const _Cell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(
      end: _columnGap,
      bottom: _rowGap,
    ),
    child: Align(alignment: AlignmentDirectional.centerStart, child: child),
  );
}

/// Holds the real [DabblerButton] in its pressed state.
///
/// The specimen page is explicit about the technique and the reason: *"Pressed
/// is a real runtime state, so hold the real component in it by dispatching the
/// mousedown it listens for — never by restyling a replica."* The Flutter
/// equivalent of that `mousedown` is a [PointerDownEvent] pushed through
/// [GestureBinding], which reaches the button's own [GestureDetector] and sets
/// its own `_pressed`. Nothing here knows what pressed looks like.
class _Pressed extends StatefulWidget {
  const _Pressed({required this.child});

  final Widget child;

  @override
  State<_Pressed> createState() => _PressedState();
}

class _PressedState extends State<_Pressed> {
  /// Well clear of any pointer the engine will allocate for a real input.
  static int _nextPointer = 900000;

  final GlobalKey _key = GlobalKey();
  late final int _pointer = _nextPointer++;
  Offset? _position;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Not the first frame: the gallery pushes an entry as a route, and while
    // that transition runs the cell's global position is still moving, so a
    // pointer dispatched at its centre lands somewhere else. Waiting for the
    // route to settle is what makes the hit test find the button.
    _timer = Timer(const Duration(milliseconds: 600), _press);
  }

  void _press() {
    if (!mounted) {
      return;
    }
    final RenderObject? object = _key.currentContext?.findRenderObject();
    if (object is! RenderBox || !object.hasSize) {
      return;
    }
    final Offset position = object.localToGlobal(object.size.center(Offset.zero));
    _position = position;
    GestureBinding.instance.handlePointerEvent(
      PointerDownEvent(pointer: _pointer, position: position),
    );
    // A DOM `mousedown` has no gesture arena; Flutter's does, and the gallery
    // page scrolls — so the button's tap recogniser sits in an open arena
    // against the scrollable's drag and never reaches `onTapDown`, which is
    // what fires on accept. Sweeping closes the arena in favour of the
    // first-registered recogniser, which is the button's own. Without this the
    // cell renders identically to `rest`.
    GestureBinding.instance.gestureArena.sweep(_pointer);
  }

  @override
  void dispose() {
    _timer?.cancel();
    final Offset? position = _position;
    if (position != null) {
      // Never leave a pointer down in the arena behind a disposed specimen.
      GestureBinding.instance.handlePointerEvent(
        PointerCancelEvent(pointer: _pointer, position: position),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => KeyedSubtree(key: _key, child: widget.child);
}

void _noop() {}
