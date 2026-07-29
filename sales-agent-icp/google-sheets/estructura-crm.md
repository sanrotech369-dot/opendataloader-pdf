# Estructura del CRM en Google Sheets (base de datos gratuita del agente)

Google Sheets es el "cerebro único" del agente: la fuente de verdad de leads, estado,
scoring, fechas de seguimiento e IDs de calendario. Es **gratis**, y evita alucinaciones
porque el agente siempre lee/escribe IDs reales aquí (regla anti-alucinación del skill n8n).

Crea **un** Google Sheet llamado `ICP_CRM_ACCES` con **3 pestañas**.

---

## Pestaña 1 — `Leads`

Una fila por prospecto ICP. Campos compactados del skill maestro ACCES GROUP.
La cabecera (fila 1) debe ir **exactamente** con estos nombres de columna:

| Columna | Significado | Quién la escribe |
|---|---|---|
| `ID_Lead` | Identificador único (ej. `L-0001`) | Tú al cargar la base |
| `Empresa` | Razón comercial | Tú |
| `Sector` | Sector/industria (financiero, salud, retail, OT…) | Tú |
| `Dominio` | dominio web (acmecorp.com) | Tú |
| `Contacto` | Nombre del contacto | Tú |
| `Cargo` | Puesto del contacto | Tú |
| `Correo` | email del contacto | Tú |
| `Ciudad` | ubicación | Tú (opcional) |
| `Investigacion_Sector` | Notas de investigación del sector/empresa (dolor probable, riesgos, contexto). **Esto es lo que hace certero el mensaje.** | Tú / el chat que ya investiga |
| `Estado` | `pendiente` · `borrador_creado` · `respondio` · `agendado` · `en_pipeline` · `nutrir` · `descartado` | Agente |
| `Score_ICP` | 0–100 (pre-score) | Agente |
| `Micro_ICP` | segmento fino calculado | Agente |
| `Etapa_Pipeline` | Análisis de Requerimiento · Desarrollo · … | Agente |
| `Ultimo_Contacto` | fecha del último toque (YYYY-MM-DD) | Agente |
| `Fecha_Siguiente_Paso` | fecha del próximo seguimiento (YYYY-MM-DD) | Agente / tú |
| `Num_Toques` | cuántos correos se han generado | Agente |
| `Canal` | `correo` (WhatsApp = fase 2) | Agente |
| `Thread_Id` | ID de conversación de Outlook (para enlazar respuestas) | Agente |
| `Event_Id` | ID real del evento de Google Calendar (nunca inventar) | Agente |
| `Asunto` | asunto del último correo | Agente |
| `Notas` | bitácora breve | Agente |

> **Regla de oro (skill n8n, ATOM_A4):** el agente **nunca inventa** `Event_Id`.
> Siempre lo lee de esta hoja antes de modificar/cancelar una cita.

---

## Pestaña 2 — `Actividad`

Bitácora append-only (una fila por acción). Sirve de auditoría y evita duplicados.

| Columna | Significado |
|---|---|
| `Timestamp` | fecha-hora de la acción |
| `ID_Lead` | lead relacionado |
| `Accion` | `borrador_correo` · `respuesta_recibida` · `respuesta_borrador` · `cita_creada` · `seguimiento` |
| `Detalle` | resumen corto |
| `Score` | score en ese momento |

---

## Pestaña 3 — `Config`

Parámetros que el agente lee, en vez de tenerlos "hardcodeados".

| Clave | Valor de ejemplo |
|---|---|
| `remitente_nombre` | Juan Pérez |
| `remitente_cargo` | Ejecutivo Comercial |
| `remitente_correo` | juan.perez@accesgroup.com |
| `calendario_id` | primary |
| `duracion_reunion_min` | 30 |
| `zona_horaria` | America/Mexico_City |
| `tope_diario_correos` | 90 |

---

## Cómo cargar tus "varias bases de datos por sector"

Tus bases viven en tu computadora. Dos formas de llevarlas a la hoja `Leads`:

1. **Manual (recomendado para el piloto):** abre cada base, copia las 5–10 mejores
   cuentas y pégalas en `Leads`. Llena `Investigacion_Sector` con lo que el chat ya
   investigó (ese texto es el que personaliza el correo).
2. **Automatizada (fase 2):** un cuarto flujo de n8n puede leer una carpeta de Google
   Drive con tus CSV por sector y volcarlos a `Leads` con deduplicación (workflow 3.2
   del skill n8n). Se arma cuando el piloto quede validado.
