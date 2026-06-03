import * as numberInput from '@zag-js/number-input';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';
import { ChevronUp, ChevronDown } from '../../lib/lucide-icons.tsrx';

export function NumberInput() {
	let service = useMachine(numberInput.machine, {
		id: 'number-input',
	});
	let api = track(() => numberInput.connect(service, normalizeProps));

	return <>
	<div {...api.value.getRootProps()}>
		<label {...api.value.getLabelProps()}>{"Enter number:"}</label>
		<div>
			<input {...api.value.getInputProps()} />
			<div>
				<button {...api.value.getIncrementTriggerProps()}>
					<ChevronUp />
				</button>
				<button {...api.value.getDecrementTriggerProps()}>
					<ChevronDown />
				</button>
			</div>
		</div>
	</div>
	</>
}
