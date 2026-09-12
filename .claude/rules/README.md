# Reglas token-efficient: donde aplican y como instalarlas

Reglas en `token-efficient.md`, adaptadas de
https://github.com/drona23/claude-token-efficient (MIT).
Incluyen una regla de override: si pides detalle en un mensaje, las reglas
se ignoran para ese mensaje.

Claude no tiene un unico lugar que cubra "todos los proyectos, chats y
coworks" a la vez. Son cuatro niveles distintos y cada uno se instala
aparte.

## 1. Este repo (ya hecho, vive en git)

`CLAUDE.md` importa `@.claude/rules/token-efficient.md`. Aplica en cada
sesion de Claude Code sobre este repo, local o en la web, sin instalar
nada mas.

## 2. Todos los proyectos de una maquina

```bash
./scripts/install-token-efficient.sh --global
```

Escribe un bloque delimitado en `~/.claude/CLAUDE.md`. Se puede volver a
correr sin duplicar. Para quitarlo, borra el bloque entre
`<!-- BEGIN token-efficient -->` y `<!-- END token-efficient -->`.

Nota: en sesiones remotas (Claude Code en la web) el contenedor es
efimero. `~/.claude/CLAUDE.md` se pierde al cerrar la sesion; lo que
persiste es el nivel 1, porque esta en git.

## 3. Otro proyecto cualquiera

```bash
./scripts/install-token-efficient.sh --project /ruta/al/proyecto
```

Copia las reglas a `<proyecto>/.claude/rules/token-efficient.md` y agrega
la linea de import a su `CLAUDE.md`. Haz commit en ese repo para que
aplique tambien en la web.

## 4. Chats de claude.ai y Cowork

Estos no leen `CLAUDE.md`: leen la configuracion de la cuenta. Se hace a
mano una vez, en claude.ai -> Settings -> Profile -> personal
preferences, pegando el texto de `token-efficient.md` (de `## Override`
hacia abajo). Queda activo en chats nuevos y en Cowork.
