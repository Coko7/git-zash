#!/usr/bin/env bash

CLI_NAME="git-zash"
VERSION="0.1.0"
THUMBPRINT="$CLI_NAME-$VERSION"

# Script: git-zash.sh
# Usage: ./git-zash.sh [--help | -h] [--backup | -b] [--restore | -r]

function show_help() {
    cat <<EOF
Usage: $CLI_NAME [OPTION]
Backup/restore your git stashes.

Options:
  -b, --backup          Create a backup of your git stashes
  -r, --restore PATH    Restore backup from provided PATH
  -h, --help            Show this help message

Examples:
  $CLI_NAME --backup
  $CLI_NAME --restore /path/to/backup
EOF
}

function backup() {
    local dt=$(date +%Y%m%d-%H%M%S)

    local stash_count=$(git stash list | wc -l)
    if [ "$stash_count" -eq 0 ]; then
        echo "🤷 No stash found."
        return 0
    fi

    local bak_dir="./gsb-$dt"
    mkdir -p "$bak_dir"

  echo "Stash message: ${stash_entry#*: }"
    for ((i=0; i<stash_count; i++)); do
        echo "📦 Backing up stash@{$i}..."
        local bak_path="$bak_dir/stash_${i}.diff"
        git stash show -p "stash@{$i}" > "$bak_path"
    done

    local summary_file="$bak_dir/SUMMARY.md"
    echo -e "# $(date "+%A %d, %B %Y at %T")\n" > "$summary_file"
    git stash list >> "$summary_file"

    echo "$THUMBPRINT" > "$bak_dir/meta.txt"

    echo "✅ Successfully backed up $stash_count stashes to: $bak_dir"
}

function restore() {
    bak_path="$1"
    if [ -z "$bak_path" ]; then
        echo "Please specify a backup location: $0 --restore [PATH]"
        return 1
    fi

    if [ ! -d "$bak_path" ]; then
        echo "No such backup: $bak_path"
        return 1
    fi

    meta_path="$bak_path/meta.txt"
    if [ ! -f "$meta_path" ]; then
        echo "Invalid backup: missing meta file"
        return 1
    fi

    if [ "$(cat "$meta_path")" != "$THUMBPRINT" ]; then
        echo "Target directory is not a backup or version is incompatible"
        return 1
    fi

    for diff_file in "$bak_path"/stash_*.diff; do
        echo "📦 Restoring $diff_file as stash@{$i}..."
        git apply "$diff_file"
        if [ $? -ne 0 ]; then
            echo "Failed to apply $diff_file"
            return 1
        fi

        local stash_message="Restored stash from $(basename "$diff_file")"
        git stash push -m "$stash_message"
        if [ $? -eq 0 ]; then
            echo "Stash created: $stash_message"
        else
            echo "Failed to create stash from $diff_file"
            exit 1
        fi

        # Reset the working directory to clean state before next diff
        git reset --hard
    done

    echo "All diffs applied and stashes recreated."
}

case "$1" in
    -h|--help) show_help ;;
    -b|--backup) backup ;;
    -r|--restore) restore "$2" ;;
    *)
        echo "Error: Unknown option '$1'"
        echo "Use --help or -h for usage."
        exit 1
        ;;
esac
