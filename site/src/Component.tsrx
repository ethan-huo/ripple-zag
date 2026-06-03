import { Navigation } from './components/navigation.tsrx';
import { OpenInStackblitz } from './components/open-in-stackblitz.tsrx';
import { Usage } from './components/usage.tsrx';
import { Code as CodeBlock } from './components/code.tsrx';
import { ContextTable } from './components/context-table.tsrx';
import { ApiTable } from './components/api-table.tsrx';
import { KeyboardInteractions } from './components/keyboard-interactions.tsrx';
import { DataAttributes } from './components/data-attributes.tsrx';
import { CSSVariables } from './components/css-variables.tsrx';
import { ComponentDemo } from './components/component-demo.tsrx';
import { Button } from './components/ui/button.tsrx';
import { Card } from './components/ui/card.tsrx';
import { components } from './lib/components';
import {
    ArrowLeft,
    Copy,
    Code,
    ChevronLeft,
    ChevronRight,
    ExternalLink,
    FileText,
    Check,
  } from "./lib/lucide-icons.tsrx";
import { useCopy } from "./lib/use-copy.tsrx";
import apiJson from "@zag-js/docs"
import * as demos from './components/demos/index.tsrx';
import { RouteContext } from "./lib/route-context";
import { track } from "ripple";

export function Component() {
    const router = RouteContext.get()
    
    const componentId = track(() => router.value.location.params.id)
    const currentIndex = track(() => components.findIndex((comp) => comp.id === componentId.value))
    const comp = track(() => components[currentIndex.value])
    const prevComponent = track(() => currentIndex.value > 0 ? components[currentIndex.value - 1] : null)
    const nextComponent = track(() => currentIndex.value < components.length - 1 ? components[currentIndex.value + 1] : null)

    return <>
    <head>
        <title>{`${comp.value.label} | ZagRipple`}</title>
    </head>

    <Navigation />

    <main class="mx-auto max-w-[48rem] px-6 py-10">
        // Breadcrumb
        <div class="mb-8 flex items-center gap-2 text-sm text-muted-foreground">
            <a {...router.value.getLinkProps({ to: '/components' })} class="hover:text-foreground">
                {'Components'}
            </a>
            <span>{'/'}</span>
            <span class="text-foreground">{comp.value.label}</span>
        </div>


        // Header
        <div class="mb-12">
        <div class="mb-6 flex items-center gap-4">
            <a {...router.value.getLinkProps({ to: '/components' })}>
            <Button variant="ghost" size="sm">
                <ArrowLeft class="h-4 w-4 mr-2" />
                {"Back to Components"}
            </Button>
            </a>
        </div>

        <h1 class="mb-3 text-[2.125rem] font-bold leading-tight">{comp.value.label}</h1>
        <p class="mb-8 text-[1rem] leading-7 text-muted-foreground">
            {comp.value.description}
        </p>

        // Component Demo
        <div class="mb-8 space-y-4">

            // Demo Badges
            <div class="flex flex-wrap gap-2">
                <OpenInStackblitz id={componentId.value} />

            
            <Button
                href={`https://zagjs.com/components/react/${componentId.value}`}
                target="_blank"
                variant="outline"
                size="sm"
                data-id="zag-docs"
                >
                    <FileText class="h-3 w-3 mr-1.5" />
                    {"Zag.js Docs"}
                    <ExternalLink class="h-3 w-3 ml-1.5" />
                </Button>

            
            <Button
                href={`https://github.com/chakra-ui/zag/blob/main/packages/machines/${componentId.value}/src/${componentId.value}.machine.ts`}
                target="_blank"
                variant="outline"
                size="sm"
                data-id="view-source"
                >
                    <Code class="h-3 w-3 mr-1.5" />
                    {"View Source"}
                    <ExternalLink class="h-3 w-3 ml-1.5" />
                </Button>
            </div>
            <ComponentDemo id={componentId.value} />
        </div>
        </div>

        // Installation
        <section class="mb-12" data-id="installation">
            <h2 class="mb-4 text-[1.3125rem] font-bold">{"Installation"}</h2>
            <Card class="p-4">
                <div class="flex items-center justify-between">
                let [copyInstall, copiedInstall] = useCopy();
                const code = track(() => `npm install zag-ripple zag.value-js/${componentId.value}`);
                <CodeBlock code={code.value} language="bash" />
                <Button variant="ghost" size="sm" onClick={() => copyInstall(code.value)}>
                    if (copiedInstall.value) {
                        <Check class="h-4 w-4" />
                    } else {
                        <Copy class="h-4 w-4" />
                    }
                </Button>
                </div>
            </Card>
        </section>

        // Usage
        <Usage id={componentId.value} />

        if(componentId.value in apiJson) {
            // Context
            <ContextTable id={componentId.value} />
            // API
            <ApiTable id={componentId.value} />
        }

        // Accessibility
        <section class="mb-12">
            <h2 class="mb-4 text-[1.3125rem] font-bold">{'Accessibility'}</h2>

            <div class="space-y-6">
                    // Data Attributes
                <DataAttributes id={comp.value.package || componentId.value} />

                    // CSS Variables
                <CSSVariables id={comp.value.package || componentId.value} />

                    // Keyboard Interactions
                <KeyboardInteractions id={comp.value.package || componentId.value} />
            </div>
        </section>

        // Navigation
        <section>
            <div class="flex justify-between items-center">
                if (prevComponent.value) {
                    <a {...router.value.getLinkProps({ to: `/components/${prevComponent.value.id}` })} class="mr-auto">
                        <Button
                            variant="outline"
                            size="lg"
                            class="flex items-center gap-3 px-6 py-4 h-auto cursor-pointer"
                        >
                            <ChevronLeft class="h-5 w-5" />
                            <div class="text-left">
                            <div class="text-sm text-muted-foreground">{"Previous"}</div>
                            <div class="font-semibold text-base">{prevComponent.value.label}</div>
                            </div>
                        </Button>
                    </a>
                }
                if (nextComponent.value) {
                    <a {...router.value.getLinkProps({ to: `/components/${nextComponent.value.id}` })} class="ml-auto">
                        <Button
                            variant="outline"
                            size="lg"
                            class="flex items-center gap-3 px-6 py-4 h-auto cursor-pointer"
                        >
                            <div class="text-right">
                            <div class="text-sm text-muted-foreground">{"Next"}</div>
                            <div class="font-semibold text-base">{nextComponent.value.label}</div>
                            </div>
                            <ChevronRight class="h-5 w-5" />
                        </Button>
                    </a>
                }
            </div>
        </section>

    </main> 
    </>
}
