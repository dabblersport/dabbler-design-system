<!--
Foundations page, D-034 template.

Sources : lib/src/foundations/vibes.dart
          lib/src/foundations/vibes_gallery.dart (specimen "Vibes - every vibe")
          Claude Design file "Post.dc.html", the VIBES array, complete (119
          entries). "Home Feed.dc.html" was fetched through DesignSync and is
          truncated at the tool's 256 KiB cap inside the same array after the
          68th entry; those 68 match Post's first 68. What follows in that file
          is unread.
-->

# Vibes
### `DabblerVibe`

A vibe is the mood a person attaches to a post, drawn as a pill with a tinted fill and a name.

There are 119 of them, each with a label, a mood, a type, the places it is offered and one accent taken from the colour palette. The design draws an emoji beside every vibe; this system ships none, so a vibe is a label and a tone.

## Specimen

Every vibe unselected, then every vibe selected, on the card surface of the current theme and brightness - see `vibes_gallery.dart`.

@specimen vibes/all

## Using it

**Resolve a vibe through `resolve(colors)`.** It returns the accent, the label ink, and the unselected and selected fill and border, all built from the theme's card surface and text colour.

**Use the label ink for the name, never the accent.** The design sets every vibe name in the ordinary ink; the accent is only the tint behind it and the border.

**Localise by key.** The `label` is the design's English name, kept as source text. The package carries no translations, so a screen looks its string up by `key`.

**Filter by context.** `DabblerVibe.forContext` returns the vibes the design offers in `kickin`, `dab` or `moment`; the Post screen uses `dab`.

**Never draw an emoji.** The design pairs one with each vibe; this system does not carry them, and the design names no per-vibe glyph.

**Where it departs from the design.**

- Each design hex is replaced by the nearest palette step, so the tint is close to, not identical with, the design. The worst case is Get Moving, 16.6 on the CIEDE2000 scale.
- The design mixes the hex with the card surface at 16%, 34%, 32% and 75%; the same blends are used, over the card surface of the active brightness.
- Dark mode has no design values of its own. The accent is unchanged and the fills follow the provisional dark card surface.

**Unread in the design.** Home Feed's VIBES entries after the 68th, its vibe context, its filter and its selected-vibe logic were cut off by the 256 KiB read limit. The Post screen's 119 entries are complete and are the source here.

### Tone mapping

Distances are CIEDE2000 between the design hex and the chosen palette step, and the Euclidean RGB distance. Candidates were every palette step except the page, card and outline surfaces.

