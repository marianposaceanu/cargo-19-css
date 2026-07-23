# Component and behavior index

All public classes use the `c19-` prefix. The framework does not register custom elements. CSS provides the complete visual and layout layer; `dist/cargo19.js` is an optional enhancement for discrete interactions.

## Document root and themes

| Concern | API | Notes |
|---|---|---|
| Root | `.c19-root` | Apply to `<body>` for global typography, background, and text color. |
| Theme | `[data-c19-theme="paper|bridge|auto"]` | May be placed on the document root or a component subtree. |
| Theme utility | `.c19-theme-paper`, `.c19-theme-bridge` | Local class-based theme override. |
| Theme control | `[data-c19-theme-toggle]` | Optional JS toggles paper/bridge and persists the selection. |
| Skip link | `.c19-skip-link` | Becomes visible on keyboard focus. |

## Application structure

| Component | Primary classes | Notes |
|---|---|---|
| Page | `.c19-page` | Full-page grid that prevents intrinsic-width overflow. |
| App bar | `.c19-appbar`, `.c19-appbar__inner` | Sticky translucent application header. |
| Brand | `.c19-brand`, `__mark`, `__text` | Compact mark and name. Text collapses on narrow screens. |
| Navigation | `.c19-nav`, `__link`, `__index` | Numbered vertical navigation; use `aria-current="page"`. |
| Panel | `.c19-panel`, `__header`, `__body`, `__footer`, `__title` | Structured operational module. Add `.c19-panel--critical` for a critical header. |
| Card | `.c19-card`, `.c19-card--interactive` | General content surface with optional hover affordance. |
| Divider | `.c19-divider`, `.c19-rule-label` | Structural separator and indexed label. |

## Signs and icons

| Component | Primary classes | Notes |
|---|---|---|
| SVG icon | `.c19-icon` | Baseline SVG sizing. Sprite symbols determine whether geometry is filled or stroked. |
| Icon sizes | `.c19-icon-xs`, `-sm`, `-lg` | Compact size utilities. |
| Sign container | `.c19-symbol`, `.c19-symbol-sm|md|lg|xl` | Preserves the `19 × 18` sign ratio. The generated sign contains its own frame and palette. |
| Micro container | `.c19-symbol--micro` | Neutral framed surface for interface glyphs. |
| Legacy semantic modifiers | `.c19-symbol--red|gray|black|yellow|blue|green` | Retained for custom current-color SVGs; generated equipment signs carry fixed colors internally. |

The sprite contains 39 equipment signs and 20 micro interface glyphs. Use `aria-hidden="true"` for decorative icons. Put the accessible name on an icon-only button, or use `role="img"` and a label for a meaningful standalone sign.

## Actions and navigation controls

| Component | Primary classes | Notes |
|---|---|---|
| Button | `.c19-button` | Primary action. |
| Button variants | `--secondary`, `--ghost`, `--warning`, `--danger`, `--small` | Preserve hierarchy; use warning/danger only for matching semantics. |
| Icon button | `.c19-icon-button`, `--secondary`, `--ghost` | Requires an accessible name. |
| Tabs | `.c19-tabs`, `__list`, `__tab` | Use native `role="tablist"`, `role="tab"`, `role="tabpanel"`, `aria-controls`, and `aria-selected`. |
| Pagination | `.c19-pagination` | Use links or buttons and `aria-current="page"`. |
| Command bar | `.c19-commandbar`, `.c19-key` | Search/command treatment with optional key hints. |
| Accordion | `.c19-accordion`, `.c19-accordion__body` | Styles native `<details>` and `<summary>`. |
| Popover menu | `.c19-menu-trigger`, `.c19-menu`, `__label`, `__item`, `__meta`, `__separator` | Uses native `popover` and `popovertarget`; no JavaScript is required. Set a shared unique `--c19-menu-anchor` when a page has multiple anchored menus. |

## Forms

