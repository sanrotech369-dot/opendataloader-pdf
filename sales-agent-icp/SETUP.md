# SETUP — Dejar el agente corriendo (100% gratis)

Guía paso a paso. Tiempo estimado: 60–90 min la primera vez. Todo con planes gratuitos
excepto el consumo de la API de Claude (centavos por correo) y, si quieres, un VPS barato.

---

## 0. Lo que necesitas

- [ ] Cuenta **Microsoft 365 / Outlook** (la que usarás para enviar).
- [ ] Cuenta **Google** (para Sheets + Calendar).
- [ ] **API key de Anthropic** (console.anthropic.com → API Keys).
- [ ] **n8n** (una de dos opciones abajo).

---

## 1. Instala n8n (gratis)

**Opción A — Local en tu PC (la más simple para el piloto):**
```bash
# Requiere Node.js 18+
npx n8n
# abre http://localhost:5678
```
Se queda corriendo mientras tu PC esté encendida en el horario 9:00–10:30. Perfecto para
validar el piloto.

**Opción B — VPS 24/7 (para producción):** un VPS económico (Hostinger/Contabo) con Docker:
```bash
docker run -it --rm --name n8n -p 5678:5678 \
  -e GENERIC_TIMEZONE="America/Mexico_City" \
  -e TZ="America/Mexico_City" \
  -v n8n_data:/home/node/.n8n docker.n8n.io/n8nio/n8n
```
> **Zona horaria:** ponla en `America/Mexico_City` (o la tuya). El tope de las 10:30 y las
> citas dependen de esto.

---

## 2. Crea el CRM en Google Sheets

1. Crea un Sheet llamado `ICP_CRM_ACCES` con 3 pestañas: `Leads`, `Actividad`, `Config`.
2. En `Leads`, pega la fila de cabeceras desde `google-sheets/plantilla-leads.csv`
   (o importa el CSV completo: Archivo → Importar).
3. Llena `Config` con tus datos (remitente, calendario, zona horaria) — ver
   `google-sheets/estructura-crm.md`.
4. Copia el **ID del Sheet** (está en la URL entre `/d/` y `/edit`).

---

## 3. Conecta las credenciales en n8n

En n8n → **Credentials → New**. Crea estas 4:

### 3.1 Google Sheets (OAuth2) y Google Calendar (OAuth2)
- Sigue el asistente de n8n. Necesitas un **OAuth Client** en Google Cloud Console:
  - Pantalla de consentimiento: **Externa**; agrega tu correo como **Usuario de prueba**.
  - Credencial tipo **Aplicación web**.
  - En **URIs de redireccionamiento autorizados**, pega **exactamente** la URL que te
    muestra el nodo de n8n (regla ATOM_A2 del skill n8n).
  - Habilita las APIs de **Google Sheets** y **Google Calendar** en la consola.

### 3.2 Microsoft Outlook (OAuth2)
- En **Azure Portal → App registrations → New registration**.
- Agrega el **Redirect URI** que te da n8n.
- Permisos delegados de Microsoft Graph: `Mail.ReadWrite`, `Mail.Send` (para borradores
  basta `Mail.ReadWrite`), `Calendars.ReadWrite` opcional.
- Crea un **Client secret** y pégalo en la credencial de n8n.

### 3.3 Header Auth (para Claude)  ← importante
- Credential type: **Header Auth**.
- **Name:** `x-api-key`
- **Value:** tu API key de Anthropic (`sk-ant-...`).
- Esta credencial se asigna a los 3 nodos "Claude: ..." (HTTP Request).

---

## 4. Importa los 3 workflows

En n8n → **Workflows → Import from File** e importa uno por uno:
- `n8n/01-cadencia-matutina.json`
- `n8n/02-respuestas-inbox.json`
- `n8n/03-seguimientos-fecha.json`

En **cada** workflow, tras importar:
1. Abre los nodos **Google Sheets** y reemplaza `REEMPLAZA_SHEET_ID` por tu ID real
   (o selecciónalo del desplegable). Asigna la credencial de Google Sheets.
2. Abre los nodos **Outlook** y asigna la credencial de Microsoft. Verifica el mapeo de
   campos (asunto, cuerpo HTML, destinatario). Confirma que el recurso sea **Draft →
   Create** (no Send).
3. Abre los nodos **Claude** (HTTP Request) y asigna la credencial **Header Auth**.
4. En el workflow 02, abre **Calendar: crear evento** y asigna la credencial de Calendar
   y tu `calendar id` (`primary` funciona).

---

## 5. Pon tu firma

Abre `firma/firma.html`, personalízala (o pega tu firma establecida de Outlook), y cópiala
dentro de la constante `FIRMA` del nodo **Parsear Claude** (workflow 01) y equivalentes en
02 y 03. *(Alternativa pro: guárdala en la pestaña `Config` y léela con un nodo — un solo
lugar para mantenerla.)*

---

## 6. Ajusta el modelo de Claude (si hace falta)

Los nodos usan `model: 'claude-sonnet-5'`. Si tu cuenta responde con error de modelo,
ábrelo en el campo `jsonBody` del nodo HTTP y cámbialo por el ID exacto que aparezca en tu
consola de Anthropic. Sonnet da la mejor relación calidad/costo para volumen; para máxima
calidad usa un modelo Opus.

---

## 7. Prueba el PILOTO (5–10 cuentas)

1. En `Leads`, deja solo 5–10 filas con `Estado=pendiente` y buena `Investigacion_Sector`.
2. Abre el workflow 01 y usa **Execute Workflow** (manual) para procesar 1 lead sin esperar
   al horario. Revisa el borrador generado en Outlook: tono, personalización, firma.
3. Ajusta el prompt (`prompts/01-...md` → constante system del nodo) hasta que el tono te
   convenza.
4. Cuando estés conforme, **activa** (toggle *Active*) los 3 workflows. El 01 empezará a
   generar borradores a las 9:00.
5. Responde tú mismo a un borrador de prueba desde otra cuenta para ver el workflow 02
   clasificar y agendar.

---

## 8. Operación diaria

- **9:00–10:30:** se generan borradores (1/min). Los revisas y envías por lotes.
- **Durante el día:** el 02 procesa respuestas y deja contestaciones/citas listas.
- **Cada mañana:** el 03 arma los seguimientos cuya fecha llegó.
- **Tú controlas el envío.** El agente nunca manda solo (por diseño, en esta fase).

---

## Solución de problemas

| Síntoma | Causa probable | Fix |
|---|---|---|
| El 01 sigue generando después de 10:30 | Zona horaria del servidor distinta | Fija `TZ`/`GENERIC_TIMEZONE` |
| "Invalid model" en el nodo Claude | ID de modelo | Cambia `claude-sonnet-5` por el de tu consola |
| No encuentra el lead al responder | Correo del remitente ≠ `Correo` en Sheets | Normaliza correos; revisa alias |
| Borrador sin firma | Constante `FIRMA` vacía | Pégala en el nodo Parsear |
| Se reprocesa la misma respuesta | No se marcó leído | Verifica el nodo "Outlook: marcar leído" |
| Claude devuelve texto no-JSON | Prompt alterado | Mantén la sección `<salida>` intacta |

---

## Nota sobre este repositorio

Este sistema vive en la carpeta `sales-agent-icp/` dentro del repo `opendataloader-pdf`
solo porque es la rama de trabajo asignada. Es **autocontenido**: no toca ni depende del
código del proyecto PDF. Si prefieres, cópialo a su propio repositorio.
