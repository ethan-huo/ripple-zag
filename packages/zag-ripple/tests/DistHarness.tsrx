import { useMachine } from "../dist/index.mjs"

export default function DistHarness({ machine, machineProps, onReady }: any) {
    const service = useMachine(machine, machineProps ?? {})
    onReady(service)
}
