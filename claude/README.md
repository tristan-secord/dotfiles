# Claude Config

Global Claude Code configuration, tracked as part of dotfiles.

`~/.claude` is a symlink to `~/.config/claude`.

## What's tracked

| Path | Purpose |
|------|---------|
| `settings.json` | Enabled plugins, MCP server names |
| `skills/execute-tickets` | Custom skill — fetches Trello tickets and dispatches parallel agents |
| `skills/to-issues` | Modified Matt Pocock skill — extended with Trello support |
| `.mcp.json.template` | MCP server config with placeholder secrets |

## New machine setup

### 1. Symlink

```bash
ln -s ~/.config/claude ~/.claude
```

If `~/.claude` already exists as a directory, back it up first:

```bash
mv ~/.claude ~/.claude.backup && ln -s ~/.config/claude ~/.claude
```

### 2. Secrets

Copy the template and fill in your credentials:

```bash
cp ~/.config/claude/.mcp.json.template ~/.config/claude/.mcp.json
```

Then edit `.mcp.json` and replace the placeholder values. Get your Trello keys at **https://trello.com/app-key**.

`.mcp.json` is gitignored — never commit it.

### 3. Plugins

```bash
claude plugin install superpowers@claude-plugins-official
claude plugin install pyright-lsp@claude-plugins-official
claude plugin install lua-lsp@claude-plugins-official
```

### 4. Matt Pocock skills

```bash
npx skills@latest add mattpocock/skills
```

This is interactive — pick the skills you want. They install into `~/.agents/skills/` and symlink into `~/.claude/skills/`.

> **Note:** if any skills fail to load after install, the relative symlinks may be broken due to `~/.claude` being a symlink itself. Fix with:
> ```bash
> for skill in ~/.agents/skills/*/; do
>   ln -sf "$skill" ~/.config/claude/skills/$(basename "$skill")
> done
> ```

## Adding a new MCP server

1. Add the server block to `.mcp.json` (gitignored — secrets live here)
2. Add a sanitized copy with placeholder values to `.mcp.json.template`
3. Document it in this README
