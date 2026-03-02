#!/usr/bin/env bash
set -e

# ─────────────────────────────────────────────
#  github-gui installer
#  Supports: fish, zsh, bash
# ─────────────────────────────────────────────

INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI="$INSTALL_DIR/cli.js"
CURRENT_SHELL="$(basename "$SHELL")"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

info()    { echo -e "${CYAN}→ $*${RESET}"; }
success() { echo -e "${GREEN}✅ $*${RESET}"; }
warn()    { echo -e "${YELLOW}⚠  $*${RESET}"; }
error()   { echo -e "${RED}✗  $*${RESET}"; exit 1; }

echo ""
echo -e "${CYAN}╔══════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║        github-gui  installer         ║${RESET}"
echo -e "${CYAN}╚══════════════════════════════════════╝${RESET}"
echo ""

# ── 1. Check Node.js ────────────────────────
info "Checking Node.js..."
if ! command -v node &>/dev/null; then
  error "Node.js is not installed. Install it from https://nodejs.org (v18+ recommended)"
fi
NODE_VER=$(node --version)
info "Found Node.js $NODE_VER"

# ── 2. Install npm dependencies ─────────────
info "Installing npm dependencies..."
cd "$INSTALL_DIR"
npm install --silent
success "Dependencies installed"

# ── 3. Make CLI executable ──────────────────
chmod +x "$CLI"

# ── 4. Install shell functions ──────────────
# The two shell function blocks we need to inject (for zsh / bash)
GC_FUNC=$(cat <<FUNC
# github-gui: shorthand commit GUI
function gc() {
  node "$CLI" commit
}
FUNC
)

GHELP_FUNC=$(cat <<FUNC
# github-gui: list all commands
function ghelp() {
  node "$CLI" help
}
FUNC
)

ALIAS_FUNCS=$(cat <<FUNC
# github-gui: git aliases
function gcb() { node "$CLI" branch; }
function ga()  { command git add "\$@"; }
function gs()  { command git switch "\$@"; }
function gco() { command git checkout "\$@"; }
function gpl() { command git pull "\$@"; }
function gps() { command git push "\$@"; }
function gst() { command git status "\$@"; }
function gd()  { command git diff "\$@"; }
function gb()  { command git branch "\$@"; }
function gbD() { command git branch -D "\$@"; }
FUNC
)

MARKER="# >>> github-gui <<<"

ZSH_COMPLETIONS=$(cat <<'COMP'
# github-gui: zsh completions for git aliases
compdef ga='git add'
compdef gs='git switch'
compdef gco='git checkout'
compdef gpl='git pull'
compdef gps='git push'
compdef gst='git status'
compdef gd='git diff'
compdef gb='git branch'
compdef gbD='git branch'
COMP
)

BASH_COMPLETIONS=$(cat <<'COMP'
# github-gui: bash completions for git aliases
if type __git_complete &>/dev/null; then
  __git_complete ga  _git_add
  __git_complete gs  _git_switch
  __git_complete gco _git_checkout
  __git_complete gpl _git_pull
  __git_complete gps _git_push
  __git_complete gst _git_status
  __git_complete gd  _git_diff
  __git_complete gb  _git_branch
  __git_complete gbD _git_branch
fi
COMP
)

inject_into_file() {
  local rcfile="$1"
  local completions="$2"
  if grep -q "github-gui" "$rcfile" 2>/dev/null; then
    warn "github-gui already present in $rcfile — skipping"
    return
  fi
  {
    echo ""
    echo "$MARKER"
    echo "$GC_FUNC"
    echo "$GHELP_FUNC"
    echo "$ALIAS_FUNCS"
    echo "$completions"
    echo "# >>> end github-gui <<<"
  } >> "$rcfile"
  success "Injected functions into $rcfile"
}

case "$CURRENT_SHELL" in
  fish)
    FISH_FUNCS="$HOME/.config/fish/functions"
    mkdir -p "$FISH_FUNCS"

    if [ -f "$FISH_FUNCS/gc.fish" ] && grep -q "github-gui" "$FISH_FUNCS/gc.fish"; then
      warn "gc.fish already configured — skipping"
    else
      cat > "$FISH_FUNCS/gc.fish" <<FISHFUNC
# github-gui: shorthand commit GUI
function gc
    node $CLI commit
end
FISHFUNC
      success "Created ~/.config/fish/functions/gc.fish"
    fi

    if [ -f "$FISH_FUNCS/ghelp.fish" ] && grep -q "github-gui" "$FISH_FUNCS/ghelp.fish"; then
      warn "ghelp.fish already configured — skipping"
    else
      cat > "$FISH_FUNCS/ghelp.fish" <<FISHFUNC
