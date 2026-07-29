# Agente Comercial Autónomo — Seguimiento de ICP (ACCES GROUP)

Sistema de seguimiento comercial B2B que **califica leads ICP, redacta correos
personalizados, agenda reuniones y los mueve al pipeline** — construido sobre
**n8n gratuito (self-hosted)** + **Claude** + **Outlook** + **Google Calendar** +
**Google Sheets** como CRM.

Combina dos bases de conocimiento de ACCES GROUP: el *Agente Maestro de Seguimiento
Comercial B2B* (metodología: ICP/BANT/MEDDICC, cadencias con valor, anti-presión) y el
skill de *Automatización n8n* (flujos deterministas, OAuth, anti-alucinación de IDs).

---

## ⚠️ Léeme primero: qué es y qué no es

| Requisito que pediste | Cómo se resuelve aquí | Estado |
|---|---|---|
| Seguir ICP de varias bases de datos | Se consolidan en un Google Sheet (`Leads`). Fase 2: ingesta automática desde carpetas/Drive | ✅ / 🔜 |
| 1 correo por minuto, 9:00–10:30 diario | Workflow 01: Schedule Trigger cada minuto 9–10 L-V con tope a las 10:30 | ✅ |
| Correos con Outlook y firma establecida | Nodo Microsoft Outlook crea **borradores** con tu firma; tú revisas y envías | ✅ |
| Si responden, contestar | Workflow 02: detecta respuesta, clasifica intención, redacta contestación | ✅ |
| Agendar reuniones | Workflow 02: crea evento en Google Calendar (guarda el `Event_Id` real) | ✅ |
| Seguimientos con fecha (correo/WhatsApp) | Workflow 03: correo automático en la fecha. **WhatsApp = fase 2** (Evolution API) | ✅ / 🔜 |
| Calificar el LEAD y meterlo al pipeline | Claude aplica pre-score ICP y mueve `Etapa_Pipeline` por evidencia | ✅ |

**Decisiones que ya tomamos juntos:**
- **Borradores, no envío automático.** El agente deja el correo listo en Outlook; tú das
  clic en enviar. Protege tu dominio de spam (límite Google/Yahoo: <0.1% quejas) y evita
  contactar sin criterio. Puedes migrar a envío automático cuando el piloto convenza.
- **Piloto primero:** 5–10 cuentas ICP reales para validar tono y calidad antes de escalar.
- **Outlook, no Gmail.** Todo el envío/borrador va por Microsoft Outlook (Microsoft Graph
  dentro de n8n).

**Por qué corre en TU n8n y no "aquí":** tus bases de datos por sector viven en tu
computadora. n8n self-hosted (gratis) corre en tu entorno, con acceso a tus datos, tu
Outlook y tu calendario. Nada de tu información sale a terceros.

---

## Arquitectura

```
                         ┌──────────────────────────────┐
                         │   Google Sheet  "ICP_CRM"     │  ← cerebro único (gratis)
                         │   Leads · Actividad · Config  │
                         └──────────────┬───────────────┘
                                        │ lee / escribe (IDs reales, sin inventar)
        ┌───────────────────────────────┼───────────────────────────────┐
        ▼                               ▼                               ▼
┌─────────────────┐          ┌─────────────────────┐         ┌────────────────────┐
│ 01 Cadencia      │          │ 02 Respuestas        │        │ 03 Seguimientos     │
│ matutina         │          │ + Agenda             │        │ con fecha           │
│ 9:00–10:30 L-V   │          │ cada 10 min          │        │ 9:00 L-V            │
│ 1 borrador/min   │          │                      │        │                     │
│                  │          │  Outlook (leer)      │        │  filtra fecha=hoy   │
│ Claude califica  │          │  Claude clasifica    │        │  Claude redacta     │
│ + redacta        │          │  Calendar (agenda)   │        │  seguimiento c/valor│
│ Outlook borrador │          │  Outlook borrador    │        │  Outlook borrador   │
└─────────────────┘          └─────────────────────┘         └────────────────────┘
        │                               │                               │
        └───────────────► Claude (Anthropic API vía HTTP) ◄─────────────┘
              modelo de calificación ICP / redacción / clasificación
```

**Diseño híbrido (regla del skill n8n):** el ruteo lo hacen nodos deterministas
(Schedule, IF, Code); Claude solo se usa para lo que requiere criterio (calificar,
redactar, clasificar). Así el flujo del negocio tiene tasa de fallo ~0% y la IA no
"pierde el foco".

---

## Contenido del repositorio

```
sales-agent-icp/
├── README.md                        ← este archivo
├── SETUP.md                         ← guía paso a paso (gratis) para dejarlo corriendo
├── n8n/
│   ├── 01-cadencia-matutina.json    ← importable en n8n
│   ├── 02-respuestas-inbox.json     ← importable en n8n
│   └── 03-seguimientos-fecha.json   ← importable en n8n
├── prompts/
│   ├── 01-calificacion-redaccion.md ← system prompt (versión legible/editable)
│   └── 02-clasificacion-respuestas.md
├── google-sheets/
│   ├── estructura-crm.md            ← esquema de las 3 pestañas
│   └── plantilla-leads.csv          ← cabeceras + 3 filas de ejemplo
└── firma/
    └── firma.html                   ← molde de tu firma corporativa
```

---

## Flujo de un lead (de principio a fin)

1. Cargas la cuenta ICP en `Leads` con `Estado=pendiente` y su `Investigacion_Sector`.
2. **09:0X** → Workflow 01 toma 1 lead/min, Claude lo califica (score ICP) y redacta el
   primer contacto → **borrador en Outlook**. `Estado=borrador_creado`.
3. Revisas el borrador y lo envías.
4. El prospecto responde → Workflow 02 lo detecta, Claude clasifica:
   - *Quiere reunión* → crea evento en Calendar + borrador de confirmación. `Estado=agendado`.
   - *Objeción/pregunta* → borrador de contestación consultiva. `Estado=respondio`.
   - *No interesado* → cierre sin presión. `Estado=nutrir`.
5. Si no responde, en `Fecha_Siguiente_Paso` → Workflow 03 redacta un seguimiento **con
   valor** (nunca "solo dando seguimiento").
6. Cuando hay evidencia (reunión, requerimiento), Claude mueve la `Etapa_Pipeline` y queda
   listo para exportar a Zoho CRM (fase 2).

---

## Fase 2 (cuando el piloto convenza)

- **WhatsApp** para seguimientos (Evolution API + `CONFIG_SESSION_PHONE_VERSION=2.3000.1023`).
- **Ingesta automática** de tus carpetas/CSV por sector con deduplicación.
- **Envío automático** (en vez de borrador) con tope diario y control de reputación.
- **Sync a Zoho CRM** de oportunidades calificadas.

Consulta **SETUP.md** para dejarlo funcionando.
