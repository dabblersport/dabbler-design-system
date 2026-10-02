/// Headless PNG rendering for design-system evidence.
///
/// `flutter_test` loads neither the package's own fonts nor Iconsax, so a bare
/// `toImage` draws the Ahem test font and tofu boxes. This harness registers
/// them with [FontLoader] from the package's own files, mounts a widget in a
/// themed, directional host and writes `build/png/<name>.png`.
///
/// ```dart
/// testWidgets('composer', (tester) async {
///   await renderPng(tester, const DabblerChatComposer(value: 'hi'),
///       name: 'chat_composer_ltr', size: const Size(390, 140));
/// });
/// ```
///
/// * Output goes to `build/png/`, which `.gitignore` already excludes
///   (`/build/`). **Never commit PNGs**: this repo commits no goldens.
/// * [renderPng] drives the framework with `tester.runAsync`, so call it from
///   `testWidgets`. [loadDesignSystemFonts] is called for you (once per
///   process).
/// * The widget is laid out in a [Size] box at the given pixel ratio, with
///   the page fill behind it, so a bottom-anchored component (a composer) sits
///   at the bottom of the image.
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:dabbler_design_system/src/tokens/dabbler_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

bool _fontsLoaded = false;

/// Registers Gloock, Glory, Wingx, Meral Sans (under
/// `packages/dabbler_design_system/<Family>`, the name `DabblerType` builds)
/// and the Iconsax icon font. Safe to call repeatedly.
Future<void> loadDesignSystemFonts() async {
  if (_fontsLoaded) return;
  Future<void> load(String family, List<String> files) async {
    final FontLoader loader = FontLoader(family);
    for (final String f in files) {
      loader.addFont(rootBundle.load(f));
    }
    await loader.load();
  }

  const String p = 'packages/dabbler_design_system';
  await load('$p/Gloock', <String>['fonts/Gloock-Regular.ttf']);
  await load('$p/Glory', <String>[
    'fonts/Glory-Light.ttf',
    'fonts/Glory-Regular.ttf',
    'fonts/Glory-Medium.ttf',
    'fonts/Glory-SemiBold.ttf',
    'fonts/Glory-Bold.ttf',
  ]);
  await load('$p/Wingx', <String>['fonts/Wingx-Regular.otf']);
  await load('$p/Meral Sans', <String>[
    'fonts/meral-sans-light.ttf',
    'fonts/meral-sans-regular.ttf',
    'fonts/meral-sans-medium.ttf',
    'fonts/meral-sans-semibold.ttf',
    'fonts/meral-sans-bold.ttf',
  ]);
  await load('packages/iconsax_flutter/FlutterIconsax', <String>[
    'packages/iconsax_flutter/fonts/FlutterIconsax.ttf',
  ]);
  _fontsLoaded = true;
}

/// Renders [widget] and writes `build/png/<name>.png`, returning the file.
///
/// [size] is in logical pixels; the PNG is `size * pixelRatio`. [brightness]
/// defaults to light. [background] defaults to the page fill (`bgPrimary`).
Future<File> renderPng(
  WidgetTester tester,
  Widget widget, {
  required String name,
  Size size = const Size(390, 600),
  TextDirection direction = TextDirection.ltr,
  double pixelRatio = 2,
  Brightness? brightness,
  Color? background,
  Alignment alignment = Alignment.bottomCenter,
}) async {
  await tester.runAsync(loadDesignSystemFonts);
  final Brightness b = brightness ?? Brightness.light;
  final DabblerColors colors = DabblerColors.resolve(
    theme: DabblerTheme.main,
    brightness: b,
  );
  final GlobalKey boundary = GlobalKey();
  tester.view.physicalSize = size * pixelRatio;
  tester.view.devicePixelRatio = pixelRatio;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: b,
        extensions: <ThemeExtension<dynamic>>[colors],
      ),
      home: Directionality(
        textDirection: direction,
        child: RepaintBoundary(
          key: boundary,
          child: ColoredBox(
            color: background ?? colors.bgPrimary,
            child: Align(alignment: alignment, child: widget),
          ),
        ),
      ),
    ),
  );
  await tester.pump();

  late final File file;
  String? problem;
  await tester.runAsync(() async {
    final RenderRepaintBoundary render =
        boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final ui.Image image = await render.toImage(pixelRatio: pixelRatio);
    final ByteData? data = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List bytes = data!.buffer.asUint8List();
    file = File('build/png/$name.png')..createSync(recursive: true);
    file.writeAsBytesSync(bytes);
    problem = await _verifyPng(bytes, name, size * pixelRatio);
  });
  expect(problem, isNull, reason: problem);
  return file;
}

/// Checks the written bytes are a real PNG of the expected pixel size and are
/// not a single flat colour (a component that painted nothing).
///
/// Decodes through `dart:ui`, so a truncated or mislabelled file fails here
/// rather than being counted as evidence because its length is non-zero.
Future<String?> _verifyPng(Uint8List bytes, String name, Size expected) async {
  const List<int> signature = <int>[137, 80, 78, 71, 13, 10, 26, 10];
  for (int i = 0; i < 8; i++) {
    if (bytes[i] != signature[i]) return '$name: not a PNG (bad signature)';
  }
  final ui.Codec codec = await ui.instantiateImageCodec(bytes);
  final ui.FrameInfo frame = await codec.getNextFrame();
  final ui.Image decoded = frame.image;
  final Size got = Size(decoded.width.toDouble(), decoded.height.toDouble());
  String? result;
  if (got != expected) {
    result = '$name: decoded size $got != size * pixelRatio $expected';
  } else {
    final Uint8List px = (await decoded.toByteData())!.buffer.asUint8List();
    bool varied = false;
    for (int i = 4; i < px.length; i += 4) {
      if (px[i] != px[0] ||
          px[i + 1] != px[1] ||
          px[i + 2] != px[2] ||
          px[i + 3] != px[3]) {
        varied = true;
        break;
      }
    }
    if (!varied) result = '$name: the image is a single flat colour';
  }
  decoded.dispose();
  codec.dispose();
  return result;
}
