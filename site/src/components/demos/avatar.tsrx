import * as avatar from '@zag-js/avatar';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';

const name = 'John Doe';
const src = 'https://avatar.iran.liara.run/public/10';

export function Avatar() @{
	let service = useMachine(avatar.machine, {
		id: 'avatar',
	});
	let api = track(() => avatar.connect(service, normalizeProps));

    const initial = name
        .split(" ")
        .map((s) => s[0])
        .join("")

    <>
    <div {...api.value.getRootProps()}>
        <div {...api.value.getFallbackProps()}>
            <div>{initial}</div>
        </div>
        <img
            alt={name}
            referrerPolicy="no-referrer"
            src={src}
            {...api.value.getImageProps()}
        />
    </div>
    </>
}