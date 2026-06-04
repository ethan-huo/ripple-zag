import { Fragment, track, trackAsync } from "ripple"
import {
  completeMarkdown,
  type MarkdownRenderCache,
  parseMarkdownIntoBlocks,
  renderMarkdownToHtml,
  type StreamdownCaret,
  type StreamdownMode,
  type StreamdownOptions,
} from "./core"
import type {
  StreamdownBlockErrorProps,
  StreamdownBlockRenderer,
  StreamdownBlockRenderProps,
  StreamdownCodeBlock,
  StreamdownPlugins,
} from "./types"

export type StreamdownAnimateOptions = {
  animation?: "fadeIn" | "blurIn" | "slideUp" | (string & {})
  duration?: number
  easing?: string
  sep?: "word" | "char"
  stagger?: number
}

export type StreamdownProps = StreamdownOptions & {
  value?: string
  children?: string
  class?: string
  className?: string
  animated?: boolean | StreamdownAnimateOptions
  blockError?: (props: StreamdownBlockErrorProps) => unknown
  blockSkeleton?: (props: StreamdownBlockRenderProps) => unknown
  dir?: "auto" | "ltr" | "rtl"
  parseMarkdownIntoBlocksFn?: (markdown: string) => string[]
  plugins?: StreamdownPlugins
}

