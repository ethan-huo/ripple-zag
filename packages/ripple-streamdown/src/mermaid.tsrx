import { Fragment, trackAsync } from "ripple"
import type { MermaidConfig } from "mermaid"
import type { StreamdownBlockRenderProps, StreamdownBlockRenderer } from "./types"

let mermaidId = 0

export type StreamdownMermaidRendererOptions = {
  config?: MermaidConfig
  name?: string
}

async function renderMermaid(code: string, config: MermaidConfig | undefined) {
  const mermaidModule = await import("mermaid")
  const mermaid = mermaidModule.default

  mermaid.initialize({
    startOnLoad: false,
    securityLevel: "strict",
    ...config,
  })

  const result = await mermaid.render(`ripple-streamdown-mermaid-${mermaidId++}`, code)

  return result.svg
}

function MermaidBlock(props: StreamdownBlockRenderProps & {
  config?: MermaidConfig
}) {
  return <>
    const svg = trackAsync(() => renderMermaid(props.block.code, props.config))

    <div class="ripple-streamdown-mermaid" data-ripple-streamdown-mermaid="">
      <Fragment innerHTML={svg.value} />
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
  }
}
