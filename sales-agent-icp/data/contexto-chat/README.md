# 🧠 contexto-chat/ — El "cerebro" del seguimiento

Aquí van **2 tipos de cosas** que me permiten adaptar el seguimiento y los flujos de n8n a
tu lógica real:

1. **El extracto del otro chat** (un solo `.md`) → el *porqué*: ICP, scoring, match con
   ACCES, plantillas, cadencia, empresas ya investigadas y su estado.
2. **Los archivos crudos que le cargaste a ese chat** → los *datos* que está leyendo.
   (Esos van mejor en `../bases-excel/` y `../bases-md/`; aquí puedes dejar cualquier otro
   documento de contexto: guías, notas, one-pagers de ACCES, etc.)

> 🔴 Recuerda: **verifica que el repo sea PRIVADO** antes de subir datos reales.

---

## 📋 Prompt para pedirle el extracto a tu otro chat (copia y pega tal cual)

```
Necesito que generes UN SOLO archivo Markdown llamado "contexto-icp.md" que sirva como
transferencia de conocimiento a otro sistema que dará seguimiento comercial automatizado.
No inventes nada: usa SOLO lo que hemos trabajado en este chat. Estructura el archivo con
estas secciones y encabezados:

1. ICP y micro-ICP: definición del perfil ideal de cliente y de los micro-ICP, con los
   criterios de calificación y umbrales que hemos usado.
2. Lógica de scoring: cómo puntúas o priorizas una cuenta (factores y pesos si existen).
3. Mapeo ACCES GROUP: qué servicio/solución de ACCES hace match con qué dolor y con qué
   sector.
4. Sectores trabajados: por cada sector, riesgos/dolores típicos y los ganchos de mensaje
   que funcionan.
5. Empresas ya investigadas: tabla con empresa, sector, contacto, cargo, correo, dolor o
   hipótesis, y ESTADO del contacto (no_contactado | contactado | respondió | agendado |
   descartado) y fecha del último contacto si aplica.
6. Plantillas y cadencia: los correos/plantillas y la secuencia de seguimiento que usamos
   (tiempos entre toques, canales).
7. Archivos fuente: lista de los archivos que te cargué; por cada uno, 1-2 líneas de qué
   contiene y qué columnas trae.
8. Reglas y estilo: tono, do's & don'ts, y cualquier regla de negocio.

Formato: Markdown limpio, con tablas donde aplique. Al terminar, expórtalo como archivo
descargable "contexto-icp.md".
```

---

## Dónde dejar cada cosa

```
data/
├── contexto-chat/
│   └── contexto-icp.md      ← el extracto que genere el otro chat
├── bases-excel/             ← los .xlsx / .csv que le cargaste al chat
└── bases-md/                ← los .md que le cargaste al chat
```

Cuando lo tengas arriba, escríbeme **"ya subí todo"** y yo:
- leo el contexto + los datos,
- **reestructuro los flujos de n8n y los prompts** para que usen tu ICP, tu scoring, tus
  estados y tu cadencia reales,
- consolido las empresas preservando su estado (quien ya contestó no recibe primer
  contacto),
- y te dejo el import listo para el Google Sheet.
