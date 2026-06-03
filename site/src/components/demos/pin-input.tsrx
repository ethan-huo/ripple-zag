import * as pinInput from '@zag-js/pin-input';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';

export function PinInput() {
	let service = useMachine(pinInput.machine, {
		id: 'pin-input',
		placeholder: "○",
        count: 4,
	});
	let api = track(() => pinInput.connect(service, normalizeProps));

	return <>
	<div {...api.value.getRootProps()}>
        <label {...api.value.getLabelProps()}>{"Enter code:"}</label>
        <div {...api.value.getControlProps()}>
            for (const index of api.value.items) {
                <input {...api.value.getInputProps({ index })} />
            }
        </div>
        <div {...api.value.getHiddenInputProps()} />
        <button onClick={() => api.value.clearValue()}>{"Clear"}</button>
	</div>
	</>
}
