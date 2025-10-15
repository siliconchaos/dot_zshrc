# dot_zshrc

Simple Zsh dotfiles setup: the repo tracks `~/.zshrc` and seeds local hook files you can edit without touching Git history.

## Install

```bash
git clone <remote-url> ~/silentcastle/projects/dot_zshrc
cd ~/silentcastle/projects/dotfiles-zsh
./install.sh --dry-run   # optional preview
./install.sh
```

The installer always creates backups such as `~/.zshrc.bak-YYYYMMDD-HHMMSS`.

### Flags

- `--dry-run` shows planned actions
- `--force` refreshes local templates (backs up first)
- `--help` prints usage

## Customize

- Edit `~/.zshrc` within the repo for shared changes, then commit.
- Edit `~/.shell_defaults` for early environment tweaks.
- Edit `~/.shell_post` for host-specific overrides.
- Rerun `./install.sh --force` if you want to pull in updated templates.

Pull the repo to pick up shared updates; the `.zshrc` symlink updates automatically.
