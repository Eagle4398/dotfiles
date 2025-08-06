#!/usr/bin/env bash
# Exit when non-zero status
# Unset Variable -> exit error
# Stop on errored pipe | 

# are binaries in path
REQUIRED_TOOLS=("uv" "clang") 
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "Error: Required tool '$tool' not found in PATH." >&2
        exit 1
    fi
done

if [ -d ".venv" ]; then
    echo ".venv already exists - skipping setup"
    exit 0
fi

if [ -f "uv.lock" ]; then
    echo "Found uv.lock - syncing environment..."
    uv sync
    exit 0
fi

if [ ! -f "pyproject.toml" ]; then
    echo "Initializing new Python project with uv..."
    uv init
fi

echo "Adding dependencies and creating environment/lockfile..."
uv add neovim "git+https://github.com/arne314/typstar.git"

echo "Environment setup complete"
