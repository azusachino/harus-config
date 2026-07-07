{...}: {
  home.file = {
    ".claude/statusline-command.sh" = {
      source = ../config/claude/statusline-command.sh;
      executable = true;
    };
    ".claude/hooks/quality-gate.sh" = {
      source = ../config/claude/hooks/quality-gate.sh;
      executable = true;
    };
    ".claude/agents/haiku-developer.md".source = ../config/claude/agents/haiku-developer.md;
    ".claude/agents/codex-developer.md".source = ../config/claude/agents/codex-developer.md;
    ".claude/agents/repo-scout.md".source = ../config/claude/agents/repo-scout.md;
    ".claude/agents/orchestrator.md".source = ../config/claude/agents/orchestrator.md;
    ".claude/docs/codex-cli-reference.md".source = ../config/claude/docs/codex-cli-reference.md;
  };
}
