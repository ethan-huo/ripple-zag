import * as toast from '@zag-js/toast';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track, Portal } from 'ripple';
import { trackSplit } from '../../lib/track-split';
import { X, Info, Check, TriangleAlert, CircleAlert, Loader } from '../../lib/lucide-icons.tsrx';

const toaster = toast.createStore(
	{
		overlap: true,
		placement: 'bottom-end',
		offsets: '24px',
		gap: 24,
	},
);

export function ToastGroup() {
	let service = useMachine(toast.group.machine, {
		id: 'toast-group',
		store: toaster,
	});
	let api = track(() => toast.group.connect(service, normalizeProps));

	return <>
	<Portal target={document.body}>
		<div {...api.value.getGroupProps()}>
			for (const toastItem of api.value.getToasts(); index index; key toastItem.id) {
				<ToastItem actor={toastItem} {index} parent={service} />
			}
		</div>
	</Portal>

	<div data-scope="toast" data-part="trigger-group">
		<button
			data-scope="toast"
			data-part="trigger"
			data-type="info"
			onClick={() => {
				toaster.create(
					{
						title: 'New message received',
						description: 'You have a new notification in your inbox.',
						type: 'info',
					},
				);
			}}
		>
			<Info size={16} />
			{'Info'}
		</button>

		<button
			data-scope="toast"
			data-part="trigger"
			data-type="success"
			onClick={() => {
				toaster.create(
					{
						title: 'Success!',
						description: 'Your changes have been saved successfully.',
						type: 'success',
					},
				);
			}}
		>
			<Check size={16} />
			{'Success'}
		</button>

		<button
			data-scope="toast"
			data-part="trigger"
			data-type="warning"
			onClick={() => {
				toaster.create(
					{
						title: 'Warning',
						description: 'Please review your input before proceeding.',
						type: 'warning',
					},
				);
			}}
		>
			<TriangleAlert size={16} />
			{'Warning'}
		</button>

		<button
			data-scope="toast"
			data-part="trigger"
			data-type="error"
			onClick={() => {
				toaster.create(
					{
						title: 'Error occurred',
						description: 'Unable to complete the request. Please try again.',
						type: 'error',
					},
				);
			}}
		>
			<CircleAlert size={16} />
			{'Error'}
		</button>

		<button
			data-scope="toast"
			data-part="trigger"
			data-type="loading"
			onClick={() => {
				toaster.create(
					{
						title: 'Processing...',
						description: 'Please wait while we process your request.',
						type: 'loading',
					},
				);
			}}
		>
			<Loader size={16} />
			{'Loading'}
		</button>
	</div>
	</>
}

function ToastItem(props) {
	let [index, actor, parent] = trackSplit(props, ['index', 'actor', 'parent']);

	let composedProps = track(() => ({ ...actor.value, index, parent }));
	let service = useMachine(toast.machine, composedProps);
	let api = track(() => toast.connect(service, normalizeProps));

	return <>
	<div {...api.value.getRootProps()}>
		<span {...api.value.getGhostBeforeProps()} />

		<div data-scope="toast" data-part="content">
			<div data-scope="toast" data-part="icon">
				if (api.value.type === 'success') {
					<Check size={20} />
				} else if (api.value.type === 'warning') {
					<TriangleAlert size={20} />
				} else if (api.value.type === 'error') {
					<CircleAlert size={20} />
				} else if (api.value.type === 'loading') {
					<Loader size={20} />
				} else {
					<Info size={20} />
				}
			</div>

			<div data-scope="toast" data-part="text">
				<div {...api.value.getTitleProps()}>{api.value.title}</div>
				if (api.value.description) {
					<div {...api.value.getDescriptionProps()}>{api.value.description}</div>
				}
			</div>
		</div>

		<button {...api.value.getCloseTriggerProps()}>
			<X size={16} />
		</button>
		<span {...api.value.getGhostAfterProps()} />
	</div>
	</>
}
