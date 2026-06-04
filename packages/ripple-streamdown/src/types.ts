import type { Component } from "ripple"

export type StreamdownCodeBlock = {
  code: string
  isStreamingTail: boolean
  language: string
  meta?: string
  source: string
}

export type StreamdownBlockRenderProps = {
  block: StreamdownCodeBlock
}

export type StreamdownBlockRenderer = {
  component: Component<StreamdownBlockRenderProps>
  language?: string | string[]
  match?: (block: StreamdownCodeBlock) => boolean
  name: string
}

export type StreamdownPlugins = {
  renderers?: StreamdownBlockRenderer[]
}

export type StreamdownBlockErrorProps = StreamdownBlockRenderProps & {
  error: unknown
}
