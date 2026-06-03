import * as combobox from '@zag-js/combobox';
import { createFilter } from "@zag-js/i18n-utils"
import { normalizeProps, useMachine } from 'zag-ripple';
import { track, Portal } from 'ripple';
import { components } from '../lib/components';
import { Search } from "../lib/lucide-icons.tsrx";
import { RouteContext } from "../lib/route-context";

// TODO utiity cmd+k zag hotkeys will also handle cmd/ctrl+k
export function SearchDocs() {
    let options = track(components)
    const router = RouteContext.get()
    const filter = createFilter({ sensitivity: "base" })

    const collection = track(() => combobox.collection({
        items: options.value,
        itemToValue: (item) => item.id,
        itemToString: (item) => item.label,
    }))

	let service = useMachine(combobox.machine, {
		id: 'search-combobox',
        collection,
        onInputValueChange(details) {
            const inputValue = details?.inputValue ?? ""
            const filtered = inputValue
                ? components.filter((item) => filter.contains(item.label, inputValue))
                : components
            const nextOptions = filtered.length > 0 ? filtered : components
            queueMicrotask(() => {
                const currentOptions = options.value
                const hasSameItems = currentOptions.length === nextOptions.length
                    && currentOptions.every((item, index) => item.id === nextOptions[index]?.id)

                if (!hasSameItems) {
                    options.value = nextOptions
                }
            })
        },
        placeholder: "Search components...",
        selectionBehavior: 'clear',
        inputBehavior: 'autohighlight',
        openOnClick: true,
        onSelect(details) {
            const itemValue = details?.itemValue
            if (!itemValue) return
            router.value.navigate(`/components/${itemValue}`)
        },
	});
	let api = track(() => combobox.connect(service, normalizeProps));

    return <>
    <div {...api.value.getRootProps()}>
        <div class="relative" {...api.value.getControlProps()}>
			<Search class="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <input
                {...api.value.getInputProps()}
                class="h-8 w-64 rounded-full border border-border bg-card pl-9! pr-14! text-sm text-foreground outline-none transition-colors placeholder:text-muted-foreground hover:bg-muted/50 focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-[-1px]"
            />
            <kbd class="absolute right-2.5 top-1/2 inline-flex h-5 -translate-y-1/2 items-center rounded-full border border-border bg-background px-1.5 font-mono text-[0.75rem] leading-none text-muted-foreground">
                {"⌘K"}
			</kbd>
        </div>
    </div>
    <Portal target={document.body}>
        <div {...api.value.getPositionerProps()}>
            if(options.value.length > 0) {
                <ul class="mt-2 max-h-80 w-(--reference-width) overflow-auto rounded-md border border-border bg-popover p-1 shadow-[var(--shadow-2)]" {...api.value.getContentProps()}>
                    for(let item of options.value) {
                        <li class="rounded px-2 py-1.5 text-sm outline-none data-[highlighted]:bg-muted" {...api.value.getItemProps({ item })}>
                            {item.label}
                        </li>
                    }
                </ul>
            }
        </div>
    </Portal>
    </>
}
