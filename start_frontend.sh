#!/usr/bin/env bash
# ==============================================================================
# D AI Assistant — Frontend Web Runner
# Serves the compiled Flutter UI and opens Safari
# ==============================================================================

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

export XDG_CONFIG_HOME="/tmp/d_config"

# If build/web doesn't exist, build it
if [ ! -d "build/web" ]; then
    echo "Compiling Flutter Web assets..."
    flutter build web
fi

echo "=================================================="
echo " Starting D AI Frontend on http://localhost:3000"
echo " Opening in Safari / Default Browser..."
echo "=================================================="

# Open browser after a slight delay
(sleep 1 && open "http://localhost:3000") &

# Serve with python built-in server
exec python3 -m http.server 3000 --directory build/web
