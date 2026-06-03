import * as floatingPanel from '@zag-js/floating-panel';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track, Portal } from 'ripple';
import { X, Minus, Maximize2, ArrowDownLeft } from '../../lib/lucide-icons.tsrx';

export function FloatingPanel() {
	let service = useMachine(floatingPanel.machine, {
		id: 'floating-panel',
	});
	let api = track(() => floatingPanel.connect(service, normalizeProps));

	return <>
	<button {...api.value.getTriggerProps()}>{'Open Panel'}</button>
	if (api.value.open) {
		<Portal target={document.body}>
			<div {...api.value.getPositionerProps()}>
				<div {...api.value.getContentProps()}>
					<div {...api.value.getDragTriggerProps()}>
						<div {...api.value.getHeaderProps()}>
							<p {...api.value.getTitleProps()}>{'Settings'}</p>
							<div {...api.value.getControlProps()}>
								<button {...api.value.getStageTriggerProps({ stage: 'minimized' })}>
									<Minus />
								</button>
								<button {...api.value.getStageTriggerProps({ stage: 'maximized' })}>
									<Maximize2 />
								</button>
								<button {...api.value.getStageTriggerProps({ stage: 'default' })}>
									<ArrowDownLeft />
								</button>
								<button {...api.value.getCloseTriggerProps()}>
									<X />
								</button>
							</div>
						</div>
					</div>
					<div {...api.value.getBodyProps()}>
						<label>
							<span>{'Theme'}</span>
							<select defaultValue="system">
								<option value="light">{'Light'}</option>
								<option value="dark">{'Dark'}</option>
								<option value="system">{'System'}</option>
							</select>
						</label>

						<label>
							<span>{'Auto-save'}</span>
							<input type="checkbox" checked={true} />
						</label>
					</div>

					<div {...api.value.getResizeTriggerProps({ axis: 'n' })} />
					<div {...api.value.getResizeTriggerProps({ axis: 'e' })} />
					<div {...api.value.getResizeTriggerProps({ axis: 'w' })} />
					<div {...api.value.getResizeTriggerProps({ axis: 's' })} />
					<div {...api.value.getResizeTriggerProps({ axis: 'ne' })} />
					<div {...api.value.getResizeTriggerProps({ axis: 'se' })} />
					<div {...api.value.getResizeTriggerProps({ axis: 'sw' })} />
					<div {...api.value.getResizeTriggerProps({ axis: 'nw' })} />
				</div>
			</div>
		</Portal>
	}
	</>
}
