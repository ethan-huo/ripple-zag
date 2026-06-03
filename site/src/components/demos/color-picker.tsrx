import * as colorPicker from '@zag-js/color-picker';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track, Portal } from 'ripple';
import { Pipette } from '../../lib/lucide-icons.tsrx';

export function ColorPicker() {
	let service = useMachine(colorPicker.machine, {
		id: 'color-picker',
		defaultValue: colorPicker.parse('#38a169').toFormat('hsla'),
		format: 'hsla',
	});
	let api = track(() => colorPicker.connect(service, normalizeProps));

	return <>
	<div {...api.value.getRootProps()}>
		<label {...api.value.getLabelProps()}>
			<span>{'Color:'}</span>
			{api.value.value.toString('hex')}
		</label>

		<div {...api.value.getControlProps()}>
			<button {...api.value.getTriggerProps()}>
				<div {...api.value.getTransparencyGridProps({ size: '8px' })} />
				<div {...api.value.getSwatchProps({ value: api.value.value })} />
			</button>
			<input {...api.value.getChannelInputProps({ channel: 'hex' })} />
			<input {...api.value.getChannelInputProps({ channel: 'alpha' })} />
		</div>

		<Portal target={document.body}>
			<div {...api.value.getPositionerProps()}>
				<div {...api.value.getContentProps()}>
					<div>
						<div {...api.value.getAreaProps()}>
							<div {...api.value.getAreaBackgroundProps()} />
							<div {...api.value.getAreaThumbProps()} />
						</div>

						<div>
							<div>
								<div {...api.value.getChannelSliderProps({ channel: 'hue' })}>
									<div {...api.value.getChannelSliderTrackProps({ channel: 'hue' })} />
									<div {...api.value.getChannelSliderThumbProps({ channel: 'hue' })} />
								</div>

								<div {...api.value.getChannelSliderProps({ channel: 'alpha' })}>
									<div {...api.value.getTransparencyGridProps({ size: '12px' })} />
									<div {...api.value.getChannelSliderTrackProps({ channel: 'alpha' })} />
									<div {...api.value.getChannelSliderThumbProps({ channel: 'alpha' })} />
								</div>
							</div>
							<button {...api.value.getEyeDropperTriggerProps()}>
								<Pipette />
							</button>
						</div>

						if (api.value.format.startsWith('hsl')) {
							<div>
								<div>
									<input {...api.value.getChannelInputProps({ channel: 'hue' })} />
									<span>{'H'}</span>
								</div>
								<div>
									<input {...api.value.getChannelInputProps({ channel: 'saturation' })} />
									<span>{'S'}</span>
								</div>
								<div>
									<input {...api.value.getChannelInputProps({ channel: 'lightness' })} />
									<span>{'L'}</span>
								</div>
								<div>
									<input {...api.value.getChannelInputProps({ channel: 'alpha' })} />
									<span>{'A'}</span>
								</div>
							</div>
						}

						if (api.value.format.startsWith('rgb')) {
							<div>
								<div>
									<input {...api.value.getChannelInputProps({ channel: 'red' })} />
									<span>{'R'}</span>
								</div>
								<div>
									<input {...api.value.getChannelInputProps({ channel: 'green' })} />
									<span>{'G'}</span>
								</div>
								<div>
									<input {...api.value.getChannelInputProps({ channel: 'blue' })} />
									<span>{'B'}</span>
								</div>
								<div>
									<input {...api.value.getChannelInputProps({ channel: 'alpha' })} />
									<span>{'A'}</span>
								</div>
							</div>
						}

						if (api.value.format.startsWith('hsb')) {
							<div>
								<div>
									<input {...api.value.getChannelInputProps({ channel: 'hue' })} />
									<span>{'H'}</span>
								</div>
								<div>
									<input {...api.value.getChannelInputProps({ channel: 'saturation' })} />
									<span>{'S'}</span>
								</div>
								<div>
									<input {...api.value.getChannelInputProps({ channel: 'brightness' })} />
									<span>{'B'}</span>
								</div>
								<div>
									<input {...api.value.getChannelInputProps({ channel: 'alpha' })} />
									<span>{'A'}</span>
								</div>
							</div>
						}

						<hr />

						<div {...api.value.getSwatchGroupProps()}>
							<p>{'Swatches'}</p>
							let presets = ['#f47373', '#697689', '#38a169', '#3182ce'];
							for (let preset of presets) {
								<button {...api.value.getSwatchTriggerProps({ value: preset })}>
									<div>
										<div {...api.value.getTransparencyGridProps({ size: '4px' })} />
										<div {...api.value.getSwatchProps({ value: preset })} />
									</div>
								</button>
							}
						</div>
					</div>
				</div>
			</div>
		</Portal>
	</div>
	</>
}
