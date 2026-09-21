import 'package:flutter/widgets.dart';
import 'package:random_avatar/random_avatar.dart';

import '../tokens/dabbler_colors.dart';
import '../tokens/dabbler_geometry.dart';
import '../tokens/dabbler_palette.dart';
import '../tokens/dabbler_type.dart';

/// The five avatar diameters, from `components/surfaces/Avatar.jsx`:
/// `const SIZES = { xs: 28, sm: 36, md: 48, lg: 64, xl: 80 }` — what
/// `Avatar.d.ts` calls *"the file's exact sizes"*. Transcribed literally rather
/// than through [DabblerSpacing], whose base-3 grid has no 28 and no 80.
enum DabblerAvatarSize {
  /// 28px.
  xs(28),
  /// 36px. The size [DabblerAvatarGroup] stacks.
  sm(36),
  /// 48px. The default.
  md(48),
  /// 64px.
  lg(64),
  /// 80px.
  xl(80);

  const DabblerAvatarSize(this.diameter);
  /// The circle's width and height in logical pixels.
  final double diameter;
}

/// The three corner-badge fills of `Avatar.jsx`'s `BADGE_TONES`.
enum DabblerAvatarBadgeTone {
  /// `var(--color-brand-primary)` — resolves to [DabblerColors.brandPrimary].
  primary,
  /// `var(--color-accent)` — resolves to [DabblerColors.accent].
  accent,
  /// `var(--accent-indigo)`, **approximated**. See [DabblerAvatar.badgeTone].
  indigo,
}

/// The hash behind [DabblerPlaceholderPortrait], and a statement of what a seed
/// is ever used for. `Avatar.d.ts` is explicit — *"Used ONLY as a seed — never
/// rendered as text"* — so a seed enters the widget tree through a hash and
/// nothing else: no [Text], no semantics label, no tooltip here consumes one.
/// 32-bit FNV-1a over the seed's UTF-16 code units.
abstract final class DabblerAvatarSeed {
  const DabblerAvatarSeed._();

  /// The default seed, from `Avatar.jsx`: `seed ?? initials ?? 'dabbler'`.
  static const String fallback = 'dabbler';
  /// The 32-bit FNV-1a hash of [seed]. Stable across runs and platforms.
  static int hash(String seed) {
    int h = 0x811C9DC5;
    for (final int unit in seed.codeUnits) {
      h = (h ^ unit) & 0xFFFFFFFF;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h;
  }
}

/// The seam through which a portrait is generated.
/// [DabblerRandomAvatarPortrait] is the real one and the default;
/// [DabblerPlaceholderPortrait] is the fallback it degrades to. The seam stays
/// because the generator is a product-wide decision, not a per-call-site one,
/// and because a test needs to substitute it. An implementation must be a pure
/// function of `(seed, diameter)` — that determinism is the whole contract an
/// avatar has with a user.
abstract class DabblerAvatarPortraitBuilder {
  /// Allows subclasses to be const.
  const DabblerAvatarPortraitBuilder();

  /// The portrait for [seed], drawn to fill a [diameter]-square box.
  ///
  /// [DabblerAvatar] clips it to a circle and hides it from semantics, so an
  /// implementation need do neither — and may never render a character of
  /// [seed].
  Widget build(BuildContext context,
      {required String seed, required double diameter});
}

/// The deterministic **fallback** portrait, drawn when Multiavatar cannot render
/// a seed. It is not an approximation of Multiavatar's output and does not try
/// to be — a fallback face will not match the app's. What it guarantees is the
/// property that matters when the real generator fails: the same seed always
/// paints the same portrait, and different seeds almost always paint different
/// ones. **Never initials** (AC2) — that holds in the fallback path too.
///
/// Three parts are picked from [DabblerAvatarSeed.hash]. Every colour is a
/// declared [DabblerPalette] brand step, so nothing here is outside
/// `tokens/colors.css`.
class DabblerPlaceholderPortrait extends DabblerAvatarPortraitBuilder {
  /// The fallback portrait builder.
  const DabblerPlaceholderPortrait();

