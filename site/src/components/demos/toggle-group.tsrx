import * as toggleGroup from '@zag-js/toggle-group';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';
import { LuBold, LuItalic, LuUnderline } from '../../lib/lucide-icons.tsrx';

export function ToggleGroup() @{
	let service = useMachine(toggleGroup.machine, {
		id: 'toggle-group',
		defaultValue: 'bold',
		multiple: true,
	});
	let api = track(() => toggleGroup.connect(service, normalizeProps));

	<>
	<div {...api.value.getRootProps()}>
		<button {...api.value.getItemProps({ value: "bold" })}>
			<LuBold size={16} />
		</button>
		<button {...api.value.getItemProps({ value: "italic" })}>
			<LuItalic size={16} />
		</button>
		<button {...api.value.getItemProps({ value: "underline" })}>
			<LuUnderline size={16} />
		</button>
	</div>
	</>
}