# github-gui: list all commands
function ghelp
    node $CLI help
end
FISHFUNC
      success "Created ~/.config/fish/functions/ghelp.fish"
    fi

    for alias_name in gcb ga gs gco gpl gps gst gd gb; do
      if [ -f "$FISH_FUNCS/$alias_name.fish" ] && grep -q "github-gui" "$FISH_FUNCS/$alias_name.fish"; then
        warn "$alias_name.fish already configured — skipping"
      else
        case "$alias_name" in
          gcb) git_cmd="__gui_branch" ;;
          ga)  git_cmd="add" ;;
          gs)  git_cmd="switch" ;;
          gco) git_cmd="checkout" ;;
          gpl) git_cmd="pull" ;;
          gps) git_cmd="push" ;;
          gst) git_cmd="status" ;;
          gd)  git_cmd="diff" ;;
          gb)  git_cmd="branch" ;;
        esac
        if [ "$alias_name" = "gcb" ]; then
          cat > "$FISH_FUNCS/gcb.fish" <<FISHFUNC
# github-gui: branch creation GUI
function gcb
    node $CLI branch
end
FISHFUNC
        else
          cat > "$FISH_FUNCS/$alias_name.fish" <<FISHFUNC
# github-gui: git alias
function $alias_name
    command git $git_cmd \$argv
end
FISHFUNC
        fi
        success "Created ~/.config/fish/functions/$alias_name.fish"
      fi
    done

    if [ -f "$FISH_FUNCS/gbD.fish" ] && grep -q "github-gui" "$FISH_FUNCS/gbD.fish"; then
      warn "gbD.fish already configured — skipping"
    else
      cat > "$FISH_FUNCS/gbD.fish" <<FISHFUNC
# github-gui: git alias
function gbD
    command git branch -D \$argv
end
FISHFUNC
      success "Created ~/.config/fish/functions/gbD.fish"
    fi

    # completions — teach fish that each alias wraps its git subcommand
    FISH_COMPLETIONS="$HOME/.config/fish/completions"
    mkdir -p "$FISH_COMPLETIONS"
    declare -A completion_map=(
      [ga]="git add" [gs]="git switch" [gco]="git checkout"
      [gpl]="git pull" [gps]="git push" [gst]="git status" [gd]="git diff"
      [gb]="git branch" [gbD]="git branch"
    )
    for alias_name in "${!completion_map[@]}"; do
      cat > "$FISH_COMPLETIONS/$alias_name.fish" <<FISHCOMP
complete -c $alias_name --wraps '${completion_map[$alias_name]}'
FISHCOMP
    done
    success "Created fish completions for aliases"
    ;;

  zsh)
    inject_into_file "$HOME/.zshrc" "$ZSH_COMPLETIONS"
    ;;

  bash)
    # macOS bash uses .bash_profile for login shells, .bashrc for interactive
    if [ -f "$HOME/.bash_profile" ]; then
      inject_into_file "$HOME/.bash_profile" "$BASH_COMPLETIONS"
    else
      inject_into_file "$HOME/.bashrc" "$BASH_COMPLETIONS"
    fi
    ;;

  *)
    warn "Shell '$CURRENT_SHELL' is not automatically supported."
    echo ""
    echo "Add these functions to your shell config manually:"
    echo ""
    echo "$GC_FUNC"
    echo "$GHELP_FUNC"
    echo "$ALIAS_FUNCS"
    ;;
esac

# ── 5. Done ─────────────────────────────────
echo ""
success "Installation complete!"
echo ""
echo -e "  ${CYAN}Restart your shell or reload your config, then:${RESET}"
echo ""
echo -e "  ${YELLOW}gcb${RESET}         → create a new feature/bugfix/hotfix branch"
echo -e "  ${YELLOW}git commit${RESET}  → normal git commit"
echo -e "  ${YELLOW}gc${RESET}          → interactive commit GUI"
echo -e "  ${YELLOW}ga${RESET}          → git add"
echo -e "  ${YELLOW}gs${RESET}          → git switch"
echo -e "  ${YELLOW}gco${RESET}         → git checkout"
echo -e "  ${YELLOW}gpl${RESET}         → git pull"
echo -e "  ${YELLOW}gps${RESET}         → git push"
echo -e "  ${YELLOW}gst${RESET}         → git status"
echo -e "  ${YELLOW}gd${RESET}          → git diff"
echo -e "  ${YELLOW}gb${RESET}          → git branch"
echo -e "  ${YELLOW}gbD${RESET}         → git branch -D"
echo -e "  ${YELLOW}ghelp${RESET}       → list all commands"
echo ""
