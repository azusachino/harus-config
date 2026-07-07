#!/bin/sh
# Antigravity CLI (agy) status line script
# Style: state · model · project · branch · X% used · XK used · XK window · X,XXX in · XXX out · plan · vX.Y.Z
#
# The TUI pipes a JSON payload to stdin on every agent-state change. Confirmed
# schema (agy 1.0.x):
#   .agent_state                          idle | thinking | authenticating | …
#   .model.{id,display_name}              "Gemini 3.5 Flash (Medium)"
#   .workspace.{current_dir,project_dir}  absolute paths
#   .cwd                                  absolute path (fallback for project)
#   .version                              CLI version, e.g. "1.0.8"
#   .plan_tier                            "Google AI Pro"
#   .context_window.{total_input_tokens,total_output_tokens,
#                    context_window_size,used_percentage,remaining_percentage}
#   .vcs.{type,root}                      NOTE: .vcs.branch is usually absent,
#                                         so the branch is derived via git below.
# Quota (5h / weekly) is NOT in this payload — it lives in the local
# language_server GetUserStatus API (see agy-hud) and is intentionally omitted.

input=$(cat)

# --- Extract JSON fields ---
agent_state=$(echo "$input" | jq -r '.agent_state // empty')
cwd=$(echo "$input"         | jq -r '.workspace.current_dir // .cwd // empty')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // .workspace.current_dir // .cwd // empty')
model_id=$(echo "$input"    | jq -r '.model.id // empty')
model_name=$(echo "$input"  | jq -r '.model.display_name // empty')
version=$(echo "$input"     | jq -r '.version // empty')
plan_tier=$(echo "$input"   | jq -r '.plan_tier // empty')
ctx_used=$(echo "$input"    | jq -r '.context_window.used_percentage // empty')
ctx_window=$(echo "$input"  | jq -r '.context_window.context_window_size // empty')
tok_in=$(echo "$input"      | jq -r '.context_window.total_input_tokens // empty')
tok_out=$(echo "$input"     | jq -r '.context_window.total_output_tokens // empty')

# --- Color support (opt out via NO_COLOR or TERM=dumb) ---
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

SEP="${C_DIM} · ${C_RESET}"

# --- Helpers ---
color() {
    c="$1"; text="$2"
    if [ -z "$c" ]; then printf '%s' "$text"; else printf "${c}%s${C_RESET}" "$text"; fi
}

# Format tokens as K/M (1 decimal) or raw.
fmt_k() {
    val="$1"
    [ -z "$val" ] && return
    awk "BEGIN {
        v = $val
        if (v >= 1000000) printf \"%.1fM\", v/1000000
        else if (v >= 1000) printf \"%.1fK\", v/1000
        else printf \"%d\", v
    }"
}

# Format integer with comma grouping.
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

out=''
append() {
    seg="$1"
    [ -z "$seg" ] && return
    if [ -z "$out" ]; then out="$seg"; else out="${out}${SEP}${seg}"; fi
}

# --- Build output segments ---

# 1. Agent state — green idle / yellow thinking / cyan otherwise
if [ -n "$agent_state" ]; then
    case "$agent_state" in
        idle|Idle)         st_color="$C_GREEN" ;;
        thinking|Thinking) st_color="$C_YELLOW" ;;
        *)                 st_color="$C_CYAN" ;;
    esac
    append "$(color "$st_color" "$agent_state")"
fi

# 2. Model — dim (full display name, e.g. "Gemini 3.5 Flash (Medium)")
if [ -n "$model_name" ]; then
    append "$(color "$C_DIM" "$model_name")"
elif [ -n "$model_id" ]; then
    append "$(color "$C_DIM" "$model_id")"
fi

# 3. Project — white (basename of project/working dir)
[ -n "$project_dir" ] && append "$(color "$C_WHITE" "$(basename "$project_dir")")"

# 4. Git branch — cyan; dirty branches get a trailing * in yellow.
# .vcs.branch is unreliable, so derive it from the working directory.
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git_branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
    if [ -n "$git_branch" ]; then
        if ! git -C "$cwd" diff --quiet 2>/dev/null || \
           ! git -C "$cwd" diff --cached --quiet 2>/dev/null; then
            append "$(color "$C_CYAN" "$git_branch")$(color "$C_YELLOW" '*')"
        else
            append "$(color "$C_CYAN" "$git_branch")"
        fi
    fi
fi

# 5. Context used% — green < 30%, yellow 30-70%, red > 70%
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

# 6. Used tokens (in + out) — white
if [ -n "$tok_in" ] || [ -n "$tok_out" ]; then
    total=$(awk "BEGIN { printf \"%d\", ${tok_in:-0} + ${tok_out:-0} }")
    [ "$total" -gt 0 ] && append "$(color "$C_WHITE" "$(fmt_k "$total") used")"
fi

# 7. Context window size — dim
[ -n "$ctx_window" ] && append "$(color "$C_DIM" "$(fmt_k "$ctx_window") window")"

# 8. Input / output token counts — dim
[ -n "$tok_in" ]  && append "$(color "$C_DIM" "$(fmt_comma "$tok_in") in")"
[ -n "$tok_out" ] && append "$(color "$C_DIM" "$(fmt_comma "$tok_out") out")"

# 9. Plan tier — dim ("Google AI Pro" -> "Pro")
if [ -n "$plan_tier" ]; then
    case "$plan_tier" in
        *Pro*) plan_label="Pro" ;;
        *)     plan_label="$plan_tier" ;;
    esac
    append "$(color "$C_DIM" "$plan_label")"
fi

# 10. Version — dim
[ -n "$version" ] && append "$(color "$C_DIM" "v${version}")"

printf '%s\n' "$out"