| Component | Primary classes | Notes |
|---|---|---|
| Field | `.c19-field`, `__label`, `__hint`, `__error` | Groups a label, native control, help text, and error text. |
| Inputs | `.c19-input`, `.c19-textarea`, `.c19-select` | Shared focus, disabled, invalid, and theme behavior. |
| Input group | `.c19-input-group`, `.c19-input-group__addon` | Joins inputs, selects, addons, and buttons while preserving native controls. |
| Choice | `.c19-choice` | Native checkbox/radio wrapper. |
| Switch | `.c19-switch`, `.c19-switch__track` | Visual switch around a native checkbox. Keep the input in the accessibility tree. |

## Feedback and status

| Component | Primary classes | Notes |
|---|---|---|
| Badge | `.c19-badge`, `--red`, `--yellow`, `--blue`, `--green` | Compact category or state text. |
| Status | `.c19-status`, `--ok`, `--warn`, `--danger`, `--cold` | Dot plus text; never relies on color alone. |
| Alert | `.c19-alert`, `__title`, `--info`, `--success`, `--warning`, `--danger` | Inline message with optional dismiss action. |
| Toast | `.c19-toast` | Compact transient message. Applications control live-region behavior and placement. |
| Tooltip | `[data-c19-tooltip]` | CSS-only supplemental text. Add `data-c19-tooltip-position="end"` near the right viewport edge. |
| Skeleton | `.c19-skeleton` | Loading placeholder that respects reduced motion. |
| Inline loading | `.c19-inline-loading`, `.c19-spinner`, `.c19-spinner--large` | Pair the visual spinner with status text; use `aria-busy` on the region or control being updated. |
| Dialog | `.c19-dialog`, `__header`, `__body`, `__footer` | Styling for native `<dialog>`. |

## Component custom properties

Global tokens remain the default customization surface. These focused variables let an application tune one component family without replacing framework selectors.

| Family | Custom properties |
|---|---|
| Panel | `--c19-panel-bg`, `-border`, `-radius`, `-shadow`, `-padding`, `-header-bg`, `-footer-bg`, `-divider`, `-header-padding`, `-footer-padding` |
| Card | `--c19-card-bg`, `-border`, `-radius`, `-shadow`, `-padding` |
| Button | `--c19-button-bg`, `-ink`, `-border`, `-radius`, `-height`, `-padding` |
| Form control | `--c19-control-bg`, `-ink`, `-border`, `-radius`, `-padding`, `-addon-bg`, `-addon-ink` |
| Popover menu | `--c19-menu-anchor`, `-bg`, `-ink`, `-border`, `-radius`, `-padding`, `-shadow` |
| Dialog | `--c19-dialog-bg`, `-ink`, `-border`, `-radius` |
| Loading | `--c19-loading-ink`, `--c19-spinner-size`, `--c19-spinner-width` |

Set variables on the component, a themed subtree, or an application shell. Every variable falls back to an existing global token.

## Data display

| Component | Primary classes | Notes |
|---|---|---|
| Table | `.c19-table-wrap`, `.c19-table` | Wrapper provides bounded horizontal scrolling on narrow screens. |
| Progress | `.c19-progress`, `.c19-progress__bar` | Set `--c19-value` from `0` to `100`; keep a programmatic value in markup. |
| Segmented meter | `.c19-segmented-meter` | Mark active child segments with `[data-active]`. |
| Statistic | `.c19-stat`, `__label`, `__value` | Compact telemetry value. |
| Terminal | `.c19-terminal`, `.c19-terminal__prompt` | Monospaced operational readout. |
| System console | `.c19-system-console`, `__head`, `__body` | Larger framed console used by the manual and examples. |

## Motion

| Pattern | Primary classes | Notes |
|---|---|---|
| Title reveal | `.c19-title-reveal` | Original horizontally resolving letter cue. |
| Signal acquisition | `.c19-signal-acquire` | One-shot, mirrored title resolution with a final signal line. Combine with `.c19-title-reveal`; reduced-motion users receive the final static state. |

