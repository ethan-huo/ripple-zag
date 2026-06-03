import * as toggleGroup from '@zag-js/toggle-group';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';
import { Bold, Italic, Underline } from '../../lib/lucide-icons.tsrx';

export function ToggleGroup() {
	let service = useMachine(toggleGroup.machine, {
		id: 'toggle-group',
		defaultValue: 'bold',
		multiple: true,
	});
	let api = track(() => toggleGroup.connect(service, normalizeProps));

	return <>
	<div {...api.value.getRootProps()}>
		<button {...api.value.getItemProps({ value: "bold" })}>
			<Bold size={16} />
		</button>
		<button {...api.value.getItemProps({ value: "italic" })}>
			<Italic size={16} />
		</button>
		<button {...api.value.getItemProps({ value: "underline" })}>
			<Underline size={16} />
		</button>
	</div>
	</>
}
