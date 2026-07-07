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
  };
}
