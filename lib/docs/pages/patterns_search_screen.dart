// =============================================================================
// Docs · Patterns — Search Screen
// -----------------------------------------------------------------------------
// The acceptance test for the liquid-glass component set: the "Search Screen"
// frame (dabbler.pen · node gJe6e) assembled ENTIRELY from restyled components —
// DabblerTextField.search, DabblerChip, DabblerIconTile, DabblerCard,
// DabblerListTile, DabblerButton — plus bare Text/Icon/Row/Column. No bespoke
// one-off widgets. It re-tints with the header's theme/mode/direction controls.
// =============================================================================

import 'package:flutter/material.dart';

import '../../components/dabbler_button.dart';
import '../../components/dabbler_card.dart';
import '../../components/dabbler_chip.dart';
import '../../components/dabbler_surface.dart';
import '../../components/dabbler_text_field.dart';
import '../../theme/dabbler_colors.dart';
import '../../theme/dabbler_spacing.dart';
import '../../theme/dabbler_type.dart';
import '../doc_blocks.dart';
import '../doc_model.dart';

final searchScreenPage = DocPage(
  id: 'search-screen',
  group: DocGroup.patterns,
  title: 'Search Screen',
  definition:
      'The glass search experience — field, recent tags, quick access, trending, '
      'and filters — built only from the component set.',
  keywords: [
    'pattern',
    'search',
    'screen',
    'glass',
    'chips',
    'trending',
    'filters',
  ],
  builder: (context) => [
    DocSection(
      'Overview',
      const DocProse(
        'This page is the acceptance test for the glass restyle: the Search '
        'Screen from the design source (dabbler.pen · "Search Screen"), '
        'assembled entirely from DabblerTextField, DabblerChip, DabblerIconTile, '
        'DabblerCard, DabblerListTile, and DabblerButton. If a piece of the '
        'screen needed a bespoke widget, the component set would be wrong. '
        'Switch the header theme to Sport or Bright to watch every glass '
        'surface re-tint.',
      ),
    ),
    DocSection(
      'Live example',
      DocExampleFrame(
        align: AlignmentDirectional.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 402),
          child: const _SearchScreen(),
        ),
      ),
    ),
    DocSection(
      'Anatomy',
      const DocAnatomy([
        AnatomyPart('Search field', 'DabblerTextField.search — glass, radius 24, brand leading icon.'),
        AnatomyPart('Recent tags', 'DabblerChip rows with a text-variant Clear button.'),
        AnatomyPart('Quick access', 'Interactive DabblerCards: DabblerIconTile · title/subtitle · circular icon DabblerButton.'),
        AnatomyPart('Trending list', 'One glass DabblerCard blurred once; DabblerListTile rows with brand-tinted dividers.'),
        AnatomyPart('Quick filters', 'DabblerChips; the active one uses the brand-filled selected treatment.'),
      ]),
    ),
    DocSection(
      'Code',
      const DocCodeBlock('''
DabblerGlassBackground(
  child: ListView(children: [
    DabblerTextField.search(hint: 'Search people, games, posts...'),
    DabblerChip(label: 'Near me', selected: true, onTap: () {}),
    DabblerCard(
      variant: DabblerCardVariant.interactive,
      onTap: openPeople,
      child: Row(children: [
        const DabblerIconTile(icon: Icons.group_outlined),
        Expanded(child: titleAndSubtitle),
        DabblerButton.icon(icon: chevron, size: DabblerButtonSize.small),
      ]),
    ),
    // Trending: ONE glass card, rows unblurred inside.
    DabblerCard(padding: EdgeInsets.zero, child: Column(children: tiles)),
  ]),
);'''),
    ),
  ],
);

class _SearchScreen extends StatelessWidget {
  const _SearchScreen();

  @override
  Widget build(BuildContext context) {
    final d = context.dabbler;
    final rtl = Directionality.of(context) == TextDirection.rtl;

    // 12/700 section header — tracking is dropped in RTL because letterspacing
    // breaks Arabic letter-joining.
    TextStyle overline(Color color) => DabblerType.caption1.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: rtl ? 0 : 1,
          color: color,
        );

    Widget sectionHeader(IconData icon, String title, Color color,
        {Widget? trailing}) {
      return Row(
        children: [
          Icon(icon, size: DabblerSizing.iconSm, color: color),
          const SizedBox(width: DabblerSpacing.space3),
          Expanded(child: Text(title, style: overline(color))),
          if (trailing != null) trailing,
        ],
      );
    }

