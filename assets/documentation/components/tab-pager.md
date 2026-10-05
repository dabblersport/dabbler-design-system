<!--
Component page, D-033 ten-part template.

Group    : Navigation
Sources  : lib/src/layout/tab_pager.dart (DabblerTabPager — DabblerTabs header,
           PageView body, keep-alive + PageStorageKey per tab id)
           lib/src/layout/refresh_gallery.dart (specimen "TabPager — tabs
           over swipeable pages")
           KAN-409 item 3
-->

# TabPager
### `DabblerTabPager`

TabPager is a `Tabs` header over a body of swipeable pages, one page per tab.

Tapping a tab slides the body to its page, and swiping the body moves the tab indicator, so the two
never disagree. Each page is kept alive with its own storage bucket, which means a list scrolled
part-way down in one tab is still there when the user comes back to it.

## Specimen

Three tabs over three lists — see `refresh_gallery.dart`'s *TabPager* section.

@specimen tab-pager

## Using it

**Give every tab a unique `id`.** The id keys the page's stored scroll position; two tabs sharing an
id share one position.

**Pass exactly one page per tab, in the same order.** The pager asserts the counts match.

**Use a `PageController` only when something outside the pager must move it.** The header follows
the body's own page changes, so a controller that jumps or animates moves the indicator too.

## Direction

**Page order follows the reading direction.** Under Arabic the first tab's page sits on the right
and the user swipes leftwards to advance, matching the `Tabs` header, which mirrors on its own.

## Tokens used

Header: everything `Tabs` uses. Page transition on tap: `slow` duration on the `easeOut` curve.

## Change log

- KAN-433 (Home fidelity) — passes `variant: DabblerTabsVariant.feed` through, and adds `tabsPadding`, passed to the header's `padding`.

## Source

`lib/src/layout/tab_pager.dart`
