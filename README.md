# SimonGustavsson.github.io

## `tailwind.css`

The site used to pull Tailwind from `cdn.tailwindcss.com` at runtime (the "Play CDN"),
which Tailwind explicitly says isn't for production and depends on an external CDN
staying up forever. `tailwind.css` replaces that: a static, pre-built stylesheet
checked into the repo, so the site has zero runtime dependency on Tailwind, npm, or
any CDN. Every page just does:

```html
<link rel="stylesheet" href="tailwind.css" />
```

### How it was generated

Built with the standalone Tailwind CLI (v3.4.19) — no Node/npm install required,
just a single downloaded binary:

```bash
curl -sL -o tailwindcss \
  https://github.com/tailwindlabs/tailwindcss/releases/download/v3.4.19/tailwindcss-macos-arm64
chmod +x tailwindcss

./tailwindcss -i input.css -o tailwind.css --minify
```

Grab the right binary for your OS/arch from the
[releases page](https://github.com/tailwindlabs/tailwindcss/releases) if you ever
need to redo this on a different machine.

`input.css`:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

`tailwind.config.js` (this is the same `theme.extend` block that used to be inlined
as a `<script>` in every page):

```js
module.exports = {
  content: ["*.html"],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        "surface-container-lowest": "#ffffff",
        "on-secondary-container": "#54198a",
        "secondary-container": "#c58cff",
        "on-error": "#ffffff",
        "tertiary-fixed": "#e2e2e2",
        "tertiary-container": "#454747",
        "on-surface-variant": "#454557",
        "on-primary-container": "#a9aeff",
        "surface-dim": "#dcd9d9",
        "tertiary": "#2f3131",
        "tertiary-fixed-dim": "#c6c6c7",
        "on-background": "#1c1b1b",
        "secondary-fixed": "#f0dbff",
        "on-secondary": "#ffffff",
        "on-tertiary-fixed": "#1a1c1c",
        "secondary-fixed-dim": "#ddb8ff",
        "on-surface": "#1c1b1b",
        "on-error-container": "#93000a",
        "outline-variant": "#c5c4da",
        "primary-container": "#0000ee",
        "primary": "#0001ab",
        "inverse-surface": "#313030",
        "inverse-primary": "#bfc2ff",
        "surface-container-highest": "#e5e2e1",
        "surface-container-low": "#f6f3f2",
        "on-tertiary": "#ffffff",
        "surface": "#fcf9f8",
        "surface-variant": "#e5e2e1",
        "surface-container": "#f0eded",
        "on-secondary-fixed": "#2c0051",
        "surface-tint": "#343dff",
        "error-container": "#ffdad6",
        "on-primary": "#ffffff",
        "on-tertiary-fixed-variant": "#454747",
        "secondary": "#7a43b0",
        "error": "#ba1a1a",
        "inverse-on-surface": "#f3f0ef",
        "surface-container-high": "#eae7e7",
        "background": "#fcf9f8",
        "on-tertiary-container": "#b4b5b5",
        "on-primary-fixed-variant": "#0102ee",
        "primary-fixed": "#e0e0ff",
        "surface-bright": "#fcf9f8",
        "on-secondary-fixed-variant": "#602896",
        "outline": "#757589",
        "primary-fixed-dim": "#bfc2ff",
        "on-primary-fixed": "#00006e"
      },
      borderRadius: {
        DEFAULT: "0.125rem",
        lg: "0.25rem",
        xl: "0.5rem",
        full: "0.75rem"
      },
      spacing: {
        "stack-md": "2.5rem",
        "margin-auto": "auto",
        "stack-lg": "5rem",
        "stack-sm": "1rem",
        "max-width": "720px"
      },
      fontFamily: {
        "headline-lg": ["\"Source Serif 4\""],
        "headline-md": ["\"Source Serif 4\""],
        "body-md": ["\"Source Serif 4\""],
        "body-lg": ["\"Source Serif 4\""],
        "label-sm": ["\"Source Sans 3\""]
      },
      fontSize: {
        "headline-lg": ["36px", { lineHeight: "1.3", fontWeight: "700" }],
        "headline-md": ["28px", { lineHeight: "1.3", fontWeight: "600" }],
        "body-md": ["18px", { lineHeight: "1.7", fontWeight: "400" }],
        "body-lg": ["20px", { lineHeight: "1.7", fontWeight: "400" }],
        "label-sm": ["14px", { lineHeight: "1", letterSpacing: "0.05em", fontWeight: "400" }]
      }
    }
  }
}
```

The `forms` and `container-queries` plugins the old CDN URL loaded were never
actually used anywhere on the site (no `<form>` elements, no `@container` classes),
so they were dropped rather than ported over.

### If you add new Tailwind classes to the HTML later

`tailwind.css` only contains the utility classes that existed in the HTML at build
time. If you add a class to a page that isn't already in `tailwind.css`, it won't be
styled until you regenerate the file using the config and commands above.

## `fonts.css` / `fonts/`

Same reasoning as `tailwind.css`: the site used to load Source Sans 3 and Source
Serif 4 from `fonts.googleapis.com`/`fonts.gstatic.com` at request time. That's now
a local `fonts.css` with `@font-face` rules pointing at three `.woff2` files in
`fonts/`, so there's no external font CDN dependency either.

It also dropped the Material Symbols Outlined icon font entirely — every page was
loading it, but grepping the actual HTML across the whole site turned up zero
elements using the `.material-symbols-outlined` class. It was dead weight from the
page-generation tool, never actually used.

### How it was generated

Fetched the real `@font-face` CSS Google serves for the exact families/weights the
site's Tailwind config uses (`Source Sans 3` 400/600, `Source Serif 4` 400/600/700
plus italic 400 — that last one only needed because of the `.italic` paragraphs),
using a desktop-Chrome user agent so Google returns woff2 (not woff/ttf):

```bash
curl -s -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
  "https://fonts.googleapis.com/css2?family=Source+Sans+3:wght@400;600&family=Source+Serif+4:ital,opsz,wght@0,8..60,400;0,8..60,600;0,8..60,700;1,8..60,400&display=swap" \
  -o google-fonts-response.css
```

That response has a separate `@font-face` block per **subset** (cyrillic, greek,
vietnamese, latin-ext, latin, ...) for every weight/style. The site's text content
is plain English (checked by scanning every `.html` file for non-ASCII characters —
only `©`, curly quotes, em dash, ellipsis, and `™` show up, all covered by the
`latin` subset), so only the `/* latin */` blocks were kept; the rest were discarded.

Both families are variable fonts, so Google serves **one woff2 file per style**
covering the whole weight range — the 400/600/700 `@font-face` blocks for Source
Serif 4 all point at the same file, just with different `font-weight` descriptors.
That meant only 3 files needed downloading, not 6:

```bash
curl -sL -o fonts/source-sans-3-normal.woff2   "<latin woff2 url from the Source Sans 3 400 block>"
curl -sL -o fonts/source-serif-4-normal.woff2  "<latin woff2 url from the Source Serif 4 400 normal block>"
curl -sL -o fonts/source-serif-4-italic.woff2  "<latin woff2 url from the Source Serif 4 400 italic block>"
```

The actual URLs are versioned (e.g. `.../sourcesans3/v19/...`) and will eventually
rotate as Google updates the fonts, so re-fetch the CSS above to get current ones
rather than reusing old gstatic URLs. `fonts.css` then just repoints each `src:
url(...)` at the local `fonts/*.woff2` path instead of gstatic, keeping the same
`unicode-range` Google used for its `latin` subset.