  /// The ten brand ramp steps the placeholder draws from, in theme order.
  ///
  /// Primitives, not [DabblerColors], because a portrait is **theme-invariant**:
  /// an avatar must not change colour as the user walks between sections. The
  /// source says the same from the other side — *"there is no `palette` prop;
  /// the library owns the avatar's colour"*.
  static const List<Color> parts = <Color>[
    DabblerPalette.mainP600, DabblerPalette.mainS600,
    DabblerPalette.socialP600, DabblerPalette.socialS600,
    DabblerPalette.sportP600, DabblerPalette.sportS600,
    DabblerPalette.activeP600, DabblerPalette.activeS600,
    DabblerPalette.brightP600, DabblerPalette.brightS600,
  ];

  @override
  Widget build(BuildContext context,
      {required String seed, required double diameter}) {
    final int h = DabblerAvatarSeed.hash(seed);
    final int ground = h % parts.length;
    // Each part is offset off the one before it, so no two adjacent parts land
    // on the same colour and paint a featureless disc.
    final int head = (ground + 1 + (h >> 8) % (parts.length - 1)) % parts.length;
    final int body = (head + 1 + (h >> 16) % (parts.length - 1)) % parts.length;
    return CustomPaint(
      size: Size.square(diameter),
      painter: _PlaceholderPortraitPainter(
          ground: parts[ground], head: parts[head], body: parts[body]),
    );
  }
}

/// Paints the three placeholder parts. Geometry is fractions of the diameter, so
/// every size renders the same portrait at a different scale.
class _PlaceholderPortraitPainter extends CustomPainter {
  const _PlaceholderPortraitPainter({
    required this.ground, required this.head, required this.body,
  });

  final Color ground;
  final Color head;
  final Color body;
  @override
  void paint(Canvas canvas, Size size) {
    final double d = size.width;
    final Paint paint = Paint()..isAntiAlias = true;

    canvas.drawRect(Offset.zero & size, paint..color = ground);

    // Shoulders: a pill rising from the lower edge.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(d * 0.14, d * 0.66, d * 0.72, d * 0.52),
          Radius.circular(d * 0.36)),
      paint..color = body,
    );

    // Head: a disc on the upper half.
    canvas.drawCircle(Offset(d * 0.5, d * 0.42), d * 0.26, paint..color = head);
  }

  @override
  bool shouldRepaint(_PlaceholderPortraitPainter old) =>
      old.ground != ground || old.head != head || old.body != body;
}

/// The real generator: Multiavatar, via `random_avatar` (`DECISIONS.md` T-084).
///
/// `Avatar.prompt.md` requires that *"an identical seed gives an identical
/// avatar in both"* this kit and the product, and names `random_avatar` as the
/// Dart port of the algorithm the web kit runs. `cto` approved it with one
/// condition that is part of the mechanism rather than a preference: **the
/// version constraint must stay identical here and in
/// `dabbler-code/pubspec.yaml`** (both `^0.0.8`). A one-sided bump is a defect,
/// not an upgrade — it silently re-faces every user on one platform.
///
/// `trBackground` is left `false`, matching the web kit: Multiavatar owns the
/// environment colour, which is why the source has no `palette` prop. If it
/// throws for a seed this degrades to [fallback] — generation is synchronous
/// and eager, so the failure surfaces here and is caught here.
class DabblerRandomAvatarPortrait extends DabblerAvatarPortraitBuilder {
  /// The Multiavatar generator, degrading to [fallback].
  const DabblerRandomAvatarPortrait({
    this.fallback = const DabblerPlaceholderPortrait(),
  });

  /// Drawn when [seed] is empty or Multiavatar throws.
  final DabblerAvatarPortraitBuilder fallback;

  @override
  Widget build(BuildContext context,
      {required String seed, required double diameter}) {
    if (seed.isNotEmpty) {
      try {
        // `excludeFromSemantics` because the portrait is decorative;
        // [DabblerAvatar] excludes it again from the outside.
        return RandomAvatar(seed,
            width: diameter, height: diameter, excludeFromSemantics: true);
      } on Object {
        // Any failure degrades to the deterministic fallback — never to an
        // error widget, and never to initials.
      }
    }
    return fallback.build(context, seed: seed, diameter: diameter);
  }
}

