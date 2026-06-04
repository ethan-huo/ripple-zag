import { Fragment, track } from "ripple"
import {
  renderMarkdownToHtml,
  type StreamdownCaret,
  type StreamdownMode,
  type StreamdownOptions,
} from "./core"

export type StreamdownProps = StreamdownOptions & {
  value?: string
  children?: string
  class?: string
  className?: string
}

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

function mergeClasses(...classes: Array<string | undefined | false>) {
  return classes.filter(Boolean).join(" ")
}

export function Streamdown(props: StreamdownProps) {
  const html = track(() =>
    renderMarkdownToHtml(getContent(props), {
      parseIncompleteMarkdown: props.parseIncompleteMarkdown,
      remend: props.remend,
    })
  )
  const mode = track<StreamdownMode>(() => props.mode ?? "static")
  const shouldShowCaret = track(() => Boolean(props.caret && props.isAnimating))

  return (
    <div
      class={mergeClasses(
        "ripple-streamdown",
        mode.value === "streaming" && "ripple-streamdown-streaming",
        props.class,
        props.className
      )}
      data-ripple-streamdown=""
      data-mode={mode.value}
    >
      <Fragment innerHTML={html.value} />
      if (shouldShowCaret.value && props.caret) {
        <span class="ripple-streamdown-caret" aria-hidden="true">
          {getCaretText(props.caret)}
        </span>
      }
    </div>
  )
}
