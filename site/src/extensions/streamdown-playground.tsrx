import * as popover from "@zag-js/popover"
import * as select from "@zag-js/select"
import { Portal, track } from "ripple"
import { StickToBottom, type StickToBottomController } from "ripple-stick-to-bottom"
import { Streamdown } from "ripple-streamdown"
import { createMermaidRenderer } from "ripple-streamdown/mermaid"
import { createShikiRenderer } from "ripple-streamdown/shiki"
import { normalizeProps, useMachine } from "zag-ripple"
import { Button } from "../components/ui/button.tsrx"
import { Navigation } from "../components/navigation.tsrx"
import { LuCheck, LuChevronDown, LuPlay, LuSettings } from '../lib/lucide-icons.tsrx';
import { streamdownSample } from "./streamdown-sample"

type PlaygroundMode = "static" | "streaming"
type CaretMode = "block" | "circle" | "none"
type AnimatedMode = "on" | "off"
type AnimationEffect = "fadeIn" | "blurIn" | "slideUp"
type AnimationEasing = "ease" | "ease-out" | "linear"
type AnimationSplitBy = "word" | "char"
type SelectOption<T extends string> = {
  label: string
  value: T
}

const modeOptions: SelectOption<PlaygroundMode>[] = [
  { label: "Static", value: "static" },
  { label: "Streaming", value: "streaming" },
]

const animatedOptions: SelectOption<AnimatedMode>[] = [
  { label: "On", value: "on" },
  { label: "Off", value: "off" },
]

const caretOptions: SelectOption<CaretMode>[] = [
  { label: "Block ▋", value: "block" },
  { label: "Circle ●", value: "circle" },
  { label: "None", value: "none" },
]

const effectOptions: SelectOption<AnimationEffect>[] = [
  { label: "Fade in", value: "fadeIn" },
  { label: "Blur in", value: "blurIn" },
  { label: "Slide up", value: "slideUp" },
]

const easingOptions: SelectOption<AnimationEasing>[] = [
  { label: "ease", value: "ease" },
  { label: "ease-out", value: "ease-out" },
  { label: "linear", value: "linear" },
]

const splitByOptions: SelectOption<AnimationSplitBy>[] = [
  { label: "Word", value: "word" },
  { label: "Character", value: "char" },
]

const streamdownPlugins = {
  renderers: [createMermaidRenderer(), createShikiRenderer()],
}

function PlaygroundSelect<T extends string>(props: {
  id: string
  value: T
  options: SelectOption<T>[]
  onValueChange: (value: T) => void
  label?: string
  ariaLabel?: string
}) @{
  const collection = select.collection({
    items: props.options,
    itemToString: (item) => item.label,
    itemToValue: (item) => item.value,
  })
  const value = track(() => [props.value])
  const service = useMachine(select.machine, {
    id: props.id,
    collection,
    value,
    positioning: { sameWidth: true },
    onValueChange(details) {
      const nextValue = details.value[0] as T | undefined

      if (nextValue) {
        props.onValueChange(nextValue)
      }
    },
  })
  const api = track(() => select.connect(service, normalizeProps))

  <div class="streamdown-select" {...api.value.getRootProps()}>
    @if (props.label) {
      <label class="streamdown-settings-label" {...api.value.getLabelProps()}>
        {props.label}
      </label>
    }
    <button
      class="streamdown-select-trigger"
      aria-label={props.ariaLabel}
      {...api.value.getTriggerProps()}
    >
      <span>{api.value.valueAsString || props.options[0]?.label}</span>
      <LuChevronDown class="h-4 w-4" />
    </button>
    <Portal target={document.body}>
      <div class="streamdown-select-positioner" {...api.value.getPositionerProps()}>
        <ul class="streamdown-select-content" {...api.value.getContentProps()}>
          @for (const item of collection.items) {
            <li class="streamdown-select-item" {...api.value.getItemProps({ item })}>
              <span {...api.value.getItemTextProps({ item })}>{item.label}</span>
              <span class="streamdown-select-check" {...api.value.getItemIndicatorProps({ item })}>
                <LuCheck class="h-4 w-4" />
              </span>
            </li>
          }
        </ul>
      </div>
    </Portal>
  </div>
}