## Layout primitives

| Primitive | Class | Configuration |
|---|---|---|
| Container | `.c19-container`, `--narrow`, `--wide` | `--c19-content`, `--c19-gutter` |
| Vertical stack | `.c19-stack` | `--c19-stack-gap` or gap utilities |
| Wrapping cluster | `.c19-cluster` | `--c19-cluster-gap`, alignment, and justification variables |
| Explicit grid | `.c19-grid` | `--c19-grid-cols`, `--c19-grid-gap` |
| Responsive grid | `.c19-auto-grid` | `--c19-grid-min`, `--c19-grid-gap`; convenience classes use `c19-grid-min-*` |
| Split | `.c19-split` | Two-sided wrapping layout. |
| Sidebar | `.c19-with-sidebar` | `--c19-sidebar` |
| Sticky region | `.c19-sticky` | `--c19-sticky-top` |
| Scroll row | `.c19-scroll-row` | Bounded horizontal strip. |

## Documentation shell

The manual is intentionally built from framework classes rather than a separate documentation stylesheet.

| Region | Primary classes |
|---|---|
| Shell | `.c19-doc-layout`, `.c19-doc-rail`, `.c19-doc-main`, `.c19-doc-mobile-nav` |
| Hero | `.c19-doc-hero`, `--compact`, `--landing`, `__grid`, `__title`, `.c19-doc-meta` |
| Section | `.c19-doc-section`, `__head`, `__index` |
| Code specimen | `.c19-doc-code-wrap`, `.c19-doc-codebar`, `.c19-doc-code` |
| Live specimen | `.c19-doc-specimen`, `--light` |
| Icon catalog | `.c19-doc-filter`, `.c19-doc-icon-grid`, `.c19-doc-icon-card`, `--micro` |
| Token display | `.c19-palette`, `.c19-doc-swatch`, `.c19-metric-strip` |
| Callout | `.c19-doc-callout`, `--success`, `--warning`, `--danger` |
| Footer | `.c19-doc-footer`, `__inner` |

Generated pages contain no page-local `<style>` block. Their only stylesheet is `dist/cargo19.css`.

## Optional JavaScript data attributes

| Attribute | Behavior |
|---|---|
| `data-c19-tabs` | Scopes an ARIA tab set. Initializes the selected tab and panels. |
| `data-c19-dismissible` | Marks the container removed by a descendant dismiss control. |
| `data-c19-dismiss` | Removes the nearest dismissible container. |
| `data-c19-dialog-open="id"` | Opens the native dialog with the matching ID. |
| `data-c19-dialog-close` | Closes the nearest native dialog. |
| `data-c19-theme-toggle` | Toggles paper/bridge theme and persists state when storage is available. |
| `data-c19-theme-label` | Receives the current theme label inside a toggle. |
| `data-c19-nav-toggle` | Opens or closes the responsive documentation navigation. |
| `data-c19-mobile-nav` | Identifies the responsive navigation panel. |
| `data-c19-copy="selector"` | Copies text from the selected code target. |
| `data-c19-copy-label` | Receives temporary copied/failure feedback. |
| `data-c19-icon-filter` | Filters all icon cards as the user types. |
| `data-c19-icon-card` | Marks a filterable icon entry. |
| `data-c19-search` | Supplies searchable icon metadata. |
| `data-c19-icon-count` | Receives the visible/total result count. |
| `data-c19-icon-empty` | Empty state shown when no icon matches. |

## Utility groups

The utility layer includes controlled spacing (`c19-gap-*`, `c19-mt-*`, `c19-mb-*`, `c19-p-*`, `c19-py-*`), text (`c19-mono`, `c19-caption`, `c19-label-text`, `c19-text-*`), surfaces and borders, alignment, overflow, radius, shadow, screen-reader-only, no-print, and motion helpers. Prefer component and layout classes first; use utilities for small local adjustments.
