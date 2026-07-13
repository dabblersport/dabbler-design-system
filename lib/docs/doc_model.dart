// =============================================================================
// Dabbler Docs — content model
// -----------------------------------------------------------------------------
// A documentation page is DATA + live-widget builders. The sidebar, search index,
// and router all derive from the page list in doc_registry.dart — nothing about
// navigation is hand-maintained. Adding a page = add one file that exposes a
// DocPage and register it in doc_registry.dart.
// =============================================================================

import 'package:flutter/widgets.dart';

/// Top-level nav groups, in sidebar order.
enum DocGroup { gettingStarted, foundations, components, patterns }

extension DocGroupX on DocGroup {
  String get slug => switch (this) {
        DocGroup.gettingStarted => 'getting-started',
        DocGroup.foundations => 'foundations',
        DocGroup.components => 'components',
        DocGroup.patterns => 'patterns',
      };

  String get label => switch (this) {
        DocGroup.gettingStarted => 'Getting Started',
        DocGroup.foundations => 'Foundations',
        DocGroup.components => 'Components',
        DocGroup.patterns => 'Patterns',
      };
}

/// One heading + its content, in the fixed page-template order. Intentionally
/// non-const: sections mix const and live-widget children, and are built once
/// per page view (not a hot path), so a const constructor would only add noise.
class DocSection {
  DocSection(this.heading, this.child);
  final String heading;
  final Widget child;
}

/// A documentation page. [builder] returns the template sections (Overview,
/// Live example, Anatomy, Variants, States, Specs, Usage, Accessibility, Code)
/// — only the ones that apply. [placeholder] marks not-yet-written stubs.
class DocPage {
  const DocPage({
    required this.id,
    required this.group,
    required this.title,
    required this.definition,
    this.builder,
    this.placeholder = false,
    this.keywords = const [],
  });

  final String id;
  final DocGroup group;
  final String title;
  final String definition;
  final List<DocSection> Function(BuildContext context)? builder;
  final bool placeholder;
  final List<String> keywords;

  String get route => '/${group.slug}/$id';

  /// Lower-cased haystack for the client-side search (title + definition +
  /// group + keywords).
  String get searchText => [
        title,
        definition,
        group.label,
        ...keywords,
      ].join(' ').toLowerCase();
}
