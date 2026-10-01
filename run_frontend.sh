#!/usr/bin/env bash
# Serve the static browser terminal UI.
set -euo pipefail
cd "$(dirname "$0")"
WEB_PORT="${WEB_PORT:-5173}"
echo "Serving frontend on http://localhost:${WEB_PORT}"
exec python -m http.server "${WEB_PORT}" -d frontend
