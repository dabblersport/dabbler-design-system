import 'package:flutter/painting.dart';

import 'dabbler_geometry.dart';

/// The values the **Home Feed** frame draws that no [DabblerSpacing] /
/// [DabblerSizing] step carries, as named tokens (KAN-433).
///
/// The frame (`Home Feed.dc.html`, 393x852) was measured element by element in
/// a browser (`home-design-measure.md`, sections 3-8) and every figure below is
/// a *measured* outer size, not a declared one: the file sets
/// `box-sizing: content-box`, so a declared 34 can measure 36.
///
/// Each token is one the base-3 grid does not have (none is a multiple of 3 —
/// `test/tokens/dabbler_home_frame_test.dart` pins that), taken as an off-grid
/// ruling on the precedent of [DabblerSizing.resultTile] (`D-018`: a drawing
/// overrides the grid). They are opt-in: a component reads them only when its
/// frame metrics are switched on ([DabblerFeedMetrics.drawn],
/// `DabblerNavigationTopBar.feed`, `DabblerTabsVariant.feed`), so a screen that
/// keeps the touch-first defaults renders exactly as before.
///
/// Values the grid already has are **not** repeated here: the frame's 18
/// gutter is [DabblerSpacing.space6], its 24 glyph [DabblerSizing.iconMd], its
/// 45 hit box [DabblerSizing.touchTargetMin].
abstract final class DabblerHomeFrame {
  const DabblerHomeFrame._();

  // --- Header (section 3) ---

  /// The wordmark's drawn box in the Home header: **110 x 21**
  /// (`dabbler_text_logo.svg` at `width:110`; measured 110x21). The top bar's
  /// default is 100 x 19.
  static const Size logoSize = Size(110, 21);

  /// Wordmark to location row: **5** (the left column's `gap:5px`).
  static const double logoToLocation = 5;

  /// The location pin: **13** (`size="13"`, bold, brand).
  static const double locationGlyph = 13;

  /// Pin to text and text to chevron in the location row: **4** (`gap:4px`).
  static const double locationGap = 4;

  // --- Tabs (section 5) ---

  /// The gap under a tab label before its underline: **10**
  /// (`padding:0 0 10px`). The 3px underline is [DabblerSpacing.space1].
  static const double tabPaddingBottom = 10;

  // --- Upcoming reminder (section 4) ---

  /// The reminder's hide button box: **34 x 34** (declared; it carries
  /// `margin:-6px -8px -6px 0`, so the title row keeps its 25).
  static const double reminderHideBox = 34;

  /// How far the hide button bleeds past the block's end edge: **8**
  /// (`margin-right:-8px`; a *physical* margin, so it bleeds right in both
  /// directions of reading and the button sits flush in RTL).
  static const double reminderHideBleed = 8;

  /// The stack wrapper's bottom padding under the front card: **14**
  /// (`padding-bottom:14px`), where the two sheets peek out.
  static const double reminderStackDepth = 14;

  /// The two sheets peeking out under the front card are **42** tall (`:141-142`
  /// declare 40 and the hairline is outside it, content-box).
  static const double reminderSheetHeight = 42;

  /// How far the white sheet is inset from each side: **14**.
  static const double reminderSheetFar = 14;

  /// How far the sunken sheet is inset from each side, and how high the white
  /// one rides above the wrapper's end: **7**.
  static const double reminderSheetNear = 7;

  /// The date tile's gap between month and day: **1** (`gap:1px`).
  static const double reminderDateGap = 1;

  /// The collapsed strip's divider between count and ticker: **14** high,
  /// 1 wide (`:99`).
  static const double reminderStripDivider = 14;

  /// The strip's dot-to-count gap: **5** (`gap:5px`).
  static const double reminderStripGap = 5;

  /// Title to venue line in the card's text column: **2** (`gap:2px`).
  static const double reminderTextGap = 2;

  // --- Post row (section 7a) ---

  /// The type pill beside the author: `padding:2px 8px` — **2** above and
  /// below.
  static const double postBadgePaddingBlock = 2;

  /// The type pill's **8** inline padding.
  static const double postBadgePaddingInline = 8;

  /// The meta row's gaps: **5** (`gap:5px`).
  static const double postMetaGap = 5;

  /// The pin's extra start margin in the meta row: **4** (`margin-left:4px`).
  static const double postMetaPinInset = 4;

  /// The sport pill's height: **32** (5 + a 20 line + 5, inside a hairline).
  static const double sportPillHeight = 32;

  /// The sport pill's top and bottom padding: **5**.
  static const double sportPillPaddingBlock = 5;

  /// The sport pill's end padding: **11**.
  static const double sportPillPaddingEnd = 11;

  /// The gap between the sport pill's glyph and label: **5**.
  static const double sportPillGap = 5;

  // --- News card (section 7c) ---

  /// Headline to excerpt in the text block: **5** (`gap:5px`).
  static const double newsTextGap = 5;

  // --- Activity row (section 7b) ---

  /// The system tile: **42** (declared 40 plus its hairline, content-box).
  static const double activityTile = 42;

  /// The card's bottom margin: **4** (`margin-bottom:4px`).
  static const double activityMarginBottom = 4;

  /// Gaps in the actor line and the meta line: **5** (`gap:5px`).
  static const double activityGap = 5;

  /// The meta line's extra top margin: **2** (`margin:2px 0 0`).
  static const double activityMetaLift = 2;

