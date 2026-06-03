
import { Page } from './Page.tsrx';
import { Components } from './Components.tsrx';
import { Component } from './Component.tsrx';
import { NotFound } from './NotFound.tsrx';
import * as routing from "routing-machine"
import { useMachine, normalizeProps } from "zag-ripple"
import { track } from "ripple"
import { RouteContext } from "./lib/route-context"
import { Navigation } from "./components/navigation.tsrx";

export function Layout() {
	const service = useMachine(routing.machine, {
		id: "router",
		routes: [
			{ path: "/", name: "home" },
			{ path: "/components", name: "components" },
			{ path: "/components/:id", name: "component" },
			{ path: "*", name: "not-found" },
		],
	})
	const router = track(() => routing.connect(service, normalizeProps))

	RouteContext.set(router)

	return <>
	<div class="fixed inset-0 grid-pattern opacity-50 -z-10" />
	<div class="min-h-screen">

		if(router.value.currentRouteName === "home") {
			<Page />
		} 
		
		if(router.value.currentRouteName === "components") {
			<Components />
		} 

		if(router.value.currentRouteName === "component") {
			<Component />
		}

		if(router.value.currentRouteName === "not-found") {
			<Navigation />
			<NotFound />
		}
	</div>
	</>
}