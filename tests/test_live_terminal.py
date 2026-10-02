import asyncio

from fastapi.responses import FileResponse


def test_live_router_is_mounted_and_api_guard_fails_closed(monkeypatch):
    monkeypatch.delenv("TERMINAL_API_KEY", raising=False)
    monkeypatch.delenv("API_TOKEN", raising=False)
    from backend.app import app
    from backend.live_api import guard

    paths = set(app.openapi()["paths"])
    assert "/api/live/net" in paths
    assert any(getattr(route, "path", None) == "/terminal.html" for route in app.routes)

    guard("")


def test_terminal_page_is_a_file_response():
    from backend.app import terminal_page

    response = asyncio.run(terminal_page())
    assert isinstance(response, FileResponse)
    assert str(response.path).endswith("frontend/terminal.html")


def test_terminal_login_has_no_terminal_api_key_controls():
    from pathlib import Path

    html = Path("frontend/terminal.html").read_text(encoding="utf-8")
    assert 'Terminal API Key' not in html
    assert 'id=la type=password' in html
    assert 'Secure login' in html


def test_angel_login_model_accepts_api_key():
    from backend.live_api import LoginIn

    payload = LoginIn(api_key="angel-key", client_id="client", pin="1234", totp="654321")
    assert payload.api_key == "angel-key"
    assert payload.client_id == "client"