  /// The action pill's height: **35** (33 declared plus its hairline).
  static const double activityActionHeight = 35;

  // --- Overlays (section 9) ---

  /// The sheet header's gap between title and subtitle, and the action row's
  /// gap between label and note: **2** and **1** respectively in the frame
  /// (`gap:2px` / `gap:1px`); the title's is this one.
  static const double sheetTitleGap = 2;

  /// An action row's block padding: **14** (`padding:14px 15px`).
  static const double actionRowPaddingBlock = 14;

  /// An action row's label-to-note gap: **1** (`gap:1px`).
  static const double actionRowTextGap = 1;

  // --- Search field (section 9b) ---

  /// The city sheet's search field: **42** high (`height:42px`, hairline
  /// inside), against the field's 45 minimum.
  static const double searchFieldHeight = 42;

  /// The search field's leading glyph: **16** (`search-normal` at 16).
  static const double searchFieldGlyph = 16;

  // --- List rows (section 9b) ---

  /// A row's label-to-subtitle gap in the city sheet: **1** (`gap:1px`), which
  /// makes a row with a subtitle 62 (12 + 20 + 1 + 16 + 12 + the hairline)
  /// where the flat DS row was 61.
  static const double listRowSubtitleGap = 1;

  /// The row's leading and trailing glyphs: **20** (the DS row role is 21).
  static const double listRowGlyph = 20;

  // --- Sub-chips (section 6) ---

  /// The leading glyph of a sub-chip: **14**, bold (`size="14"`).
  static const double subChipGlyph = 14;
}

/// Which metrics a feed row draws with.
///
/// [touch] is the long-standing default: every action keeps a 45px hit box in
/// layout, gaps take the nearest base-3 step and the rows are a little taller
/// than the drawing. [drawn] lays the row out exactly as the Home Feed frame
/// measures it (named off-grid tokens in [DabblerHomeFrame], the 45px target
/// kept as a hit-test-only area), so a screen can mirror the frame to the
/// pixel.
enum DabblerFeedMetrics {
  /// Touch-first: 45px action boxes in layout, nearest-step gaps.
  touch,

  /// As the Home Feed frame draws it.
  drawn,
}

/// Every [DabblerHomeFrame] value by name, in declaration order — what the
/// gallery tabulates and `test/tokens/dabbler_home_frame_test.dart` pins.
/// (The wordmark's 110 x 21 is a [Size] and is listed in the gallery as its
/// two sides.)
const Map<String, double> homeFrameTokens = <String, double>{
  'logoWidth': 110,
  'logoHeight': 21,
  'logoToLocation': DabblerHomeFrame.logoToLocation,
  'locationGlyph': DabblerHomeFrame.locationGlyph,
  'locationGap': DabblerHomeFrame.locationGap,
  'tabPaddingBottom': DabblerHomeFrame.tabPaddingBottom,
  'reminderHideBox': DabblerHomeFrame.reminderHideBox,
  'reminderHideBleed': DabblerHomeFrame.reminderHideBleed,
  'reminderStackDepth': DabblerHomeFrame.reminderStackDepth,
  'reminderSheetHeight': DabblerHomeFrame.reminderSheetHeight,
  'reminderSheetFar': DabblerHomeFrame.reminderSheetFar,
  'reminderSheetNear': DabblerHomeFrame.reminderSheetNear,
  'reminderDateGap': DabblerHomeFrame.reminderDateGap,
  'reminderTextGap': DabblerHomeFrame.reminderTextGap,
  'reminderStripDivider': DabblerHomeFrame.reminderStripDivider,
  'reminderStripGap': DabblerHomeFrame.reminderStripGap,
  'postBadgePaddingBlock': DabblerHomeFrame.postBadgePaddingBlock,
  'postBadgePaddingInline': DabblerHomeFrame.postBadgePaddingInline,
  'postMetaGap': DabblerHomeFrame.postMetaGap,
  'postMetaPinInset': DabblerHomeFrame.postMetaPinInset,
  'sportPillHeight': DabblerHomeFrame.sportPillHeight,
  'sportPillPaddingBlock': DabblerHomeFrame.sportPillPaddingBlock,
  'sportPillPaddingEnd': DabblerHomeFrame.sportPillPaddingEnd,
  'sportPillGap': DabblerHomeFrame.sportPillGap,
  'newsTextGap': DabblerHomeFrame.newsTextGap,
  'activityTile': DabblerHomeFrame.activityTile,
  'activityMarginBottom': DabblerHomeFrame.activityMarginBottom,
  'activityGap': DabblerHomeFrame.activityGap,
  'activityMetaLift': DabblerHomeFrame.activityMetaLift,
  'activityActionHeight': DabblerHomeFrame.activityActionHeight,
  'sheetTitleGap': DabblerHomeFrame.sheetTitleGap,
  'actionRowPaddingBlock': DabblerHomeFrame.actionRowPaddingBlock,
  'actionRowTextGap': DabblerHomeFrame.actionRowTextGap,
  'subChipGlyph': DabblerHomeFrame.subChipGlyph,
  'searchFieldHeight': DabblerHomeFrame.searchFieldHeight,
  'searchFieldGlyph': DabblerHomeFrame.searchFieldGlyph,
  'listRowSubtitleGap': DabblerHomeFrame.listRowSubtitleGap,
  'listRowGlyph': DabblerHomeFrame.listRowGlyph,
};
