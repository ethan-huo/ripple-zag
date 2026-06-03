import * as steps from '@zag-js/steps';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';

export function Steps() {
	let service = useMachine(steps.machine, {
		id: 'steps',
		count: stepsData.length,
        orientation: 'horizontal',
	});
	let api = track(() => steps.connect(service, normalizeProps));

	return <>
	<div {...api.value.getRootProps()}>
		<div {...api.value.getListProps()}>
			<div {...api.value.getItemProps({ index: 0 })}>
				<button {...api.value.getTriggerProps({ index: 0 })}>
					<div {...api.value.getIndicatorProps({ index: 0 })}>{"1"}</div>
					<span>{stepsData[0].title}</span>
				</button>
				<div {...api.value.getSeparatorProps({ index: 0 })} />
			</div>
			<div {...api.value.getItemProps({ index: 1 })}>
				<button {...api.value.getTriggerProps({ index: 1 })}>
					<div {...api.value.getIndicatorProps({ index: 1 })}>{"2"}</div>
					<span>{stepsData[1].title}</span>
				</button>
				<div {...api.value.getSeparatorProps({ index: 1 })} />
			</div>
			<div {...api.value.getItemProps({ index: 2 })}>
				<button {...api.value.getTriggerProps({ index: 2 })}>
					<div {...api.value.getIndicatorProps({ index: 2 })}>{"3"}</div>
					<span>{stepsData[2].title}</span>
				</button>
				<div {...api.value.getSeparatorProps({ index: 2 })} />
			</div>
			<div {...api.value.getItemProps({ index: 3 })}>
				<button {...api.value.getTriggerProps({ index: 3 })}>
					<div {...api.value.getIndicatorProps({ index: 3 })}>{"4"}</div>
					<span>{stepsData[3].title}</span>
				</button>
				<div {...api.value.getSeparatorProps({ index: 3 })} />
			</div>
		</div>

		<div {...api.value.getContentProps({ index: 0 })}>
			{stepsData[0].title}
		</div>
		<div {...api.value.getContentProps({ index: 1 })}>
			{stepsData[1].title}
		</div>
		<div {...api.value.getContentProps({ index: 2 })}>
			{stepsData[2].title}
		</div>
		<div {...api.value.getContentProps({ index: 3 })}>
			{stepsData[3].title}
		</div>

		<div {...api.value.getContentProps({ index: stepsData.length })}>
			{"Complete - Thank you 🎉"}
		</div>

		<div>
			<button {...api.value.getPrevTriggerProps()}>{"Back"}</button>
			<button {...api.value.getNextTriggerProps()}>{"Next"}</button>
		</div>
	</div>
	</>
}

const stepsData = [
	{ title: "Account" },
	{ title: "Profile" },
	{ title: "Preferences" },
	{ title: "Review" },
];
