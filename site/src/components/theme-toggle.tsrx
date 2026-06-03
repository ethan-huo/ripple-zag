import { Button } from "./ui/button.tsrx";
import { effect, track } from "ripple";
import { Moon, Sun } from "../lib/lucide-icons.tsrx";

export function ThemeToggle() {
    let theme = track("dark")

    effect(() => {
        const savedTheme = localStorage.getItem("theme");
        const prefersDark = window.matchMedia(
            "(prefers-color-scheme: dark)"
        ).matches;
        const initialTheme = savedTheme || (prefersDark ? "dark" : "light");
        theme.value = initialTheme
        applyTheme(initialTheme)

        // Listen for system theme changes
        const mediaQuery = window.matchMedia("(prefers-color-scheme: dark)");
        const handleChange = (e: MediaQueryListEvent) => {
            if (!localStorage.getItem("theme")) {
                const systemTheme = e.matches ? "dark" : "light";
                theme.value = systemTheme
                applyTheme(systemTheme)
            }
        };

        mediaQuery.addEventListener("change", handleChange);
        return () => mediaQuery.removeEventListener("change", handleChange);
    })

    function applyTheme(newTheme: "light" | "dark") {
        const root = document.documentElement;
        if (newTheme === "dark") {
            root.classList.add("dark");
        } else {
            root.classList.remove("dark");
        }
    }

    function toggleTheme() {
        const newTheme = theme.value === "light" ? "dark" : "light";
        theme.value = newTheme
        localStorage.setItem("theme", newTheme)
        applyTheme(newTheme)
    }

    return <>
    <Button variant="ghost" size="sm" class="w-8 h-8 p-0" onClick={toggleTheme} >
        if (theme.value === "light") {
            <Sun class="w-4 h-4 transition-transform hover:scale-110" />
        } else {
            <Moon class="w-4 h-4 transition-transform hover:scale-110" />
        }
        <span class="sr-only">
            {"Switch to "}{theme.value === "light" ? "dark" : "light"}{" theme"}
        </span>
    </Button>
    </>
}
