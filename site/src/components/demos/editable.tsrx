import * as editable from '@zag-js/editable';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';

export function Editable() {
	let service = useMachine(editable.machine, {
		id: 'editable',
		placeholder: 'Enter your text...',
        submitMode: 'enter',
	});
	let api = track(() => editable.connect(service, normalizeProps));

    return <>
    <div {...api.value.getRootProps()}>
        <div {...api.value.getAreaProps()}>
            <input {...api.value.getInputProps()} />
            <span {...api.value.getPreviewProps()}>
              {api.value.valueText}
            </span>
        </div>

        <div {...api.value.getControlProps()}>
            if (api.value.editing) {
                <button {...api.value.getSubmitTriggerProps()}>{"Save"}</button>
                <button {...api.value.getCancelTriggerProps()}>{"Cancel"}</button>
            } else {
                <button {...api.value.getEditTriggerProps()}>{"Edit"}</button>
            }
        </div>
    </div>
    </>
}