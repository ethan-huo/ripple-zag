import * as demos from './demos/index.tsrx';
import { track } from 'ripple';

function toCamelCase(str: string): string {
    if(!str) throw new Error('Invalid Component');
    return str.replace(/-([a-z])/g, (_, letter) => letter.toUpperCase())
}

export function ComponentDemo({id}) {
    const Demo = track(() => demos[toCamelCase(id)]);


    return <>
    if (Demo) {
        <div class="flex min-h-36 flex-wrap items-center rounded-md border border-border bg-card p-6 shadow-[var(--shadow-1)]">
            <@Demo />
        </div>
    }
    </>
}
