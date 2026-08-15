#!/usr/bin/env bash
# Instala ScrapeGraphAI (https://github.com/ScrapeGraphAI/Scrapegraph-ai) en un
# virtualenv aislado, aplica los parches necesarios y verifica la instalacion.
#
# Uso:
#   bash tools/scrapegraphai/install.sh             # venv en ~/.venvs/scrapegraphai
#   VENV_DIR=/ruta/venv bash tools/scrapegraphai/install.sh
#   SCRAPEGRAPHAI_VERSION=1.76.0 bash tools/scrapegraphai/install.sh
set -euo pipefail

VENV_DIR="${VENV_DIR:-$HOME/.venvs/scrapegraphai}"
SCRAPEGRAPHAI_SPEC="scrapegraphai${SCRAPEGRAPHAI_VERSION:+==$SCRAPEGRAPHAI_VERSION}"

# Revision de Chromium -> version de Playwright que la empaqueta. Se usa solo
# cuando el entorno trae navegadores preinstalados y prohibe descargarlos.
declare -A PLAYWRIGHT_FOR_CHROMIUM_REV=(
  [1194]=1.56.0
  [1200]=1.57.0
  [1208]=1.58.0
)

log() { printf '\n==> %s\n' "$*"; }

# --- 1. venv ---------------------------------------------------------------
log "Creando virtualenv en $VENV_DIR"
if command -v uv >/dev/null 2>&1; then
  uv venv "$VENV_DIR"
  PY="$VENV_DIR/bin/python"
  pip_install() { uv pip install --python "$PY" "$@"; }
else
  python3 -m venv "$VENV_DIR"
  PY="$VENV_DIR/bin/python"
  pip_install() { "$PY" -m pip install "$@"; }
  "$PY" -m pip install --upgrade pip
fi

# --- 2. paquete ------------------------------------------------------------
log "Instalando $SCRAPEGRAPHAI_SPEC"
pip_install "$SCRAPEGRAPHAI_SPEC"

SITE_PACKAGES="$("$PY" -c 'import scrapegraphai, os; print(os.path.dirname(os.path.dirname(scrapegraphai.__file__)))')"

# --- 3. parche ChatOllama --------------------------------------------------
# scrapegraphai 1.76.0 todavia importa ChatOllama desde langchain_community,
# de donde fue eliminado en langchain-community 0.4. La clase vive ahora en
# langchain-ollama, que el propio paquete ya declara como dependencia.
if grep -rqs "from langchain_community.chat_models import ChatOllama" "$SITE_PACKAGES/scrapegraphai"; then
  log "Parcheando imports de ChatOllama -> langchain_ollama"
  grep -rl "from langchain_community.chat_models import ChatOllama" \
    --include='*.py' "$SITE_PACKAGES/scrapegraphai" |
    xargs sed -i 's/^from langchain_community\.chat_models import ChatOllama$/from langchain_ollama import ChatOllama/'
  find "$SITE_PACKAGES/scrapegraphai" -name __pycache__ -type d -exec rm -rf {} + 2>/dev/null || true
else
  log "Imports de ChatOllama ya correctos, sin parche"
fi

# --- 4. navegador de Playwright -------------------------------------------
log "Verificando navegador de Playwright"
EXPECTED_REV="$("$PY" - <<'PYEOF'
import json, pathlib
from playwright._impl._driver import compute_driver_executable
manifest = pathlib.Path(compute_driver_executable()[1]).parent.parent / "package" / "browsers.json"
data = json.loads(manifest.read_text())
print(next(b["revision"] for b in data["browsers"] if b["name"] == "chromium"))
PYEOF
)"
BROWSERS_PATH="${PLAYWRIGHT_BROWSERS_PATH:-$HOME/.cache/ms-playwright}"

if [ -d "$BROWSERS_PATH/chromium-$EXPECTED_REV" ]; then
  echo "Chromium $EXPECTED_REV ya disponible en $BROWSERS_PATH"
elif [ "${PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD:-0}" = "1" ]; then
  # Entorno gestionado con navegadores preinstalados: en vez de descargar,
  # alineamos la version de Playwright con el Chromium que ya existe.
  PRESENT_REV="$(ls -d "$BROWSERS_PATH"/chromium-* 2>/dev/null | head -1 | sed 's/.*chromium-//')"
  TARGET_PW="${PLAYWRIGHT_FOR_CHROMIUM_REV[${PRESENT_REV:-none}]:-}"
  if [ -n "$TARGET_PW" ]; then
    echo "Chromium preinstalado rev $PRESENT_REV; fijando playwright==$TARGET_PW"
    pip_install --no-deps "playwright==$TARGET_PW"
  else
    echo "AVISO: Chromium preinstalado (rev ${PRESENT_REV:-desconocida}) no coincide con" \
         "playwright (espera $EXPECTED_REV) y no hay mapeo conocido."
    echo "AVISO: pasa executable_path='$BROWSERS_PATH/chromium' en loader_kwargs al usar los grafos."
  fi
else
  "$PY" -m playwright install chromium
fi

# --- 5. verificacion -------------------------------------------------------
log "Verificando instalacion"
"$PY" "$(dirname "$0")/smoke_test.py"

log "Listo. Interprete: $PY"
echo "Activar con: source $VENV_DIR/bin/activate"
