# A plain, working neovim for every machine: enabled, default editor, the usual
# aliases, no python/ruby providers.
#
# Deliberately no plugins, no lua config and no language servers. An editor
# config is a dotfile you want to own directly, and this repo's placement rule
# sends those to the private consumer rather than to a public base that six
# machines pin by tag — otherwise changing a keymap costs a release, a tag and an
# input bump. The private consumer's `users/haru/neovim.nix` adds only quick-edit
# options; no LazyVim, language servers or formatter dependencies. Future editor
# requirements belong in the editor's Nix module, never the global mise manifest.
#
# What stays here is the part a stranger consuming the base would want anyway:
# `nvim`, `vi` and `vim` all exist and open a usable editor.
{...}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    withPython3 = false;
    withRuby = false;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
}
