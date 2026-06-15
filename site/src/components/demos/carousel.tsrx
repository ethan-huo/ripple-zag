import * as carousel from '@zag-js/carousel';
import { normalizeProps, useMachine } from 'zag-ripple';
import { track } from 'ripple';
import { LuChevronLeft, LuChevronRight } from '../../lib/lucide-icons.tsrx';

const items = [
  "https://tinyurl.com/dd44dvue",
  "https://tinyurl.com/2s3pzdvd",
  "https://tinyurl.com/bdffcbjr",
  "https://tinyurl.com/4hpw7nmf",
  "https://tinyurl.com/7ksvxfjh",
]
export function Carousel() @{
	let service = useMachine(carousel.machine, {
		id: 'carousel',
        slideCount: items.length,
	});
	let api = track(() => carousel.connect(service, normalizeProps));

    <>
    <div {...api.value.getRootProps()}>
        <div {...api.value.getItemGroupProps()}>
            @for(const image of items; index index) {
                <div {...api.value.getItemProps({ index })}>
                    <img src={image} alt={`Slide Image ${index}`} />
                </div>
            }
        </div>

        <div {...api.value.getControlProps()}>
        <button {...api.value.getPrevTriggerProps()}>
            <LuChevronLeft />
        </button>
        <div {...api.value.getIndicatorGroupProps()}>
            @for(const _ of api.value.pageSnapPoints; index index) {
                <button {...api.value.getIndicatorProps({ index })} />
            }
        </div>
        <button {...api.value.getNextTriggerProps()}>
            <LuChevronRight />
        </button>
        </div>
    </div>
    </>
}