import * as tree from '@zag-js/tree-view';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';
import { trackSplit } from '../../lib/track-split';
import { LuFile, LuFolder, LuChevronRight } from '../../lib/lucide-icons.tsrx';

export function TreeView() @{
	let service = useMachine(tree.machine, {
		id: 'tree-view',
		collection,
	});
	let api = track(() => tree.connect(service, normalizeProps));

	<>
	<div {...api.value.getRootProps()}>
		<h3 {...api.value.getLabelProps()}>{"My Documents"}</h3>
		<div data-scope="tree-view" data-part="controls">
			<button 
				data-scope="tree-view" 
				data-part="trigger"
				onClick={() => api.value.collapse()}
			>
				{"Collapse All"}
			</button>
			<button 
				data-scope="tree-view" 
				data-part="trigger"
				onClick={() => api.value.expand()}
			>
				{"Expand All"}
			</button>
		</div>
		<div {...api.value.getTreeProps()}>
			@if (collection.rootNode.children) {
				@for (const node of collection.rootNode.children; index nodeIndex) {
					<TreeNode
						node={node}
						indexPath={[nodeIndex]}
						api={api.value}
					/>
				}
			}
		</div>
	</div>
	</>
}


const collection = tree.collection({
	nodeToValue: (node) => node.id,
	nodeToString: (node) => node.name,
	rootNode: {
		id: "ROOT",
		name: "",
		children: [
			{
				id: "node_modules",
				name: "node_modules",
				children: [
					{ id: "node_modules/zag-js", name: "zag-js" },
					{ id: "node_modules/zag-ripple", name: "zag-ripple" },
					{ id: "node_modules/ripple", name: "ripple" },
					{
						id: "src/lib/lucide-icons.tsrx",
						name: "lucide-icons.tsrx",
						children: [
							{ id: "src/lib/lucide-icons.tsrx#icon", name: "Icon" },
							{ id: "src/lib/lucide-icons.tsrx#exports", name: "exports" },
						],
					},
				],
			},
			{
				id: "src",
				name: "src",
				children: [
					{ id: "src/App.tsrx", name: "App.tsrx" },
					{ id: "src/Layout.tsrx", name: "Layout.tsrx" },
					{
						id: "src/components",
						name: "components",
						children: [
							{ id: "src/components/Button.tsrx", name: "Button.tsrx" },
							{ id: "src/components/Card.tsrx", name: "Card.tsrx" },
						],
					},
					{ id: "src/index.ts", name: "index.ts" },
				],
			},
			{ id: "vite.config.js", name: "vite.config.js" },
			{ id: "package.json", name: "package.json" },
			{ id: "tsconfig.json", name: "tsconfig.json" },
			{ id: "README.md", name: "README.md" },
		],
	},
});


function TreeNode(props) @{
    let [indexPath, node, api] = trackSplit(props, ['indexPath', 'node', 'api']);
	let nodeProps = track(() => ({ indexPath: indexPath.value, node: node.value }));
	let treeApi = track(() => api.value);
    let nodeState = track(() => treeApi.value.getNodeState(nodeProps.value));

	<>
	@if (nodeState.value.isBranch) {
		<div {...treeApi.value.getBranchProps(nodeProps.value)}>
			<div {...treeApi.value.getBranchControlProps(nodeProps.value)}>
				<LuFolder size={16} />
				<span {...treeApi.value.getBranchTextProps(nodeProps.value)}>{node.value.name}</span>
				<span {...treeApi.value.getBranchIndicatorProps(nodeProps.value)}>
					<LuChevronRight size={16} />
				</span>
			</div>
			<div {...treeApi.value.getBranchContentProps(nodeProps.value)}>
				<div {...treeApi.value.getBranchIndentGuideProps(nodeProps.value)} />
				@if (node.value.children) {
					@for (const childNode of node.value.children; index childIndex) {
						let newIndexPath = [...indexPath.value, childIndex];
						<TreeNode
							node={childNode}
							indexPath={newIndexPath}
							api={treeApi.value}
						/>
					}
				}
			</div>
		</div>
	} @else {
		<div {...treeApi.value.getItemProps(nodeProps.value)}>
			<LuFile size={16} />
			{node.value.name}
		</div>
	}
	</>
}