| Vibe | Design hex | Chosen token | Token hex | ΔE2000 | RGB distance |
|---|---|---|---|---|---|
| Supportive | `#6AC47E` | `sportS600` | `#6CBD6A` | 3.7 | 21.3 |
| Caring | `#F7A6C5` | `activeP300` | `#E592BE` | 6.0 | 27.8 |
| Loving | `#E94F4F` | `activeError` | `#E5484D` | 1.9 | 8.3 |
| Inspired | `#FFD166` | `tileAmberSurface` | `#FFD60A` | 7.7 | 92.1 |
| Proud | `#F4A261` | `brightP600` | `#F6AA4F` | 6.3 | 19.8 |
| Hopeful | `#FFB703` | `warning500` | `#F59E0B` | 7.9 | 28.1 |
| Nostalgic | `#A8A8FF` | `socialP300` | `#8FB2E9` | 8.1 | 34.8 |
| Positive | `#57CC99` | `sportS400` | `#92CE91` | 8.3 | 59.6 |
| Loved | `#F28482` | `activeError` | `#E5484D` | 13.3 | 81.1 |
| Supported | `#80ED99` | `sportS400` | `#92CE91` | 8.4 | 36.7 |
| Amazed | `#FFD166` | `tileAmberSurface` | `#FFD60A` | 7.7 | 92.1 |
| Happy | `#FFE066` | `tileAmberSurface` | `#FFD60A` | 6.0 | 92.5 |
| Calm | `#4EA8DE` | `socialS600` | `#65A8FF` | 7.5 | 40.2 |
| Relaxed | `#A2D2FF` | `socialS400` | `#8DBFFF` | 5.3 | 28.3 |
| Thankful | `#FFE45C` | `tileAmberSurface` | `#FFD60A` | 5.7 | 83.2 |
| Surprised | `#F3722C` | `spotlight500` | `#FF5A1F` | 5.8 | 29.8 |
| Energetic | `#F94144` | `error500` | `#EF4444` | 1.7 | 10.4 |
| Determined | `#F3722C` | `spotlight500` | `#FF5A1F` | 5.8 | 29.8 |
| Motivated | `#E76F51` | `spotlight500` | `#FF5A1F` | 7.7 | 59.3 |
| Focused | `#118AB2` | `socialS700` | `#4F83C7` | 11.8 | 65.8 |
| Excited | `#FB8500` | `warning500` | `#F59E0B` | 9.3 | 28.0 |
| Empowered | `#FF7E67` | `spotlight500` | `#FF5A1F` | 10.9 | 80.5 |
| Heroic | `#E63946` | `activeError` | `#E5484D` | 2.2 | 16.6 |
| Brave | `#F77F00` | `warning500` | `#F59E0B` | 10.8 | 33.0 |
| Recognized | `#FFD700` | `tileAmberSurface` | `#FFD60A` | 0.4 | 10.0 |
| Kind | `#FFB5A7` | `error100` | `#FEE2E2` | 14.2 | 74.2 |
| Sympathetic | `#A2D2FF` | `socialS400` | `#8DBFFF` | 5.3 | 28.3 |
| Together | `#70E000` | `success500` | `#22C55E` | 13.4 | 125.1 |
| Free | `#ADE8F4` | `tagProgressSurface` | `#DBEAFB` | 12.9 | 46.6 |
| Reflective | `#9D4EDD` | `mainP400` | `#9760DB` | 4.2 | 19.1 |
| Grateful | `#FFD166` | `tileAmberSurface` | `#FFD60A` | 7.7 | 92.1 |
| Longing | `#C0A9BD` | `ink300` | `#C2BFCB` | 9.6 | 26.2 |
| Broken | `#8D99AE` | `ink400` | `#9C98A8` | 7.3 | 16.2 |
| Unique | `#FFAFCC` | `activeP300` | `#E592BE` | 8.1 | 41.4 |
| Heard | `#84A59D` | `sportP300` | `#8FBC92` | 12.6 | 27.8 |
| Grounded | `#588157` | `sportS700` | `#549353` | 7.5 | 18.9 |
| Awake | `#F9C74F` | `tileAmberSurface` | `#FFD60A` | 7.2 | 70.9 |
| Jittery | `#F8961E` | `warning500` | `#F59E0B` | 4.3 | 20.8 |
| Exploring | `#06D6A0` | `success500` | `#22C55E` | 11.1 | 73.7 |
| Orbiting | `#577590` | `socialP600` | `#3473D7` | 8.4 | 79.2 |
| Aligned | `#90BE6D` | `sportS600` | `#6CBD6A` | 5.6 | 36.1 |
| Stellar | `#FFD166` | `tileAmberSurface` | `#FFD60A` | 7.7 | 92.1 |
| Celestial | `#6D597A` | `ink600` | `#595663` | 10.5 | 30.6 |
| Solar | `#FFB703` | `warning500` | `#F59E0B` | 7.9 | 28.1 |
| Lunar | `#CDB4DB` | `ink300` | `#C2BFCB` | 11.9 | 22.3 |
| Unearthly | `#8338EC` | `tagSubmittedInk` | `#6A32D6` | 5.3 | 33.8 |
| Blessed | `#F9C74F` | `tileAmberSurface` | `#FFD60A` | 7.2 | 70.9 |
| Fortunate | `#90EE90` | `sportS400` | `#92CE91` | 8.7 | 32.1 |
| Wishing | `#A29BFE` | `mainP300` | `#B289E4` | 8.7 | 35.4 |
| Manifesting | `#FF9F1C` | `warning500` | `#F59E0B` | 2.7 | 19.7 |
| Resplendent | `#7209B7` | `mainP700` | `#5A1FA1` | 4.6 | 39.3 |
| Misty-eyed | `#CDB4DB` | `ink300` | `#C2BFCB` | 11.9 | 22.3 |
| Still | `#BDE0FE` | `info100` | `#DBEAFE` | 6.4 | 31.6 |
| Muted | `#DEE2E6` | `tagExpiredSurface` | `#EDEDEF` | 3.2 | 20.7 |
| Wilting | `#9D8189` | `ink400` | `#9C98A8` | 11.5 | 38.6 |
| Fading | `#A5A58D` | `sportP300` | `#8FBC92` | 14.1 | 32.2 |
| Restless | `#FF8C42` | `brightP600` | `#F6AA4F` | 11.5 | 33.9 |
| Regretful | `#8E9AAF` | `ink400` | `#9C98A8` | 7.3 | 15.8 |
| Rusty | `#B08968` | `brightP700` | `#C0853E` | 9.0 | 45.1 |
| Layered | `#CDB4DB` | `ink300` | `#C2BFCB` | 11.9 | 22.3 |
| Creative | `#FF70A6` | `activeP400` | `#DB6CA8` | 7.5 | 36.3 |
| Innovative | `#118AB2` | `socialS700` | `#4F83C7` | 11.8 | 65.8 |
| Game On | `#F94144` | `error500` | `#EF4444` | 1.7 | 10.4 |
| Last Call | `#FF7B00` | `spotlight500` | `#FF5A1F` | 11.1 | 45.3 |
| Kickoff Ready | `#43AA8B` | `sportP400` | `#69A56C` | 9.9 | 49.3 |
| Almost Full | `#F9C74F` | `tileAmberSurface` | `#FFD60A` | 7.2 | 70.9 |
| Join Fast | `#E76F51` | `spotlight500` | `#FF5A1F` | 7.7 | 59.3 |
| Final Whistle | `#F8961E` | `warning500` | `#F59E0B` | 4.3 | 20.8 |
| Warming Up | `#F3722C` | `spotlight500` | `#FF5A1F` | 5.8 | 29.8 |
| Get Moving | `#00B4D8` | `socialS400` | `#8DBFFF` | 16.6 | 146.7 |
| Let's Rally | `#90BE6D` | `sportS600` | `#6CBD6A` | 5.6 | 36.1 |
| Squad Assemble | `#7209B7` | `mainP700` | `#5A1FA1` | 4.6 | 39.3 |
| Game Time | `#FFD166` | `tileAmberSurface` | `#FFD60A` | 7.7 | 92.1 |
| Open Slot | `#4CC9F0` | `socialS400` | `#8DBFFF` | 13.8 | 67.5 |
| Late Entry | `#F8961E` | `warning500` | `#F59E0B` | 4.3 | 20.8 |
| Countdown | `#FB5607` | `spotlight500` | `#FF5A1F` | 2.3 | 24.7 |
| Hustle Up | `#E63946` | `activeError` | `#E5484D` | 2.2 | 16.6 |
| Let's Go | `#FF006E` | `activeS600` | `#EB005A` | 5.3 | 28.3 |
| All In | `#3A86FF` | `info500` | `#3B82F6` | 1.6 | 9.9 |
| Bring It On | `#F72585` | `activeS400` | `#F04285` | 2.6 | 29.8 |
| Underway | `#FFB703` | `warning500` | `#F59E0B` | 7.9 | 28.1 |
| Locking In | `#577590` | `socialP600` | `#3473D7` | 8.4 | 79.2 |
| Drained | `#9CA3AF` | `ink400` | `#9C98A8` | 6.8 | 13.0 |
| Heavy | `#4B5563` | `tagExpiredInk` | `#5A5A62` | 5.5 | 15.8 |
| Off Day | `#94A3B8` | `ink400` | `#9C98A8` | 8.9 | 21.0 |
| Under Pressure | `#F59E0B` | `warning500` | `#F59E0B` | 0.0 | 0.0 |
| Tense | `#E56B6F` | `activeError` | `#E5484D` | 7.8 | 48.8 |
| Shaky | `#CBD5F5` | `info100` | `#DBEAFE` | 7.0 | 27.9 |
| Disconnected | `#6C757D` | `ink500` | `#787484` | 8.9 | 13.9 |
| Left Out | `#A27B9D` | `activeP400` | `#DB6CA8` | 12.3 | 60.0 |
| Lonely | `#5C677D` | `tagExpiredInk` | `#5A5A62` | 8.1 | 30.0 |
| Disappointed | `#9E768F` | `activeP400` | `#DB6CA8` | 13.1 | 66.7 |
| Uncertain | `#B5C3D9` | `ink300` | `#C2BFCB` | 7.7 | 19.5 |
| Sluggish | `#C9ADA7` | `ink300` | `#C2BFCB` | 12.2 | 40.9 |
| Flat | `#B0BEC5` | `ink300` | `#C2BFCB` | 9.3 | 19.0 |
| Numb | `#7F8C99` | `ink400` | `#9C98A8` | 10.4 | 34.8 |
| Overthinking | `#C77DFF` | `mainP300` | `#B289E4` | 6.1 | 36.2 |
| Benched | `#8D99AE` | `ink400` | `#9C98A8` | 7.3 | 16.2 |
| Slipping | `#F77F81` | `activeError` | `#E5484D` | 12.7 | 77.8 |
| Burned Out | `#CC7A7A` | `activeError` | `#E5484D` | 11.9 | 71.8 |
| Frustrated | `#EF4444` | `error500` | `#EF4444` | 0.0 | 0.0 |
| Annoyed | `#E07A5F` | `spotlight500` | `#FF5A1F` | 10.1 | 78.0 |
| Angry | `#D7263D` | `tagFailedInk` | `#C0292F` | 5.3 | 27.1 |
| Irritated | `#F4A259` | `brightP600` | `#F6AA4F` | 4.7 | 13.0 |
| Salty | `#F9844A` | `spotlight500` | `#FF5A1F` | 8.6 | 60.4 |
| Rattled | `#F97316` | `spotlight500` | `#FF5A1F` | 7.8 | 27.2 |
| On Edge | `#F59E0B` | `warning500` | `#F59E0B` | 0.0 | 0.0 |
| Heated | `#E63946` | `activeError` | `#E5484D` | 2.2 | 16.6 |
| Clashing | `#9D4EDD` | `mainP400` | `#9760DB` | 4.2 | 19.1 |
| Snappy | `#FB5607` | `spotlight500` | `#FF5A1F` | 2.3 | 24.7 |
| Boiling Over | `#D00000` | `tagFailedInk` | `#C0292F` | 8.2 | 64.4 |
| Resentful | `#6B7280` | `ink500` | `#787484` | 6.2 | 13.7 |
| Tilted | `#C1121F` | `tagFailedInk` | `#C0292F` | 3.1 | 28.0 |
| Short-Fused | `#F97373` | `activeError` | `#E5484D` | 10.2 | 60.8 |
| Fed Up | `#8D99AE` | `ink400` | `#9C98A8` | 7.3 | 16.2 |
| Overloaded | `#BC6C25` | `tagPendingInk` | `#B4530E` | 8.2 | 34.9 |
| Stressed | `#F2A2A2` | `activeP300` | `#E592BE` | 13.9 | 34.8 |
| Boomerang Thoughts | `#9A8C98` | `ink400` | `#9C98A8` | 5.6 | 20.1 |
| Neutral | `#000000` | `ink` | `#141414` | 3.7 | 34.6 |

## Axes

### Mood
Positive, negative or neutral - `82`, `36` and `1` vibes.

### Type
Action (`43`) or feeling (`76`) - the design's `type` field.

### Context
`kickin`, `dab`, `moment`; a vibe can be offered in several.

## Direction

Vibes carry no direction of their own; a pill's padding is symmetric and its label follows the reading direction.

## Change log

- Added for the Home Feed and Post vibe picker (KAN-411).

## Source

`lib/src/foundations/vibes.dart`
