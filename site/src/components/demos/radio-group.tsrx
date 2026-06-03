import * as radioGroup from '@zag-js/radio-group';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';

export function RadioGroup() {
	let service = useMachine(radioGroup.machine, {
		id: 'radio-group',
		defaultValue: 'apple',
	});
	let api = track(() => radioGroup.connect(service, normalizeProps));

	return <>
	<div {...api.value.getRootProps()}>
		<h2 {...api.value.getLabelProps()}>{"Fruits"}</h2>
		<div>
			for (const opt of items) {
				<label {...api.value.getItemProps({ value: opt.id })}>
					<span {...api.value.getItemTextProps({ value: opt.id })}>
						{opt.label}
					</span>
					<input
						data-peer=""
						{...api.value.getItemHiddenInputProps({ value: opt.id })}
					/>
					<div {...api.value.getItemControlProps({ value: opt.id })}>
						if (api.value.value === opt.id) {
							<svg
								viewBox="0 0 24 24"
								fill="currentcolor"
								transform="scale(0.7)"
							>
								<path d="M20.285 2l-11.285 11.567-5.286-5.011-3.714 3.716 9 8.728 15-15.285z" />
							</svg>
						}
					</div>
				</label>
			}
		</div>
	</div>
	</>
}

const items = [
	{ id: 'apple', label: 'Apple' },
	{ id: 'orange', label: 'Orange' },
	{ id: 'banana', label: 'Banana' },
	{ id: 'grape', label: 'Grape' },
];
