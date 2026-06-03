
import { codeToHtml } from 'https://esm.sh/shiki@3.0.0'
import { cn } from '../lib/utils'

export function Code({code, language, ...rest}:any) {

	const divRef = async (node) => {
		const html = await codeToHtml(code, {
			lang: language,
			themes: { 
				light: 'min-light',
				dark: 'vitesse-dark',
			  }
		});
		node.innerHTML = html;
	};
    
    return <>
    <div ref={divRef} data-code="" {...rest}  />
    </>
}
