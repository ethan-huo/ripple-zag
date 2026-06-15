#!/usr/bin/env bun
/**
 * Post-migration verifier for TSRX template control-flow directives.
 *
 * Why this exists: the text-based migration (migrate_tsrx_control_flow.py)
 * decides whether a `for`/`if`/`try` belongs to render output by scanning its
 * body for a `<`. But `<` also appears in comparisons (`i <= 0`) and generics
 * (`Map<K, V>`), so a plain function loop can be wrongly rewritten to `@for`.
 * A template directive (`@for`/`@if`/`@switch`/`@try`) is only valid in render
 * output, where its body produces JSX — never in a plain data function.
 *
 * This checker parses each .tsrx with the SAME compiler front-end the build
 * uses (@tsrx/core) and flags any directive whose body contains no JSX node.
 * That is an exact, syntax-free signal: plain logic never contains JSX nodes,
 * and any real render branch always does (a closing tag, self-close, or
 * fragment). Heuristics can't tell `i < 0` from `<i/>`; the AST can.
 *
 * Usage:  bun tools/check-tsrx-directives.mjs [path ...]    (default: packages site)
 * Exit:   0 = clean, 1 = suspected mis-conversions found (CI-friendly).
 */
import { createRequire } from 'node:module'
import { readdirSync, readFileSync } from 'node:fs'
import { join, dirname, relative } from 'node:path'
import { fileURLToPath, pathToFileURL } from 'node:url'

const ROOT = dirname(dirname(fileURLToPath(import.meta.url)))

// @tsrx/core is a transitive dep (via ripple). Resolve it through a workspace
// that depends on ripple rather than hard-coding bun's hashed .bun/ path.
function resolveCore() {
	const bases = [join(ROOT, 'site')]
	try {
		for (const d of readdirSync(join(ROOT, 'packages')))
			bases.push(join(ROOT, 'packages', d))
	} catch {}
	for (const base of bases) {
		try {
			const compiler = createRequire(join(base, 'noop.js')).resolve(
				'ripple/compiler',
			)
			return createRequire(compiler).resolve('@tsrx/core')
		} catch {}
	}
	throw new Error(
		'Could not resolve @tsrx/core — run from the repo root with deps installed.',
	)
}

const { parseModule } = await import(pathToFileURL(resolveCore()).href)

const isDirective = (t) => /^JSX(For|If|Switch|Try|Each|Await|Key)/.test(t)
const isJsxContent = (t) =>
	/^JSX(Element|Fragment|Text|CodeBlock|ExpressionContainer)$/.test(t)

function walk(node, cb) {
	if (!node || typeof node !== 'object') return
	if (Array.isArray(node)) {
		for (const x of node) walk(x, cb)
		return
	}
	if (typeof node.type === 'string') cb(node)
	for (const k in node) {
		if (k === 'loc' || k === 'start' || k === 'end' || k === 'range' || k === 'parent')
			continue
		walk(node[k], cb)
	}
}

function collectTsrx(target) {
	const out = []
	let entries
	try {
		entries = readdirSync(target, { recursive: true, withFileTypes: true })
	} catch {
		// a single file path
		if (target.endsWith('.tsrx')) return [target]
		return out
	}
	for (const e of entries) {
		if (!e.isFile() || !e.name.endsWith('.tsrx')) continue
		// Node/Bun give parentPath (or path) for recursive dirents
		const dir = e.parentPath ?? e.path ?? target
		if (dir.includes('node_modules')) continue
		out.push(join(dir, e.name))
	}
	return out
}

const targets = process.argv.slice(2)
const roots = targets.length ? targets : ['packages', 'site']
const files = [...new Set(roots.flatMap((r) => collectTsrx(join(ROOT, r))))].sort()

let directiveCount = 0
const suspects = []
for (const f of files) {
	let ast
	const src = readFileSync(f, 'utf8')
	try {
		ast = parseModule(src, f)
	} catch (e) {
		console.error(`parse error: ${relative(ROOT, f)} — ${e?.message?.split('\n')[0]}`)
		continue
	}
	const lines = src.split('\n')
	walk(ast, (n) => {
		if (!isDirective(n.type)) return
		directiveCount++
		let hasJsx = false
		walk(n, (m) => {
			if (m !== n && isJsxContent(m.type)) hasJsx = true
		})
		if (!hasJsx) {
			const line = n.loc?.start?.line
			suspects.push({ file: relative(ROOT, f), line, type: n.type, text: lines[line - 1]?.trim() })
		}
	})
}

console.log(
	`scanned ${files.length} .tsrx files, ${directiveCount} template directives`,
)
if (suspects.length === 0) {
	console.log('✓ no mis-converted directives (every @-directive renders JSX)')
	process.exit(0)
}
console.log(`\n✗ ${suspects.length} suspected mis-conversion(s) — directive with no JSX in body:\n`)
for (const s of suspects) console.log(`  ${s.file}:${s.line}\n    ${s.text}`)
console.log('\nA plain JS for/if/try inside a non-render function must NOT use @.')
process.exit(1)