const maxRenderCacheSize = 256
const codeFencePattern = /^```([^\s`]*)?([^\n`]*)\n([\s\S]*?)(?:\n```)?\s*$/
const htmlTagPattern = /<[^>]*>/g
const whitespacePattern = /\s/
const whitespaceOnlyPattern = /^\s+$/
const skipAnimationTags = new Set(["annotation", "code", "math", "pre", "svg"])

type StreamdownMarkdownRenderBlock = {
  html: string
  index: number
  key: string
  source: string
  type: "markdown"
}

type StreamdownPluginRenderBlock = {
  block: StreamdownCodeBlock
  index: number
  key: string
  renderer: StreamdownBlockRenderer
  type: "renderer"
}

type StreamdownRenderBlock = StreamdownMarkdownRenderBlock | StreamdownPluginRenderBlock
type StreamdownAnimationState = Map<string, {
  charCount: number
  sourceLength: number
}>

function getContent(props: StreamdownProps) {
  if (typeof props.value === "string") {
    return props.value
  }

  if (typeof props.children === "string") {
    return props.children
  }

  return ""
}

function getCaretText(caret: StreamdownCaret) {
  return caret === "circle" ? "●" : "▋"
}

function getAnimationOptions(props: StreamdownProps): StreamdownAnimateOptions | undefined {
  return props.animated && typeof props.animated === "object" ? props.animated : undefined
}

function getAnimationStyle(props: StreamdownProps, skipAnimation: boolean, delay: number) {
  const options = getAnimationOptions(props)
  const animation = options?.animation ?? "fadeIn"
  const duration = Math.max(0, options?.duration ?? 150)
  const easing = options?.easing ?? "ease"
  const style = `--sd-animation:sd-${animation};--sd-duration:${skipAnimation ? 0 : duration}ms;--sd-easing:${easing};`

  return delay > 0 ? `${style}--sd-delay:${delay}ms;` : style
}

function splitTextByWord(text: string) {
  const parts: string[] = []
  let current = ""
  let inWhitespace = false

  for (const character of text) {
    const isWhitespace = whitespacePattern.test(character)

    if (isWhitespace !== inWhitespace && current) {
      parts.push(current)
      current = ""
    }

    current += character
    inWhitespace = isWhitespace
  }

  if (current) {
    parts.push(current)
  }

  return parts
}

function splitTextByCharacter(text: string) {
  const parts: string[] = []
  let whitespaceBuffer = ""

  for (let index = 0; index < text.length; index += 1) {
    const entityMatch = text.slice(index).match(/^&[#\w]+;/)
    const part = entityMatch?.[0] ?? text[index]

    if (whitespacePattern.test(part)) {
      whitespaceBuffer += part
    } else {
      if (whitespaceBuffer) {
        parts.push(whitespaceBuffer)
        whitespaceBuffer = ""
      }

      parts.push(part)
    }

    index += part.length - 1
  }

  if (whitespaceBuffer) {
    parts.push(whitespaceBuffer)
  }

  return parts
}

function getHtmlTagName(tag: string) {
  return tag.match(/^<\/?\s*([a-zA-Z0-9:-]+)/)?.[1]?.toLowerCase()
}

function getAnimationSkipDelta(tag: string) {
  const tagName = getHtmlTagName(tag)

  if (!tagName || !skipAnimationTags.has(tagName) || tag.endsWith("/>")) {
    return 0
  }

  return tag.startsWith("</") ? -1 : 1
}

function animateTextSegment(
  text: string,
  props: StreamdownProps,
  counters: { charCount: number; newTokenCount: number },
  prevContentLength: number,
) {
  const options = getAnimationOptions(props)
  const parts = options?.sep === "char" ? splitTextByCharacter(text) : splitTextByWord(text)

  return parts.map((part) => {
    const partStart = counters.charCount
    counters.charCount += part.length

    if (whitespaceOnlyPattern.test(part)) {
      return part
    }

    const skipAnimation = prevContentLength > 0 && partStart < prevContentLength
    const stagger = Math.max(0, options?.stagger ?? 40)
    const delay = skipAnimation ? 0 : counters.newTokenCount * stagger
    const style = getAnimationStyle(props, skipAnimation, delay)

    counters.newTokenCount += 1

    return `<span data-sd-animate="true" style="${style}">${part}</span>`
  }).join("")
}

function animateHtml(html: string, props: StreamdownProps, prevContentLength: number) {
  const counters = { charCount: 0, newTokenCount: 0 }
  const chunks: string[] = []
  let skipDepth = 0
  let lastIndex = 0

  for (const match of html.matchAll(htmlTagPattern)) {
    const index = match.index ?? 0
    const text = html.slice(lastIndex, index)

    chunks.push(skipDepth > 0
      ? text
      : animateTextSegment(text, props, counters, prevContentLength))

    const tag = match[0]
    chunks.push(tag)
    skipDepth = Math.max(0, skipDepth + getAnimationSkipDelta(tag))
    lastIndex = index + tag.length
  }

  const trailingText = html.slice(lastIndex)
  chunks.push(skipDepth > 0
    ? trailingText
    : animateTextSegment(trailingText, props, counters, prevContentLength))

  return {
    charCount: counters.charCount,
    html: chunks.join(""),
  }
}

function DefaultBlockSkeleton(_props: StreamdownBlockRenderProps) {
  return (
    <div class="ripple-streamdown-block-skeleton" data-ripple-streamdown-block-skeleton="">
      <div class="ripple-streamdown-block-skeleton-header" />
      <div class="ripple-streamdown-block-skeleton-body">
        <span class="ripple-streamdown-block-skeleton-spinner" aria-hidden="true" />
        <span class="ripple-streamdown-visually-hidden">{"Loading block"}</span>
      </div>
    </div>
  )
}

function DefaultBlockError(props: StreamdownBlockErrorProps) {
  const message = props.error instanceof Error ? props.error.message : "Unable to render block."

  return (
    <div class="ripple-streamdown-block-error" data-ripple-streamdown-block-error="">
      <strong>{"Block render failed"}</strong>
      <pre>{message}</pre>
    </div>
  )
}

function pruneRenderCache(cache: MarkdownRenderCache) {
  while (cache.size > maxRenderCacheSize) {
    const oldestKey = cache.keys().next().value

    if (oldestKey === undefined) {
      return
    }

    cache.delete(oldestKey)
  }
}

function getRendererLanguageMatches(renderer: StreamdownBlockRenderer, language: string) {
  if (!renderer.language) {
    return false
  }

  if (Array.isArray(renderer.language)) {
    return renderer.language.includes(language)
  }

  return renderer.language === language
}

function getBlockRenderers(props: StreamdownProps) {
  return props.plugins?.renderers ?? []
}

function findBlockRenderer(block: StreamdownCodeBlock, props: StreamdownProps) {
  const renderers = getBlockRenderers(props)

  return renderers.find((renderer) =>
    getRendererLanguageMatches(renderer, block.language) || Boolean(renderer.match?.(block))
  )
}

function hasIncompleteCodeFence(source: string) {
  const fenceCount = source.match(/```/g)?.length ?? 0

  return fenceCount % 2 === 1
}

function hasTable(source: string) {
  return /(^|\n)\|.+\|\n\|[\s:-]+\|/m.test(source)
}

function parseCodeFenceBlock(source: string): Omit<StreamdownCodeBlock, "isStreamingTail"> | null {
  const match = source.match(codeFencePattern)

  if (!match) {
    return null
  }

  const language = match[1]?.trim() ?? ""
  const meta = match[2]?.trim() || undefined

  return {
    code: match[3] ?? "",
    language,
    meta,
    source,
  }
}

function renderCachedMarkdownBlock(
  source: string,
  options: StreamdownOptions,
  cache: MarkdownRenderCache,
) {
  const cached = cache.get(source)

  if (cached !== undefined) {
    return cached
  }

  const html = renderMarkdownToHtml(source, {
    ...options,
    parseIncompleteMarkdown: false,
  })

  cache.set(source, html)
  return html
}

function createRenderBlocks(
  props: StreamdownProps,
  cache: MarkdownRenderCache,
  animationState: StreamdownAnimationState,
) {
  const content = getContent(props)
  const shouldParseIncompleteMarkdown = props.parseIncompleteMarkdown ?? true
  const completedMarkdown = shouldParseIncompleteMarkdown
    ? completeMarkdown(content, props.remend)
    : content
  const parseBlocks = props.parseMarkdownIntoBlocksFn ?? parseMarkdownIntoBlocks
  const rawBlocks = parseBlocks(completedMarkdown)
  const lastBlockIndex = rawBlocks.length - 1

  return rawBlocks.map((source, index): StreamdownRenderBlock => {
    const codeBlock = parseCodeFenceBlock(source)

    if (codeBlock) {
      const block = {
        ...codeBlock,
        isStreamingTail: Boolean(props.isAnimating && index === lastBlockIndex),
      }
      const renderer = findBlockRenderer(block, props)

      if (renderer) {
        return {
          block,
          index,
          key: String(index),
          renderer,
          type: "renderer",
        }
      }
    }

    const baseHtml = renderCachedMarkdownBlock(source, props, cache)
    const isLastBlock = index === lastBlockIndex
    const shouldAnimateBlock = isLastBlock && props.isAnimating && props.animated !== false
    const key = String(index)
    const previousAnimationState = animationState.get(key)
    const prevContentLength = previousAnimationState && source.length >= previousAnimationState.sourceLength
      ? previousAnimationState.charCount
      : 0
    const animationResult = shouldAnimateBlock
      ? animateHtml(baseHtml, props, prevContentLength)
      : undefined

    if (animationResult) {
      animationState.set(key, {
        charCount: animationResult.charCount,
        sourceLength: source.length,
      })
    }

    return {
      html: animationResult?.html ?? baseHtml,
      index,
      key,
      source,
      type: "markdown",
    }
  })
}

function detectTextDirection(text: string) {
  if (/[\u0590-\u08ff]/.test(text)) {
    return "rtl"
  }

  return "ltr"
}

function RendererFallbackBlock(props: {
  block: StreamdownCodeBlock
  fallback?: (props: StreamdownBlockRenderProps) => unknown
}) {
  const renderProps = { block: props.block }

  if (props.fallback) {
    return <>{props.fallback(renderProps)}</>
  }

  return <DefaultBlockSkeleton block={props.block} />
}

function RendererBlock(props: {
  block: StreamdownCodeBlock
  blockError?: (props: StreamdownBlockErrorProps) => unknown
  blockSkeleton?: (props: StreamdownBlockRenderProps) => unknown
  renderer: StreamdownBlockRenderer
}) {
  const renderProps = { block: props.block }
  const fallback = props.renderer.fallback ?? props.blockSkeleton
  const errorComponent = props.blockError ?? DefaultBlockError

  if (props.block.isStreamingTail) {
    return <RendererFallbackBlock block={props.block} fallback={fallback} />
  }

  const html = trackAsync(() => Promise.resolve(props.renderer.render(renderProps)))

  return (
    <div class="ripple-streamdown-renderer-block" data-ripple-streamdown-renderer-block={props.renderer.name}>
      try {
        <Fragment innerHTML={html.value} />
      } pending {
        <RendererFallbackBlock block={props.block} fallback={fallback} />
      } catch (error) {
        {errorComponent({ ...renderProps, error })}
      }
    </div>
  )
}

export function Streamdown(props: StreamdownProps) {
  const renderCache: MarkdownRenderCache = new Map()
  const animationState: StreamdownAnimationState = new Map()
  const mode = track<StreamdownMode>(() => props.mode ?? "streaming")
  const blocks = track(() => {
    const renderedBlocks = createRenderBlocks(props, renderCache, animationState)

    pruneRenderCache(renderCache)

    return renderedBlocks
  })
  const shouldShowCaret = track(() => {
    if (!(mode.value === "streaming" && props.isAnimating && props.caret)) {
      return false
    }

    const lastBlock = blocks.value.at(-1)

    if (!lastBlock) {
      return true
    }

    if (lastBlock.type === "renderer") {
      return false
    }

    const lastSource = lastBlock.source

    return !(hasIncompleteCodeFence(lastSource) || hasTable(lastSource))
  })
  const caretStyle = track(() => {
    if (!(shouldShowCaret.value && props.caret)) {
      return undefined
    }

    // Match Streamdown's root-level caret: CSS owns the marker so markdown HTML
    // can stay cacheable and completed blocks keep their DOM identity.
    return { "--ripple-streamdown-caret": `" ${getCaretText(props.caret)}"` }
  })
  const direction = track(() => {
    if (!props.dir) {
      return undefined
    }

    return props.dir === "auto" ? detectTextDirection(getContent(props)) : props.dir
  })

  return (
    <div
      class={[
        "ripple-streamdown",
        mode.value === "streaming" && "ripple-streamdown-streaming",
        shouldShowCaret.value && "ripple-streamdown-with-caret",
        props.class,
        props.className
      ]}
      data-ripple-streamdown=""
      data-mode={mode.value}
      dir={direction.value}
      style={caretStyle.value}
    >
      for (const block of blocks.value; index index; key block.key) {
        if (block.type === "renderer") {
          <RendererBlock
            block={block.block}
            blockError={props.blockError}
            blockSkeleton={props.blockSkeleton}
            renderer={block.renderer}
          />
        } else {
          <Fragment innerHTML={block.html} />
        }
      }
      if (blocks.value.length === 0 && shouldShowCaret.value) {
        <span aria-hidden="true" />
      }
    </div>
  )
}
