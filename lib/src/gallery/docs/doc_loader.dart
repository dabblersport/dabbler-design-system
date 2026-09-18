/// Reads a documentation page out of the asset bundle — `T-085` part 2.
///
/// The four `assets:` lines in `pubspec.yaml` are what make these files visible
/// to [rootBundle] at all; without them every call here returns
/// [DabblerDocPage.unavailable]. The declaration is non-recursive by directory,
/// which is why it names four directories and not one — see the comment beside
/// it in `pubspec.yaml`.
library;

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import 'doc_page.dart';
import 'doc_vocabulary.dart';

/// Loads and parses documentation pages from the asset bundle.
///
/// **Never throws.** A missing, unreadable or unparseable page comes back as
/// [DabblerDocPage.unavailable], which renders as a visible "page not available"
/// section — a broken page is a visible defect in the gallery, not a crash in a
/// consumer's app.
class DabblerDocLoader {
  /// Creates a loader reading from [bundle], defaulting to [rootBundle].
  ///
  /// The seam exists so a test can supply its own bundle; it is not a
  /// configuration point for consumers.
  const DabblerDocLoader({AssetBundle? bundle}) : _bundle = bundle;

  final AssetBundle? _bundle;

  AssetBundle get _effectiveBundle => _bundle ?? rootBundle;

  /// The full asset path for a page named relative to the corpus root.
  ///
  /// `components/button.md` becomes
  /// `assets/documentation/components/button.md`. A path that already carries
  /// the root is returned unchanged, so either spelling is accepted at every
  /// entry point here.
  static String assetPathFor(String page) {
    if (page.startsWith('${DabblerDocVocabulary.assetRoot}/')) {
      return page;
    }
    final String trimmed = page.startsWith('/') ? page.substring(1) : page;
    return '${DabblerDocVocabulary.assetRoot}/$trimmed';
  }

  /// Reads one page's markdown and splits it into sections.
  ///
  /// [page] is either a corpus-relative path (`foundations/colour.md`) or a full
  /// asset path. The provenance comment is stripped before splitting.
  Future<DabblerDocPage> load(String page) async {
    final String path = assetPathFor(page);
    final String raw;
    try {
      raw = await _effectiveBundle.loadString(path);
    } on Object catch (error) {
      return DabblerDocPage.unavailable(path, _reason(error));
    }
    try {
      return DabblerDocSplitter.split(path, raw);
    } on Object catch (error) {
      return DabblerDocPage.unavailable(path, _reason(error));
    }
  }

  /// Reads the raw markdown without splitting it, for a caller that only needs
  /// to know whether the bundle can see the file.
  ///
  /// Returns `null` instead of throwing when it cannot.
  Future<String?> loadRaw(String page) async {
    try {
      return await _effectiveBundle.loadString(assetPathFor(page));
    } on Object {
      return null;
    }
  }

  /// A one-line reason for the "not available" section, without a stack trace.
  ///
  /// The commonest case by far is the asset not being declared in
  /// `pubspec.yaml`, and Flutter's own message for that is long and unhelpful in
  /// a rendered section, so it is named directly.
  static String _reason(Object error) {
    final String text = error.toString();
    if (text.contains('Unable to load asset')) {
      return 'the bundle has no such asset (is it declared under `assets:` in '
          'pubspec.yaml? that declaration is not recursive)';
    }
    final int newline = text.indexOf('\n');
    return newline < 0 ? text : text.substring(0, newline);
  }
}
