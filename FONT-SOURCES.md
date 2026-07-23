# Typography research and font sources

CARGO/19 CSS separates historical reference from the open-source implementation shipped by the framework. No font binary is included in the package.

## Historical reference

Richard Greenberg's discussion of the *Alien* opening title identifies the original face as Helvetica Black, revealed as widely spaced, disconnected segments. The framework uses that construction principle—weight, interruption, and tracking—without bundling or reproducing Helvetica artwork.

Reference:

- https://www.artofthetitle.com/title/alien/

A broader survey of the film's screens and signage shows that the production used a mixed practical typography environment rather than one universal “science-fiction” face:

- https://typesetinthefuture.com/2014/12/01/alien/

## Open-source stack used by CARGO/19 CSS

| Role | Family | Package use | Official source | License |
|---|---|---|---|---|
| Interface/body | Space Grotesk | Neutral grotesque text and controls | https://github.com/floriankarsten/space-grotesk | SIL Open Font License 1.1 |
| Display and labels | Rajdhani | Display construction, panel identifiers, compact controls, and navigation | https://github.com/google/fonts/tree/main/ofl/rajdhani | SIL Open Font License 1.1 |
| Telemetry/data | IBM Plex Mono | Code, terminal output, tables, and technical values | https://github.com/IBM/plex | SIL Open Font License 1.1 |

`dist/cargo19.css` requests those families from Google Fonts. `dist/cargo19-core.css` contains no `@import` and uses system fallbacks.

## Commercial Helvetica route

A product that needs a licensed Helvetica implementation should obtain the appropriate desktop or web license from an authorized foundry or distributor and host it according to that license. Keep licensed commercial files outside the CARGO/19 CSS package.

- https://www.monotype.com/fonts/helvetica-now
- https://www.monotype.com/fonts/library

## Self-hosting an open-source font

Download the family from its official project, retain the license and copyright notice, convert or subset only as the license permits, and define local `@font-face` rules in the consuming application. Do not add font files to this framework's redistributable archive.

## Licensing rule

Never copy font files from an operating-system or desktop application installation into a web project unless the applicable license explicitly permits web embedding and redistribution. The framework's MIT license does not grant rights to third-party fonts.
