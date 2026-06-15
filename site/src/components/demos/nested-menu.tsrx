import * as menu from '@zag-js/menu';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track, Portal } from 'ripple';
import { LuChevronDown, LuChevronRight } from '../../lib/lucide-icons.tsrx';

export function NestedMenu() @{
	// Level 1 - File Menu
	let fileMenuService = useMachine(menu.machine, {
		id: '1',
		'aria-label': 'File',
	});
	let fileMenu = track(() => menu.connect(fileMenuService, normalizeProps));

	// Level 2 - Share Menu
	let shareMenuService = useMachine(menu.machine, {
		id: '2',
		'aria-label': 'Share',
	});
	let shareMenu = track(() => menu.connect(shareMenuService, normalizeProps));

	setTimeout(() => {
		fileMenu.value.setChild(shareMenuService);
		shareMenu.value.setParent(fileMenuService);
	});

	// Share menu trigger
	const shareMenuTriggerProps = track(() => fileMenu.value.getTriggerItemProps(shareMenu.value));

	<>
	<button {...fileMenu.value.getTriggerProps()}>
		{'Click me'}
		<span {...fileMenu.value.getIndicatorProps()}>
			<LuChevronDown />
		</span>
	</button>

	<Portal target={document.body}>
		<div {...fileMenu.value.getPositionerProps()}>
			<ul {...fileMenu.value.getContentProps()}>
				@for (const item of data) {
					<li {...fileMenu.value.getItemProps({ value: item.value })}>{item.label}</li>
				}
				<li {...shareMenuTriggerProps.value}>
					{'Share'}
					<span {...shareMenu.value.getIndicatorProps()}>
						<LuChevronRight />
					</span>
				</li>
			</ul>
		</div>
	</Portal>

	<Portal target={document.body}>
		<div {...shareMenu.value.getPositionerProps()}>
			<ul {...shareMenu.value.getContentProps()}>
				@for (const item of shareMenuData) {
					<li {...shareMenu.value.getItemProps({ value: item.value })}>{item.label}</li>
				}
			</ul>
		</div>
	</Portal>
	</>
}

const data = [
	{ value: 'new', label: 'New File' },
	{ value: 'open', label: 'Open File' },
	{ value: 'save', label: 'Save' },
	{ value: 'export', label: 'Export' },
];

const shareMenuData = [
	{ value: 'email', label: 'Email' },
	{ value: 'copy-link', label: 'Copy Link' },
	{ value: 'social', label: 'Social Media' },
	{ value: 'print', label: 'Print' },
];
