# github-gui

A minimal terminal GUI for structured git branch and commit workflows. Prompts you interactively for branch type, ticket ID, and commit message — then does the git work for you.

---

## What it does

**Creating a branch** (`gcb`):
1. Asks: branch type — `feature`, `bugfix`, or `hotfix`
2. Asks: ticket / task ID — e.g. `SMN-222`
3. Asks: short description — e.g. `add login page`
4. Creates and checks out: `feature/SMN-222/add-login-page`

**Committing** (`gc`):
1. Shows your staged changes
2. Asks: commit type — `FEATURE`, `BUGFIX`, `HOTFIX`, `REVERT`, or `BUMP`
3. Asks: commit message
4. Commits with: `FEATURE: Add login page`

---

## Requirements

- **Node.js** v18 or later — [nodejs.org](https://nodejs.org)
- **macOS** (Linux should work too, untested)
- **git**

---

## Install

Clone or copy this project somewhere permanent (it must stay in place after install):

```sh
git clone https://github.com/you/github-gui ~/local/github-gui
cd ~/local/github-gui
./install.sh
```

Then restart your terminal (or reload your shell config).

The installer auto-detects your shell and injects the right functions:

| Shell | Config file modified |
|-------|----------------------|
| fish  | `~/.config/fish/functions/` — one `.fish` file per alias |
| zsh   | `~/.zshrc` |
| bash  | `~/.bash_profile` (or `~/.bashrc`) |

---

## Usage

### Create a branch

```sh
gcb
```

```
? Branch type:
❯ ✨  feature  – new feature
  🐛  bugfix   – bug fix
  🔥  hotfix   – urgent fix

? Ticket / Task ID (e.g. SMN-222): SMN-222
? Short description (becomes the branch slug): add login page

🌿 Creating branch: feature/SMN-222/add-login-page
```

### Commit and push

```sh
gc
```

```
📋 Staged changes:
 src/login.js | 42 +++++++

? Commit type:
❯ ✨  FEATURE  – new feature
  🐛  BUGFIX   – bug fix
  🔥  HOTFIX   – urgent fix
  ⏪  REVERT   – revert change

? Commit message: Add login page

✅ Committing: "FEATURE: Add login page"
```

Then run `gps` to push.
```

### Git aliases

The following shorthand aliases are also installed:

| Alias | Equivalent |
|-------|------------|
| `gcb` | branch creation GUI |
| `ga`  | `git add` |
| `gs`  | `git switch` |
| `gco` | `git checkout` |
| `gpl` | `git pull` |
| `gps` | `git push` |
| `gst` | `git status` |
| `gd`  | `git diff` |
| `gm`  | `git merge` |
| `gb`  | `git branch` |
| `gbD` | `git branch -D` |

Run `ghelp` at any time to print the full command list.

All aliases pass extra arguments through, e.g. `gs stage`, `ga .`, `gps origin main`.

### Pass-through behaviour

- `git commit` and all other `git` commands work normally — no interception.

---

## Manual install (any shell)

If the installer doesn't support your shell, add these functions to your shell config:

```sh
function gcb() { node /path/to/github-gui/cli.js branch; }
function gc()  { node /path/to/github-gui/cli.js commit; }
function ga()  { command git add "$@"; }
function gs()  { command git switch "$@"; }
function gco() { command git checkout "$@"; }
function gpl() { command git pull "$@"; }
function gps() { command git push "$@"; }
function gst() { command git status "$@"; }
function gd()  { command git diff "$@"; }
function gb()  { command git branch "$@"; }
function gbD() { command git branch -D "$@"; }
```

Replace `/path/to/github-gui` with the actual path where you cloned this repo.

---

## Project structure

```
github-gui/
├── cli.js          # Entry point — routes commit/branch subcommands
├── src/
│   ├── commit.js   # Interactive commit + push workflow
│   └── branch.js   # Interactive branch creation workflow
├── install.sh      # Automated installer (fish / zsh / bash)
└── package.json
```

---

## Uninstall

Remove the injected block from your shell config (look for `# >>> github-gui <<<`) and delete the project folder.

For fish, delete:
```sh
rm ~/.config/fish/functions/gcb.fish
rm ~/.config/fish/functions/gc.fish
rm ~/.config/fish/functions/ga.fish
rm ~/.config/fish/functions/gs.fish
rm ~/.config/fish/functions/gco.fish
rm ~/.config/fish/functions/gpl.fish
rm ~/.config/fish/functions/gps.fish
rm ~/.config/fish/functions/gst.fish
rm ~/.config/fish/functions/gd.fish
rm ~/.config/fish/functions/gb.fish
rm ~/.config/fish/functions/gbD.fish
```
