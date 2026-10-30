#!/usr/bin/env bash
# ==============================================================================
# D AI Assistant — Backend Runner
# Starts FastAPI server on http://127.0.0.1:8000
# ==============================================================================

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR/backend"

if [ ! -d ".venv" ]; then
    echo "Creating Python virtualenv..."
    python3 -m venv .venv
    .venv/bin/pip install --upgrade pip
    .venv/bin/pip install -r requirements.txt
    .venv/bin/pip install aiosqlite
fi

if [ ! -f ".env" ]; then
    echo "Initializing .env from .env.example..."
    cp .env.example .env
fi

echo "=================================================="
echo " Starting D AI Backend on http://127.0.0.1:8000"
echo " Interactive Docs: http://127.0.0.1:8000/docs"
echo " Health Status:    http://127.0.0.1:8000/api/v1/health"
echo "=================================================="

exec .venv/bin/uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
