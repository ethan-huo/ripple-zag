# Backlog

- Streamdown parity: the Ripple package now covers streaming-safe markdown blocks, root-level caret, Streamdown-style `animated` options, KaTeX math, Mermaid diagram plugins, and stable completed-block rendering. It still needs native Shiki code highlighting/controls, link-safety controls, and official-style code/table/Mermaid control surfaces before it fully matches https://streamdown.ai/playground.
- Sigil icon sizing: the generated icons default to `1em` instead of the old script's `24px`. Bare icons (no `class`/`size`) are used in many demos; verify visually after deploy and add `size={24}` or `class="size-6"` anywhere the 24px default is required.
