import * as numberInput from '@zag-js/number-input';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';
import { LuChevronUp, LuChevronDown } from '../../lib/lucide-icons.tsrx';

export function NumberInput() @{
	let service = useMachine(numberInput.machine, {
		id: 'number-input',
	});
	let api = track(() => numberInput.connect(service, normalizeProps));

	<>
	<div {...api.value.getRootProps()}>
		<label {...api.value.getLabelProps()}>{"Enter number:"}</label>
		<div>
			<input {...api.value.getInputProps()} />
			<div>
				<button {...api.value.getIncrementTriggerProps()}>
					<LuChevronUp />
				</button>
				<button {...api.value.getDecrementTriggerProps()}>
					<LuChevronDown />
				</button>
			</div>
		</div>
	</div>
	</>
}
