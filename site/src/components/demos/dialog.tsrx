import * as dialog from '@zag-js/dialog';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track, Portal } from 'ripple';
import { X } from '../../lib/lucide-icons.tsrx';

export function Dialog() {
	let service = useMachine(dialog.machine, {
		id: 'dialog',
	});
	let api = track(() => dialog.connect(service, normalizeProps));

	return <>
	<button {...api.value.getTriggerProps()}>{'Open Dialog'}</button>
	<Portal target={document.body}>
		<div {...api.value.getBackdropProps()} />
		<div {...api.value.getPositionerProps()}>
			<div {...api.value.getContentProps()}>
				<h2 {...api.value.getTitleProps()}>{'Edit profile'}</h2>
				<p {...api.value.getDescriptionProps()}>
					{'Make changes to your profile here. Click save when you are done.'}
				</p>

				<div>
					<input placeholder="Enter name..." />
					<button>{'Save'}</button>
				</div>
				<button {...api.value.getCloseTriggerProps()}>
					<X />
				</button>
			</div>
		</div>
	</Portal>
	</>
}
