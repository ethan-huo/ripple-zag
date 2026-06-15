import { effect, track } from "ripple"
import {
  type BundledLanguage,
  type BundledTheme,
  bundledLanguages,
  bundledLanguagesInfo,
  createHighlighter,
  type HighlighterGeneric,
  type SpecialLanguage,
  type ThemeRegistrationAny,
  type TokensResult,
} from "shiki"
import { createJavaScriptRegexEngine } from "shiki/engine/javascript"
import type { StreamdownBlockRenderer, StreamdownBlockRenderProps } from "./types"

export type StreamdownShikiTheme = BundledTheme | ThemeRegistrationAny

export type StreamdownShikiRendererOptions = {
  lineNumbers?: boolean
  name?: string
  themes?: [StreamdownShikiTheme, StreamdownShikiTheme]
}

type HighlightResult = TokensResult

const defaultThemes: [StreamdownShikiTheme, StreamdownShikiTheme] = ["github-light", "github-dark"]
const languageAliases = Object.fromEntries(
  bundledLanguagesInfo.flatMap((info) =>
    (info.aliases ?? []).map((alias) => [alias, info.id as BundledLanguage])
  ),
) as Record<string, BundledLanguage>
const languageNames = new Set(Object.keys(bundledLanguages) as BundledLanguage[])
const highlighterCache = new Map<string, Promise<HighlighterGeneric<BundledLanguage, BundledTheme>>>()
const tokensCache = new Map<string, HighlightResult>()
const jsEngine = createJavaScriptRegexEngine({ forgiving: true })

function getThemeName(theme: StreamdownShikiTheme) {
  return typeof theme === "string" ? theme : (theme.name ?? "custom")
}

function getThemes(options: StreamdownShikiRendererOptions | undefined) {
  return options?.themes ?? defaultThemes
}

function normalizeLanguage(language: string) {
  const lower = language.trim().toLowerCase()

  return languageAliases[lower] ?? lower
}

function supportsLanguage(language: string) {
  return languageNames.has(normalizeLanguage(language) as BundledLanguage)
}

function getHighlighterCacheKey(language: BundledLanguage | SpecialLanguage, themes: [StreamdownShikiTheme, StreamdownShikiTheme]) {
  return `${language}:${getThemeName(themes[0])}:${getThemeName(themes[1])}`
}

function getTokensCacheKey(code: string, language: string, themes: [StreamdownShikiTheme, StreamdownShikiTheme]) {
  const themeNames = [getThemeName(themes[0]), getThemeName(themes[1])]
  const start = code.slice(0, 100)
  const end = code.length > 100 ? code.slice(-100) : ""

  return `${language}:${themeNames[0]}:${themeNames[1]}:${code.length}:${start}:${end}`
}

function trimTrailingNewlines(code: string) {
  let end = code.length

  while (end > 0 && code[end - 1] === "\n") {
    end -= 1
  }

  return code.slice(0, end)
}

function getHighlighter(language: BundledLanguage | SpecialLanguage, themes: [StreamdownShikiTheme, StreamdownShikiTheme]) {
  const cacheKey = getHighlighterCacheKey(language, themes)
  const cached = highlighterCache.get(cacheKey)

  if (cached) {
    return cached
  }

  const highlighterPromise = createHighlighter({
    engine: jsEngine,
    langs: [language],
    themes,
  })

  highlighterCache.set(cacheKey, highlighterPromise)
  return highlighterPromise
}

function createRawResult(code: string): HighlightResult {
  return {
    bg: "transparent",
    fg: "inherit",
    tokens: code.split("\n").map((line) => [{
      bgColor: "transparent",
      color: "inherit",
      content: line,
      htmlStyle: {},
      offset: 0,
    }]),
  }
}

async function highlightCode(code: string, language: string, themes: [StreamdownShikiTheme, StreamdownShikiTheme]) {
  const resolvedLanguage = normalizeLanguage(language)
  const safeLanguage: BundledLanguage | SpecialLanguage = languageNames.has(resolvedLanguage as BundledLanguage)
    ? (resolvedLanguage as BundledLanguage)
    : "text"
  const cacheKey = getTokensCacheKey(code, safeLanguage, themes)
  const cached = tokensCache.get(cacheKey)

  if (cached) {
    return cached
  }

  const highlighter = await getHighlighter(safeLanguage, themes)
  const loadedLanguages = highlighter.getLoadedLanguages()
  const languageToUse = loadedLanguages.includes(safeLanguage as BundledLanguage)
    ? safeLanguage
    : "text"
  const themeNames = {
    dark: getThemeName(themes[1]),
    light: getThemeName(themes[0]),
  }
  const result = highlighter.codeToTokens(code, {
    lang: languageToUse,
    themes: themeNames,
  })

  tokensCache.set(cacheKey, result)
  return result
}

