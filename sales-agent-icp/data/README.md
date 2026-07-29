# 📂 data/ — Sube aquí tus bases de datos por sector

Esta es la carpeta donde subes tus archivos **MD y Excel** (los que el chat ya creó para
dar seguimiento: a quién se le escribió, quién contestó, etc.). Una vez subidos, yo los
leo desde aquí, los **consolido, deduplico y normalizo** al formato del CRM
(`../google-sheets/plantilla-leads.csv`), y **adapto los flujos de n8n a tus columnas
reales**.

---

## 🔴 ANTES DE SUBIR NADA — Privacidad (léelo)

Tus archivos contienen **datos personales** (nombres, correos, empresas, historial de
contacto). Por eso:

1. **Verifica que este repositorio sea PRIVADO.**
   GitHub → pestaña **Settings** del repo → sección **Danger Zone** → *Change repository
   visibility*. Debe decir **Private**. Si dice *Public*, cámbialo a **Private** ANTES de
   subir cualquier base real.
2. Si por alguna razón el repo debe seguir público, **no subas datos reales aquí**: avísame
   y usamos otra vía (Google Drive privado con el conector, o archivos anonimizados).
3. Regla del propio método ACCES: no exponer información sensible innecesaria.

> Si no estás seguro de la visibilidad, **pregúntame y lo verificamos juntos** antes de
> que subas nada.

---

## Dónde poner cada archivo

```
data/
├── bases-md/      ← tus archivos .md (seguimientos, bitácoras, notas del chat)
├── bases-excel/   ← tus archivos .xlsx / .xls / .csv (bases por sector)
└── consolidado/   ← (lo genero yo) el CRM unificado listo para importar a Sheets
```

- Un archivo por sector está perfecto (ej. `financiero.xlsx`, `salud.md`,
  `manufactura-ot.xlsx`). No necesitas renombrar nada especial — yo interpreto la
  estructura.
- Si un mismo prospecto aparece en varias bases, **no te preocupes por duplicados**: yo los
  deduplico por correo/dominio/empresa.

---

## Qué haré yo en cuanto subas los archivos

1. **Leer** todos los MD/Excel y entender la estructura real de cada uno.
2. **Mapear** tus columnas a las del CRM (Empresa, Contacto, Correo, Estado, quién
   contestó, fechas de seguimiento, etc.).
3. **Deduplicar** y consolidar en `data/consolidado/leads-consolidado.csv`.
4. **Preservar el estado real**: los que ya contestaron NO reciben primer contacto; entran
   directo al flujo de respuestas/pipeline. Los pendientes entran a la cadencia.
5. **Robustecer los flujos y prompts** de n8n para que usen tus columnas reales y tu lógica
   de seguimiento.
6. Dejarte el import listo para pegar en el Google Sheet del agente.

---

## Cómo subir los archivos (2 formas)

### Forma A — Desde la web de GitHub (la más fácil, sin comandos)
1. En GitHub, entra a este repo y navega a `sales-agent-icp/data/bases-excel/`
   (o `bases-md/`).
2. Botón **Add file → Upload files**.
3. **Arrastra** tus Excel/MD (puedes soltar varios a la vez).
4. Abajo, en *Commit changes*, elige **la rama** `claude/autonomous-sales-agent-icp-g3h1kx`
   (importante: la misma rama de trabajo).
5. Clic en **Commit changes**. Listo.
6. Avísame aquí ("ya subí las bases") y yo las proceso.

### Forma B — Desde tu computadora con git
```bash
# en tu clon del repo, en la rama de trabajo
git checkout claude/autonomous-sales-agent-icp-g3h1kx
cp /ruta/a/tus/bases/*.xlsx sales-agent-icp/data/bases-excel/
cp /ruta/a/tus/bases/*.md   sales-agent-icp/data/bases-md/
git add sales-agent-icp/data
git commit -m "Add ICP sector databases"
git push
```

---

## Nota

Los `.gitkeep` de las subcarpetas solo existen para que Git conserve las carpetas vacías;
puedes ignorarlos o borrarlos cuando subas tus archivos.
