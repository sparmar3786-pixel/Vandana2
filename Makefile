PY ?= python
VENV ?= .venv
PORT ?= 8000
WEB_PORT ?= 5173
PYTEST ?= $(PY) -m pytest

.PHONY: help venv install backend frontend test lint mcp clean docker

help:
	@echo "nse-ai-terminal — make targets"
	@echo "  make venv       create virtualenv"
	@echo "  make install    install requirements"
	@echo "  make backend    run FastAPI + WebSocket on :$(PORT)"
	@echo "  make frontend   serve static terminal UI on :$(WEB_PORT)"
	@echo "  make test       run pytest"
	@echo "  make mcp        run NSE MCP server (stdio)"
	@echo "  make clean      remove caches and local db"

venv:
	$(PY) -m venv $(VENV)

install:
	$(PY) -m pip install --upgrade pip
	$(PY) -m pip install -r requirements.txt

backend:
	$(PY) -m uvicorn backend.main:app --reload --host 0.0.0.0 --port $(PORT)

frontend:
	$(PY) -m http.server $(WEB_PORT) -d frontend

test:
	$(PYTEST) -q

mcp:
	$(PY) -m backend.mcp.nse_mcp_server --transport stdio

clean:
	find . -type d -name "__pycache__" -prune -exec rm -rf {} +
	rm -rf .pytest_cache data/strategy_memory.sqlite

docker:
	docker compose up --build
