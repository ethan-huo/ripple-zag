export function Kbd({ children }:any) {
    return <>
    <kbd class="font-mono inline-flex h-5 items-center rounded-full border border-border bg-card px-1.5 text-[0.75rem] leading-none text-muted-foreground">
        {children}
    </kbd>
    </>
}
