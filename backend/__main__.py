"""Allow `python -m backend` to start the API server."""
from __future__ import annotations

import uvicorn

from backend.config import get_settings


def main() -> None:
    s = get_settings()
    uvicorn.run("backend.main:app", host=s.host, port=s.port, reload=False)


if __name__ == "__main__":
    main()
