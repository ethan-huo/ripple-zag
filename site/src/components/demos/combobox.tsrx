import * as combobox from '@zag-js/combobox';
import { createFilter } from '@zag-js/i18n-utils';
import { normalizeProps, useMachine, mergeProps } from 'zag-ripple';
import { track, Portal } from 'ripple';
import { ChevronsUpDown } from '../../lib/lucide-icons.tsrx';

export function Combobox() {
	let options = track(comboboxData);

	const filter = createFilter({ sensitivity: 'base' });

	const collection = track(
		() => combobox.collection(
			{
				items: options.value,
				itemToValue: (item) => item.code,
				itemToString: (item) => item.label,
			},
		),
	);

	let service = useMachine(combobox.machine, {
		id: 'combobox',
		collection,
		onInputValueChange({ inputValue }) {
			const filtered = comboboxData.filter((item) => filter.contains(item.label, inputValue));
			options.value = filtered.length > 0 ? filtered : comboboxData;
		},
		placeholder: 'Type or select country',
	});
	let api = track(() => combobox.connect(service, normalizeProps));

	return <>
	<div {...api.value.getRootProps()}>
		<label {...api.value.getLabelProps()}>{'Nationality'}</label>
		<div {...api.value.getControlProps()}>
			<input {...api.value.getInputProps()} />
			const triggerProps = mergeProps(api.value.getTriggerProps(), {
				onClick() {
					options.value = comboboxData;
				},
			});
			<button {...triggerProps}>
				<ChevronsUpDown />
			</button>
		</div>
	</div>
	<Portal target={document.body}>
		<div {...api.value.getPositionerProps()}>
			if (options.value.length > 0) {
				<ul {...api.value.getContentProps()}>
					for (let item of options.value) {
						<li {...api.value.getItemProps({ item })}>{item.label}</li>
					}
				</ul>
			}
		</div>
	</Portal>
	</>
}

const comboboxData = [
	{ label: 'Zambia', code: 'ZA' },
	{ label: 'Benin', code: 'BN' },
	{ label: 'Canada', code: 'CA' },
	{ label: 'United States', code: 'US' },
	{ label: 'Japan', code: 'JP' },
	{ label: 'Nigeria', code: 'NG' },
	{ label: 'Albania', code: 'AL' },
	{ label: 'Algeria', code: 'DZ' },
	{ label: 'American Samoa', code: 'AS' },
	{ label: 'Andorra', code: 'AD' },
	{ label: 'Angola', code: 'AO' },
	{ label: 'Anguilla', code: 'AI' },
	{ label: 'Antarctica', code: 'AQ' },
	{ label: 'Australia', code: 'AU' },
	{ label: 'Austria', code: 'AT' },
	{ label: 'Azerbaijan', code: 'AZ' },
	{ label: 'Bahamas', code: 'BS' },
	{ label: 'Bahrain', code: 'BH' },
	{ label: 'Madagascar', code: 'MG' },
	{ label: 'Malawi', code: 'MW' },
	{ label: 'Malaysia', code: 'MY' },
	{ label: 'Maldives', code: 'MV' },
	{ label: 'Mali', code: 'ML' },
	{ label: 'Malta', code: 'MT' },
	{ label: 'Togo', code: 'TG' },
	{ label: 'Tokelau', code: 'TK' },
	{ label: 'Tonga', code: 'TO' },
	{ label: 'Trinidad and Tobago', code: 'TT' },
	{ label: 'Tunisia', code: 'TN' },
];
