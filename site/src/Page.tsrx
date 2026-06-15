import { Navigation } from './components/navigation.tsrx';
import { HeroSection } from './components/hero-section.tsrx';

export function Page() @{
	<>
	<head>
		<title>{"ZagRipple - Zag.js for Ripple"}</title>
	</head>

	<Navigation noSearch />
	<main>
		<HeroSection />
	</main>
	</>
}