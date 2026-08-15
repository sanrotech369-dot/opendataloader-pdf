"""Verificacion de la instalacion de ScrapeGraphAI.

No requiere clave de API: comprueba los imports, el arranque de Chromium via
Playwright, la carga de una pagina local con ChromiumLoader y la construccion
de un SmartScraperGraph. La llamada real al LLM queda fuera de alcance porque
depende de credenciales del usuario.
"""

import importlib.metadata as md
import pathlib
import tempfile

DEMO_HTML = """<html><head><title>Demo</title></head><body>
<h1>Productos</h1><ul><li>Router X - $120</li><li>Firewall Y - $890</li></ul>
</body></html>"""


def main() -> None:
    print("scrapegraphai", md.version("scrapegraphai"))
    print("playwright   ", md.version("playwright"))

    from scrapegraphai.graphs import (  # noqa: F401
        OmniScraperGraph,
        ScriptCreatorGraph,
        SearchGraph,
        SmartScraperGraph,
    )
    from scrapegraphai.nodes import (  # noqa: F401
        FetchNode,
        GenerateAnswerNode,
        ParseNode,
        SearchInternetNode,
    )
    from scrapegraphai.docloaders import ChromiumLoader

    print("[ok] imports de graphs, nodes y docloaders")

    from playwright.sync_api import sync_playwright

    with sync_playwright() as p:
        browser = p.chromium.launch(args=["--no-sandbox"])
        page = browser.new_page()
        page.set_content("<h1>ok</h1>")
        assert page.inner_text("h1") == "ok"
        browser.close()
    print("[ok] Chromium arranca via Playwright")

    with tempfile.TemporaryDirectory() as tmp:
        demo = pathlib.Path(tmp, "demo.html")
        demo.write_text(DEMO_HTML, encoding="utf-8")
        docs = ChromiumLoader(
            [demo.as_uri()], backend="playwright", headless=True, args=["--no-sandbox"]
        ).load()
        assert "Firewall Y" in docs[0].page_content, docs[0].page_content
    print("[ok] ChromiumLoader carga y extrae HTML")

    graph = SmartScraperGraph(
        prompt="Lista los productos y precios",
        source="https://example.com",
        config={
            "llm": {"model": "openai/gpt-4o-mini", "api_key": "sk-dummy"},
            "headless": True,
            "verbose": False,
        },
    )
    assert len(graph.graph.nodes) >= 3
    print(f"[ok] SmartScraperGraph construido ({len(graph.graph.nodes)} nodos)")
    print("\nVerificacion completa.")


if __name__ == "__main__":
    main()
