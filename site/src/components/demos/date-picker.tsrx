import * as datePicker from '@zag-js/date-picker';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track, Portal } from 'ripple';
import { CalendarDays, ChevronLeft, ChevronRight } from '../../lib/lucide-icons.tsrx';

export function DatePicker() {
	let service = useMachine(datePicker.machine, {
		id: 'date-picker',
		locale: 'en-US',
		selectionMode: 'single',
	});
	let api = track(() => datePicker.connect(service, normalizeProps));

	return <>
	<div {...api.value.getControlProps()}>
		<input {...api.value.getInputProps()} />
		<button {...api.value.getTriggerProps()}>
			<CalendarDays />
		</button>
	</div>
	<Portal target={document.body}>
		<div {...api.value.getPositionerProps()}>
			<div {...api.value.getContentProps()}>
				<div hidden={api.value.view !== 'day'}>
					<div {...api.value.getViewControlProps({ view: 'year' })}>
						<button {...api.value.getPrevTriggerProps()}>
							<ChevronLeft />
						</button>
						<button {...api.value.getViewTriggerProps()}>{api.value.visibleRangeText.start}</button>
						<button {...api.value.getNextTriggerProps()}>
							<ChevronRight />
						</button>
					</div>

					<table {...api.value.getTableProps({ view: 'day' })}>
						<thead {...api.value.getTableHeaderProps({ view: 'day' })}>
							<tr {...api.value.getTableRowProps({ view: 'day' })}>
								for (let day of api.value.weekDays) {
									<th scope="col" aria-label={day.long}>{day.narrow}</th>
								}
							</tr>
						</thead>
						<tbody {...api.value.getTableBodyProps({ view: 'day' })}>
							for (let week of api.value.weeks) {
								<tr {...api.value.getTableRowProps({ view: 'day' })}>
									for (let value of week) {
										<td {...api.value.getDayTableCellProps({ value })}>
											<div {...api.value.getDayTableCellTriggerProps({ value })}>{value.day}</div>
										</td>
									}
								</tr>
							}
						</tbody>
					</table>
				</div>

				<div style={{display: 'flex', gap: '40px'}}>
					<div hidden={api.value.view !== 'month'} style={{width: '100%'}}>
						<div {...api.value.getViewControlProps({ view: 'month' })}>
							<button {...api.value.getPrevTriggerProps({ view: 'month' })}>
								<ChevronLeft />
							</button>
							<button {...api.value.getViewTriggerProps({ view: 'month' })}>
								{api.value.visibleRange.start.year}
							</button>
							<button {...api.value.getNextTriggerProps({ view: 'month' })}>
								<ChevronRight />
							</button>
						</div>

						<table {...api.value.getTableProps({ view: 'month', columns: 4 })}>
							<tbody {...api.value.getTableBodyProps({ view: 'month' })}>
								for (let months of api.value.getMonthsGrid({ columns: 4, format: 'short' })) {
									<tr {...api.value.getTableRowProps()}>
										for (let month of months) {
											<td {...api.value.getMonthTableCellProps({ ...month, columns: 4 })}>
												<div {...api.value.getMonthTableCellTriggerProps({ ...month, columns: 4 })}>
													{month.label}
												</div>
											</td>
										}
									</tr>
								}
							</tbody>
						</table>
					</div>

					<div hidden={api.value.view !== 'year'} style={{width: '100%'}}>
						<div {...api.value.getViewControlProps({ view: 'year' })}>
							<button {...api.value.getPrevTriggerProps({ view: 'year' })}>
								<ChevronLeft />
							</button>
							<span>
								{api.value.getDecade().start}
								{' - '}
								{api.value.getDecade().end}
							</span>
							<button {...api.value.getNextTriggerProps({ view: 'year' })}>
								<ChevronRight />
							</button>
						</div>

						<table {...api.value.getTableProps({ view: 'year', columns: 4 })}>
							<tbody {...api.value.getTableBodyProps()}>
								for (let years of api.value.getYearsGrid({ columns: 4 })) {
									<tr {...api.value.getTableRowProps({ view: 'year' })}>
										for (let year of years) {
											<td {...api.value.getYearTableCellProps({ ...year, columns: 4 })}>
												<div {...api.value.getYearTableCellTriggerProps({ ...year, columns: 4 })}>
													{year.label}
												</div>
											</td>
										}
									</tr>
								}
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</div>
	</Portal>
	</>
}
