import * as scrollArea from '@zag-js/scroll-area';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';

export function ScrollArea() @{
	let service = useMachine(scrollArea.machine, {
		id: 'scroll-area',
	});
	let api = track(() => scrollArea.connect(service, normalizeProps));

	<>
	<div {...api.value.getRootProps()}>
		<div {...api.value.getViewportProps()}>
			<div {...api.value.getContentProps()}>
				@for (const index of Array.from({length: 50}, (_, i) => i)) {
					<div>
						{"Item "}{index + 1}
					</div>
				}
			</div>
		</div>
		<div {...api.value.getScrollbarProps()}>
			<div {...api.value.getThumbProps()} />
		</div>
	</div>
	</>
}