/// Avatar — a generated portrait identifying one person. **Never initials.**
///
/// Transcribed from `Avatar.jsx`, `Avatar.d.ts` and `Avatar.prompt.md`, which
/// merge the Figma kit's nine avatar symbols into one component: five sizes, a
/// 24px corner badge in three tones, and [DabblerAvatarGroup].
///
/// ```dart
/// const DabblerAvatar(seed: 'Rahul Menon');
/// const DabblerAvatar(seed: 'user_8812', size: DabblerAvatarSize.lg,
///     badgeTone: DabblerAvatarBadgeTone.accent, badge: Icon(Icons.star));
/// ```
///
/// ## The seed is a hash input, never text
///
/// The component's defining rule, and it is absolute. `Avatar.d.ts`: *"Used ONLY
/// as a seed — never rendered as text."* The specimen
/// `identity-status.card.html` puts it in product terms: *"the old two-letter
/// tinted circles are gone from every component, card and screen."* [seed]
/// therefore reaches only a generator, and the portrait is wrapped in
/// [ExcludeSemantics] — a seed is usually a user id or a raw handle and is not a
/// thing to read aloud. A screen that needs the person announced labels the
/// *row* with their display name, which it has and this widget does not.
///
/// ## The seed contract — pass what the app passes
///
/// Portraits are Multiavatar (see [DabblerRandomAvatarPortrait]), so one seed
/// yields one face here, in the web kit and in `dabbler-code`. That parity is
/// only as good as the caller: **pass the same stable identifier the app
/// passes.** A display name here and a user id there gives one person two faces,
/// and nothing will report it.
class DabblerAvatar extends StatelessWidget {
  /// An avatar for [seed] at [size].
  const DabblerAvatar({
    super.key, this.seed, this.size = DabblerAvatarSize.md, this.badge,
    this.badgeTone = DabblerAvatarBadgeTone.primary, this.ringColor,
  });

  /// The stable identifying string — a name, handle or user id. **Never
  /// rendered.** Defaults to [DabblerAvatarSeed.fallback]. The source's
  /// deprecated `initials` alias is not ported: reproducing the name would put
  /// the very word this component abolished into a brand-new API.
  final String? seed;

  /// The diameter. Defaults to [DabblerAvatarSize.md] (48px).
  final DabblerAvatarSize size;

  /// The 24px corner badge's content; omit for no badge. The specimen passes a
  /// 10px bold icon; this widget supplies the ink and text style.
  final Widget? badge;

  /// The corner-badge fill. Defaults to [DabblerAvatarBadgeTone.primary].
  final DabblerAvatarBadgeTone badgeTone;

  /// An optional [_ringWidth]-wide ring, set by [DabblerAvatarGroup] to separate
  /// overlapping avatars. The source draws it as a `box-shadow` spread; this
  /// system is flat, so it is a border — the same two pixels of paper, painted
  /// by something that is not a shadow.
  final Color? ringColor;

  /// The 2px of `Avatar.jsx`'s group ring and badge border.
  static const double _ringWidth = 2;

  /// `width: 24, height: 24` in `Avatar.jsx` — [DabblerSizing.iconMd].
  static const double badgeDiameter = DabblerSizing.iconMd;
  /// How far the badge overhangs the circle: `right: -2, bottom: -2`.
  static const double _badgeOverhang = -2;

  /// The portrait generator every [DabblerAvatar] draws through.
  ///
  /// Defaults to [DabblerRandomAvatarPortrait], the real Multiavatar generator.
  /// A mutable static rather than an inherited widget deliberately: it is not a
  /// themeable choice — the whole product must generate the same face for the
  /// same person in every subtree, and one process-wide value says so.
  static DabblerAvatarPortraitBuilder portrait =
      const DabblerRandomAvatarPortrait();

