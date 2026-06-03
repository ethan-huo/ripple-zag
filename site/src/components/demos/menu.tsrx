import * as menu from '@zag-js/menu';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track, Portal } from 'ripple';
import { ChevronDown } from '../../lib/lucide-icons.tsrx';

export function Menu() {
	let service = useMachine(menu.machine, {
		id: 'menu',
	});
	let api = track(() => menu.connect(service, normalizeProps));

	return <>
	<button {...api.value.getTriggerProps()}>
		{'Actions'}
		<span {...api.value.getIndicatorProps()}>
			<ChevronDown />
		</span>
	</button>
	<Portal target={document.body}>
		<div {...api.value.getPositionerProps()}>
			<ul {...api.value.getContentProps()}>
				for (const item of data) {
					<li {...api.value.getItemProps({ value: item.value })}>{item.label}</li>
				}
			</ul>
		</div>
	</Portal>
	</>
}

const data = [
	{ value: 'edit', label: 'Edit' },
	{ value: 'duplicate', label: 'Duplicate' },
	{ value: 'archive', label: 'Archive' },
	{ value: 'delete', label: 'Delete' },
];
