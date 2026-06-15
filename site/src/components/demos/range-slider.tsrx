import * as slider from '@zag-js/slider';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';

export function RangeSlider() @{
	let service = useMachine(slider.machine, {
		id: 'range-slider',
		defaultValue: [10, 60],
	});
	let api = track(() => slider.connect(service, normalizeProps));

	<>
	<div {...api.value.getRootProps()}>
		<div>
			<label {...api.value.getLabelProps()}>{"Quantity"}</label>
			<output {...api.value.getValueTextProps()}>
				<b>{api.value.value.join(" - ")}</b>
			</output>
		</div>

		<div {...api.value.getControlProps()}>
			<div {...api.value.getTrackProps()}>
				<div {...api.value.getRangeProps()} />
			</div>
			<div {...api.value.getThumbProps({ index: 0 })}>
				<input {...api.value.getHiddenInputProps({ index: 0 })} />
			</div>
			<div {...api.value.getThumbProps({ index: 1 })}>
				<input {...api.value.getHiddenInputProps({ index: 1 })} />
			</div>
		</div>
	</div>
	</>
}
