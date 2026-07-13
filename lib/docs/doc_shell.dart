// =============================================================================
// Dabbler Docs — app shell
// -----------------------------------------------------------------------------
// Persistent left sidebar (a Drawer on narrow screens) + content pane. The
// header carries the global controls (theme / light-dark / LTR-RTL) and a
// client-side search over page titles + headings. The ENTIRE shell renders in
// the selected theme + direction, so the docs are themselves a live demo of the
// system — flip to Sport/dark/RTL and the whole site follows.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:forui/forui.dart' as f;

import '../components/dabbler_text_field.dart';
import '../theme/dabbler_colors.dart';
import '../theme/dabbler_forui_theme.dart';
import '../theme/dabbler_spacing.dart';
import '../theme/dabbler_theme_data.dart';
import '../theme/dabbler_type.dart';
import 'doc_blocks.dart';
import 'doc_controls.dart';
import 'doc_model.dart';
import 'doc_registry.dart';
import 'doc_router.dart';

class DocShell extends StatelessWidget {
  const DocShell({super.key, required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    final controls = DocControlsScope.of(context);
    final theme = dabblerThemeData(
      controls.theme,
      controls.brightness,
      locale: controls.locale,
    );
    final page = pageForRoute(path);

    // Whole shell is themed + directioned by the header controls.
    return Theme(
      data: theme,
      child: f.FTheme(
        data: dabblerForuiThemeData(theme),
        child: Directionality(
          textDirection: controls.textDirection,
          child: Builder(
            builder: (context) => LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 900;
                final d = context.dabbler;
                return Scaffold(
                  backgroundColor: d.bgPrimary,
                  drawer: wide
                      ? null
                      : Drawer(
                          backgroundColor: d.bgSecondary,
                          child: SafeArea(
                            child: _Sidebar(
                              path: path,
                              onNavigate: () => Navigator.of(context).maybePop(),
                            ),
                          ),
                        ),
                  body: SafeArea(
                    child: Column(
                      children: [
                        _Header(showMenu: !wide),
                        Divider(
                            height: 1,
                            thickness: DabblerSizing.borderHairline,
                            color: d.borderDefault),
                        Expanded(
                          child: wide
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(
                                      width: 268,
                                      child: _Sidebar(path: path),
                                    ),
                                    VerticalDivider(
                                        width: 1,
                                        thickness: DabblerSizing.borderHairline,
                                        color: d.borderDefault),
                                    Expanded(child: DocPageView(page)),
                                  ],
                                )
                              : DocPageView(page),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// --- header ------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.showMenu});
  final bool showMenu;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    return Container(
      color: d.bgSecondary,
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: DabblerSpacing.space5,
        vertical: DabblerSpacing.space3,
      ),
      child: Row(
        children: [
          if (showMenu)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                color: d.textPrimary,
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          GestureDetector(
            onTap: () => DocRouterScope.of(context).go(defaultRoute),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: DabblerSizing.iconMd,
                  height: DabblerSizing.iconMd,
                  decoration: BoxDecoration(
                    color: d.brandPrimary,
                    borderRadius: DabblerRadius.smRadius,
                  ),
                ),
                const SizedBox(width: DabblerSpacing.space3),
                Text('Dabbler Design System',
                    style: DabblerType.emphasized(DabblerType.headline)
                        .copyWith(color: d.textPrimary)),
              ],
            ),
          ),
          const Spacer(),
          const Flexible(child: _Search()),
          const SizedBox(width: DabblerSpacing.space4),
          const _Controls(),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls();

  @override
  Widget build(BuildContext context) {
    final controls = DocControlsScope.of(context);
    final d = context.dabbler;
    final dark = controls.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Theme switcher — driven by the DabblerTheme enum.
        DropdownButtonHideUnderline(
          child: DropdownButton<DabblerTheme>(
            value: controls.theme,
            borderRadius: DabblerRadius.mdRadius,
            style: DabblerType.footnote.copyWith(color: d.textPrimary),
            dropdownColor: d.surfaceCard,
            onChanged: (t) => t == null ? null : controls.theme = t,
            items: [
              for (final t in DabblerTheme.values)
                DropdownMenuItem(
                  value: t,
                  child: Text(_themeLabel(t)),
                ),
            ],
          ),
        ),
        IconButton(
          tooltip: dark ? 'Light' : 'Dark',
          color: d.textPrimary,
          icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          onPressed: controls.toggleBrightness,
        ),
        IconButton(
          tooltip: controls.rtl ? 'LTR (EN)' : 'RTL (AR)',
          color: d.textPrimary,
          isSelected: controls.rtl,
          icon: const Icon(Icons.format_textdirection_r_to_l),
          onPressed: controls.toggleRtl,
        ),
      ],
    );
  }
}

String _themeLabel(DabblerTheme t) => switch (t) {
      DabblerTheme.main => 'Main',
      DabblerTheme.sport => 'Sport',
      DabblerTheme.social => 'Social',
      DabblerTheme.active => 'Active',
      DabblerTheme.bright => 'Bright',
      DabblerTheme.simple => 'Simple',
      DabblerTheme.shade => 'Shade',
    };

// --- search ------------------------------------------------------------------

class _Search extends StatelessWidget {
  const _Search();

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Autocomplete<DocPage>(
        displayStringForOption: (p) => p.title,
        optionsBuilder: (value) {
          final q = value.text.trim().toLowerCase();
          if (q.isEmpty) return const Iterable<DocPage>.empty();
          return docPages.where((p) => p.searchText.contains(q));
        },
        onSelected: (p) => DocRouterScope.of(context).go(p.route),
        fieldViewBuilder: (context, controller, focusNode, onSubmit) {
          return DabblerTextField.search(
            controller: controller,
            focusNode: focusNode,
            hint: 'Search',
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: AlignmentDirectional.topStart,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.only(top: DabblerSpacing.space2),
                constraints:
                    const BoxConstraints(maxWidth: 320, maxHeight: 360),
                decoration: BoxDecoration(
                  color: d.surfaceCard,
                  borderRadius: DabblerRadius.mdRadius,
                  border: Border.all(
                      color: d.borderDefault,
                      width: DabblerSizing.borderHairline),
                ),
                clipBehavior: Clip.antiAlias,
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  children: [
                    for (final p in options)
                      InkWell(
                        onTap: () => onSelected(p),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DabblerSpacing.space4,
                            vertical: DabblerSpacing.space3,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.title,
                                  style: DabblerType.callout
                                      .copyWith(color: d.textPrimary)),
                              Text(p.group.label,
                                  style: DabblerType.caption2
                                      .copyWith(color: d.textTertiary)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// --- sidebar -----------------------------------------------------------------

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.path, this.onNavigate});
  final String path;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final grouped = docPagesByGroup;

    return Container(
      color: d.bgSecondary,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: DabblerSpacing.space5,
          horizontal: DabblerSpacing.space4,
        ),
        children: [
          for (final entry in grouped.entries) ...[
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: DabblerSpacing.space3,
                bottom: DabblerSpacing.stackTight,
                top: DabblerSpacing.space3,
              ),
              child: Text(
                entry.key.label.toUpperCase(),
                style: DabblerType.caption2
                    .copyWith(color: d.textTertiary, letterSpacing: 0.6),
              ),
            ),
            for (final page in entry.value)
              _NavItem(
                page: page,
                selected: page.route == path,
                onTap: () {
                  DocRouterScope.of(context).go(page.route);
                  onNavigate?.call();
                },
              ),
            const SizedBox(height: DabblerSpacing.space4),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.page,
    required this.selected,
    required this.onTap,
  });
  final DocPage page;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    return Material(
      color: selected
          ? Color.lerp(d.surfaceCard, d.brandPrimary, 0.10)
          : Colors.transparent,
      borderRadius: DabblerRadius.smRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DabblerSpacing.space3,
            vertical: DabblerSpacing.space3,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  page.title,
                  style: (selected
                          ? DabblerType.emphasized(DabblerType.footnote)
                          : DabblerType.footnote)
                      .copyWith(
                          color: selected ? d.brandPrimary : d.textSecondary),
                ),
              ),
              if (page.placeholder)
                Text('soon',
                    style: DabblerType.caption2
                        .copyWith(color: d.textTertiary)),
            ],
          ),
        ),
      ),
    );
  }
}
