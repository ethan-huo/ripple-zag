import { Card } from './/ui/card.tsrx';
import { } from "@zag-js/docs"
import { getCssVarDoc } from "@zag-js/docs"
import { Kbd } from './ui/kbd.tsrx';
import { track } from 'ripple';

export function CSSVariables({id}:any) {
  return <>
  try {
    const data = track(() => getCssVarDoc(id))
    <Card class="p-5">
        <h3 class="text-base font-semibold mb-4">{'CSS Variables'}</h3>
        <div class="space-y-6">
          if(data.value){
            for(const [part, vars] of Object.entries(data.value)) {
                <div>
                    <h4 class="font-semibold mb-3 text-sm">{part}</h4>
                    <div class="overflow-x-auto">
                        <table class="w-full text-sm">
                            <thead>
                                <tr class="border-b border-border">
                                  <th class="text-left py-2 font-semibold w-48">
                                    {"Variable"}
                                  </th>
                                  <th class="text-left py-2 font-semibold">
                                    {"Description"}
                                  </th>
                                </tr>
                              </thead>
                              <tbody>
                                for(const [key, value] of Object.entries(vars).filter(([_key, value]) => value !== "")) {
                                    <tr class="not-last:border-b border-border">
                                        <td class="py-2 font-mono w-48"><Kbd>{key}</Kbd></td>
                                        <td class="py-2">{value}</td>
                                    </tr>
                                }
                              </tbody>
                        </table>
                    </div>    
                </div>
            }
          }
        </div>
    </Card>
  } catch (error) {
  }
  </>
}