  /// The badge fill for [tone] under [colors].
  static Color badgeFill(DabblerColors colors, DabblerAvatarBadgeTone tone) =>
      switch (tone) {
        DabblerAvatarBadgeTone.primary => colors.brandPrimary,
        DabblerAvatarBadgeTone.accent => colors.accent,
        DabblerAvatarBadgeTone.indigo => DabblerPalette.accentIndigo,
      };

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final double d = size.diameter;
    final Color? ring = ringColor;
    Widget circle = ClipOval(
      child: ColoredBox(
        // `background: var(--faint)` — what the source shows while the portrait
        // resolves, and what shows through one that does not fill its box.
        color: colors.bgTertiary,
        child: SizedBox.square(
          dimension: d,
          child: portrait.build(context,
              seed: seed ?? DabblerAvatarSeed.fallback, diameter: d),
        ),
      ),
    );
    // `aria-hidden="true"` on the portrait in `Avatar.jsx`.
    circle = ExcludeSemantics(child: circle);

    if (ring != null) {
      circle = DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ring, width: _ringWidth),
        ),
        position: DecorationPosition.foreground,
        child: circle,
      );
    }

    if (badge == null) return SizedBox.square(dimension: d, child: circle);

    return SizedBox.square(
      dimension: d,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          circle,
          PositionedDirectional(
            end: _badgeOverhang, bottom: _badgeOverhang,
            child: _Badge(
              fill: badgeFill(colors, badgeTone),
              ink: colors.surfaceCard, border: colors.bgPrimary, child: badge!,
            ),
          ),
        ],
      ),
    );
  }
}

/// The 24px corner badge: a circular fill with a 2px paper border.
class _Badge extends StatelessWidget {
  const _Badge({
    required this.fill, required this.ink, required this.border,
    required this.child,
  });

  final Color fill;
  final Color ink;
  final Color border;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        width: DabblerAvatar.badgeDiameter,
        height: DabblerAvatar.badgeDiameter,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: DabblerAvatar._ringWidth),
        ),
        // `color: var(--surface-card)`, `font-size: 11`, `font-weight: 700`.
        child: IconTheme.merge(
          data: IconThemeData(color: ink, size: 10),
          child: DefaultTextStyle.merge(
            style: DabblerType.caption2
                .resolveForDirection(Directionality.of(context))
                .copyWith(color: ink, fontWeight: DabblerType.bold),
            child: child,
          ),
        ),
      );
}

/// AvatarGroup — an overlapping row of [DabblerAvatarSize.sm] avatars with an
/// optional `+N` chip. From `AvatarGroup` in `Avatar.jsx` and the specimen's own
/// summary: *"an overlapping row of `sm` (36px) circles at −10px overlap, each
/// ringed in `--surface-page`, with an optional `+N` chip in
/// `--faint`/`--muted`."*
///
/// ```dart
/// const DabblerAvatarGroup(
///     people: <String>['Rahul Menon', 'Aisha Khan'], overflow: 42);
/// ```
///
/// The `+N` chip is the **only** text this whole file renders, and it is a count
/// — no part of any seed reaches it.
///
/// ## Overlap, with the ring on the inside
///
/// The source's ring is a `box-shadow` **spread**, outside the 36px box, so its
/// −10px margin measures between the circles themselves. This system paints no
/// shadows, so the ring is a 2px border *inside* the circle: every box stays
/// exactly 36px and the overlap exactly −10, keeping the centres 26px apart as
/// in the source, at the cost of 2px of portrait on each side.
///
/// Laid out with [Stack] and [PositionedDirectional] rather than negative
/// margins, so it mirrors under RTL — in Arabic the stack runs from the right
/// and the first person stays on top.
class DabblerAvatarGroup extends StatelessWidget {
  /// A group of [people], with an optional `+`[overflow] chip.
  const DabblerAvatarGroup({
    super.key, this.people = const <String>[], this.overflow = 0,
  }) : assert(overflow >= 0, 'an overflow count cannot be negative');

  /// The seeds to render, in order. Each is a stable identifying string, and
  /// **never rendered as text** — see [DabblerAvatar.seed].
  final List<String> people;

  /// The trailing `+N` chip's count. `0` renders no chip.
  final int overflow;

