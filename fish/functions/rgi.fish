# Interactive search with rg, fzf, and bat, then open in VS Code.
# Usage: rgi <search_term> <path>
function rgi
    # The search term is the first argument, path is the second.
    set search_term $argv[1]
    set search_path $argv[2]

    # Run rg and pipe to fzf.
    # --with-nth '1,2' tells fzf to only output the first two fields (file and line).
    set selection (rg --color=always --line-number --no-heading "$search_term" "$search_path" |
        fzf --ansi \
            --delimiter ':' \
            --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
            --preview-window 'up:50%:wrap' \
            --with-nth '1,2')

    # If a selection was made (not cancelled with Esc)
    if test -n "$selection"
        # Split selection into file and line
        set file (echo $selection | cut -d: -f1)
        set line (echo $selection | cut -d: -f2)
        nvim +$line $file
    end
end
