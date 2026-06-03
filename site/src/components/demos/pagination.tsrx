import * as pagination from '@zag-js/pagination';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';
import { ChevronLeft, ChevronRight } from '../../lib/lucide-icons.tsrx';

export function Pagination() {
	let service = useMachine(pagination.machine, {
		id: 'pagination',
		count: 1000,
	});
	let api = track(() => pagination.connect(service, normalizeProps));

	return <>
	if (api.value.totalPages > 1) {
		let pageIndex = 0;
		<nav {...api.value.getRootProps()}>
			<ul role="pagination">
				<li>
					<a href="#previous" {...api.value.getPrevTriggerProps()}>
						<ChevronLeft /> <span>{"Previous Page"}</span>
					</a>
				</li>
				for (const page of api.value.pages) {
					if (page.type === "page") {
						<li>
							<a href={`#${page.value}`} {...api.value.getItemProps(page)}>
								{page.value}
							</a>
						</li>
					} else {
						<li>
							<span {...api.value.getEllipsisProps({ index: pageIndex })}>
								{"..."}
							</span>
						</li>
					}
					pageIndex++;
				}
				<li>
					<a href="#next" {...api.value.getNextTriggerProps()}>
						<ChevronRight /> <span>{"Next Page"}</span>
					</a>
				</li>
			</ul>
		</nav>
	}
	</>
}
