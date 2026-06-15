import { cva, type VariantProps } from 'class-variance-authority'
import { cn } from "../../lib/utils";
import { RouteContext } from "../../lib/route-context";


export const buttonVariants = cva(
  "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-colors disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 shrink-0 [&_svg]:shrink-0 outline-none focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-[-1px] aria-invalid:border-destructive",
  {
    variants: {
      variant: {
        default:
          'bg-primary text-primary-foreground hover:bg-primary/90',
        destructive:
          'bg-destructive text-destructive-foreground hover:bg-destructive/90',
        outline:
          'border border-border bg-card hover:bg-muted',
        secondary:
          'bg-secondary text-secondary-foreground hover:bg-muted',
        ghost:
          'hover:bg-muted',
        link: 'text-primary underline-offset-4 hover:underline',
      },
      size: {
        default: 'h-8 px-3 py-1.5 has-[>svg]:px-2.5',
        sm: 'h-7 rounded-md gap-1.5 px-2.5 text-xs has-[>svg]:px-2',
        lg: 'h-9 rounded-md px-4 has-[>svg]:px-3',
        icon: 'size-8',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  },
)

export function Button({
    class: className,
    variant,
    size,
    children,
    href,
    target,
    ...props
}:any) @{

  const router = RouteContext.get()

    <>
    @if (href) {
            <a
                class={cn(buttonVariants({ variant, size }), className)}
                {...target === "_blank" ? { href } : router.value.getLinkProps({ to: href })}
                target={target}
                {...props}
            >
            {children}
            </a>
    } @else {
        <button
            class={cn(buttonVariants({ variant, size }), className)}
            {...props}
        >
            {children}
        </button>
    }

    </>
}