  /// `size="sm"` — the group's circles are 36px.
  static const DabblerAvatarSize avatarSize = DabblerAvatarSize.sm;
  /// `marginLeft: -10` — how far each item sits under the one before it.
  static const double overlap = 10;

  /// The chip's `minWidth: 28` and `padding: '0 8px'`.
  static const double _chipMinWidth = 28;
  static const double _chipPadding = 8;
  double get _step => avatarSize.diameter - overlap;

  @override
  Widget build(BuildContext context) {
    final DabblerColors colors = DabblerColors.of(context);
    final double d = avatarSize.diameter;
    final int n = people.length;
    final List<Widget> items = <Widget>[];
    for (int i = 0; i < n; i++) {
      items.add(PositionedDirectional(
        start: i * _step,
        // `ringColor` is `--surface-page`, the 2px separating ring.
        child: DabblerAvatar(
            seed: people[i], size: avatarSize, ringColor: colors.bgPrimary),
      ));
    }

    double width = n == 0 ? 0 : d + (n - 1) * _step;
    if (overflow > 0) {
      // The chip is as wide as `+N` needs, never the bare minimum: a
      // [PositionedDirectional] with only `start` set hands its child unbounded
      // horizontal constraints, so a chip laid out inside a [SizedBox] sized to
      // [_chipMinWidth] painted up to 32px **outside** the group and overlapped
      // whatever followed it in a row. Measured rather than assumed — see
      // [_OverflowChip.widthFor].
      final double chipWidth = _OverflowChip.widthFor(context, overflow);
      items.add(PositionedDirectional(
        start: n * _step,
        width: chipWidth,
        child: _OverflowChip(count: overflow, colors: colors, height: d),
      ));
      width = n * _step + chipWidth;
    }
    if (items.isEmpty) return const SizedBox.shrink();

    // Painter's order puts the last child on top; the source gives the FIRST
    // person the highest `zIndex`, so the stack is reversed.
    return SizedBox(
      width: width,
      height: d,
      child: Stack(
          clipBehavior: Clip.none,
          children: items.reversed.toList(growable: false)),
    );
  }
}

/// The trailing `+N` chip: `--faint` on `--muted`, pill radius, 36px tall.
class _OverflowChip extends StatelessWidget {
  const _OverflowChip({
    required this.count, required this.colors, required this.height,
  });

  final int count;
  final DabblerColors colors;
  final double height;

  /// The chip's label, `+N`.
  static String labelFor(int count) => '+$count';

  /// The chip's own width: `+N` laid out in [textStyleFor], plus the horizontal
  /// padding on both sides, floored at
  /// [DabblerAvatarGroup._chipMinWidth] — the source's `minWidth: 28` and
  /// `padding: '0 8px'` read as the two halves of one rule rather than as a
  /// fixed box.
  ///
  /// Measured through a [TextPainter] at the ambient [TextScaler], so a user
  /// who has scaled their text up still gets a chip that contains its label.
  static double widthFor(BuildContext context, int count) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: labelFor(count),
        style: textStyleFor(context, DabblerColors.of(context)),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final double width = painter.width + 2 * DabblerAvatarGroup._chipPadding;
    painter.dispose();
    return width < DabblerAvatarGroup._chipMinWidth
        ? DabblerAvatarGroup._chipMinWidth
        : width;
  }

  /// The label's style — `--muted` ink at the 11px bold caption step.
  static TextStyle textStyleFor(BuildContext context, DabblerColors colors) =>
      DabblerType.caption2
          .resolveForDirection(Directionality.of(context))
          .copyWith(color: colors.textSecondary, fontWeight: DabblerType.bold);

  @override
  Widget build(BuildContext context) => Container(
        height: height,
        constraints:
            const BoxConstraints(minWidth: DabblerAvatarGroup._chipMinWidth),
        padding: const EdgeInsets.symmetric(
            horizontal: DabblerAvatarGroup._chipPadding),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.bgTertiary,
          borderRadius: DabblerRadius.pillAll,
          border: Border.all(
              color: colors.bgPrimary, width: DabblerAvatar._ringWidth),
        ),
        child: Text(
          labelFor(count),
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.clip,
          style: textStyleFor(context, colors),
        ),
      );
}
