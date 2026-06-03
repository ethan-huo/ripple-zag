# Ripple Basic Template

A minimal Ripple application template with TypeScript and Vite.

## Getting Started

1. Install dependencies:

    ```bash
    pnpm install
    ```

2. Start the development server:

    ```bash
    pnpm dev
    ```

3. Build for production:
    ```bash
    pnpm build
    ```

## Code Formatting

This template includes Prettier with the Ripple plugin for consistent code formatting.

### Available Commands

- `pnpm format` - Format all files
- `pnpm format:check` - Check if files are formatted correctly

### Configuration

Prettier is configured in `.prettierrc` with the following settings:

- Uses tabs for indentation
- Single quotes for strings
- 100 character line width
- Includes `@tsrx/prettier-plugin` for `.tsrx` file formatting

### VS Code Integration

For the best development experience, install the [Prettier VS Code extension](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode) and the [Ripple VS Code extension](https://marketplace.visualstudio.com/items?itemName=ripplejs.ripple-vscode-plugin).

## Learn More

- [Ripple Documentation](https://www.ripple-ts.com)
- [Vite Documentation](https://vitejs.dev/)
