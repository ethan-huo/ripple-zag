import { Navigation } from './components/navigation.tsrx';
import { Card } from './components/ui/card.tsrx';
import { Badge } from './components/ui/badge.tsrx';
import { LuSearch } from './lib/lucide-icons.tsrx';
import { components } from './lib/components';
import * as icons from "./components/icons.tsrx";
import { useSearch } from "./lib/use-search.tsrx";
import { track } from "ripple";
import { RouteContext } from "./lib/route-context";

export function Components() @{
    const router = RouteContext.get()
    let searchTerm = track("")
    const results = useSearch(searchTerm, components,
        [
            { name: 'label', weight: 3 },
            { name: 'description', weight: 1 },
        ]
    )

  <>
  <head>
    <title>{"Components | ZagRipple"}</title>
  </head>

  <Navigation noSearch />

  <main class="mx-auto max-w-[89rem] px-6 py-10">
    // Header
    <div class="mb-10 max-w-[48rem]">
      <h1 class="mb-4 text-[2.125rem] font-bold leading-tight">
        <span class="text-primary">{"Components"}</span>
      </h1>
      <p class="mb-6 text-[1rem] leading-7 text-muted-foreground">
        {`Explore our comprehensive collection of accessible, customizable
        components built with Zag.js for Ripple TS.`}
      </p>

      // Search
      <div class="relative max-w-md">
        <LuSearch class="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
        <input
          type="text"
          value={searchTerm.value}
        onInput={(e) => searchTerm.value = (e.target as HTMLInputElement).value}
          placeholder="Search components..."
          class="h-9 w-full rounded-full border border-border bg-card pl-10 pr-4 text-sm outline-none placeholder:text-muted-foreground hover:bg-muted/50 focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-[-1px]"
        />
      </div>
    </div>

    // Components Grid
    <div class="grid grid-cols-1 gap-3 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
        @for (const comp of results.value) {
            const Icon = icons[comp.icon] || icons.defaultIcon;
            <a {...router.value.getLinkProps({ to: `/components/${comp.id}` })}>
                <Card class="group relative cursor-pointer overflow-hidden p-4 transition-colors hover:bg-muted/40">
            // Edge line keeps cards aligned with the Base UI docs grid language.
            <div class="absolute inset-x-0 top-0 h-px bg-border" />

            // Content
            <div class="relative">
              // Icon
              <div class="mb-4 w-fit rounded-md border border-border bg-background p-2 transition-colors group-hover:bg-card">
              <Icon class="w-6 h-6 text-primary" />
              </div>

              // Header
              <div class="flex items-center justify-between mb-3">
                <h3 class="text-base font-semibold transition-colors group-hover:text-primary">
                  {comp.label}
                </h3>
                @if (comp.beta) {
                  <Badge
                    variant="secondary"
                    class="border-border bg-card text-xs text-muted-foreground"
                  >
                    {'Beta'}
                  </Badge>
                }
              </div>

              // Description
              <p class="text-sm leading-relaxed text-muted-foreground">
                {comp.description}
              </p>

              // Arrow indicator
              <div class="mt-4 flex items-center text-xs text-muted-foreground transition-colors group-hover:text-primary">
                <span>{'View docs'}</span>
                <svg
                  class="w-3 h-3 ml-1 transform group-hover:translate-x-1 transition-transform duration-300"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M9 5l7 7-7 7"
                  />
                </svg>
              </div>
            </div>
          </Card>
        </a>
        }
    </div>

    // Stats
    <div class="mt-12">
      <div class="inline-flex items-center gap-8 rounded-md border border-border bg-card px-5 py-3">
        <div>
          <div class="text-2xl font-bold text-primary">
            {components.length}
          </div>
          <div class="text-sm text-muted-foreground">{'Components'}</div>
        </div>
        <div class="w-px h-8 bg-border" />
        <div>
          <div class="text-2xl font-bold text-primary">{'100%'}</div>
          <div class="text-sm text-muted-foreground">{'Accessible'}</div>
        </div>
        <div class="w-px h-8 bg-border" />
        <div>
          <div class="text-2xl font-bold text-primary">{'TypeScript'}</div>
          <div class="text-sm text-muted-foreground">{'First-class'}</div>
        </div>
      </div>
    </div>
  </main>
  </>
}
