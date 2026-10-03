<!--
Component page, D-033 ten-part template.

Group    : Identity and status
Sources  : lib/src/media/provider_mark.dart (class dartdoc, incl. deviations)
           lib/src/media/provider_mark_gallery.dart (specimen title:
           "ProviderMark — vendor sign-in marks")
           design: Auth and Onboarding.dc.html:123-125, 164-166, 195-197 (the
           Google and Apple buttons; plain outlined buttons with no vendor art)
           vendor artwork: see "Source of the artwork" below
-->

# ProviderMark
### `DabblerProviderMark`

ProviderMark is a sign-in vendor's own mark — Google's "G" or the Apple logo — drawn exactly as the vendor published it.

It is the icon for a "Continue with Google" or "Continue with Apple" row. It picks the light or dark tile from the theme, keeps the artwork untouched, and is announced as "Google" or "Apple".

## Specimen

Each vendor at its native size and scaled down, and the mark inside a labelled row with its own semantics excluded — see `provider_mark_gallery.dart`. Switch the gallery theme to see the dark tiles.

@specimen provider-mark

## Using it

**Put it inside a button that says what the action is.** Google's guidelines do not allow the icon by itself, without a button boundary and text naming the action. Pair it with "Continue with Google" or "Continue with Apple" copy.

**Exclude its semantics when the button already names the provider.** Pass `excludeFromSemantics` so a screen reader does not say "Google, Continue with Google".

**Do not recolour, crop, round, tint or stretch it.** The tile is the vendor's artwork. `size` scales the square; nothing else about it is a parameter. The Google tile sits on its own light or dark fill and the Apple tile is black or white, so neither is placed on a coloured chip.

**Do not mirror it.** The artwork is symmetric and the vendors give no mirrored version; under Arabic it stays as it is.

## Axes

### Vendor
`google` (`DabblerProviderMark.google`) or `apple` (`DabblerProviderMark.apple`).

### Brightness
Chosen from the theme, never passed in. Google: the light tile on a light theme, the dark tile on a dark one. Apple: the black tile on a light theme, the white tile on a dark one.

### Size
The tile's native logical size by default — 40 for Google, 44 for Apple — or any square `size`.

@figure 40 lib/src/media/provider_mark.dart#DabblerProviderMark
@figure 44 lib/src/media/provider_mark.dart#DabblerProviderMark

## Tokens used

The theme's brightness (`DabblerColors.brightness`) and nothing else. No colour, spacing, radius or type token is read; the tile's 40 and 44 are the vendors' native sizes, not design-system tokens.

### Exception

These marks carry the vendors' own colours: Google's four-colour "G", and the tile fill and stroke in both tiles, are vendor artwork. They are not Dabbler colour tokens and must not be turned into them. Any hex or colour gate that scans the app's assets or source must **allow-list `assets/provider_marks/`** (the PNGs hold no source literals, but a pixel or asset audit will find the vendor colours). The component itself uses no colour literal; the only token it reads is the theme's brightness.


### Deviations

**PNG tiles, not the vendors' SVG.** The SVG sources could not be bundled. Google's SVG is a Figma export built on `foreignObject`, a CSS `conic-gradient` and blur filters, which Flutter does not render; Apple's SVG has an embedded white rectangle. The official PNG tiles are used instead, at four (Google) and three (Apple) densities.

**Apple's "monochrome following the text colour" is a black or white tile chosen by brightness.** The mark is not tinted by a text colour; it picks the black tile on light and the white tile on dark.


## Change log

- Alpha — new component.

## Source

`lib/src/media/provider_mark.dart`

### Source of the artwork

Downloaded 2026-10-04 from the vendors' own pages and bundled unmodified under `assets/provider_marks/` as resolution-aware assets (1x at the root, then `2.0x/`, `3.0x/`, `4.0x/`).

- **Google** — the "Show text = No, Shape = Square" Android and Web sign-in icon tiles, 40 x 40 at 1x, in `signin-assets.zip` (`https://developers.google.com/static/identity/images/signin-assets.zip`), linked as "Download Pre-Approved Brand Icons" from `https://developers.google.com/identity/branding-guidelines`. Light and dark tiles at 1x to 4x.
- **Apple** — the "Logo Only" tiles, 44 x 44 at 1x, black and white, in `Logo-Sign-in-with-Apple.dmg` (`https://devimages-cdn.apple.com/design/resources/download/Logo-Sign-in-with-Apple.dmg`), linked from `https://developer.apple.com/design/resources/`. 1x to 3x only; the 4x slot is left to Flutter's nearest-density fallback. The licence that came with the download is bundled as `assets/provider_marks/APPLE_LICENSE.rtf`.

#### Brand-usage rules, as published

Checked against the Google page on 2026-10-04:

- "Regardless of the text, you can't change the size or color of the Google 'G' logo. It must be the standard color version (the standard color gradient super G logo)."
- Do "Use the Google brand color for Google icon for dark, light, and neutral modes"; do not "Use monochrome versions of the Google 'G' for the button".
- Do not "Put the standard color Google 'G' icon on a colored background other than light, dark, or neutral".
- Do not "Use the Google icon or logo by itself without the button boundary and without text to indicate the user action". Do "Use the Google 'G' by itself for action button if needed."
- Button fills published there: light fill #FFFFFF with a #747775 stroke, dark fill #131314 with a #8E918F stroke.
- Scaling: "you must preserve the aspect ratio so that the Google logo is not stretched."

Apple: the licence in the download (`APPLE_LICENSE.rtf`) grants use "subject to … compliance with Apple's Human Interface Guidelines", and its stated purpose is creating mock-ups of interfaces for Apple platforms. The Human Interface Guidelines page for Sign in with Apple (`https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple`) is rendered by script and could not be read when this page was written, so its minimum-size and clear-space figures are **not** quoted here. They have to be read from that page before release, and the mock-up wording of the licence checked against production use by whoever owns that decision.

