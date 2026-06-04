import { Button } from './ui/button.tsrx';
import { ArrowRight, Sparkles, Zap, CodeXml, Check } from '../lib/lucide-icons.tsrx';
import { useCopy } from '../lib/use-copy.tsrx';

export function HeroSection() {
	let [copy, copied] = useCopy();

	return <>
	// Announcement Badge
	<section class="relative flex min-h-[calc(100vh-3rem)] items-center">
		// Main Heading
		<div class="relative mx-auto max-w-[48rem] px-6 text-left">
			<div
				class="mb-6 inline-flex items-center gap-2 rounded-full border border-border bg-card px-3 py-1 text-sm text-muted-foreground"
			>
				<Sparkles class="h-4 w-4" />
				<span>{'Built with Zag.js • Headless • Accessible'}</span>
			</div>

			<h1 class="mb-5 text-[2.625rem] font-bold leading-[1.05] text-balance md:text-[3.75rem]">
				<span class="text-primary">{'ZagRipple'}</span>

				<br />
				{'Component Library'}
			</h1>

			// Subtitle
			<p class="mb-8 max-w-[42rem] text-[1.125rem] leading-7 text-muted-foreground text-balance">
				{`Beautiful, accessible, and performant UI components for Ripple TS.
          Built with Zag.js for maximum flexibility and developer experience.`}
			</p>

			// CTA Buttons
			<div class="mb-12 flex flex-col gap-3 sm:flex-row sm:items-center">
				<Button size="lg" href="/components">
					{'Browse Components'}
					<ArrowRight class="ml-2 h-5 w-5" />
				</Button>
				<Button size="lg" href="/streamdown" variant="outline">
					{'Streamdown Playground'}
					<ArrowRight class="ml-2 h-5 w-5" />
				</Button>
				// Installation Command

				<div
					class="inline-flex h-9 items-center gap-3 rounded-md border border-border bg-card px-3 font-mono text-sm"
				>
					<span class="text-muted-foreground">{'$'}</span>

					<span>{'npm install zag-ripple'}</span>
					<Button
						variant="ghost"
						size="sm"
						class="h-6 w-6 p-0"
						onClick={() => copy('npm install zag-ripple')}
					>
						if (copied.value) {
							<Check class="h-3 w-3" />
						} else {
							<CodeXml class="h-3 w-3" />
						}
					</Button>
				</div>
			</div>

			// Feature Icons
			<div class="flex flex-wrap items-center gap-x-8 gap-y-3 border-t border-border pt-6 text-muted-foreground">
				<div class="flex items-center gap-2">
					<Zap class="h-5 w-5 text-primary" />
					<span class="text-sm">{'Lightning Fast'}</span>
				</div>
				<div class="flex items-center gap-2">
					<Sparkles class="h-5 w-5 text-primary" />
					<span class="text-sm">{'Fully Accessible'}</span>
				</div>
				<div class="flex items-center gap-2">
					<CodeXml class="h-5 w-5 text-primary" />
					<span class="text-sm">{'Developer First'}</span>
				</div>
			</div>
			</div>
		</section>
	</>
	}
