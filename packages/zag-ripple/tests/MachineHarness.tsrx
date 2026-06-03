import { useMachine } from "../src"

export default function MachineHarness({ machine, machineProps, onReady }: any) {
    const service = useMachine(machine, machineProps ?? {})
    onReady(service)
}
