# AGENTS.md - Coding Agent Guidelines

## Build/Lint/Test Commands

This is a Neovim configuration repository. No traditional build/test commands exist.

- **Plugin sync**: `nvim --headless "+Lazy! sync" +qa`
- **Formatting**: Uses Stylua (configured in `.stylua.toml`)
- **No testing framework** - manual testing required

## Code Style Guidelines

### Formatting
- **Indentation**: 2 spaces (configured in `.stylua.toml`)
- **Line endings**: Unix
- **Quote style**: Auto-prefer single quotes
- **Column width**: 160 characters
- **Call parentheses**: None (function calls don't require parentheses)

### Imports
- Use `require 'module.path'` for imports
- Single quotes preferred
- No trailing commas in require statements

### Naming Conventions
- **Functions**: snake_case (e.g., `close_other_buffers`, `is_vim_single_win`)
- **Variables**: snake_case for locals, mixed camelCase for some globals
- **Modules**: PascalCase for module tables (e.g., `local M = {}`)
- **Files**: snake_case.lua

### Types and Error Handling
- **Types**: Lua with vim.* APIs (vim.opt, vim.o, vim.wo, vim.api)
- **Error handling**: Use `error()` function for failures
- **Nil checks**: Explicit checks for required values
- **Assertions**: Minimal, only for critical paths

### Structure
- **Modules**: Export functions via `local M = {}` pattern
- **Plugin configs**: Return table from plugin files for Lazy.nvim
- **Options**: Use vim.opt, vim.o, vim.wo appropriately
- **Comments**: Minimal - only TODO comments and brief explanations
- **No semicolons** at end of statements

### Best Practices
- **Security**: Never expose secrets or keys
- **Performance**: Use vim.defer_fn for async operations
- **Compatibility**: Target latest stable Neovim
- **Dependencies**: Check existing plugins before adding new ones</content>
<parameter name="filePath">/home/anto/dotfiles/AGENTS.md