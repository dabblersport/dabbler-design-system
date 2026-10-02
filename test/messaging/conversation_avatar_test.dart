// Pins ConversationAvatar.jsx + messaging.jsx KIND_GLYPH (live project
// 4286affa-..., mirror 2026-10-02): avatar md>=48 / sm>=36 / xs; tile
// round(size*.4) at insetInlineEnd -2 bottom -2, --radius-sm, --surface-card,
// 1px --outline-card, glyph round(tile*.62) bold in --ink; squad 'people',
// huddle 'global', game = sport (football default); online dot (player only)
// round(size*.24) content-box + 2px --surface-page ring, insetInlineEnd 0
// bottom 0, --color-status-success; badge and dot aria-hidden.
import 'package:dabbler_design_system/src/foundations/icon.dart';
import 'package:dabbler_design_system/src/foundations/sport_icon.dart';
import 'package:dabbler_design_system/src/foundations/sports.dart';
import 'package:dabbler_design_system/src/messaging/messaging_atoms.dart';
import 'package:dabbler_design_system/src/messaging/messaging_foundations.dart';
import 'package:dabbler_design_system/src/surfaces/avatar.dart';
import 'package:dabbler_design_system/src/tokens/dabbler_geometry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/png_harness.dart';
import 'atoms_host.dart';

Widget _at(Widget a, {TextDirection d = TextDirection.ltr}) =>
    atomHost(Center(child: a), direction: d);

