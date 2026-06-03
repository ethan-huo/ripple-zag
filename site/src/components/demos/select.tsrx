import * as select from '@zag-js/select';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track, Portal } from 'ripple';
import { ChevronDown, Check } from '../../lib/lucide-icons.tsrx';

export function Select() {
	const collection = select.collection(
		{
			items: data,
			itemToValue: (item) => item.value,
			itemToString: (item) => item.label,
		},
	);

	let service = useMachine(select.machine, {
		id: 'select',
		collection,
		placeholder: 'Select option',
	});
	let api = track(() => select.connect(service, normalizeProps));

	return <>
	<div {...api.value.getRootProps()}>
		<label {...api.value.getLabelProps()}>{'Label'}</label>
		<div {...api.value.getControlProps()}>
			<button {...api.value.getTriggerProps()}>
				<span>{api.value.valueAsString || 'Select option'}</span>
				<ChevronDown />
			</button>
		</div>
		<Portal target={document.body}>
			<div {...api.value.getPositionerProps()}>
				<ul {...api.value.getContentProps()}>
					for (const item of collection.items) {
						<li {...api.value.getItemProps({ item })}>
							<span {...api.value.getItemTextProps({ item })}>{item.label}</span>
							<span {...api.value.getItemIndicatorProps({ item })}>
								<Check />
							</span>
						</li>
					}
				</ul>
			</div>
		</Portal>
	</div>
	</>
}

const data = [
	{ value: 'apple', label: 'Apple' },
	{ value: 'banana', label: 'Banana' },
	{ value: 'cherry', label: 'Cherry' },
	{ value: 'grape', label: 'Grape' },
	{ value: 'orange', label: 'Orange' },
];
