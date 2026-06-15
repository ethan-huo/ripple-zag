import * as pagination from '@zag-js/pagination';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';
import { LuChevronLeft, LuChevronRight } from '../../lib/lucide-icons.tsrx';

export function Pagination() @{
	let service = useMachine(pagination.machine, {
		id: 'pagination',
		count: 1000,
	});
	let api = track(() => pagination.connect(service, normalizeProps));

	<>
	@if (api.value.totalPages > 1) {
		<nav {...api.value.getRootProps()}>
			<ul role="pagination">
				<li>
					<a href="#previous" {...api.value.getPrevTriggerProps()}>
						<LuChevronLeft /> <span>{"Previous Page"}</span>
					</a>
				</li>
				@for (const page of api.value.pages; index index; key page.value) {
					@if (page.type === "page") {
						<li>
							<a href={`#${page.value}`} {...api.value.getItemProps(page)}>
								{page.value}
							</a>
						</li>
					} @else {
						<li>
							<span {...api.value.getEllipsisProps({ index })}>
								{"..."}
							</span>
						</li>
					}
				}
				<li>
					<a href="#next" {...api.value.getNextTriggerProps()}>
						<LuChevronRight /> <span>{"Next Page"}</span>
					</a>
				</li>
			</ul>
		</nav>
	}
	</>
}