function StreamdownSettings(props: {
  animated: AnimatedMode
  animationDuration: number
  animationEasing: AnimationEasing
  animationEffect: AnimationEffect
  animationSplitBy: AnimationSplitBy
  caret: CaretMode
  speed: number
  onAnimatedChange: (value: AnimatedMode) => void
  onAnimationDurationChange: (value: number) => void
  onAnimationEasingChange: (value: AnimationEasing) => void
  onAnimationEffectChange: (value: AnimationEffect) => void
  onAnimationSplitByChange: (value: AnimationSplitBy) => void
  onCaretChange: (value: CaretMode) => void
  onSpeedChange: (value: number) => void
}) @{
  const service = useMachine(popover.machine, {
    id: "streamdown-settings",
    portalled: true,
    positioning: {
      placement: "bottom-end",
      gutter: 8,
    },
  })
  const api = track(() => popover.connect(service, normalizeProps))

  <>
    <button class="streamdown-settings-trigger" {...api.value.getTriggerProps()} aria-label="Streamdown settings">
        <LuSettings class="h-4 w-4" />
      </button>
      <Portal target={document.body}>
        <div class="streamdown-settings-positioner" {...api.value.getPositionerProps()}>
          <div class="streamdown-settings-panel" {...api.value.getContentProps()}>
            <section class="streamdown-settings-section">
              <h2 {...api.value.getTitleProps()}>{"Rendering"}</h2>
              <div class="streamdown-settings-row">
                <PlaygroundSelect
                  id="streamdown-animated-select"
                  label="Animated"
                  ariaLabel="Animated"
                  value={props.animated}
                  options={animatedOptions}
                  onValueChange={props.onAnimatedChange}
                />
              </div>
              @if (props.animated === "on") {
                <>
                <div class="streamdown-settings-row">
                  <PlaygroundSelect
                    id="streamdown-effect-select"
                    label="Effect"
                    ariaLabel="Effect"
                    value={props.animationEffect}
                    options={effectOptions}
                    onValueChange={props.onAnimationEffectChange}
                  />
                </div>
                <label class="streamdown-speed">
                  <span>{"Duration (ms)"}</span>
                  <input
                    type="number"
                    min="0"
                    max="2000"
                    value={props.animationDuration}
                    onInput={(event) => {
                      props.onAnimationDurationChange(Math.max(0, Number((event.target as HTMLInputElement).value)))
                    }}
                  />
                </label>
                <div class="streamdown-settings-row">
                  <PlaygroundSelect
                    id="streamdown-easing-select"
                    label="Easing"
                    ariaLabel="Easing"
                    value={props.animationEasing}
                    options={easingOptions}
                    onValueChange={props.onAnimationEasingChange}
                  />
                </div>
                <div class="streamdown-settings-row">
                  <PlaygroundSelect
                    id="streamdown-split-by-select"
                    label="Split by"
                    ariaLabel="Split by"
                    value={props.animationSplitBy}
                    options={splitByOptions}
                    onValueChange={props.onAnimationSplitByChange}
                  />
                </div>
                </>
              }
              <div class="streamdown-settings-row">
                <PlaygroundSelect
                  id="streamdown-caret-select"
                  label="Caret"
                  ariaLabel="Caret"
                  value={props.caret}
                  options={caretOptions}
                  onValueChange={props.onCaretChange}
                />
              </div>
            </section>

            <section class="streamdown-settings-section">
              <h2>{"Streaming"}</h2>
              <label class="streamdown-speed">
                <span>{"Speed (ms)"}</span>
                <input
                  type="number"
                  min="1"
                  max="500"
                  value={props.speed}
                  onInput={(event) => {
                    props.onSpeedChange(Math.max(1, Number((event.target as HTMLInputElement).value)))
                  }}
                />
              </label>
            </section>
          </div>
        </div>
      </Portal>
    </>
}

