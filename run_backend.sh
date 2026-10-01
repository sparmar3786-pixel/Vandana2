#!/usr/bin/env bash
# Start the FastAPI + WebSocket backend.
set -euo pipefail
cd "$(dirname "$0")"
export HOST="${HOST:-0.0.0.0}"
export PORT="${PORT:-8000}"
echo "Starting nse-ai-terminal backend on ${HOST}:${PORT}"
exec python -m uvicorn backend.main:app --host "${HOST}" --port "${PORT}" "$@"
