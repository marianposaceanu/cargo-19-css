# Changelog

## 1.3.0 — 2026-07-23

### Consolidation

- Restored the 1.0 typography, theme palette, rounded surface geometry, and full component-showcase landing page.
- Retained the 1.2 generated 59-glyph sign system, expanded components, responsive manual, examples, JavaScript behaviors, and release validation.
- Preserved the stronger fixed equipment-sign palette introduced after 1.0 while returning interface colors to the original visual direction.
- Kept the landing page deliberately curated while continuing to generate the manual and examples from framework classes.

### Components and motion

- Added native popover menus, compound input groups, inline loading states, and spinner sizes.
- Added focused component custom properties for panels, cards, buttons, form controls, menus, dialogs, and loading indicators.
- Added a one-shot, mirrored signal-acquisition title cue with a static reduced-motion state.
- Expanded the manual with live component examples, a component-variable reference, richer typography specimens, and corrected light-specimen token contrast.
- Embedded the complete icon sprite in generated manual and example pages so Safari can render every glyph when the package is opened directly from disk.
- Replaced atmospheric gradients with flat surfaces, hard signal bands, and solid loading motion.
- Tightened the landing-page palette rail and bounded the vacuum-black swatch so every specified color remains visible.

## 1.2.0 — 2026-07-21

### Visual system

- Rebuilt the sign palette from one fixed seven-color specification and separated it from accessible interface-status colors.
- Tightened spacing, container behavior, app-bar geometry, panel density, form controls, tooltips, and responsive type sizing.
- Corrected the title reveal so the lockup remains legible throughout animation and resolves predictably.
- Removed hidden horizontal overflow at narrow documentation widths.

### Icons

- Replaced the mixed icon drawings with a generated construction pipeline.
- Standardized all glyphs on `viewBox="0 0 19 18"`.
- Rebuilt 39 framed equipment signs around one outer field and equipment plate.
- Added 20 consistent interface glyphs.
- Added individual light and dark exports, richer catalog metadata, categories, search terms, and fixed counts.

### Documentation

- Rebuilt the landing page, manual, component reference, icon catalog, typography guide, token guide, accessibility notes, attribution, changelog, and examples using CARGO/19 classes only.
- Added one responsive documentation shell with numbered desktop navigation and a mobile disclosure menu.
- Added live component specimens, icon filtering, copy controls, theme persistence, and responsive examples.
- Removed page-local style blocks from all generated documentation.

### Tooling and packaging

- Added generated metadata and release checksums.
- Added structural validation for HTML, SVG, CSS, JavaScript, local links, icon counts, and prohibited font binaries.
- Added a one-command release pipeline.

## 1.0.0 — 2026-07-21

- Initial release.
- Two visual themes, eight cascade layers, and a documented token system.
- Core UI components, data displays, terminal treatment, optional behavior helpers, and an initial SVG catalog.
