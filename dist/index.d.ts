import { MachineSchema, Machine, Service } from '@zag-js/core';
export { mergeProps } from '@zag-js/core';
import { Tracked } from 'ripple';
import * as _zag_js_types from '@zag-js/types';

type MaybeTracked<T> = {
    [K in keyof T]?: T[K] | Tracked<T[K]>;
};
/**
* UseMachine hook for Ripple JS
* @param machine - The machine to use
* @param userProps - The user props to use
* @returns The service
*/
declare function useMachine<T extends MachineSchema>(machine: Machine<T>, userProps?: MaybeTracked<T["props"]>): Service<T>;

type HTMLAttributes = JSX.IntrinsicElements['head'];
type PropTypes = JSX.IntrinsicElements & {
    element: HTMLAttributes;
    style: Record<string, any>;
};
declare const normalizeProps: _zag_js_types.NormalizeProps<PropTypes>;

export { type PropTypes, normalizeProps, useMachine };
