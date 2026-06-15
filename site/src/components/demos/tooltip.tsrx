import * as tooltip from '@zag-js/tooltip';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track, Portal } from 'ripple';

export function Tooltip() @{
	let service = useMachine(tooltip.machine, {
		id: 'tooltip',
	});
	let api = track(() => tooltip.connect(service, normalizeProps));

	<>
	<button {...api.value.getTriggerProps()}>{'Hover me'}</button>
	<Portal target={document.body}>
		@if (api.value.open) {
			<div {...api.value.getPositionerProps()}>
				<div {...api.value.getContentProps()}>
					<div {...api.value.getArrowProps()}>
						<div {...api.value.getArrowTipProps()} />
					</div>
					{'Tooltip'}
				</div>
			</div>
		}
	</Portal>
	</>
}
