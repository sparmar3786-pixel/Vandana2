import os

import pytest
from fastapi.testclient import TestClient


def test_live_router_is_mounted_and_requires_api_key(monkeypatch):
    monkeypatch.setenv("TERMINAL_API_KEY", "test-key")
    from backend.app import app

    client = TestClient(app)
    response = client.get("/api/live/net")
    assert response.status_code == 401

    response = client.get("/api/live/net", headers={"X-API-Key": "test-key"})
    assert response.status_code == 200
    assert "offline" in response.json()


def test_terminal_page_is_served():
    from backend.app import app

    client = TestClient(app)
    response = client.get("/terminal.html")
    assert response.status_code == 200
    assert "NSE-AI-TERMINAL" in response.text
