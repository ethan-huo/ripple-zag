# AGENTS.md - Guidelines for AI Coding Agents

This repository maintains `zag-ripple`, a Ripple/TSRX adapter for Zag JS state
machines, plus a demo site that exercises the adapter across many Zag
components.

## Project Layout

- `packages/zag-ripple/` - The library package published through GitHub release
  snapshot tags.
- `packages/zag-ripple/src/` - Runtime adapter code (`useMachine`,
  `normalizeProps`, mount helpers, and small utilities).
- `packages/zag-ripple/tests/` - Vitest + TSRX regression tests for the adapter.
- `site/` - Vite demo site built with Ripple/TSRX and Zag component demos.
- `site/src/components/demos/` - One demo per Zag component.
- `site/icons.json` - Sigil manifest declaring the icon libraries and icons used
  by the demo site.
- `site/src/lib/lucide-icons.tsrx` - Generated TSRX icon wrapper produced by
  `sigil etch` from `site/icons.json`. Do not hand-edit; update the manifest and
  regenerate.

## Commands

Use Bun as the workspace package manager.

```bash
# Install dependencies
bun install

# Build the library package
bun --filter zag-ripple build

# Test the library package
bun --filter zag-ripple test -- --run

# Build the demo site
bun --filter ./site build

# Generate site icons from the sigil manifest
bun --filter ./site icons:generate
```

## Browser Verification

When a task needs browser-based verification, first refresh the source-of-truth
API surface with:

```bash
ctx read https://bun.com/docs/runtime/webview 2>&1
```

Prefer `Bun.WebView` for lightweight local smoke tests of the demo site before
reaching for Playwright or opening many user-visible browser tabs. Use an
ephemeral view and, when Chrome-specific behavior matters, force a fresh
headless Chrome backend with `backend: { type: "chrome", url: false }` so the
test does not attach to the user's existing Chrome session. Capture page
console errors and use `evaluate()` for DOM assertions such as wrapper counts,
caret state, and rendered SVG presence. `Bun.WebView` is experimental, so fall
back to Playwright only when the test needs its runner, tracing, multi-context,
or broader cross-browser features.

## Release Model

This package is not published to npm. Releases are distributed as GitHub
snapshot tags.

The release workflow reads `packages/zag-ripple/package.json`, builds and tests
the package, then creates an annotated `vX.Y.Z` tag whose root contains only the
installable package snapshot (`package.json`, `dist`, `src`, README, LICENSE,
and changelog). Consumers can install with a GitHub dependency such as:

```json
{
  "dependencies": {
    "zag-ripple": "github:ethan-huo/zag-ripple#v0.1.4"
  }
}
```

Only bump `packages/zag-ripple/package.json` when a new release tag should be
created.

## Coding Notes

- Keep adapter changes small and source-backed. `@zag-js/*`, `ripple`, and TSRX
  are moving targets; check local installed package code or upstream docs before
  changing integration behavior.
- `useMachine` accepts plain props and top-level tracked props. Do not call
  function props while unwrapping user props; Zag callbacks and stores commonly
  contain functions that must be passed through.
- In TSRX demos, pass plain Zag API objects to recursive children unless the
  child explicitly expects a `Tracked<T>`. Accidentally passing a tracked wrapper
  through `trackSplit` creates an extra `.value` layer and causes runtime API
  shape errors.
- Avoid writing tracked state during a derived `track(() => ...)` computation.
  If a Zag callback fires during connect and must update local demo state, defer
  the write and guard against loops.
- Comments should explain why an adapter boundary exists, not restate the code.

## Documentation Entrypoints

- Zag JS LLM docs: https://zagjs.com/llms.txt
- Ripple/TSRX LLM docs: https://www.ripple-ts.com/llms.txt
- TSRX LLM docs: https://tsrx.dev/llms.txt
- Base UI LLM docs for the demo site style reference: https://base-ui.com/llms.txt
