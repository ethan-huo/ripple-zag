import { track } from "ripple"
import { Streamdown } from "ripple-streamdown"
import { Button } from "../components/ui/button.tsrx"
import { Navigation } from "../components/navigation.tsrx"
import { ExternalLink, FileText, Play, RotateCcw } from "../lib/lucide-icons.tsrx"
import { streamdownSample } from "./streamdown-sample"

type PlaygroundMode = "static" | "streaming"
type CaretMode = "block" | "circle" | "none"

export function StreamdownPlayground() {
  const markdown = track(streamdownSample)
  const markdownOutput = track(streamdownSample)
  const mode = track<PlaygroundMode>("static")
  const caret = track<CaretMode>("block")
  const streamSpeed = track(30)
  const isStreaming = track(false)
  let streamTimer: ReturnType<typeof setInterval> | null = null
  let tokenIndex = 0

  const stopStreaming = () => {
    if (streamTimer) {
      clearInterval(streamTimer)
      streamTimer = null
    }

    isStreaming.value = false
  }

  const simulateStreaming = () => {
    stopStreaming()

    const tokens = markdown.value.split(" ").map((token) => `${token} `)
    let currentContent = ""
    tokenIndex = 0
    markdownOutput.value = ""
    mode.value = "streaming"
    isStreaming.value = true

    streamTimer = setInterval(() => {
      if (tokenIndex >= tokens.length) {
        stopStreaming()
        return
      }

      currentContent += tokens[tokenIndex]
      tokenIndex += 1
      markdownOutput.value = currentContent
    }, streamSpeed.value)
  }

  const clearMarkdown = () => {
    stopStreaming()
    markdown.value = ""
    markdownOutput.value = ""
  }

  const resetMarkdown = () => {
    stopStreaming()
    markdown.value = streamdownSample
    markdownOutput.value = streamdownSample
    mode.value = "static"
  }

  return (
    <>
      <head>
        <title>{"Streamdown Playground | ZagRipple"}</title>
      </head>

      <Navigation noSearch />

      <main class="streamdown-playground">
        <header class="streamdown-playground-header">
          <div>
            <p class="streamdown-playground-kicker">{"Advanced Extension"}</p>
            <h1>{"Streamdown Playground"}</h1>
          </div>

          <div class="streamdown-playground-actions">
            <Button href="https://streamdown.ai/docs" target="_blank" variant="outline" size="sm">
              <FileText class="h-3.5 w-3.5" />
              {"Official Docs"}
              <ExternalLink class="h-3.5 w-3.5" />
            </Button>

            <select
              value={mode.value}
              onInput={(event) => {
                mode.value = (event.target as HTMLSelectElement).value as PlaygroundMode
                if (mode.value === "static") {
                  stopStreaming()
                  markdownOutput.value = markdown.value
                }
              }}
              class="streamdown-control"
              aria-label="Rendering mode"
            >
              <option value="static">{"Static"}</option>
              <option value="streaming">{"Streaming"}</option>
            </select>

            <select
              value={caret.value}
              onInput={(event) => {
                caret.value = (event.target as HTMLSelectElement).value as CaretMode
              }}
              class="streamdown-control"
              aria-label="Caret"
            >
              <option value="block">{"Block caret"}</option>
              <option value="circle">{"Circle caret"}</option>
              <option value="none">{"No caret"}</option>
            </select>

            <label class="streamdown-speed">
              <span>{"Speed"}</span>
              <input
                type="number"
                min="1"
                max="500"
                value={streamSpeed.value}
                onInput={(event) => {
                  streamSpeed.value = Math.max(1, Number((event.target as HTMLInputElement).value))
                }}
              />
            </label>

            <Button
              onClick={() => {
                if (isStreaming.value) {
                  stopStreaming()
                } else {
                  simulateStreaming()
                }
              }}
              size="sm"
              variant={isStreaming.value ? "destructive" : "default"}
            >
              <Play class="h-3.5 w-3.5" />
              {isStreaming.value ? "Stop" : "Simulate Stream"}
            </Button>

            <Button onClick={resetMarkdown} size="sm" variant="outline">
              <RotateCcw class="h-3.5 w-3.5" />
              {"Reset"}
            </Button>

            <Button onClick={clearMarkdown} size="sm" variant="outline">
              {"Clear"}
            </Button>
          </div>
        </header>

        <section class="streamdown-playground-grid">
          <div class="streamdown-playground-pane">
            <div class="streamdown-pane-title">{"Markdown Input"}</div>
            <textarea
              class="streamdown-editor"
              spellCheck={false}
              value={markdown.value}
              placeholder="Type your markdown here..."
              onInput={(event) => {
                markdown.value = (event.target as HTMLTextAreaElement).value
                if (!isStreaming.value) {
                  markdownOutput.value = markdown.value
                }
              }}
            />
          </div>

          <div class="streamdown-playground-pane">
            <div class="streamdown-pane-title">{"Streamdown Output"}</div>
            <div class="streamdown-output">
              <Streamdown
                value={isStreaming.value ? markdownOutput.value : markdown.value}
                mode={mode.value}
                isAnimating={isStreaming.value}
                caret={caret.value === "none" ? undefined : caret.value}
              />
            </div>
          </div>
        </section>
      </main>
    </>
  )
}
