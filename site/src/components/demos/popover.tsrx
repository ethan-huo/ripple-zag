import * as popover from '@zag-js/popover';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track, Portal } from 'ripple';
import { LuX } from '../../lib/lucide-icons.tsrx';

export function Popover() @{
	let service = useMachine(popover.machine, {
		id: 'popover',
		portalled: true,
	});
	let api = track(() => popover.connect(service, normalizeProps));

	<>
	<button {...api.value.getTriggerProps()}>{'Click me'}</button>
	<Portal target={document.body}>
		<div {...api.value.getPositionerProps()}>
			<div {...api.value.getContentProps()}>
				<div {...api.value.getArrowProps()}>
					<div {...api.value.getArrowTipProps()} />
				</div>

				<div>
					<div {...api.value.getTitleProps()}>
						<b>{'Quick Settings'}</b>
					</div>
					<div {...api.value.getDescriptionProps()}>
						{'Adjust your preferences and account settings from this convenient panel.'}
					</div>
					<button>{'Update Profile'}</button>
				</div>
				<button {...api.value.getCloseTriggerProps()}>
					<LuX />
				</button>
			</div>
		</div>
	</Portal>
	</>
}
