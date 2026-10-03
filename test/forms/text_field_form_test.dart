import 'package:dabbler_design_system/dabbler_design_system.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show SemanticsNode;
import 'package:flutter_test/flutter_test.dart';

import '_host.dart';

String? _required(String? v) => (v == null || v.isEmpty) ? 'Required' : null;

Widget _form(
  GlobalKey<FormState> key,
  Widget child, {
  TextDirection direction = TextDirection.ltr,
}) => host(
  Form(key: key, child: child),
  direction: direction,
);

void main() {
  group('DabblerTextField — Form integration', () {
    testWidgets('validate() shows the message in the error slot', (
      WidgetTester tester,
    ) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      await tester.pumpWidget(
        _form(form, const DabblerTextField(validator: _required)),
      );
      expect(find.text('Required'), findsNothing);
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      final Text error = tester.widget<Text>(find.text('Required'));
      expect(
        error.style!.color,
        testColors().status(DabblerStatusTone.error).base,
      );

      await tester.enterText(find.byType(EditableText), 'ok');
      expect(form.currentState!.validate(), isTrue);
      await tester.pump();
      expect(find.text('Required'), findsNothing);
    });

    testWidgets('save() passes the current text to onSaved', (
      WidgetTester tester,
    ) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      String? saved;
      await tester.pumpWidget(
        _form(form, DabblerTextField(onSaved: (String? v) => saved = v)),
      );
      await tester.enterText(find.byType(EditableText), 'dabbler');
      form.currentState!.save();
      expect(saved, 'dabbler');
    });

    testWidgets('reset() restores the initial text and clears the error', (
      WidgetTester tester,
    ) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      final TextEditingController c = TextEditingController(text: 'start');
      addTearDown(c.dispose);
      await tester.pumpWidget(
        _form(form, DabblerTextField(controller: c, validator: _required)),
      );
      await tester.enterText(find.byType(EditableText), '');
      form.currentState!.validate();
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);

      form.currentState!.reset();
      await tester.pump();
      expect(c.text, 'start');
      expect(find.text('Required'), findsNothing);
    });

    testWidgets('onUserInteraction validates live after the first edit', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          const DabblerTextField(
            validator: _required,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            initialValue: 'a',
          ),
        ),
      );
      expect(find.text('Required'), findsNothing);
      await tester.enterText(find.byType(EditableText), '');
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
      await tester.enterText(find.byType(EditableText), 'b');
      await tester.pump();
      expect(find.text('Required'), findsNothing);
    });

    testWidgets('a validator message wins over errorText, which shows after', (
      WidgetTester tester,
    ) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      await tester.pumpWidget(
        _form(
          form,
          const DabblerTextField(validator: _required, errorText: 'Server'),
        ),
      );
      expect(find.text('Server'), findsOneWidget);
      form.currentState!.validate();
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
      expect(find.text('Server'), findsNothing);
    });

    testWidgets('the clear button updates the form value', (
      WidgetTester tester,
    ) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      await tester.pumpWidget(
        _form(
          form,
          const DabblerTextField(
            variant: DabblerTextFieldVariant.search,
            clearable: true,
            initialValue: 'x',
            validator: _required,
          ),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Clear'));
      await tester.pump();
      expect(form.currentState!.validate(), isFalse);
    });

    testWidgets('password and multiline validate too', (
      WidgetTester tester,
    ) async {
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      await tester.pumpWidget(
        _form(
          form,
          const Column(
            children: <Widget>[
              DabblerTextField(
                variant: DabblerTextFieldVariant.password,
                validator: _required,
              ),
              DabblerTextField(
                variant: DabblerTextFieldVariant.multiline,
                validator: _required,
              ),
            ],
          ),
        ),
      );
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Required'), findsNWidgets(2));
    });

    testWidgets('the error is announced as a live region', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final GlobalKey<FormState> form = GlobalKey<FormState>();
      await tester.pumpWidget(
        _form(form, const DabblerTextField(validator: _required)),
      );
      form.currentState!.validate();
      await tester.pump();
      expect(
        tester.getSemantics(find.text('Required')),
        isA<SemanticsNode>()
            .having(
              (SemanticsNode n) => n.flagsCollection.isLiveRegion,
              'live region',
              isTrue,
            )
            .having(
              (SemanticsNode n) => n.label,
              'label',
              contains('Required'),
            ),
      );
      handle.dispose();
    });

    testWidgets('a plain errorText is not a live region (unchanged)', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const DabblerTextField(errorText: 'Bad')));
      expect(
        tester.getSemantics(find.text('Bad')),
        isA<SemanticsNode>().having(
          (SemanticsNode n) => n.flagsCollection.isLiveRegion,
          'live region',
          isFalse,
        ),
      );
      handle.dispose();
    });

    testWidgets('without validator/onSaved/autovalidateMode no FormField', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(const DabblerTextField()));
      expect(find.byType(FormField<String>), findsNothing);
    });
  });

  group('DabblerTextField — suffixText', () {
    for (final DabblerTextFieldVariant v in <DabblerTextFieldVariant>[
      DabblerTextFieldVariant.standard,
      DabblerTextFieldVariant.search,
      DabblerTextFieldVariant.password,
      DabblerTextFieldVariant.multiline,
    ]) {
      testWidgets('${v.name}: shown inside the box in the secondary role', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(DabblerTextField(variant: v, suffixText: 'min')),
        );
        final Text t = tester.widget<Text>(find.text('min'));
        expect(t.style!.color, testColors().textSecondary);
        final Rect box = tester.getRect(find.byType(DabblerSurface).first);
        final Rect r = tester.getRect(find.text('min'));
        expect(box.contains(r.center), isTrue);
      });
    }

    for (final TextDirection d in TextDirection.values) {
      testWidgets('sits at the trailing edge (${d.name})', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          host(const DabblerTextField(suffixText: 'km'), direction: d),
        );
        final Rect input = tester.getRect(find.byType(EditableText));
        final Rect suffix = tester.getRect(find.text('km'));
        if (d == TextDirection.ltr) {
          expect(suffix.left, greaterThanOrEqualTo(input.right));
        } else {
          expect(suffix.right, lessThanOrEqualTo(input.left));
        }
      });
    }

    testWidgets('disabled takes the tertiary role', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(const DabblerTextField(suffixText: 'min', enabled: false)),
      );
      expect(
        tester.widget<Text>(find.text('min')).style!.color,
        testColors().textTertiary,
      );
    });

    testWidgets('select ignores it', (WidgetTester tester) async {
      await tester.pumpWidget(
        host(
          const DabblerTextField(
            variant: DabblerTextFieldVariant.select,
            suffixText: 'min',
          ),
        ),
      );
      expect(find.text('min'), findsNothing);
    });
  });
}
