import { Card } from './/ui/card.tsrx';
import { getAccessibilityDoc } from "@zag-js/docs"
import { LuKeyboard } from '../lib/lucide-icons.tsrx';
import { Kbd } from './ui/kbd.tsrx';
import { Fragment, track } from 'ripple';

export function KeyboardInteractions({id}:any) @{
  
  <>
  @try {
    const data = track(() => getAccessibilityDoc(id))
    @if(data.value.keyboard) {
    <Card class="p-5">
      <div class="flex items-center gap-2 mb-4">
        <LuKeyboard class="h-4 w-4 text-primary" />
        <h3 class="text-base font-semibold">{'Keyboard Interactions'}</h3>
      </div>
      <div class="overflow-x-auto">
        <table class="w-full text-sm">
          <thead>
            <tr class="border-b border-border">
              <th class="text-left py-2 font-semibold">{"Key"}</th>
              <th class="text-left py-2 font-semibold">
                {'Description'}
              </th>
            </tr>
          </thead>
          <tbody>
            @for(const item of data.value.keyboard) {
              <tr class='not-last:border-b border-border'>
                <td class="py-2 flex gap-2 items-center">
                  @for(const key of item.keys) {
                    <Kbd>
                      {key}
                    </Kbd>
                  }
                </td>
                <td class="py-2"><Fragment innerHTML={item.description} /></td>
              </tr>
            }
          </tbody>
        </table>
        </div>
      </Card>
    }
  } @catch  {
    
  }
  </>
}