export function StreamdownPlayground() @{
  const markdown = track(streamdownSample)
  const markdownOutput = track("")
  const mode = track<PlaygroundMode>("static")
  const caret = track<CaretMode>("block")
  const animated = track<AnimatedMode>("off")
  const animationDuration = track(150)
  const animationEasing = track<AnimationEasing>("ease")
  const animationEffect = track<AnimationEffect>("fadeIn")
  const animationSplitBy = track<AnimationSplitBy>("word")
  const streamSpeed = track(30)
  const isStreaming = track(false)
  const isOutputAtBottom = track(true)
  const tokenIndex = track(0)
  let streamTimer: ReturnType<typeof setInterval> | null = null
  let outputScrollController: StickToBottomController | null = null

  const stopStreaming = () => {
    if (streamTimer) {
      clearInterval(streamTimer)
      streamTimer = null
    }

    isStreaming.value = false
  }

  const simulateStreaming = () => {
    if (streamTimer) {
      return
    }

    const tokens = markdown.value.split(" ").map((token) => `${token} `)
    tokenIndex.value = 0
    markdownOutput.value = ""

    mode.value = "streaming"
    isStreaming.value = true
    outputScrollController?.scrollToBottom({ animation: "instant", ignoreEscapes: true })

    streamTimer = setInterval(() => {
      if (tokenIndex.value >= tokens.length) {
        stopStreaming()
        return
      }

      markdownOutput.value += tokens[tokenIndex.value]
      tokenIndex.value += 1
    }, streamSpeed.value)
  }

  <>
    <head>
      <title>{"Streamdown Playground | ZagRipple"}</title>
    </head>

      <Navigation noSearch />

      <main class="streamdown-playground">
        <header class="streamdown-playground-header">
          <div class="streamdown-playground-actions">
            <PlaygroundSelect
              id="streamdown-mode-select"
              ariaLabel="Rendering mode"
              value={mode.value}
              options={modeOptions}
              onValueChange={(value) => {
                mode.value = value
                if (value === "static") {
                  stopStreaming()
                }
              }}
            />

            <StreamdownSettings
              animated={animated.value}
              animationDuration={animationDuration.value}
              animationEasing={animationEasing.value}
              animationEffect={animationEffect.value}
              animationSplitBy={animationSplitBy.value}
              caret={caret.value}
              speed={streamSpeed.value}
              onAnimatedChange={(value) => {
                animated.value = value
              }}
              onAnimationDurationChange={(value) => {
                animationDuration.value = value
              }}
              onAnimationEasingChange={(value) => {
                animationEasing.value = value
              }}
              onAnimationEffectChange={(value) => {
                animationEffect.value = value
              }}
              onAnimationSplitByChange={(value) => {
                animationSplitBy.value = value
              }}
              onCaretChange={(value) => {
                caret.value = value
              }}
              onSpeedChange={(value) => {
                streamSpeed.value = value
              }}
            />

            <Button
              onClick={() => {
                if (isStreaming.value) {
                  stopStreaming()
                } else {
                  simulateStreaming()
                }
              }}
              class="streamdown-action-button"
              variant={isStreaming.value ? "destructive" : "default"}
            >
              <LuPlay class="h-3.5 w-3.5" />
              {isStreaming.value ? "Stop" : "Simulate Stream"}
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
                  markdownOutput.value = ""
                  tokenIndex.value = 0
                }
              }}
            />
          </div>

          <div class="streamdown-playground-pane">
            <div class="streamdown-pane-title">{"Streamdown Output"}</div>
            <StickToBottom
              class="streamdown-output"
              bottomInset={48}
              initial={false}
              contextRef={(controller) => {
                outputScrollController = controller
              }}
              onStateChange={(snapshot) => {
                isOutputAtBottom.value = snapshot.isAtBottom
              }}
              resize={{
                damping: 0.7,
                mass: 1.25,
                stiffness: 0.05,
              }}
            >
              <Streamdown
                value={mode.value === "streaming" ? markdownOutput.value : markdown.value}
                mode={mode.value}
                plugins={streamdownPlugins}
                isAnimating={isStreaming.value}
                animated={animated.value === "on"
                  ? {
                    animation: animationEffect.value,
                    duration: animationDuration.value,
                    easing: animationEasing.value,
                    sep: animationSplitBy.value,
                  }
                  : false}
                caret={caret.value === "none" ? undefined : caret.value}
              />
            </StickToBottom>
            @if (mode.value === "streaming" && !isOutputAtBottom.value) {
              <button
                class="streamdown-scroll-to-bottom"
                type="button"
                aria-label="Scroll to bottom"
                onClick={() => {
                  outputScrollController?.scrollToBottom()
                }}
              >
                <LuChevronDown class="h-5 w-5" />
              </button>
            }
          </div>
        </section>
      </main>
    </>
}