function parseRootStyle(rootStyle: string | false | undefined) {
  const style: Record<string, string> = {}

  if (!rootStyle) {
    return style
  }

  for (const declaration of rootStyle.split(";")) {
    const index = declaration.indexOf(":")

    if (index <= 0) {
      continue
    }

    const property = declaration.slice(0, index).trim()
    const value = declaration.slice(index + 1).trim()

    if (property && value) {
      style[property] = value
    }
  }

  return style
}

function getTokenStyle(token: HighlightResult["tokens"][number][number]) {
  const style: Record<string, string> = {}
  const htmlStyle = token.htmlStyle as Record<string, string> | undefined

  if (token.color) {
    style["--ripple-streamdown-code-color"] = token.color
  }

  if (token.bgColor) {
    style["--ripple-streamdown-code-bg"] = token.bgColor
  }

  if (htmlStyle) {
    for (const [key, value] of Object.entries(htmlStyle)) {
      if (key === "color") {
        style["--ripple-streamdown-code-color"] = value
      } else if (key === "background-color") {
        style["--ripple-streamdown-code-bg"] = value
      } else {
        style[key] = value
      }
    }
  }

  return style
}

function getPreStyle(result: HighlightResult) {
  const style = parseRootStyle(result.rootStyle)

  if (result.bg) {
    style["--ripple-streamdown-code-pre-bg"] = result.bg
  }

  if (result.fg) {
    style["--ripple-streamdown-code-pre-fg"] = result.fg
  }

  return style
}

function getStartLine(meta: string | undefined) {
  const startLine = meta?.match(/\bstartLine=(\d+)\b/)?.[1]

  if (!startLine) {
    return 1
  }

  return Math.max(1, Number(startLine))
}

function getLineNumbersEnabled(meta: string | undefined, options: StreamdownShikiRendererOptions | undefined) {
  if (options?.lineNumbers === false) {
    return false
  }

  return !/\bnoLineNumbers\b/.test(meta ?? "")
}

function ShikiBlock(props: StreamdownBlockRenderProps & { options?: StreamdownShikiRendererOptions }) @{
  const trimmedCode = track(() => trimTrailingNewlines(props.block.code))
  const result = track<HighlightResult>(createRawResult(trimmedCode.value))
  const language = track(() => normalizeLanguage(props.block.language || "text"))
  const themes = track(() => getThemes(props.options))
  const showLineNumbers = track(() => getLineNumbersEnabled(props.block.meta, props.options))
  const startLine = track(() => getStartLine(props.block.meta))
  let highlightRequest = 0

  effect(() => {
    const requestId = highlightRequest + 1
    const code = trimmedCode.value
    const blockLanguage = language.value
    const blockThemes = themes.value
    const cacheKey = getTokensCacheKey(code, blockLanguage, blockThemes)
    const cached = tokensCache.get(cacheKey)

    highlightRequest = requestId
    result.value = cached ?? createRawResult(code)

    // Match upstream Streamdown: incomplete fences stay readable as plain text
    // and only pay Shiki cost after the block is complete.
    if (props.block.isStreamingTail) {
      return
    }

    highlightCode(code, blockLanguage, blockThemes)
      .then((highlighted) => {
        if (highlightRequest === requestId) {
          result.value = highlighted
        }
      })
      .catch((error) => {
        console.error("[Ripple Streamdown Shiki] Failed to highlight code:", error)
      })
  })

  (
    <div class="ripple-streamdown-shiki" data-ripple-streamdown-shiki="" data-language={language.value}>
      <div class="ripple-streamdown-code-header">
        <span>{language.value}</span>
      </div>
      <pre style={getPreStyle(result.value)}>
        <code
          class={showLineNumbers.value && "ripple-streamdown-code-line-numbers"}
          style={showLineNumbers.value && startLine.value > 1 ? { counterReset: `line ${startLine.value - 1}` } : undefined}
        >
          @for (const row of result.value.tokens; index lineIndex; key lineIndex) {
            <span class="ripple-streamdown-code-line">
              @if (row.length === 0 || (row.length === 1 && row[0].content === "")) {
                {"\n"}
              } @else {
                @for (const token of row; index tokenIndex; key tokenIndex) {
                  <span class="ripple-streamdown-code-token" style={getTokenStyle(token)} {...token.htmlAttrs}>
                    {token.content}
                  </span>
                }
              }
            </span>
          }
        </code>
      </pre>
    </div>
  )
}

export function createShikiRenderer(options: StreamdownShikiRendererOptions = {}): StreamdownBlockRenderer {
  return {
    component(props) {
      return <ShikiBlock block={props.block} options={options} />
    },
    match(block) {
      return block.language !== "mermaid" && supportsLanguage(block.language || "text")
    },
    name: options.name ?? "shiki",
    renderWhileStreaming: true,
  }
}
