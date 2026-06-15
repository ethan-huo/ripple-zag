import * as tagsInput from '@zag-js/tags-input';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';
import { LuX } from '../../lib/lucide-icons.tsrx';

export function TagsInput() @{
	let service = useMachine(tagsInput.machine, {
		id: 'tags-input',
		defaultValue: ["Ripple JS", "Svelte"],
	});
	let api = track(() => tagsInput.connect(service, normalizeProps));

	<>
	<fieldset {...api.value.getRootProps()}>
		<legend {...api.value.getLabelProps()}>{"Enter frameworks:"}</legend>
		<ul {...api.value.getControlProps()}>
			@for (const value of api.value.value; index index) {
				<li {...api.value.getItemProps({ index, value })}>
					<div {...api.value.getItemPreviewProps({ index, value })}>
						<span>{value}</span>
						<button {...api.value.getItemDeleteTriggerProps({ index, value })}>
							<LuX />
						</button>
					</div>
					<input {...api.value.getItemInputProps({ index, value })} />
				</li>
			}
			<input placeholder="Add tag..." {...api.value.getInputProps()} />
		</ul>
	</fieldset>
	</>
}
