import * as tour from '@zag-js/tour';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track, Portal } from 'ripple';
import { LuX } from '../../lib/lucide-icons.tsrx';

export function Tour() @{
	let service = useMachine(
		tour.machine,
		() => ({
			id: 'tour',
			steps: steps,
		}),
	);
	let api = track(() => tour.connect(service, normalizeProps));

	<>
	<button data-scope="tour" data-part="trigger" onClick={() => api.value.start()}>{'Start Tour'}</button>

	@if (api.value.step && api.value.open) {
		<Portal target={document.body}>
			@if (api.value.step.backdrop) {
				<div {...api.value.getBackdropProps()} />
			}
			<div {...api.value.getSpotlightProps()} />
			<div {...api.value.getPositionerProps()}>
				<div {...api.value.getContentProps()}>
					@if (api.value.step.arrow) {
						<div {...api.value.getArrowProps()}>
							<div {...api.value.getArrowTipProps()} />
						</div>
					}

					<div {...api.value.getProgressTextProps()}>{api.value.getProgressText()}</div>

					<p {...api.value.getTitleProps()}>{api.value.step.title}</p>
					<div {...api.value.getDescriptionProps()}>{api.value.step.description}</div>

					@if (api.value.step.actions) {
						<div data-scope="tour" data-part="actions">
							@for (const action of api.value.step.actions; index actionIndex) {
								<button {...api.value.getActionTriggerProps({ action })}>{action.label}</button>
							}
						</div>
					}

					<button {...api.value.getCloseTriggerProps()}>
						<LuX size={16} />
					</button>
				</div>
			</div>
		</Portal>
	}
	</>
}

const steps = [
	{
		type: 'dialog',
		id: 'start',
		title: 'Welcome to ZagRipple!',
		description: 'Let\'s take a quick tour of the documentation to help you get started with ZagRipple components.',
		actions: [
			{ label: 'Let\'s go!', action: 'next' },
		],
	},
	{
		id: 'stackblitz',
		title: 'Try it Live',
		description: 'Click \'Open in Stackblitz\' to experiment with this component in a live coding environment.',
		target: () => document.querySelector('[data-id=stackblitz]'),
		placement: 'bottom',
		actions: [
			{ label: 'Prev', action: 'prev' },
			{ label: 'Next', action: 'next' },
		],
	},
	{
		id: 'zag-docs',
		title: 'Official Zag.js Documentation',
		description: 'Visit the official Zag.js docs to dive deeper into the machine logic and API details.',
		target: () => document.querySelector('[data-id=zag-docs]'),
		placement: 'bottom',
		actions: [
			{ label: 'Prev', action: 'prev' },
			{ label: 'Next', action: 'next' },
		],
	},
	{
		id: 'view-source',
		title: 'View Source Code',
		description: 'Check out the complete source code on GitHub to understand the implementation details.',
		target: () => document.querySelector('[data-id=view-source]'),
		placement: 'bottom',
		actions: [
			{ label: 'Prev', action: 'prev' },
			{ label: 'Next', action: 'next' },
		],
	},
	{
		id: 'installation',
		title: 'Installation Guide',
		description: 'Here\'s how to install ZagRipple and the component packages you need for your project.',
		target: () => document.querySelector('[data-id=installation]'),
		placement: 'top',
		actions: [
			{ label: 'Prev', action: 'prev' },
			{ label: 'Next', action: 'next' },
		],
	},
	{
		id: 'usage',
		title: 'Usage Examples',
		description: 'Learn how to use the component with practical code examples and best practices.',
		target: () => document.querySelector('[data-id=usage]'),
		placement: 'top',
		actions: [
			{ label: 'Prev', action: 'prev' },
			{ label: 'Next', action: 'next' },
		],
	},
	{
		type: 'dialog',
		id: 'end',
		title: 'You\'re all set!',
		description: 'Now you know how to navigate the ZagRipple docs. Start building amazing components with Ripple!',
		actions: [
			{ label: 'Finish', action: 'dismiss' },
		],
	},
];
