import { effect, Fragment, track } from "ripple"
import type { MermaidConfig } from "mermaid"
import type { StreamdownBlockRenderProps, StreamdownBlockRenderer } from "./types"

let mermaidId = 0
let mermaidConfigId = 0
const mermaidConfigIds = new WeakMap<object, number>()
const svgCache = new Map<string, string>()

export type StreamdownMermaidRendererOptions = {
  config?: MermaidConfig
  name?: string
}

function getMermaidConfigKey(config: MermaidConfig | undefined) {
  if (!config) {
    return "default"
  }

  const cached = mermaidConfigIds.get(config)

  if (cached) {
    return String(cached)
  }

  mermaidConfigId += 1
  mermaidConfigIds.set(config, mermaidConfigId)
  return String(mermaidConfigId)
}

function getMermaidCacheKey(code: string, config: MermaidConfig | undefined) {
  return `${getMermaidConfigKey(config)}:${code}`
}

async function renderMermaid(code: string, config: MermaidConfig | undefined) {
  const cacheKey = getMermaidCacheKey(code, config)
  const cached = svgCache.get(cacheKey)

  if (cached) {
    return cached
  }

  const mermaidModule = await import("mermaid")
  const mermaid = mermaidModule.default

  mermaid.initialize({
    suppressErrorRendering: true,
    startOnLoad: false,
    securityLevel: "strict",
    ...config,
  })

  const result = await mermaid.render(`ripple-streamdown-mermaid-${mermaidId++}`, code)

  svgCache.set(cacheKey, result.svg)
  return result.svg
}

function ThrowError(props: { error: unknown }) {
  throw props.error
}

function MermaidBlock(props: StreamdownBlockRenderProps & {
  config?: MermaidConfig
}) @{
  const svg = track("")
  const status = track<"pending" | "ready" | "stale">("pending")
  const finalError = track<unknown | null>(null)
  let renderRequest = 0

  effect(() => {
    const requestId = renderRequest + 1
    const code = props.block.code
    const config = props.config
    const isStreamingTail = props.block.isStreamingTail

    renderRequest = requestId

    if (!code.trim()) {
      svg.value = ""
      status.value = "pending"
      finalError.value = null
      return
    }

    renderMermaid(code, config)
      .then((result) => {
        if (renderRequest !== requestId) {
          return
        }

        svg.value = result
        status.value = "ready"
        finalError.value = null
      })
      .catch((error) => {
        if (renderRequest !== requestId) {
          return
        }

        // Mermaid fences often alternate between valid and invalid while tokens
        // stream in; preserve the last good SVG until the completed block is
        // truly invalid.
        if (isStreamingTail) {
          status.value = svg.value ? "stale" : "pending"
          finalError.value = null
          return
        }

        finalError.value = error
      })
  })

  <>
    @if (finalError.value) {
      <ThrowError error={finalError.value} />
    }

    <div class="ripple-streamdown-mermaid" data-ripple-streamdown-mermaid="" data-state={status.value}>
      @if (svg.value) {
        <Fragment innerHTML={svg.value} />
      } @else {
        <>
          <span class="ripple-streamdown-block-skeleton-spinner" aria-hidden="true" />
          <span class="ripple-streamdown-visually-hidden">{"Rendering diagram"}</span>
        </>
      }
    </div>
  </>
}

export function createMermaidRenderer(options: StreamdownMermaidRendererOptions = {}): StreamdownBlockRenderer {
  return {
    component(props) {
      return <MermaidBlock block={props.block} config={options.config} />
    },
    language: "mermaid",
    name: options.name ?? "mermaid",
    renderWhileStreaming: true,
  }
}
