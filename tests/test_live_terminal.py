import asyncio

from fastapi.responses import FileResponse


def test_live_router_is_mounted_and_api_guard_fails_closed(monkeypatch):
    monkeypatch.setenv("TERMINAL_API_KEY", "test-key")
    from backend.app import app
    from backend.live_api import guard

    paths = {getattr(route, "path", None) for route in app.routes}
    assert "/api/live/net" in paths
    assert "/terminal.html" in paths

    try:
        guard("")
    except Exception as exc:
        assert getattr(exc, "status_code", None) == 401
    else:
        raise AssertionError("missing API key must be rejected")


def test_terminal_page_is_a_file_response():
    from backend.app import terminal_page

    response = asyncio.run(terminal_page())
    assert isinstance(response, FileResponse)
    assert response.path.endswith("frontend/terminal.html")


def test_terminal_login_has_editable_api_key_controls():
    from pathlib import Path

    html = Path("frontend/terminal.html").read_text(encoding="utf-8")
    assert 'id=lk type=password' in html
    assert 'Save / Update API Key' in html
    assert 'function toggleTerminalKey()' in html
