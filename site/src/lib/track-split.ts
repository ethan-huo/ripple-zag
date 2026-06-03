export function trackSplit<T extends Record<string, any>, K extends keyof T>(props: T, keys: K[]) {
  return keys.map((key) => ({
    get value() {
      return props[key]
    },
    set value(value) {
      props[key] = value
    },
  }))
}
