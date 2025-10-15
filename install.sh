#!/usr/bin/env bash

# dotfiles-zsh installer
# Symlinks .zshrc and copies template files to $HOME

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
DRY_RUN=false
FORCE=false

info() {
    printf "%s\n" "$@"
}

warn() {
    printf "Warning: %s\n" "$@" >&2
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "OPTIONS:"
    echo "  -n, --dry-run    Show what would be done without executing"
    echo "  --force          Overwrite existing template files (with backup)"
    echo "  -h, --help       Show this help message"
    exit 0
}

backup_file() {
    local file="$1"
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S)
    local backup="${file}.bak-${timestamp}"
    
    if [ -f "$file" ] || [ -L "$file" ]; then
        if [ "$DRY_RUN" = true ]; then
            echo "Would backup: $file -> $backup"
        else
            echo "Backing up: $file -> $backup"
            cp "$file" "$backup" 2>/dev/null || mv "$file" "$backup"
        fi
    fi
}

create_symlink() {
    local source="$1"
    local target="$2"
    
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        echo "Symlink already correct: $target -> $source"
        return
    fi
    
    if [ -f "$target" ] || [ -L "$target" ]; then
        backup_file "$target"
    fi
    
    if [ "$DRY_RUN" = true ]; then
        echo "Would symlink: $target -> $source"
    else
        echo "Creating symlink: $target -> $source"
        ln -sf "$source" "$target"
    fi
}

copy_template() {
    local source="$1"
    local target="$2"
    local filename
    filename="$(basename "$target")"
    
    if [ -f "$target" ]; then
        if [ "$FORCE" = true ]; then
            backup_file "$target"
            if [ "$DRY_RUN" = true ]; then
                echo "Would copy template: $filename"
            else
                echo "Copying template (forced): $filename"
                cp "$source" "$target"
            fi
        else
            echo "Skipping existing file: $filename (use --force to overwrite)"
        fi
    else
        if [ "$DRY_RUN" = true ]; then
            echo "Would copy template: $filename"
        else
            echo "Copying template: $filename"
            cp "$source" "$target"
        fi
    fi
}

detect_default_shell() {
    if command -v getent >/dev/null 2>&1; then
        getent passwd "$USER" | awk -F: '{print $7}'
    elif command -v dscl >/dev/null 2>&1; then
        dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}'
    else
        printf "%s\n" "${SHELL:-}"
    fi
}

check_zsh_status() {
    local zsh_path default_shell
    zsh_path="$(command -v zsh 2>/dev/null || true)"
    default_shell="$(detect_default_shell)"

    if [ -z "$zsh_path" ]; then
        warn "zsh not found on PATH. Install zsh to use these dotfiles fully."
        return
    fi

    info "Detected zsh at: $zsh_path"

    if [ -z "$default_shell" ]; then
        warn "Unable to determine your default shell."
        return
    fi

    if [ "$default_shell" != "$zsh_path" ]; then
        warn "Your login shell is '$default_shell'. Consider running 'chsh -s \"$zsh_path\" $USER' to switch to zsh."
    fi
}

# Parse arguments
while [ $# -gt 0 ]; do
    case $1 in
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

echo "dotfiles-zsh installer"
echo "======================"
echo "Dotfiles directory: $DOTFILES_DIR"
echo "Target directory: $HOME"

check_zsh_status

if [ "$DRY_RUN" = true ]; then
    echo "DRY RUN MODE - no changes will be made"
fi

echo ""

# Symlink .zshrc
create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# Copy template files
echo ""
echo "Processing templates:"
for template in "$DOTFILES_DIR"/templates/.*; do
    # Skip . and .. entries
    case "$(basename "$template")" in
        .|..) continue ;;
    esac
    
    # Skip if no templates found (glob did not expand)
    [ -f "$template" ] || continue
    
    target="$HOME/$(basename "$template")"
    copy_template "$template" "$target"
done

echo ""
if [ "$DRY_RUN" = true ]; then
    echo "Dry run complete. Use without -n to apply changes."
else
    echo "Installation complete!"
    echo ""
    echo "Next steps:"
    echo "1. Source your new .zshrc: source ~/.zshrc"
    echo "2. Customize ~/.shell_defaults and ~/.shell_post as needed"
fi
