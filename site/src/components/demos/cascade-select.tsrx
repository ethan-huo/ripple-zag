import * as cascadeSelect from '@zag-js/cascade-select';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track, Portal } from 'ripple';
import { trackSplit } from '../../lib/track-split';
import { LuChevronDown, LuChevronRight, LuCheck, LuX } from '../../lib/lucide-icons.tsrx';

export function CascadeSelect() @{
	let service = useMachine(cascadeSelect.machine, {
		id: 'cascade-select',
		collection,
	});
	let api = track(() => cascadeSelect.connect(service, normalizeProps));

	<>
	<div {...api.value.getRootProps()}>
		<label {...api.value.getLabelProps()}>{'Location'}</label>
		<div {...api.value.getControlProps()}>
			<button {...api.value.getTriggerProps()}>
				<span>{api.value.valueAsString || 'Select location'}</span>
				<span {...api.value.getIndicatorProps()}>
					<LuChevronDown size={16} />
				</span>
			</button>
			<button {...api.value.getClearTriggerProps()}>
				<LuX size={14} />
			</button>
		</div>
		<Portal target={document.body}>
			<div {...api.value.getPositionerProps()}>
				<div {...api.value.getContentProps()}>
					<TreeNode node={collection.rootNode} indexPath={[]} value={[]} api={api.value} />
				</div>
			</div>
		</Portal>
	</div>
	</>
}

interface TreeNodeProps {
	node: Node;
	indexPath?: number[];
	value?: string[];
	api: cascadeSelect.Api;
}

function TreeNode(props) @{
	let [indexPath, value, node, api] = trackSplit(props, ['indexPath', 'value', 'node', 'api']);
	let cascadeApi = track(() => api.value);
	let nodeProps = track(() => ({ indexPath: indexPath.value, value: value.value, item: node.value }));
	let nodeState = track(() => cascadeApi.value.getItemState(nodeProps.value));
	let children = track(() => collection.getNodeChildren(node.value) || []);

	let highlightedChild = track(() => nodeState.value.highlightedChild);
	let highlightedIndexPath = track(() => [...indexPath.value, nodeState.value.highlightedIndex]);
	let highlightedValue = track(
		() => nodeState.value.highlightedChild
			? [...value.value, collection.getNodeValue(nodeState.value.highlightedChild)]
			: value.value,
	);

	<>
	<ul {...cascadeApi.value.getListProps(nodeProps.value)}>
		@for (const item of children.value; index index) {
			let itemProps = track(
				() => ({
					indexPath: [...indexPath.value, index],
					value: [...value.value, collection.getNodeValue(item)],
					item,
				}),
			);

			let itemState = track(() => cascadeApi.value.getItemState(itemProps.value));

			<li {...cascadeApi.value.getItemProps(itemProps.value)}>
				<span {...cascadeApi.value.getItemTextProps(itemProps.value)}>{item.label}</span>
				@if (itemState.value.hasChildren) {
					<span data-scope="cascade-select" data-part="branch-indicator">
						<LuChevronRight size={14} />
					</span>
				}
				<span {...cascadeApi.value.getItemIndicatorProps(itemProps.value)}>
					<LuCheck size={12} />
				</span>
			</li>
		}
	</ul>
	@if (highlightedChild.value && collection.isBranchNode(highlightedChild.value)) {
		<TreeNode
			node={highlightedChild.value}
			indexPath={highlightedIndexPath.value}
			value={highlightedValue.value}
			api={cascadeApi.value}
		/>
	}
	</>
}

interface Node {
	label: string;
	value: string;
	children?: Node[];
}

const collection = cascadeSelect.collection<Node>(
	{
		nodeToValue: (node) => node.value,
		nodeToString: (node) => node.label,
		nodeToChildren: (node) => node.children ?? [],
		rootNode: {
			label: 'ROOT',
			value: 'ROOT',
			children: [
				{
					label: 'North America',
					value: 'north-america',
					children: [
						{
							label: 'United States',
							value: 'us',
							children: [
								{ label: 'New York', value: 'ny' },
								{ label: 'California', value: 'ca' },
								{ label: 'Texas', value: 'tx' },
							],
						},
						{
							label: 'Canada',
							value: 'ca-country',
							children: [
								{ label: 'Ontario', value: 'on' },
								{ label: 'British Columbia', value: 'bc' },
							],
						},
					],
				},
				{
					label: 'Africa',
					value: 'africa',
					children: [
						{
							label: 'Nigeria',
							value: 'ng',
							children: [
								{ label: 'Lagos', value: 'lagos' },
								{ label: 'Abuja', value: 'abuja' },
							],
						},
						{
							label: 'Kenya',
							value: 'ke',
							children: [
								{ label: 'Nairobi', value: 'nairobi' },
								{ label: 'Mombasa', value: 'mombasa' },
							],
						},
					],
				},
				{
					label: 'Asia',
					value: 'asia',
					children: [
						{
							label: 'Japan',
							value: 'jp',
							children: [
								{ label: 'Tokyo', value: 'tokyo' },
								{ label: 'Osaka', value: 'osaka' },
							],
						},
						{
							label: 'India',
							value: 'in',
							children: [
								{ label: 'Mumbai', value: 'mumbai' },
								{ label: 'Delhi', value: 'delhi' },
							],
						},
					],
				},
			],
		},
	},
);
