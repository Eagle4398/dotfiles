#!/usr/bin/env bash

# Check if 'stow' is available in PATH
if ! command -v stow >/dev/null 2>&1; then
    echo "stow is necessary in PATH"
    exit 1
fi

DRY_RUN=false

if [[ "$1" == "dry" ]]; then
    DRY_RUN=true
    shift
    echo "Running in dry-run mode. Commands will be printed but not executed."
fi

if ! $DRY_RUN; then
    echo "WARNING: Current config targets will be renamed to _bak or .bak."
    echo "If there is another config which is already appended with _bak or .bak, it will be irreversibly destroyed."
    read -p "Proceed? ([y], n) " confirm
    if [[ ! "$confirm" =~ ^([yY]|)$ ]]; then
        echo "Aborted by user."
        exit 2
    fi
fi

# I mean at this point one might ask: Why not just use home-manager?
# And one could. Literally. I use home-manager on NixOS. This is just non-nixy
# backup with primitive stow.
input_file="./stowignore/stowpaths.txt" 

# wrapper for dry run
execute() {
    if $DRY_RUN; then
        echo "WOULD EXECUTE: $@"
    else
        "$@"
    fi
}

# ingest stow paths
while IFS= read -r line || [ -n "$line" ]; do
    # replace $HOME with ~
    path="${line//\$HOME/~}"
    # trim.
    path="$(echo "$path" | sed 's/[[:space:]]*$//')"

    # if paths ends with /* then folder and symlink members
    # if someone then writes into e.g. ~/.config/app/...
    # then it will not be transferred into the dotfiles
    if [[ "$path" =~ /\*[[:space:]]*$ ]]; then
        dir="${path%/*}"
        dir="${dir//\~/$HOME}"
        parent_dir="$(dirname "$dir")"
        if [ ! -d "$parent_dir" ]; then
            execute mkdir -p "$parent_dir"
        fi

    # if path ends with / then symlink the folder. writes
    # into that folder will be transferred to dotfiles
    elif [[ "$path" =~ /[[:space:]]*$ ]]; then
        dir="${path//\~/$HOME}"
        dir="$(echo "$dir" | sed 's:[/[:space:]]*$::')"
        if [ ! -d "$dir" ]; then
            parent_dir="$(dirname "$dir")"
            if [ ! -d "$parent_dir" ]; then
                execute mkdir -p "$parent_dir"
            fi
        else
            execute mv "$dir" "${dir}_bak"
        fi
    
    # in this case it is just a file
    else
        file="${path//\~/$HOME}"
        if [ -e "$file" ]; then
            execute mv "$file" "${file}.bak"
        fi
    fi
done < "$input_file"

# get current script dir (root of dotfiles)
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# from this positionexecute stow
cd "$script_dir" || exit 3
if $DRY_RUN; then
    echo "WOULD EXECUTE: stow -t \"$HOME\" *"
else
    # This now matches the dry run's logic
    # stow . # sometimes doesn't work?
    stow -t "$HOME" *
fi
