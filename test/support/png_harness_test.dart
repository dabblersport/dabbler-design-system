import 'dart:io';
import 'dart:typed_data';

import 'package:dabbler_design_system/src/messaging/chat_composer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'png_harness.dart';

/// (width, height) from the PNG's IHDR chunk, after checking the signature.
(int, int) _pngSize(File f) {
  final Uint8List b = f.readAsBytesSync();
  const List<int> signature = <int>[137, 80, 78, 71, 13, 10, 26, 10];
  expect(b.sublist(0, 8), signature, reason: 'PNG signature');
  final ByteData d = ByteData.sublistView(b);
  return (d.getUint32(16), d.getUint32(20));
}

Widget _text(String family, String text) => Padding(
  padding: const EdgeInsets.all(8),
  child: Text(
    text,
    style: TextStyle(
      fontFamily: family,
      fontSize: 24,
      fontWeight: FontWeight.w500,
    ),
  ),
);

void main() {
  testWidgets('a render that paints only the flat page fill is rejected', (
    tester,
  ) async {
    Object? failure;
    try {
      await renderPng(
        tester,
        const SizedBox.shrink(),
        name: 'harness_flat_probe',
        size: const Size(60, 40),
      );
    } on TestFailure catch (e) {
      failure = e;
    }
    expect(failure, isNotNull, reason: 'flat image must fail the harness');
    expect(failure.toString(), contains('single flat colour'));
  });

  testWidgets('renders one component in LTR and RTL to non-empty PNGs', (
    tester,
  ) async {
    const Size size = Size(390, 140);
    final Widget composer = DabblerChatComposer(
      value: 'hello',
      placeholder: 'Message',
      onAttach: () {},
      onEmoji: () {},
    );
    final File ltr = await renderPng(
      tester,
      composer,
      name: 'harness_selftest_ltr',
      size: size,
    );
    final File rtl = await renderPng(
      tester,
      composer,
      name: 'harness_selftest_rtl',
      size: size,
      direction: TextDirection.rtl,
    );
    for (final File f in <File>[ltr, rtl]) {
      expect(f.existsSync(), isTrue);
      expect(f.lengthSync(), greaterThan(1000));
      expect(_pngSize(f), (780, 280), reason: '390x140 at 2x');
    }
    expect(
      ltr.readAsBytesSync(),
      isNot(rtl.readAsBytesSync()),
      reason: 'mirroring changes the pixels',
    );
  });

  testWidgets('shipped fonts are loaded, not the test fallback', (
    tester,
  ) async {
    const Size size = Size(300, 60);
    Future<Uint8List> shot(String family, String text, String name) async {
      final File f = await renderPng(
        tester,
        _text(family, text),
        name: name,
        size: size,
        alignment: Alignment.topLeft,
      );
      return f.readAsBytesSync();
    }

    const String p = 'packages/dabbler_design_system';
    const String latin = 'Dabbler Games 123';
    const String arabic = 'مرحبا بكم في دابلر';
    final Uint8List glory = await shot('$p/Glory', latin, 'harness_glory');
    final Uint8List latinFallback = await shot(
      'NoSuchFamily',
      latin,
      'harness_latin_fallback',
    );
    expect(glory, isNot(latinFallback), reason: 'Glory differs from fallback');

    final Uint8List meral = await shot(
      '$p/Meral Sans',
      arabic,
      'harness_meral',
    );
    final Uint8List arabicFallback = await shot(
      'NoSuchFamily',
      arabic,
      'harness_arabic_fallback',
    );
    expect(
      meral,
      isNot(arabicFallback),
      reason: 'Meral Sans differs from fallback',
    );
    expect(meral, isNot(glory));
  });
}