void main() {
  test('size math', () {
    expect(DabblerConversationAvatar.avatarSizeFor(48), DabblerAvatarSize.md);
    expect(DabblerConversationAvatar.avatarSizeFor(36), DabblerAvatarSize.sm);
    expect(DabblerConversationAvatar.avatarSizeFor(28), DabblerAvatarSize.xs);
    expect(DabblerConversationAvatar.tileFor(48), 19);
    expect(DabblerConversationAvatar.glyphFor(48), 12);
    expect(DabblerConversationAvatar.dotFor(48), 12);
    expect(DabblerConversationAvatar.tileFor(36), 14);
    expect(DabblerConversationAvatar.glyphFor(36), 9);
    expect(DabblerConversationAvatar.dotFor(36), 9);
  });

  Finder tile() => find.byWidgetPredicate(
    (w) =>
        w is Container &&
        w.decoration is BoxDecoration &&
        (w.decoration! as BoxDecoration).borderRadius == DabblerRadius.smAll,
  );
  Finder dot() => find.byWidgetPredicate(
    (w) =>
        w is Container &&
        w.decoration is BoxDecoration &&
        (w.decoration! as BoxDecoration).shape == BoxShape.circle,
  );

  testWidgets('player: no badge; online dot only for player', (t) async {
    await t.pumpWidget(_at(const DabblerConversationAvatar(seed: 'a')));
    expect(tile(), findsNothing);
    expect(dot(), findsNothing);
    await t.pumpWidget(
      _at(
        const DabblerConversationAvatar(
          kind: DabblerConversationKind.squad,
          online: true,
        ),
      ),
    );
    expect(dot(), findsNothing);
  });

  testWidgets('squad/huddle glyphs and game sport glyph', (t) async {
    await t.pumpWidget(
      _at(const DabblerConversationAvatar(kind: DabblerConversationKind.squad)),
    );
    expect(t.widget<DabblerIcon>(find.byType(DabblerIcon)).name, 'people');
    await t.pumpWidget(
      _at(
        const DabblerConversationAvatar(kind: DabblerConversationKind.huddle),
      ),
    );
    expect(t.widget<DabblerIcon>(find.byType(DabblerIcon)).name, 'global');
    await t.pumpWidget(
      _at(const DabblerConversationAvatar(kind: DabblerConversationKind.game)),
    );
    expect(
      t.widget<DabblerSportIcon>(find.byType(DabblerSportIcon)).sport,
      DabblerSport.football,
    );
    await t.pumpWidget(
      _at(
        const DabblerConversationAvatar(
          kind: DabblerConversationKind.game,
          sport: DabblerSport.padel,
        ),
      ),
    );
    final DabblerSportIcon s = t.widget<DabblerSportIcon>(
      find.byType(DabblerSportIcon),
    );
    expect(s.sport, DabblerSport.padel);
    expect(s.size, 12);
    expect(s.color, atomColors().textPrimary);
  });

  testWidgets('badge: card fill, 1px outline, overhangs end-bottom by 2', (
    t,
  ) async {
    await t.pumpWidget(
      _at(const DabblerConversationAvatar(kind: DabblerConversationKind.squad)),
    );
    final Rect whole = t.getRect(find.byType(DabblerConversationAvatar));
    expect(whole.size, const Size(48, 48));
    final Rect r = t.getRect(tile());
    expect(r.size, const Size(19, 19));
    expect(r.right - whole.right, 2);
    expect(r.bottom - whole.bottom, 2);
    final BoxDecoration d =
        t.widget<Container>(tile()).decoration! as BoxDecoration;
    expect(d.color, atomColors().surfaceCard);
    expect((d.border! as Border).top.width, 1);
    expect((d.border! as Border).top.color, atomColors().borderDefault);
  });

  testWidgets('RTL: badge and dot move to the left corner', (t) async {
    await t.pumpWidget(
      _at(
        const DabblerConversationAvatar(kind: DabblerConversationKind.huddle),
        d: TextDirection.rtl,
      ),
    );
    final Rect whole = t.getRect(find.byType(DabblerConversationAvatar));
    expect(whole.left - t.getRect(tile()).left, 2);
    await t.pumpWidget(
      _at(const DabblerConversationAvatar(online: true), d: TextDirection.rtl),
    );
    expect(t.getRect(dot()).left, whole.left);
    expect(t.getRect(dot()).bottom, whole.bottom);
  });

  testWidgets('online dot at 48 and 36: content + 2px page ring', (t) async {
    for (final double s in <double>[48, 36]) {
      await t.pumpWidget(_at(DabblerConversationAvatar(online: true, size: s)));
      final Rect whole = t.getRect(find.byType(DabblerConversationAvatar));
      final Rect r = t.getRect(dot());
      expect(r.width, DabblerConversationAvatar.dotFor(s) + 4);
      expect(r.right, whole.right);
      expect(r.bottom, whole.bottom);
      final BoxDecoration d =
          t.widget<Container>(dot()).decoration! as BoxDecoration;
      expect(d.color, atomColors().success.base);
      expect((d.border! as Border).top.width, 2);
      expect((d.border! as Border).top.color, atomColors().bgPrimary);
      expect(t.getSize(find.byType(DabblerAvatar)), Size(s, s));
    }
  });

  testWidgets('badge and dot are hidden from semantics', (t) async {
    final SemanticsHandle h = t.ensureSemantics();
    await t.pumpWidget(
      _at(
        const DabblerConversationAvatar(
          kind: DabblerConversationKind.game,
          sport: DabblerSport.tennis,
        ),
      ),
    );
    expect(
      find.bySemanticsLabel(RegExp('tennis', caseSensitive: false)),
      findsNothing,
    );
    h.dispose();
  });

  testWidgets('renders LTR and RTL PNGs', (t) async {
    for (final TextDirection d in TextDirection.values) {
      final f = await renderPng(
        t,
        const Padding(
          padding: EdgeInsets.all(12),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              DabblerConversationAvatar(seed: 'omar', online: true),
              DabblerConversationAvatar(
                kind: DabblerConversationKind.squad,
                seed: 's',
              ),
              DabblerConversationAvatar(
                kind: DabblerConversationKind.huddle,
                seed: 'h',
              ),
              DabblerConversationAvatar(
                kind: DabblerConversationKind.game,
                sport: DabblerSport.padel,
                seed: 'g',
              ),
              DabblerConversationAvatar(seed: 'mina', size: 36, online: true),
              DabblerConversationAvatar(
                kind: DabblerConversationKind.squad,
                seed: 's',
                size: 36,
              ),
            ],
          ),
        ),
        name: 'conversation_avatar_${d.name}',
        size: const Size(320, 140),
        direction: d,
        alignment: Alignment.topCenter,
      );
      expect(f.lengthSync(), greaterThan(0));
    }
  });
}
