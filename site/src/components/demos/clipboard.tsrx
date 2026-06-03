import * as clipboard from '@zag-js/clipboard';
import { normalizeProps, useMachine } from 'zag-ripple';
import { Check, ClipboardCopy } from '../../lib/lucide-icons.tsrx';
import { track } from 'ripple';

export function Clipboard() {
	let service = useMachine(clipboard.machine, {
		id: 'clipboard',
        value: 'https://www.tsrxjs.com/',
	});
	let api = track(() => clipboard.connect(service, normalizeProps));

    return <>
    <div {...api.value.getRootProps()}>
        <label {...api.value.getLabelProps()}>{"Copy this link"}</label>
        <div {...api.value.getControlProps()}>
            <input {...api.value.getInputProps()} />
            <button {...api.value.getTriggerProps()}>
                if(api.value.copied) {
                    <Check />
                }
                else {
                    <ClipboardCopy />
                }
            </button>
        </div>
    </div>
    </>
}