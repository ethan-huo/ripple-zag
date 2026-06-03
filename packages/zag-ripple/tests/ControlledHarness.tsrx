import { useMachine } from "../src"
import { track } from "ripple"

export default function ControlledHarness({ machine, initialOpen, onReady }: any) {
    let open = track(initialOpen ?? false)

    const service = useMachine(machine, { id: "test", open })

    onReady({
        service,
        setOpen(value: boolean) {
            open.value = value
        },
        getOpen() {
            return open.value
        },
    })
}
