# Codex CLI Reference

<!-- pinned: 2026-04-01 from https://developers.openai.com/codex/cli/reference -->

## Invocation

Run without a global install via Bun: `bunx @openai/codex <args>`
(e.g. `bunx @openai/codex exec "prompt"`). The `codex` commands below assume
this alias — substitute `bunx @openai/codex` wherever a global `codex` isn't on `$PATH`.

## Non-interactive usage

```bash
codex exec "prompt"              # non-interactive (alias: codex e)
codex exec --full-auto "prompt"  # low-friction preset: workspace-write sandbox + on-request approvals
codex exec --yolo "prompt"       # DANGEROUS: bypass all approvals AND sandbox
```

## `codex exec` flags

| Flag                                                    | Alias | Description                                                                           |
| ------------------------------------------------------- | ----- | ------------------------------------------------------------------------------------- |
| `--full-auto`                                           |       | Low-friction preset: `workspace-write` sandbox + `on-request` approvals.              |
| `--yolo` / `--dangerously-bypass-approvals-and-sandbox` |       | Bypass ALL approval prompts and sandboxing. Dangerous — only use in isolated runners. |
| `--sandbox`                                             | `-s`  | Sandbox policy: `read-only`, `workspace-write`, `danger-full-access`.                 |
| `--cd`                                                  | `-C`  | Set workspace root before executing.                                                  |
| `--model`                                               | `-m`  | Override model for this run.                                                          |
| `--output-last-message`                                 | `-o`  | Write assistant's final message to a file. Useful for downstream scripting.           |
| `--ephemeral`                                           |       | Run without persisting session files.                                                 |
| `--profile`                                             | `-p`  | Select a config profile from `~/.codex/config.toml`.                                  |
| `--json`                                                |       | Print newline-delimited JSON events instead of formatted text.                        |

## --full-auto vs --yolo

| Flag          | Sandbox           | Approvals  | When to use                          |
| ------------- | ----------------- | ---------- | ------------------------------------ |
| `--full-auto` | `workspace-write` | on-request | Normal agent dispatch — safe default |
| `--yolo`      | **none**          | **none**   | Only inside fully isolated runners   |

## Context auto-loaded

- `AGENTS.md` — merged from `~/.codex/AGENTS.md` + repo root + cwd (no bootstrap needed)
- `~/.codex/config.toml` — global config and profiles
