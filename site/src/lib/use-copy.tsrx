import { track } from "ripple";


export function useCopy() {
    let copied = track(false)

    function copy(text: string) {
        navigator.clipboard.writeText(text);
        copied.value = true
        setTimeout(() => copied.value = false, 2000);
    }
    
    return [copy, copied]
}