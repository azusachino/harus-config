{...}: {
  # Antigravity CLI (agy) statusline script. The settings.json that points at
  # this path is managed by agent-sync (tools/agent-sync); home-manager only
  # deploys the script asset, mirroring the claude.nix split.
  home.file.".gemini/antigravity-cli/statusline.sh" = {
    source = ../config/gemini/statusline.sh;
    executable = true;
  };
}
