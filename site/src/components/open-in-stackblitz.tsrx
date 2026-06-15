import { Button } from './ui/button.tsrx';
import { LuPlay, LuExternalLink } from '../lib/lucide-icons.tsrx';
import sdk from '@stackblitz/sdk';
import { components } from '../lib/components';
import { getComponentCode } from '../lib/get-component-code';
import { toPascalCase } from '../lib/get-component-code';
import { getComponentStyles } from '../lib/get-component-styles';
import lucideIcons from '../lib/lucide-icons.tsrx?raw';

export function OpenInStackblitz({ id }: { id: string }) @{
	<>
	<Button data-id='stackblitz' onClick={() => openInStackblitz(id)} variant='outline' size='sm'>
		<LuPlay class='h-3 w-3 mr-1.5' />
		{'Open in StackBlitz'}
		<LuExternalLink class='h-3 w-3 ml-1.5' />
	</Button>
	</>
}

function openInStackblitz(id: string) {
	const comp = components.find(comp => comp.id === id);
	sdk.openProject({
		title: 'Zag Ripple - ' + comp.label,
		description: comp.description,
		template: 'node',
		files: {
			[`src/${toPascalCase(id)}.tsrx`]: getComponentCode(id),
			'src/lib/lucide-icons.tsrx': lucideIcons,
			'src/index.ts': getIndexTS(id),
			'src/styles.css': getStylesCSS(comp.package ?? id),
			'index.html': indexHtml(comp.label),
			'package.json': packageJson(id),
			'tsrx.d.ts': `declare module '*.tsrx';`,
			'vite.config.js': viteConfig,
			'tsconfig.json': JSON.stringify(tsConfig),
		},
	}, {
		openFile: `src/index.ts,src/${toPascalCase(id)}.tsrx`,
		showSidebar: false,
		newWindow: true,
	});
}

const getStylesCSS = (id: string) => {
	const tw = `@import 'tailwindcss';
@import 'tw-animate-css';`;

	const theme = getComponentStyles('theme');
	const componentStyles = getComponentStyles(id);
	return `${tw}\n${theme}\n${componentStyles}`;
};

const getIndexTS = (id: string) => `import { mount } from 'ripple';
import { ${toPascalCase(id)} } from './${toPascalCase(id)}.tsrx';
import './styles.css';

mount(${toPascalCase(id)}, {
	target: document.getElementById('root'),
});`;

const indexHtml = (label: string) => {
	return `<!doctype html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1" />
		<meta name="theme-color" content="#000000" />
		<title>Zag Ripple - ${label}</title>
	</head>
	<body>
		<noscript>You need to enable JavaScript to run this app.</noscript>
		<div id="root"></div>

		<script src="/src/index.ts" type="module"></script>
	</body>
</html>
`;
};

const packageJson = (id: string) => JSON.stringify({
	'name': `zag-ripple-${id}-demo`,
	'version': '0.0.0',
	'description': '',
	'type': 'module',
	'engines': {
		'node': '>=20.0.0',
	},
	'scripts': {
		'start': 'vite',
		'dev': 'vite',
		'build': 'vite build',
		'serve': 'vite preview',
		'format': 'prettier --write .',
		'format:check': 'prettier --check .',
	},
	'license': 'MIT',
	'devDependencies': {
		'prettier': 'latest',
		'@tsrx/prettier-plugin': 'latest',
		'typescript': '^5.9.2',
		'vite': '^7.1.4',
		'@ripple-ts/vite-plugin': 'latest',
	},
	'dependencies': {
		[`@zag-js/${id}`]: 'latest',
		'@zag-js/i18n-utils': 'latest',
		'ripple': 'latest',
		'zag-ripple': 'latest',
		'tailwindcss': '^4.1.9',
		"tw-animate-css": "1.3.3",
		"@tailwindcss/vite": "^4.1.13",
	},
}, null, 2);

const tsConfig = {
	'compilerOptions': {
		'target': 'ESNext',
		'module': 'ESNext',
		'lib': ['ES2022', 'DOM', 'DOM.Iterable'],
		'allowSyntheticDefaultImports': true,
		'esModuleInterop': true,
		'moduleResolution': 'bundler',
		'jsx': 'preserve',
		'jsxImportSource': 'ripple',
		'noEmit': true,
		'isolatedModules': true,
	},
};

const viteConfig = `import { defineConfig } from 'vite';
import { ripple } from '@ripple-ts/vite-plugin';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
	plugins: [ripple(), tailwindcss()],
	server: {
		port: 3000,
	},
	build: {
		target: 'esnext',
	},
});`;
