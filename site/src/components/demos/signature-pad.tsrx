import * as signaturePad from '@zag-js/signature-pad';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';
import { RotateCcw } from '../../lib/lucide-icons.tsrx';

export function SignaturePad() {
	let service = useMachine(signaturePad.machine, {
		id: 'signature-pad',
	});
	let api = track(() => signaturePad.connect(service, normalizeProps));

	return <>
	<div {...api.value.getRootProps()}>
		<label {...api.value.getLabelProps()}>{"Sign here"}</label>

		<div {...api.value.getControlProps()}>
			<svg {...api.value.getSegmentProps()}>
				for (const path of api.value.paths; index i) {
					<path {...api.value.getSegmentPathProps({ path })} />
				}
				if (api.value.currentPath) {
					<path {...api.value.getSegmentPathProps({ path: api.value.currentPath })} />
				}
			</svg>

			<button {...api.value.getClearTriggerProps()}>
				<RotateCcw />
			</button>

			<div {...api.value.getGuideProps()} />
		</div>
	</div>
	</>
}
