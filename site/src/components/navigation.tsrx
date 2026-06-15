import { Button } from "./ui/button.tsrx";
import { SiGithub } from '../lib/lucide-icons.tsrx';
import { ThemeToggle } from "./theme-toggle.tsrx";
import { SearchDocs } from "./search-docs.tsrx";
import { RouteContext } from "../lib/route-context";
import { track } from "ripple";
import { cn } from "../lib/utils";

export function Navigation({ noSearch }: { noSearch?: boolean }) @{
	const showSearch = track(() => !noSearch)
	const router = RouteContext.get()

	<>
	<nav class="sticky top-0 z-40 border-b border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/80">
	<div class="mx-auto max-w-[89rem] px-6">
        <div class="flex h-12 items-center justify-between">
		<a class='flex items-center gap-2 rounded-md px-2 py-1 -ml-2 hover:bg-muted focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-[-1px]' {...router.value.getLinkProps({ to: '/' })}>
			<img src='https://cdn.jsdelivr.net/gh/ethan-huo/zag-ripple@main/site/src/assets/logo.svg' alt='logo' class='size-7 rounded-sm' />
			<span class='font-semibold text-[0.9375rem]'>{'ZagRipple'}</span>
		</a>

		<div class={cn("hidden md:flex items-center gap-2", !showSearch.value && "[&_[data-scope='combobox']]:hidden!")}>
			<a
				class="rounded-md px-2 py-1 text-sm text-muted-foreground hover:bg-muted hover:text-foreground focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-[-1px]"
				{...router.value.getLinkProps({ to: '/components' })}
			>
				{"Components"}
			</a>
			<a
				class="rounded-md px-2 py-1 text-sm text-muted-foreground hover:bg-muted hover:text-foreground focus-visible:outline-2 focus-visible:outline-ring focus-visible:outline-offset-[-1px]"
				{...router.value.getLinkProps({ to: '/streamdown' })}
			>
				{"Streamdown"}
			</a>
			<SearchDocs />
            <ThemeToggle />
            <Button variant="ghost" size="sm">
			<a href="https://github.com/ethan-huo/zag-ripple" target="_blank">
                <SiGithub class="h-4 w-4" />
			</a>
            </Button>
		</div>
        </div>
	</div>
    </nav>
	</>
}
