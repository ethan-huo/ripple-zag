
import { Card } from './/ui/card.tsrx';
import apiJson from "@zag-js/docs"
import { track } from 'ripple';

export function ContextTable({id}:any) {
    const data = track(() => apiJson[id]["context"])
    const entries = track(() => Object.entries(data.value))

    return <>
    <section class="mb-12">
        <h2 class="mb-4 text-[1.3125rem] font-bold">{"Context"}</h2>
        <Card class="p-5">
            <div class="overflow-x-auto">
                <table class="w-full text-sm">
                    <thead>
                        <tr class="border-b border-border">
                            <th class="text-left py-2 font-semibold">{"Prop"}</th>
                            <th class="text-left py-2 font-semibold">{"Description"}</th>
                            <th class="text-left py-2 font-semibold">{"Type"}</th>
                        </tr>
                    </thead>
                    <tbody>
                        for (const item of entries.value) {
                            let [name, prop] = item;
                                <tr
                                    class='not-last:border-b border-border'
                                >
                                    <td class="py-2 font-mono min-w-50 text-primary">{name}</td>
                                    <td class="py-2 pr-4">{prop.description}</td>
                                    <td class="py-2 font-mono text-muted-foreground">
                                    {prop.type}
                                    </td>
                                </tr>
                        }
                    </tbody>
                </table>
            </div>
        </Card>
  </section>
    </>
}
