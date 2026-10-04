import 'package:dabbler_design_system/dabbler_design_system.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// KAN-433: the Home Feed frame's off-grid values, pinned. Every figure is a
/// *measured outer size* from `home-design-measure.md`, and none of them is a
/// step of the base-3 scale — a value that lands on the scale belongs to
/// `DabblerSpacing` / `DabblerSizing`, not here.
void main() {
  group('DabblerHomeFrame', () {
    const Map<String, double> pinned = <String, double>{
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

    const Map<String, double> expected = <String, double>{
      'logoToLocation': 5,
      'locationGlyph': 13,
      'locationGap': 4,
      'tabPaddingBottom': 10,
      'reminderHideBox': 34,
      'reminderHideBleed': 8,
      'reminderStackDepth': 14,
      'reminderSheetHeight': 42,
      'reminderSheetFar': 14,
      'reminderSheetNear': 7,
      'reminderDateGap': 1,
      'reminderTextGap': 2,
      'reminderStripDivider': 14,
      'reminderStripGap': 5,
      'postBadgePaddingBlock': 2,
      'postBadgePaddingInline': 8,
      'postMetaGap': 5,
      'postMetaPinInset': 4,
      'sportPillHeight': 32,
      'sportPillPaddingBlock': 5,
      'sportPillPaddingEnd': 11,
      'sportPillGap': 5,
      'newsTextGap': 5,
      'activityTile': 42,
      'activityMarginBottom': 4,
      'activityGap': 5,
      'activityMetaLift': 2,
      'activityActionHeight': 35,
      'sheetTitleGap': 2,
      'actionRowPaddingBlock': 14,
      'actionRowTextGap': 1,
      'subChipGlyph': 14,
      'searchFieldHeight': 42,
      'searchFieldGlyph': 16,
      'listRowSubtitleGap': 1,
      'listRowGlyph': 20,
    };

    test('every token has its measured value', () {
      expect(pinned.keys.toSet(), expected.keys.toSet());
      for (final MapEntry<String, double> e in expected.entries) {
        expect(pinned[e.key], e.value, reason: e.key);
      }
    });

    test('no token is a step of the base-3 scale', () {
      for (final MapEntry<String, double> e in pinned.entries) {
        // 3 and 6 etc. are DabblerSpacing steps; a frame value that is one of
        // them must be spelled with the step, never re-declared here.
        expect(
          DabblerSpacing.scale.contains(e.value),
          isFalse,
          reason: '${e.key} (${e.value}) is on the scale',
        );
      }
    });

    test('the wordmark is 110 x 21', () {
      expect(DabblerHomeFrame.logoSize, const Size(110, 21));
      expect(homeFrameTokens['logoWidth'], 110);
      expect(homeFrameTokens['logoHeight'], 21);
    });

    test('homeFrameTokens lists every pinned token and nothing else', () {
      expect(homeFrameTokens.keys.toSet(), <String>{
        ...pinned.keys,
        'logoWidth',
        'logoHeight',
      });
      for (final MapEntry<String, double> e in pinned.entries) {
        expect(homeFrameTokens[e.key], e.value, reason: e.key);
      }
    });

    test('the frame gutter and feed bottom are on the scale', () {
      expect(
        DabblerInsets.feedScreen,
        const EdgeInsets.symmetric(horizontal: DabblerSpacing.space6),
      );
      expect(
        DabblerInsets.feedBottom,
        const EdgeInsets.only(
          bottom:
              DabblerSpacing.floatingBarClearance +
              DabblerSpacing.listBottomInset,
        ),
      );
    });

    test('two metrics: touch (default) and drawn', () {
      expect(DabblerFeedMetrics.values, <DabblerFeedMetrics>[
        DabblerFeedMetrics.touch,
        DabblerFeedMetrics.drawn,
      ]);
    });
  });
}
