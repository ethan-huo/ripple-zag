import * as passwordInput from '@zag-js/password-input';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';
import { Eye, EyeOff } from '../../lib/lucide-icons.tsrx';

export function PasswordInput() {
	let service = useMachine(passwordInput.machine, {
		id: 'password-input',
	});
	let api = track(() => passwordInput.connect(service, normalizeProps));

	return <>
	<div {...api.value.getRootProps()}>
		<label {...api.value.getLabelProps()}>{"Password"}</label>
		<div {...api.value.getControlProps()}>
			<input {...api.value.getInputProps()} />
			<button {...api.value.getVisibilityTriggerProps()}>
				<span {...api.value.getIndicatorProps()}>
					if (api.value.visible) {
						<Eye />
					} else {
						<EyeOff />
					}
				</span>
			</button>
		</div>
	</div>
	</>
}
