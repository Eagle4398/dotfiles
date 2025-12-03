#!/usr/bin/env bash
# Exit when non-zero status
# Unset Variable -> exit error
# Stop on errored pipe | 

exit 0

# are binaries in path
REQUIRED_TOOLS=("uv" "clang") 
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "Error: Required tool '$tool' not found in PATH." >&2
        exit 1
    fi
done

if [ -d "$HOME/.config/nvim/.venv" ]; then
    echo ".venv already exists - skipping setup"
    exit 0
fi

if [ -f "$HOME/config/nvim/uv.lock" ]; then
    echo "Found uv.lock - syncing environment..."
    cd "$HOME/config/nvim/"
    uv sync
    exit 0
fi

if [ ! -f "pyproject.toml" ]; then
    echo "Initializing new Python project with uv..."
    cd "$HOME/config/nvim/"
    uv init
    echo "Adding dependencies and creating environment/lockfile..."
    uv add neovim "git+https://github.com/arne314/typstar.git"
    echo "Environment setup complete"
    exit 0
fi

echo "Some kind of error..."
exit 1 


