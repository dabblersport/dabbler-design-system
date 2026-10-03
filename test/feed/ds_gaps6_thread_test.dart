import 'package:dabbler_design_system/src/feed/attachment_chip.dart';
import 'package:dabbler_design_system/src/feed/comment_row.dart';
import 'package:dabbler_design_system/src/feed/reply_composer.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'thread_host.dart';

const ValueKey<String> _a = ValueKey<String>('a');
const ValueKey<String> _b = ValueKey<String>('b');
const ValueKey<String> _c = ValueKey<String>('c');

void main() {
  for (final TextDirection dir in TextDirection.values) {
    group('DS gaps 6 (${dir.name})', () {
      testWidgets('text composer action: pill with its label, one button', (
        WidgetTester t,
      ) async {
        final SemanticsHandle h = t.ensureSemantics();
        int gif = 0;
        await t.pumpWidget(
          threadHost(
            DabblerReplyComposer(
              onSend: (_) {},
              attachActions: <DabblerReplyComposerAction>[
                const DabblerReplyComposerAction(
                  icon: 'gallery',
                  label: 'Photo',
                  onTap: null,
                ),
                DabblerReplyComposerAction.text(
                  label: 'GIF',
                  onTap: () => gif++,
                ),
              ],
            ),
            direction: dir,
          ),
        );
        expect(find.text('GIF'), findsOneWidget);
        await t.tap(find.text('GIF'));
        expect(gif, 1);
        expect(find.bySemanticsLabel('GIF'), findsOneWidget);
        final Rect target = t.getRect(
          find
              .ancestor(
                of: find.text('GIF'),
                matching: find.byType(ConstrainedBox),
              )
              .first,
        );
        expect(
          target.height,
          greaterThanOrEqualTo(DabblerSizing.touchTargetMin),
        );
        expect(
          target.width,
          greaterThanOrEqualTo(DabblerSizing.touchTargetMin),
        );
        // Order follows direction: the icon action leads the text action.
        final double photo = t.getCenter(find.bySemanticsLabel('Photo')).dx;
        final double g = t.getCenter(find.text('GIF')).dx;
        expect(dir == TextDirection.ltr ? photo < g : photo > g, isTrue);
        expect(t.takeException(), isNull);
        h.dispose();
      });

      testWidgets('text action is disabled while sending', (t) async {
        int gif = 0;
        await t.pumpWidget(
          threadHost(
            DabblerReplyComposer(
              onSend: (_) {},
              sending: true,
              attachActions: <DabblerReplyComposerAction>[
                DabblerReplyComposerAction.text(
                  label: 'GIF',
                  onTap: () => gif++,
                ),
              ],
            ),
            direction: dir,
          ),
        );
        await t.tap(find.text('GIF'), warnIfMissed: false);
        expect(gif, 0);
      });

      for (final (String name, DabblerAttachmentChip chip, Size want)
          in <(String, DabblerAttachmentChip, Size)>[
            (
              'size 80x60',
              const DabblerAttachmentChip(
                thumbnail: SizedBox.expand(),
                label: 'photo',
                size: Size(80, 60),
              ),
              const Size(80, 60),
            ),
            (
              'size 200x150',
              const DabblerAttachmentChip(
                thumbnail: SizedBox.expand(),
                label: 'photo',
                size: Size(200, 150),
              ),
              const Size(200, 150),
            ),
            (
              'aspectRatio 4/3 at 60',
              const DabblerAttachmentChip(
                thumbnail: SizedBox.expand(),
                label: 'photo',
                thumbnailSize: 60,
                aspectRatio: 4 / 3,
              ),
              const Size(80, 60),
            ),
            (
              'default square',
              const DabblerAttachmentChip(
                thumbnail: SizedBox.expand(),
                label: 'photo',
              ),
              const Size(96, 96),
            ),
          ]) {
        testWidgets('attachment chip $name', (t) async {
          await t.pumpWidget(threadHost(Center(child: chip), direction: dir));
          expect(t.getSize(find.byType(DabblerAttachmentChip)), want);
          expect(chip.thumbnailBox, want);
        });
      }

      testWidgets('attachment chip radius token and remove at end corner', (
        t,
      ) async {
        await t.pumpWidget(
          threadHost(
            Center(
              child: DabblerAttachmentChip(
                thumbnail: const SizedBox.expand(),
                label: 'photo',
                size: const Size(200, 150),
                borderRadius: DabblerRadius.mdAll,
                onRemove: () {},
              ),
            ),
            direction: dir,
          ),
        );
        final Iterable<Container> boxes = t.widgetList<Container>(
          find.descendant(
            of: find.byType(DabblerAttachmentChip),
            matching: find.byType(Container),
          ),
        );
        final BoxDecoration d = boxes.first.decoration! as BoxDecoration;
        expect(d.borderRadius, DabblerRadius.mdAll);
        final Rect chip = t.getRect(find.byType(DabblerAttachmentChip));
        final Rect remove = t.getRect(
          find.bySemanticsLabel('Remove attachment'),
        );
        if (dir == TextDirection.ltr) {
          expect(remove.right, chip.right);
        } else {
          expect(remove.left, chip.left);
        }
      });

      testWidgets('comment row lays several attachments out in a wrap', (
        t,
      ) async {
        await t.pumpWidget(
          threadHost(
            const DabblerCommentRow(
              name: 'Karim',
              time: '1h',
              body: 'pics',
              attachment: SizedBox(key: _a, width: 80, height: 60),
              attachments: <Widget>[
                SizedBox(key: _b, width: 80, height: 60),
                SizedBox(key: _c, width: 80, height: 60),
              ],
            ),
            direction: dir,
          ),
        );
        expect(find.byType(Wrap), findsOneWidget);
        final Rect a = t.getRect(find.byKey(_a));
        final Rect b = t.getRect(find.byKey(_b));
        final Rect c = t.getRect(find.byKey(_c));
        expect(a.top, b.top);
        if (dir == TextDirection.ltr) {
          expect(b.left - a.right, DabblerSpacing.space2);
          expect(c.left - b.right, DabblerSpacing.space2);
        } else {
          expect(a.left - b.right, DabblerSpacing.space2);
          expect(b.left - c.right, DabblerSpacing.space2);
        }
        expect(t.takeException(), isNull);
      });

      testWidgets('single attachment still renders without a wrap', (t) async {
        await t.pumpWidget(
          threadHost(
            const DabblerCommentRow(
              name: 'Karim',
              time: '1h',
              body: 'pic',
              attachment: SizedBox(key: _a, width: 80, height: 60),
            ),
            direction: dir,
          ),
        );
        expect(find.byKey(_a), findsOneWidget);
        expect(find.byType(Wrap), findsNothing);
      });
    });
  }
}
