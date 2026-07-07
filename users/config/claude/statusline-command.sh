#!/bin/sh
# Claude Code status line script
# Style: model · project · branch · 5h:X% · 7d:X% · X% left · X% used · vX.Y.Z · XK window · XK used · X,XXX in · XXX out

input=$(cat)

# --- Extract JSON fields ---
cwd=$(echo "$input"           | jq -r '.workspace.current_dir // .cwd // empty')
project_dir=$(echo "$input"   | jq -r '.workspace.project_dir // empty')
model_id=$(echo "$input"      | jq -r '.model.id // empty')
model_name=$(echo "$input"    | jq -r '.model.display_name // empty')
version=$(echo "$input"       | jq -r '.version // empty')
ctx_remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
ctx_used=$(echo "$input"      | jq -r '.context_window.used_percentage // empty')
ctx_window=$(echo "$input"    | jq -r '.context_window.context_window_size // empty')
session_in=$(echo "$input"    | jq -r '.context_window.total_input_tokens // empty')
session_out=$(echo "$input"   | jq -r '.context_window.total_output_tokens // empty')
rl_5h=$(echo "$input"         | jq -r '.rate_limits.five_hour.used_percentage // empty')
rl_5h_resets=$(echo "$input"  | jq -r '.rate_limits.five_hour.resets_at // empty')
rl_7d=$(echo "$input"         | jq -r '.rate_limits.seven_day.used_percentage // empty')
rl_7d_resets=$(echo "$input"  | jq -r '.rate_limits.seven_day.resets_at // empty')

# --- Color support ---
# Disable colors if NO_COLOR is set, TERM is dumb/unknown, or stdout is not a tty-like context.
# Claude Code statusLine commands run non-interactively so we always allow colors unless
# explicitly opted out via NO_COLOR or TERM=dumb.
if [ -n "${NO_COLOR:-}" ] || [ "${TERM:-}" = "dumb" ]; then
    C_RESET=''; C_DIM=''; C_WHITE=''; C_CYAN=''
    C_GREEN=''; C_YELLOW=''; C_RED=''
else
    C_RESET=$(printf '\033[0m')
    C_DIM=$(printf '\033[2m')
    C_WHITE=$(printf '\033[0;37m')
    C_CYAN=$(printf '\033[0;36m')
    C_GREEN=$(printf '\033[0;32m')
    C_YELLOW=$(printf '\033[0;33m')
    C_RED=$(printf '\033[0;31m')
fi

# Dim separator used between every segment
SEP="${C_DIM} · ${C_RESET}"

# --- Helper: wrap text in a color, then reset ---
# Usage: color $C_XXX "text"  → outputs escape + text + reset
color() {
    c="$1"; text="$2"
    if [ -z "$c" ]; then
        printf '%s' "$text"
    else
        printf "${c}%s${C_RESET}" "$text"
    fi
}

# --- Helper: shorten path by replacing HOME with ~ ---
shorten_path() {
    p="$1"
    home="${HOME:-/root}"
    case "$p" in
        "$home"*) printf '~%s' "${p#$home}" ;;
        *)        printf '%s' "$p" ;;
    esac
}

# --- Helper: format integer with comma grouping (awk-based) ---
fmt_comma() {
    val="$1"
    [ -z "$val" ] && return
    printf '%s' "$val" | awk '{
        n = $0; s = ""
        while (length(n) > 3) {
            s = "," substr(n, length(n)-2) s
            n = substr(n, 1, length(n)-3)
        }
        printf "%s%s\n", n, s
    }'
}

# --- Helper: format tokens as K (1 decimal) or raw ---
fmt_k() {
    val="$1"
    [ -z "$val" ] && return
    awk "BEGIN { if ($val >= 1000) printf \"%.1fK\", $val/1000; else printf \"%d\", $val }"
}

# --- Build output segments ---
out=''

append() {
    seg="$1"
    [ -z "$seg" ] && return
    if [ -z "$out" ]; then
        out="$seg"
    else
        out="${out}${SEP}${seg}"
    fi
}

# 1. Model name — dim/gray (less important)
if [ -n "$model_id" ]; then
    model_label="$model_id"
