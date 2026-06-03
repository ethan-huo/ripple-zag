import * as progress from '@zag-js/progress';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';

export function LinearProgress() {
	let service = useMachine(progress.machine, {
		id: 'linear-progress',
		defaultValue: 60,
	});
	let api = track(() => progress.connect(service, normalizeProps));

	return <>
	<div>
		<div {...api.value.getRootProps()}>
			<div {...api.value.getLabelProps()}>{"Upload progress"}</div>
			<div {...api.value.getTrackProps()}>
				<div {...api.value.getRangeProps()} />
			</div>
			<div {...api.value.getValueTextProps()}>{api.value.valueAsString}</div>
		</div>

		<div>
			<button onclick={() => api.value.setValue((api.value.value ?? 0) - 20)}>
				{"Decrease"}
			</button>

			<button onclick={() => api.value.setValue((api.value.value ?? 0) + 20)}>
				{"Increase"}
			</button>

			<button onclick={() => api.value.setValue(null)}>{"Indeterminate"}</button>
		</div>
	</div>
	</>
}
