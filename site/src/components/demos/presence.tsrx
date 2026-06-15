import * as presence from '@zag-js/presence';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';

export function Presence() @{
    let present = track(false)

    let service = useMachine(presence.machine, {
        present,
    })
    let api = track(() => presence.connect(service, normalizeProps))

    const divRef = (node) => {
        api.value.setNode(node)
    };

    <>
    <div data-scope="presence" data-part="root">
        <button onclick={() => (present.value = !present.value)}>{"Toggle"}</button>
        @if (api.value.present) {
            <div
                ref={divRef}
                data-scope="presence"
                data-part="content"
                data-state={present.value ? "open" : "closed"}
            >
                    {"Content"}
            </div>
        }
    </div>
    </>
}