    Widget quickAccessCard({
      required IconData icon,
      required String title,
      required String subtitle,
    }) {
      return DabblerCard(
        variant: DabblerCardVariant.interactive,
        onTap: () {},
        padding: const EdgeInsets.symmetric(
          horizontal: DabblerSpacing.space5, // 15 (pen 16)
          vertical: DabblerSpacing.space5,
        ),
        child: Row(
          children: [
            DabblerIconTile(icon: icon),
            const SizedBox(width: DabblerSpacing.stackDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: DabblerType.headline
                          .copyWith(color: d.textPrimary)),
                  const SizedBox(height: DabblerSpacing.space1),
                  Text(subtitle,
                      style: DabblerType.footnote
                          .copyWith(color: d.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: DabblerSpacing.stackDefault),
            DabblerButton.icon(
              icon: rtl ? Icons.chevron_left : Icons.chevron_right,
              size: DabblerButtonSize.small,
              onPressed: () {},
            ),
          ],
        ),
      );
    }

    const trends = [
      ('#PadelDubai2026', '2.4k searches', Icons.tag),
      ('#YouthLeague', '1.8k searches', Icons.tag),
      ('#SundayRun', '1.2k searches', Icons.tag),
      ('#RooftopPadel', '960 searches', Icons.tag),
      ('#CityLeagues', '740 searches', Icons.tag),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1 · Search field — the Search Field treatment.
        const DabblerTextField.search(hint: 'Search people, games, posts...'),
        const SizedBox(height: DabblerSpacing.space7),

        // 2 · Recent
        Row(
          children: [
            Icon(Icons.history,
                size: DabblerSizing.iconSm, color: d.textSecondary),
            const SizedBox(width: DabblerSpacing.space3),
            Expanded(child: Text('RECENT', style: overline(d.textSecondary))),
            DabblerButton(
              label: 'Clear',
              variant: DabblerButtonVariant.text,
              size: DabblerButtonSize.small,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: DabblerSpacing.space3),
        Wrap(
          spacing: DabblerSpacing.space3,
          runSpacing: DabblerSpacing.space3,
          children: [
            for (final tag in [
              'padel courts',
              '5-a-side sunday',
              'beach volleyball',
              'mixed doubles',
              'run club'
            ])
              DabblerChip(label: tag, onTap: () {}),
          ],
        ),
        const SizedBox(height: DabblerSpacing.space7),

        // 3 · Quick access cards
        quickAccessCard(
          icon: Icons.group_outlined,
          title: 'People nearby',
          subtitle: '32 players within 5 km',
        ),
        const SizedBox(height: DabblerSpacing.space3),
        quickAccessCard(
          icon: Icons.sports_soccer,
          title: 'Popular games',
          subtitle: 'Open spots tonight',
        ),
        const SizedBox(height: DabblerSpacing.space3),
        quickAccessCard(
          icon: Icons.local_fire_department_outlined,
          title: 'Trending posts',
          subtitle: 'What the city is playing',
        ),
        const SizedBox(height: DabblerSpacing.space7),

        // 4 · Trending — ONE glass container, unblurred rows, brand dividers.
        sectionHeader(
          Icons.trending_up, 'TRENDING NOW', d.textPrimary,
          trailing: DabblerButton(
            label: 'View all',
            variant: DabblerButtonVariant.text,
            size: DabblerButtonSize.small,
            onPressed: () {},
          ),
        ),
        const SizedBox(height: DabblerSpacing.space3),
        DabblerCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < trends.length; i++)
                DabblerListTile(
                  leading: Icon(trends[i].$3,
                      size: DabblerSizing.iconMd, color: d.brandPrimary),
                  title: trends[i].$1,
                  subtitle: trends[i].$2,
                  trailing: const DabblerChevron(),
                  onTap: () {},
                  showDivider: i < trends.length - 1,
                ),
            ],
          ),
        ),
        const SizedBox(height: DabblerSpacing.space7),

        // 5 · Search smarter grid — nested glass cards inside the flat ladder.
        sectionHeader(Icons.auto_awesome, 'SEARCH SMARTER', d.textPrimary),
        const SizedBox(height: DabblerSpacing.space3),
        for (final row in const [
          [('Search posts', Icons.article_outlined), ('Search venues', Icons.place_outlined)],
          [('Search photos', Icons.photo_outlined), ('Search coaches', Icons.sports_outlined)],
        ]) ...[
          Row(
            children: [
              for (final (label, icon) in row) ...[
                Expanded(
                  child: DabblerCard(
                    variant: DabblerCardVariant.outlined,
                    onTap: () {},
                    padding: const EdgeInsets.symmetric(
                      horizontal: DabblerSpacing.space4,
                      vertical: DabblerSpacing.space4,
                    ),
                    child: Row(
                      children: [
                        Icon(icon,
                            size: DabblerSizing.iconSm, color: d.brandPrimary),
                        const SizedBox(width: DabblerSpacing.space3),
                        Expanded(
                          child: Text(label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: DabblerType.footnote
                                  .copyWith(color: d.textPrimary)),
                        ),
                      ],
                    ),
                  ),
                ),
                if (row.last.$1 != label)
                  const SizedBox(width: DabblerSpacing.space3),
              ],
            ],
          ),
          const SizedBox(height: DabblerSpacing.space3),
        ],
        const SizedBox(height: DabblerSpacing.space4),

        // 6 · Quick filters — Near Me carries the selected treatment.
        sectionHeader(Icons.filter_alt_outlined, 'QUICK FILTERS', d.textSecondary),
        const SizedBox(height: DabblerSpacing.space3),
        Wrap(
          spacing: DabblerSpacing.space3,
          runSpacing: DabblerSpacing.space3,
          children: [
            DabblerChip(
                label: 'Near me',
                selected: true,
                leadingIcon: Icons.near_me,
                onTap: () {}),
            DabblerChip(label: 'Today', onTap: () {}),
            DabblerChip(label: 'This week', onTap: () {}),
            DabblerChip(label: 'Friends only', onTap: () {}),
            DabblerChip(label: 'Popular', onTap: () {}),
            DabblerChip(label: 'Free to join', onTap: () {}),
          ],
        ),
      ],
    );
  }
}
