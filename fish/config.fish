# customize path (local, rust, go)
fish_add_path $HOME/.local/bin/ $HOME/.cargo/bin/ $HOME/go/bin/ $HOME/.bun/bin/

## fish settings
### disable greeting
set fish_greeting

# setup fish with homebrew
if test -d /home/linuxbrew/.linuxbrew # Linux
	set -gx HOMEBREW_PREFIX "/home/linuxbrew/.linuxbrew"
	set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
	set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/Homebrew"
else if test -d /opt/homebrew # MacOS
	set -gx HOMEBREW_PREFIX "/opt/homebrew"
	set -gx HOMEBREW_CELLAR "$HOMEBREW_PREFIX/Cellar"
	set -gx HOMEBREW_REPOSITORY "$HOMEBREW_PREFIX/homebrew"
end

fish_add_path -gP "$HOMEBREW_PREFIX/bin" "$HOMEBREW_PREFIX/sbin"

## alias
# shortcuts & alias
alias mci="mvn clean install -Dmaven.test.skip=true"
alias mcd="mvn clean deploy -DskipTests"

alias kl="kubectl logs -f --tail 200 "
alias ss="ssh -o StrictHostKeyChecking=no "

alias sk="sudo k3s kubectl "
alias gco="git checkout"
alias gfp="git fetch -v && git pull -v"

alias l="eza -la --icons"

## tools initialization
fzf --fish | source
zoxide init fish | source
mise activate fish | source
