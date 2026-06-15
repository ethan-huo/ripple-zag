import * as splitter from '@zag-js/splitter';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';

export function Splitter() @{
	let service = useMachine(splitter.machine, {
		id: 'splitter',
		panels: [{ id: "a" }, { id: "b" }],
		defaultSize: [50, 50],
	});
	let api = track(() => splitter.connect(service, normalizeProps));

	<>
	<div {...api.value.getRootProps()}>
		<div {...api.value.getPanelProps({ id: "a" })}>
			<p>{"A"}</p>
		</div>
		<div {...api.value.getResizeTriggerProps({ id: "a:b" })} />
		<div {...api.value.getPanelProps({ id: "b" })}>
			<p>{"B"}</p>
		</div>
	</div>
	</>
}
