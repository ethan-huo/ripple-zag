---
name: sync-latest
description: Sync this zag-ripple repository to the latest Ripple/TSRX and Zag JS releases. Use when asked to update dependencies, learn current Ripple or Zag changes, add newly released Zag components to the demo site, remove obsolete adapter APIs, regenerate icons, fix upgrade regressions, validate all component pages, or prepare release/deploy follow-up after a broad technical upgrade.
---

# Sync Latest

## Mission

Bring `zag-ripple` back in line with current upstream behavior, not just current package versions. Treat Ripple/TSRX, Zag JS, the adapter package, and the demo site as one integration surface.

Read `references/upgrade-playbook.md` when runtime errors, TSRX behavior, recursive demos, release workflow, icon generation, or Cloudflare/GitHub deployment details matter.

## Source Of Truth

Start by reading local project context:

```bash
git status --short --branch
sed -n '1,220p' AGENTS.md
tree --gitignore -L 3 packages/zag-ripple site .github .agents
```

Fetch current upstream docs before changing version-sensitive code:

```bash
ctx read https://zagjs.com/llms.txt --no-cache 2>&1
ctx read https://www.ripple-ts.com/llms.txt --no-cache 2>&1
ctx read https://base-ui.com/llms.txt --no-cache 2>&1
```

Prefer package metadata and installed source over memory:

```bash
bun pm view ripple version
bun pm view @ripple-ts/vite-plugin version
bun pm view @zag-js/core version
bun pm view @zag-js/react version
```

## Workflow

1. Inventory current state.
   Check dependency versions, existing demos, exported adapter APIs, workflows, and generated icon files. Identify user changes in the worktree before editing.

2. Research upstream drift.
   Compare Zag component docs/package list against `site/src/lib/components.ts` and `site/src/components/demos/`. Check Ripple/TSRX docs and installed package source for changed syntax, lifecycle behavior, tracking semantics, and Vite plugin behavior.

3. Upgrade dependencies with Bun.
   Use `bun add` / `bun update` in the correct workspace. Do not reintroduce pnpm files. Regenerate `bun.lock` through Bun only.

4. Align adapter APIs.
   Keep `packages/zag-ripple/src` minimal. Remove exported helpers that do not have practical Ripple/TSRX value. Preserve Zag service contracts that machines actually use, such as `service.refs`.

5. Add or update demos.
   Add missing Zag components, remove stale beta labels when upstream has stabilized them, and ensure each demo uses current Zag connect APIs. Keep demo data labels explicit; do not assume nested item shapes.

6. Regenerate generated code.
   Run `bun --filter ./site icons:generate` after icon usage changes. Do not hand-edit generated icon wrappers except to fix the generator.

7. Validate runtime behavior.
   Build and test first, then crawl component routes for console/page errors. Avoid opening many visible browser tabs; use script or browser automation that reuses one page and closes or reuses sessions.

8. Finish the release/deploy loop when requested.
   For package release, bump only `packages/zag-ripple/package.json` when a new GitHub snapshot tag is intended. For site deploy, rely on `.github/workflows/deploy-site.yml` and Cloudflare Pages.

## Required Checks

Run the narrow checks first:

```bash
bun --filter zag-ripple test -- --run
bun --filter zag-ripple build
bun --filter ./site build
```

When demos changed, also run route-level runtime validation against the built or dev site. Capture page errors and console errors; fix every actionable error before finishing.

Before commit:

```bash
git status --short
git diff --stat
```

Keep commits grouped by purpose: dependency/adapter upgrade, demo/runtime fixes, workflow/release/deploy changes.

## Stop Conditions

Stop and ask the user before:

- Creating or rotating secrets, unless the user explicitly asked you to do it.
- Publishing a new package tag or pushing a release branch without an explicit release request.
- Reverting user changes or deleting demos that might be intentionally incomplete.

If an upgrade leaves a known tail, append it to `.agents/backlog.md` with the concrete command, page, or upstream issue needed to resume.
