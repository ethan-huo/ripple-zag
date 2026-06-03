import { Code as CodeBlock } from './/code.tsrx';
import { Card } from './ui/card.tsrx';
import { getComponentCode } from '../lib/get-component-code';
import { track } from 'ripple';

export function Usage({ id }: { id: string }) {
	const code = track(() => getComponentCode(id));

	return <>
	<section class='mb-12' data-id="usage">
		<h2 class='mb-4 text-[1.3125rem] font-bold'>{'Usage'}</h2>
		<Card class='p-6 bg-muted/50'><CodeBlock code={code.value} language='jsx' /></Card>
	</section>
	</>
}