# A plain, working neovim for every machine: enabled, default editor, the usual
# aliases, no python/ruby providers.
#
# Deliberately no plugins, no lua config and no language servers. An editor
# config is a dotfile you want to own directly, and this repo's placement rule
# sends those to the private consumer rather than to a public base that six
# machines pin by tag — otherwise changing a keymap costs a release, a tag and an
# input bump. The LazyVim setup that used to live here now sits in
# harus-nix (`users/haru/neovim.nix`), which dev machines opt into the same way
# they opt into `homeManagerModules.runtimes`; lean machines get just this.
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
