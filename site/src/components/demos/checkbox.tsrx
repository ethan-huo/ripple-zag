import * as checkbox from '@zag-js/checkbox';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';

export function Checkbox() {
	let service = useMachine(checkbox.machine, {
		id: 'checkbox',
	});
	let api = track(() => checkbox.connect(service, normalizeProps));

    return <>
    <label {...api.value.getRootProps()}>
        <span {...api.value.getLabelProps()}>{"Select Ripple JS"}</span>
        <input data-peer {...api.value.getHiddenInputProps()} />
        <div {...api.value.getControlProps()}>
            if(api.value.checkedState === true) {
                <svg viewBox="0 0 24 24" fill="currentcolor" transform="scale(0.7)">
                    <path d="M20.285 2l-11.285 11.567-5.286-5.011-3.714 3.716 9 8.728 15-15.285z" />
                </svg>
            }
            if(api.value.checkedState === "indeterminate") {  
                <svg viewBox="0 0 24 24" stroke="currentColor" stroke-width="4">
                    <line x1="21" x2="3" y1="12" y2="12" />
                </svg>
            }
        </div>
    </label>
    </>
}