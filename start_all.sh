#!/usr/bin/env bash
# ==============================================================================
# D AI Assistant — Launch Everything (Backend + Frontend)
# ==============================================================================

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

echo "=================================================="
echo " Launching D AI Assistant on Local Machine"
echo "=================================================="

# Function to kill child processes on exit
cleanup() {
    echo ""
    echo "Stopping D AI services..."
    kill $(jobs -p) 2>/dev/null || true
    exit 0
}
trap cleanup SIGINT SIGTERM EXIT

# 1. Start Backend in background
./start_backend.sh &
BACKEND_PID=$!

# Wait 2 seconds for backend to initialize
sleep 2

# 2. Start Frontend in background
./start_frontend.sh &
FRONTEND_PID=$!

echo ""
echo " Both Backend & Frontend are running!"
echo " Backend:  http://127.0.0.1:8000"
echo " Frontend: http://localhost:3000"
echo " Press Ctrl+C in this terminal to stop all services."
echo ""

wait
