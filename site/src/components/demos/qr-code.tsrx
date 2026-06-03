import * as qrCode from '@zag-js/qr-code';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';

export function QrCode() {
	let service = useMachine(qrCode.machine, {
		id: 'qr-code',
		value: 'https://www.tsrxjs.com',
		encoding: { ecc: "H" },
	});
	let api = track(() => qrCode.connect(service, normalizeProps));

	return <>
	<div {...api.value.getRootProps()}>
		<svg {...api.value.getFrameProps()}>
			<path {...api.value.getPatternProps()} />
		</svg>
		<div {...api.value.getOverlayProps()}>
			<img
				src="https://www.tsrxjs.com/favicon.svg"
				alt=""
			/>
		</div>
	</div>
	</>
}
