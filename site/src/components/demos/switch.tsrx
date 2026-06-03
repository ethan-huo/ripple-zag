import * as toggle from '@zag-js/switch';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';

export function Switch() {
	let service = useMachine(toggle.machine, {
		id: 'switch',
	});
	let api = track(() => toggle.connect(service, normalizeProps));

	return <>
	<label {...api.value.getRootProps()}>
		<input {...api.value.getHiddenInputProps()} />
		<span {...api.value.getControlProps()}>
			<span {...api.value.getThumbProps()} />
		</span>
		<span {...api.value.getLabelProps()}>{api.value.checked ? "On" : "Off"}</span>
	</label>
	</>
}
