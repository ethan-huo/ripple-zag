import * as collapsible from '@zag-js/collapsible';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';

export function Collapsible() {
	let service = useMachine(collapsible.machine, {
		id: 'collapsible',
	});
	let api = track(() => collapsible.connect(service, normalizeProps));

    return <>
    <div {...api.value.getRootProps()}>
        <button {...api.value.getTriggerProps()}>{"Ripple JS Info"}</button>
        <div {...api.value.getContentProps()}>
            <p>
                {`Ripple was designed to be a JS/TS-first framework, rather than HTML-first. Ripple modules have their own .tsrx extension, and these modules fully support TypeScript. By introducing a new extension, it allows Ripple to invent its own superset language, which plays really nicely with TypeScript and JSX, but with a few interesting touches. In my experience, this has led to better DX not only for humans, but also for LLMs. `}
                <a href="https://www.tsrxjs.com/">{`Check out Docs`}</a>
            </p>
        </div>
    </div>
    </>
}