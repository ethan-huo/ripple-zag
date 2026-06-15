import * as angleSlider from '@zag-js/angle-slider';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';

export function AngleSlider() @{
	let service = useMachine(angleSlider.machine, {
		id: 'angle-slider',
	});
	let api = track(() => angleSlider.connect(service, normalizeProps));

    <>
    <div {...api.value.getRootProps()}>
        <label {...api.value.getLabelProps()}>{'Wind direction'}</label>
        <div {...api.value.getControlProps()}>
            <div {...api.value.getThumbProps()} />
            <div {...api.value.getMarkerGroupProps()}>
                @for (const value of [0, 45, 90, 135, 180, 225, 270, 315]) {
                    <div {...api.value.getMarkerProps({ value })}></div>
                }
            </div>
        </div>
        <div {...api.value.getValueTextProps()}>{api.value.value}{"°"}</div>
        <input {...api.value.getHiddenInputProps()} />
    </div>
    </>
}