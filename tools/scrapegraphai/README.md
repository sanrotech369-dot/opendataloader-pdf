# ScrapeGraphAI

Instalación reproducible de [ScrapeGraphAI](https://github.com/ScrapeGraphAI/Scrapegraph-ai)
en un virtualenv aislado. No es una dependencia de `opendataloader-pdf`: es una
herramienta auxiliar, por eso vive en su propio entorno y no toca `python/`.

## Instalar

```bash
bash tools/scrapegraphai/install.sh
```

Variables opcionales:

| Variable | Por defecto | Uso |
| --- | --- | --- |
| `VENV_DIR` | `~/.venvs/scrapegraphai` | Dónde crear el entorno |
| `SCRAPEGRAPHAI_VERSION` | última publicada | Fijar una versión concreta |

Usa `uv` si está disponible y cae a `python3 -m venv` + `pip` si no.

## Usar

```bash
source ~/.venvs/scrapegraphai/bin/activate
export OPENAI_API_KEY=...   # o la clave del proveedor que uses
```

```python
from scrapegraphai.graphs import SmartScraperGraph

graph = SmartScraperGraph(
    prompt="Extrae los productos y sus precios",
    source="https://ejemplo.com/catalogo",
    config={
        "llm": {"model": "openai/gpt-4o-mini", "api_key": "..."},
        "headless": True,
    },
)
print(graph.run())
```

También queda instalado `scrapegraph-py`, el cliente del servicio gestionado
(`SGAI_API_KEY`), por si prefieres no ejecutar los grafos en local.

## Verificar

```bash
~/.venvs/scrapegraphai/bin/python tools/scrapegraphai/smoke_test.py
```

Comprueba imports, arranque de Chromium, `ChromiumLoader` y construcción de un
grafo. No llama al LLM, así que no necesita credenciales.

## Dos arreglos que aplica el instalador

1. **`ChatOllama`.** `scrapegraphai` 1.76.0 aún importa `ChatOllama` desde
   `langchain_community.chat_models`, de donde se eliminó en
   `langchain-community` 0.4. Sin el parche, `import scrapegraphai.graphs`
   falla con `ImportError`. El instalador reescribe esos imports a
   `langchain_ollama`, que el propio paquete ya declara como dependencia.
   Es un bug del paquete publicado; cuando upstream lo corrija, el parche se
   vuelve un no-op (el script lo detecta y lo omite).

2. **Versión de Playwright.** En entornos con navegadores preinstalados y
   `PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1`, la revisión de Chromium disponible
   puede no coincidir con la que espera la última versión de Playwright. El
   instalador fija la versión de Playwright que empaqueta esa revisión en
   lugar de descargar un navegador nuevo. Fuera de esos entornos simplemente
   ejecuta `playwright install chromium`.