elif [ -n "$model_name" ]; then
    model_label=$(printf '%s' "$model_name" | sed 's/^Claude //' | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
fi
[ -n "${model_label:-}" ] && append "$(color "$C_DIM" "$model_label")"

# 2. Project root — normal/white
if [ -n "$project_dir" ]; then
    append "$(color "$C_WHITE" "$(shorten_path "$project_dir")")"
fi

# 3. Git branch — cyan; dirty branches get a trailing * in yellow
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git_branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
    if [ -n "$git_branch" ]; then
        if ! git -C "$cwd" diff --quiet 2>/dev/null || \
           ! git -C "$cwd" diff --cached --quiet 2>/dev/null; then
            git_label="$(color "$C_CYAN" "$git_branch")$(color "$C_YELLOW" '*')"
        else
            git_label="$(color "$C_CYAN" "$git_branch")"
        fi
        append "$git_label"
    fi
fi

# 4. Rate limits — 5h and 7d used%, with resets_at if near limit
fmt_resets() {
    ts="$1"
    [ -z "$ts" ] && return
    now=$(date +%s)
    diff=$(( ts - now ))
    [ "$diff" -le 0 ] && return
    hrs=$(( diff / 3600 ))
    mins=$(( (diff % 3600) / 60 ))
    printf '%dh%dm' "$hrs" "$mins"
}

rl_color() {
    pct="$1"
    [ -z "$pct" ] && return
    int=$(printf '%.0f' "$pct")
    if [ "$int" -ge 90 ]; then
        printf '%s' "$C_RED"
    elif [ "$int" -ge 70 ]; then
        printf '%s' "$C_YELLOW"
    else
        printf '%s' "$C_GREEN"
    fi
}

if [ -n "$rl_5h" ]; then
    pct_int=$(printf '%.0f' "$rl_5h")
    c=$(rl_color "$rl_5h")
    seg="$(color "$c" "5h:${pct_int}%")"
    if [ "$pct_int" -ge 70 ] && [ -n "$rl_5h_resets" ]; then
        resets=$(fmt_resets "$rl_5h_resets")
        [ -n "$resets" ] && seg="${seg}$(color "$C_DIM" " ~${resets}")"
    fi
    append "$seg"
fi

if [ -n "$rl_7d" ]; then
    pct_int=$(printf '%.0f' "$rl_7d")
    c=$(rl_color "$rl_7d")
    seg="$(color "$c" "7d:${pct_int}%")"
    if [ "$pct_int" -ge 70 ] && [ -n "$rl_7d_resets" ]; then
        resets=$(fmt_resets "$rl_7d_resets")
        [ -n "$resets" ] && seg="${seg}$(color "$C_DIM" " ~${resets}")"
    fi
    append "$seg"
fi

# 5. X% left — green > 30%, yellow 10-30%, red < 10%
if [ -n "$ctx_remaining" ]; then
    remaining_int=$(printf '%.0f' "$ctx_remaining")
    if [ "$remaining_int" -gt 30 ]; then
        left_color="$C_GREEN"
    elif [ "$remaining_int" -ge 10 ]; then
        left_color="$C_YELLOW"
    else
        left_color="$C_RED"
    fi
    append "$(color "$left_color" "${remaining_int}% left")"
fi

# 6. X% used — green < 30%, yellow 30-70%, red > 70%
if [ -n "$ctx_used" ]; then
    used_int=$(printf '%.0f' "$ctx_used")
    if [ "$used_int" -gt 70 ]; then
        used_color="$C_RED"
    elif [ "$used_int" -ge 30 ]; then
        used_color="$C_YELLOW"
    else
        used_color="$C_GREEN"
    fi
    append "$(color "$used_color" "${used_int}% used")"
fi

# 9. Version — dim/gray
if [ -n "$version" ]; then
    append "$(color "$C_DIM" "v${version}")"
fi

# 10. XK window — dim/gray
if [ -n "$ctx_window" ]; then
    win_k=$(fmt_k "$ctx_window")
    append "$(color "$C_DIM" "${win_k} window")"
fi

# 11. XK used — normal/white (derived: used% * window_size / 100)
if [ -n "$ctx_used" ] && [ -n "$ctx_window" ]; then
    used_tokens=$(awk "BEGIN { printf \"%.0f\", $ctx_used * $ctx_window / 100 }")
    used_k=$(fmt_k "$used_tokens")
    append "$(color "$C_WHITE" "${used_k} used")"
fi

# 12. X,XXX in — dim/gray
if [ -n "$session_in" ]; then
    in_fmt=$(fmt_comma "$session_in")
    append "$(color "$C_DIM" "${in_fmt} in")"
fi

# 13. XXX out — dim/gray
if [ -n "$session_out" ]; then
    out_fmt=$(fmt_comma "$session_out")
    out_seg="$(color "$C_DIM" "${out_fmt} out")"
    if [ -z "$out" ]; then
        out="$out_seg"
    else
        out="${out}${SEP}${out_seg}"
    fi
fi

printf '%s\n' "$out"
