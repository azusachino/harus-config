{
  pkgs,
  lib,
  ...
}: {
  programs.fish = {
    enable = true;

    shellInit = ''
      # Disable greeting
      set fish_greeting

      # Environment
      set -gx EDITOR "nvim"
      set -gx VISUAL "nvim"
      set -gx KUBECONFIG "$HOME/.kube/config"
      # Normalize TERM — xterm-ghostty is not in most terminfo databases
      if not set -q TERM; or test "$TERM" = "xterm-ghostty"
        set -gx TERM "xterm-256color"
      end

      ${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
        # Homebrew (Apple Silicon)
        fish_add_path -g /opt/homebrew/bin /opt/homebrew/sbin
      ''}

      # Determinate Nix CLI
      fish_add_path -g ~/.nix-profile/bin /nix/var/nix/profiles/default/bin

      # Nix-installed packages ship completions here; fish doesn't search it by default on macOS
      if not contains ~/.nix-profile/share/fish/vendor_completions.d $fish_complete_path
        set -p fish_complete_path ~/.nix-profile/share/fish/vendor_completions.d
      end

      # Extra paths (language runtimes managed outside Nix)
      # -g keeps these session-global; without it fish_add_path writes the
      # *universal* fish_user_paths (~/.config/fish/fish_variables), which drifts
      # outside Nix and leaks stale entries (e.g. old JDKs) into GUI tools.
      fish_add_path -g ~/.local/bin ~/.cargo/bin ~/go/bin ~/.bun/bin

      # Machine-local secrets — not tracked in Nix (NOTION_API_KEY etc.)
      if test -f ~/.config/fish/secrets.fish
        source ~/.config/fish/secrets.fish
      end

    '';

    interactiveShellInit = ''
      # Completions for custom functions
      complete -c work -f -a '(ls ~/Working 2>/dev/null; ls ~/Projects 2>/dev/null)'
      complete -c tms -f -a '(tmux list-sessions -F "#S" 2>/dev/null)'
      complete -c dotenv -f -a '(ls *.env .env* 2>/dev/null)'
      complete -c undotenv -f
    '';

    shellAliases = {
      # Files
      l = "eza -la --icons";
      bat = "bat -p";
      cls = "clear";
      # Kubernetes
      k = "kubectl";
      kl = "kubectl logs -f --tail 200";
      # SSH
      ss = "ssh -o StrictHostKeyChecking=accept-new";
      # Media — yt-dlp runs via uv's tool runner (not a Nix package)
      yt-dlp = "uvx yt-dlp";
    };

    functions = {
      # Load .env file into shell environment
      dotenv = ''
        if test (count $argv) -ne 1
          echo "Usage: dotenv <file>"
          return 1
        end
        if not test -f $argv[1]
          echo "dotenv: file not found: $argv[1]"
          return 1
        end

        # Initialize tracking list if it doesn't exist
        if not set -q __dotenv_vars
          set -g __dotenv_vars
        end

        for line in (string split \n -- (cat $argv[1]))
          set line (string trim $line)
          if test -z "$line"; or string match -q "#*" $line
            continue
          end
          set name_value (string split -m 1 = $line)
          if test (count $name_value) -lt 2
            continue
          end
          set name (string trim $name_value[1])
          set value (string trim $name_value[2])
          if not string match -rq '^[A-Za-z_][A-Za-z0-9_]*$' -- $name
            continue
          end
          # Strip surrounding quotes
          if string match -q '"*"' $value; or string match -q "'*'" $value
            set value (string sub -s 2 -e -1 $value)
          end
          # Expand environment variable references without evaluating shell code
          set expanded $value
          for token in (string match -r -a '\$\{?[A-Za-z_][A-Za-z0-9_]*\}?' -- $value)
            set var_name (string replace -r -- '^\$\{?([A-Za-z_][A-Za-z0-9_]*)\}?$' '$1' $token)
            set replacement ""
            if set -q $var_name
              set replacement $$var_name
            end
            set expanded (string replace -a -- $token "$replacement" $expanded)
          end
          set -gx $name $expanded
          # Track this variable for cleanup
          set -g __dotenv_vars $__dotenv_vars $name
        end
      '';

      # Unload tracked dotenv variables
      undotenv = ''
        if not set -q __dotenv_vars
          echo "undotenv: no tracked variables"
          return 1
        end
        for var in $__dotenv_vars
          set -e $var
        end
        set -e __dotenv_vars
      '';

      # Quick context switch helper
      work = ''
        if test (count $argv) -eq 0
          echo "Usage: work <project-name>"
          echo "Switches to ~/Working/<project-name> or ~/Projects/<project-name>"
          return 1
        end
        if test -d ~/Working/$argv[1]
          cd ~/Working/$argv[1]
        else if test -d ~/Projects/$argv[1]
          cd ~/Projects/$argv[1]
        else
          echo "work: project not found: $argv[1]"
          return 1
        end
      '';

      mkcd = ''
        mkdir -p $argv[1] && cd $argv[1]
      '';

      gacp = ''
        if test (count $argv) -eq 0
          echo "Usage: gacp <commit-message>"
          return 1
        end
        git add -A && git commit -m (string join " " $argv) && git push
      '';

      # fd → fzf (multi) → nvim
      fdn = ''
        set files (fd $argv | fzf --multi)
        if test -n "$files"
          nvim $files
        end
      '';

      # fd → fzf with bat preview → nvim
      fdp = ''
        set files (fd $argv | fzf --multi --preview 'bat --color=always {}')
        if test -n "$files"
          nvim $files
        end
      '';

      # fzf into a directory and cd
      fcd = ''
        set dir (fd --type d $argv | fzf --preview 'eza -la --icons {}')
        if test -n "$dir"
          cd $dir
        end
      '';

      # Git: fuzzy branch checkout
      gbs = ''
        set branch (git branch --all | string trim | fzf --preview 'git log --oneline --color=always {1}' | string replace 'remotes/origin/' ''')
        if test -n "$branch"
          git checkout $branch
        end
      '';

      # Git: fuzzy branch delete (local)
      gbd = ''
        set branches (git branch | string trim | grep -v '^\*' | fzf --multi --preview 'git log --oneline --color=always {}')
        if test -n "$branches"
          echo $branches | xargs git branch -d
        end
      '';

      # Git: fuzzy log → show diff
      gshow = ''
        git log --oneline --color=always | fzf --ansi --preview 'git show --color=always {1}' | awk '{print $1}' | xargs git show
      '';

      # kubectl: fuzzy namespace switch
      kns = ''
        set ns (kubectl get ns --no-headers -o custom-columns=':metadata.name' | fzf)
        if test -n "$ns"
          kubectl config set-context --current --namespace=$ns
          echo "Namespace → $ns"
        end
      '';

      # kubectl: fuzzy context switch
      kx = ''
        set ctx (kubectl config get-contexts --no-headers -o name | fzf)
        if test -n "$ctx"
          kubectl config use-context $ctx
        end
      '';

      # Fuzzy kill process
      fkill = ''
        set pid (ps aux | fzf --multi --header-lines=1 | awk '{print $2}')
        if test -n "$pid"
          echo $pid | xargs kill $argv
        end
      '';

      # tmux: fuzzy session switch (or create new)
      tms = ''
        if test (count $argv) -gt 0
          tmux new-session -As $argv[1]
        else
          set session (tmux list-sessions -F '#S' 2>/dev/null | fzf --preview 'tmux list-windows -t {}')
          if test -n "$session"
            tmux switch-client -t $session
          end
        end
      '';

      # SSH: fuzzy host from ~/.ssh/config
      sshf = ''
        set host (grep -E '^Host ' ~/.ssh/config ~/.ssh/work-hosts 2>/dev/null | awk '{print $2}' | grep -v '\*' | fzf)
        if test -n "$host"
          ssh $host
        end
      '';

      # Interactive jq explorer: browse top-level keys, preview subtree
      jqf = ''
        set input $argv[1]
        if test -z "$input"
          echo "Usage: jqf <file.json>"
          return 1
        end
        set key (jq -r 'to_entries[] | "\(.key)\t(\(.value|type))"' $input 2>/dev/null \
          | fzf --delimiter '\t' --with-nth '1,2' --header "Keys in $input" \
                --preview "jq -C '.[\"$(string split \t {} | head -1)\"]' $input 2>/dev/null" \
          | cut -f1)
        if test -n "$key"
          jq -C ".\"$key\"" $input
        end
      '';

      # gh: fuzzy PR checkout
      ghpr = ''
        set pr (gh pr list | fzf --preview 'gh pr view {1}' | awk '{print $1}')
        if test -n "$pr"
          gh pr checkout $pr
        end
      '';

      # Show listening ports (platform-aware)
      ports = ''
        if test (uname) = Darwin
          lsof -iTCP -sTCP:LISTEN -P -n
        else
          command ss -tlnp
        end
      '';

      # Podman/docker: fuzzy exec into container shell
      csh = ''
        set runtime docker
        if type -q podman; and not type -q docker
          set runtime podman
        end
        set ctr ($runtime ps --format '{{.Names}}' | fzf --preview "$runtime stats --no-stream {}")
        if test -n "$ctr"
          $runtime exec -it $ctr sh -c 'bash || sh'
        end
      '';

      # Podman/docker: fuzzy container logs
      clog = ''
        set runtime docker
        if type -q podman; and not type -q docker
          set runtime podman
        end
        set ctr ($runtime ps -a --format '{{.Names}}' | fzf)
        if test -n "$ctr"
          $runtime logs -f --tail 200 $ctr
        end
      '';

      # Podman/docker: interactive image cleaner TUI
      cprune = ''
        set -l script_path "$HOME/Projects/project-github/harus-nix/scripts/clean-images.py"
        if not test -f $script_path
          echo "Error: clean-images.py not found at $script_path"
          return 1
        end
        uv run $script_path $argv
      '';

      # AWS: fuzzy profile switch
      awsp = ''
        set profile (aws configure list-profiles | fzf)
        if test -n "$profile"
          set -gx AWS_PROFILE $profile
          echo "AWS_PROFILE → $profile"
        end
      '';

      # Git: fuzzy stash pop
      gstf = ''
        set stash (git stash list | fzf --preview 'git stash show -p {1} --color=always' --delimiter ':' --with-nth 1,3 | cut -d: -f1)
        if test -n "$stash"
          git stash pop $stash
        end
      '';

      # mise: fuzzy tool version switch (two-step: pick tool, then version)
      misef = ''
        set tool (mise ls --current | tail -n +2 | fzf --header "Select tool" | awk '{print $1}')
        if test -z "$tool"
          return
        end
        set version (mise ls $tool 2>/dev/null | fzf --header "Select version for $tool" | awk '{print $2}')
        if test -n "$version"
          mise use $tool@$version
        end
      '';

      # Interactive ripgrep → fzf → nvim
      rgi = ''
        set search_term $argv[1]
        set search_path $argv[2]
        set selection (rg --color=always --line-number --no-heading "$search_term" "$search_path" |
          fzf --ansi \
              --delimiter ':' \
              --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
              --preview-window 'up:50%:wrap' \
              --with-nth '1,2')
        if test -n "$selection"
          set file (echo $selection | cut -d: -f1)
          set line (echo $selection | cut -d: -f2)
          nvim +$line $file
        end
      '';

      # zoxide: fuzzy jump with eza preview (wraps zi with richer preview)
      zf = ''
        set dir (zoxide query --list | fzf --preview 'eza -la --icons {}')
        if test -n "$dir"
          cd $dir
        end
      '';

      # gh: fuzzy issue view/open
      ghif = ''
        set issue (gh issue list --limit 50 | fzf --preview 'gh issue view {1}' | awk '{print $1}')
        if test -n "$issue"
          gh issue view $issue --web
        end
      '';

      # gh: sync all personal repos to $GH_SYNC_DIR (default ~/Projects/project-github)
      sync-gh = ''
        set -l base_dir $GH_SYNC_DIR
        if test -z "$base_dir"
          set base_dir "$HOME/Projects/project-github"
        end

        set -l yellow (set_color yellow)
        set -l green (set_color green)
        set -l red (set_color red)
        set -l normal (set_color normal)

        echo $yellow"━━━ Syncing GitHub repos → $base_dir ━━━"$normal

        set -l repos (gh api --paginate '/user/repos?type=owner' --jq '.[] | "\(.owner.login)/\(.name)"' 2>/dev/null)
        if test $status -ne 0
          echo $red"[error]  gh api failed — check auth and network"$normal
          return 1
        end

        mkdir -p $base_dir

        set -l n_cloned 0
        set -l n_pulled 0
        set -l n_skipped 0
        set -l n_failed 0

        for full_name in $repos
          set -l repo_name (string split -m 1 / $full_name)[2]
          set -l dest "$base_dir/$repo_name"

          if not test -d $dest
            gh repo clone $full_name $dest >/dev/null 2>&1
            echo $green"[clone]  $repo_name"$normal
            set n_cloned (math $n_cloned + 1)
          else
            set -l dirty (git -C $dest status --porcelain 2>/dev/null)
            if test -n "$dirty"
              echo $yellow"[skip]   $repo_name  ← uncommitted or untracked changes"$normal
              set n_skipped (math $n_skipped + 1)
            else
              git -C $dest pull --ff-only >/dev/null 2>&1
              if test $status -eq 0
                echo $green"[pull]   $repo_name"$normal
                set n_pulled (math $n_pulled + 1)
              else
                echo $red"[error]  $repo_name  ← pull failed"$normal
                set n_failed (math $n_failed + 1)
              end
            end
          end
        end

        echo $green"━━━ Done: $n_cloned cloned, $n_pulled pulled, $n_skipped skipped, $n_failed errors ━━━"$normal

        if test $n_failed -gt 0
          return 1
        end
      '';

      # gh: fuzzy run watch (CI)
      ghrf = ''
        set run (gh run list --limit 30 | fzf --preview 'gh run view {1}' | awk '{print $1}')
        if test -n "$run"
          gh run view $run --log
        end
      '';

      # kubectl: fuzzy pod → logs (uses existing kl alias style)
      klf = ''
        set pod (kubectl get pods --no-headers | fzf --preview 'kubectl describe pod {1}' | awk '{print $1}')
        if test -n "$pod"
          kubectl logs -f --tail 200 $pod $argv
        end
      '';

      # kubectl: fuzzy pod → exec shell
      kexec = ''
        set pod (kubectl get pods --no-headers | fzf --preview 'kubectl describe pod {1}' | awk '{print $1}')
        if test -n "$pod"
          kubectl exec -it $pod -- sh -c 'bash || sh'
        end
      '';

      # mise: fuzzy task run
      mrt = ''
        set task (mise tasks | tail -n +2 | fzf --preview 'mise task show {1}' | awk '{print $1}')
        if test -n "$task"
          mise run $task $argv
        end
      '';

      # tmux: fuzzy window switch across all sessions
      tmw = ''
        set win (tmux list-windows -a -F '#S:#I #W' 2>/dev/null | fzf --preview 'tmux list-panes -t {1}')
        if test -n "$win"
          set target (echo $win | awk '{print $1}')
          tmux switch-client -t $target
        end
      '';
    };
  };

  # Shell integrations — each module installs the binary and wires the fish hook
  # programs.mise    → default.nix
  # programs.starship → starship.nix
  programs.zoxide.enable = true;
}
