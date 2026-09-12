# GUÍA DE ESTILO VISUAL — VERSIÓN PRECONGRESO CONEIC

## Fuente analizada

Se revisaron los archivos enviados correspondientes a la página:

```text
https://royer-enriquez.github.io/precongreso-Coneic/
```

En particular se aprovecharon:

```text
css/tokens.css
css/base.css
css/layout.css
css/components.css
css/pages.css

assets/images/logo-default.png
assets/images/hero-default.jpg
assets/icons/*

js/utils/dom.js
js/components/navbar.js
js/components/footer.js
js/services/settings.service.js
js/config.js
```

## Qué se adaptó

El sistema visual se separó del backend del proyecto original.

Se conservaron:

- identidad guinda / dorado / negro;
- design tokens;
- componentes visuales;
- accesibilidad;
- layout responsive;
- tema oscuro;
- hero;
- cards;
- badges;
- timeline;
- formularios;
- toast;
- modal;
- skeleton;
- QR box;
- tabs;
- tablas;
- layout admin;
- recursos gráficos.

## Qué NO se debe copiar al proyecto actual

No sustituir el backend V3.2.1 con:

```text
sql/schema.sql
js/supabase.js
js/services/auth.service.js
js/services/attendance.service.js
js/services/certificates.service.js
```

Tampoco sustituir automáticamente:

```text
router.js
app.js
```

porque el proyecto actual ya tiene su propia arquitectura modular y su propia
base de datos validada.

La recomendación es:

```text
ARQUITECTURA ACTUAL + SUPABASE V3.2.1
                    +
SISTEMA VISUAL DE ESTA PROPUESTA
```

## Importación estándar

Desde:

```text
modulos/autenticacion/registro.html
```

usar:

```html
<link rel="stylesheet" href="../../compartido/estilos/tokens.css">
<link rel="stylesheet" href="../../compartido/estilos/base.css">
<link rel="stylesheet" href="../../compartido/estilos/layout.css">
<link rel="stylesheet" href="../../compartido/estilos/components.css">
<link rel="stylesheet" href="../../compartido/estilos/pages.css">

<link rel="stylesheet" href="./estilos.css">
```

## Colores

No inventar colores nuevos dentro de cada módulo.

Usar:

```css
var(--color-primary)
var(--color-secondary)
var(--color-bg)
var(--color-bg-alt)
var(--color-surface)
var(--color-text)
var(--color-text-muted)
var(--color-success)
var(--color-warning)
var(--color-error)
var(--color-info)
```

## Botones

```html
<button class="btn btn--primary">
  Guardar
</button>

<button class="btn btn--secondary">
  Destacar
</button>

<button class="btn btn--ghost">
  Cancelar
</button>
```

## Cards

```html
<article class="card">
  <div class="card__body">

    <span class="card__eyebrow">
      Ponencia
    </span>

    <h3 class="card__title">
      Título
    </h3>

    <p>
      Descripción
    </p>

  </div>
</article>
```

## Formularios

```html
<div class="form-field">
  <label for="correo">
    Correo
  </label>

  <input
    id="correo"
    type="email"
  >
</div>
```

## Layout responsive

```html
<div class="container">
  <div class="grid grid--3">
    ...
  </div>
</div>
```

## Tema oscuro

El sistema ya contiene:

```css
[data-theme="dark"]
```

Puede activarse con:

```javascript
document.documentElement.setAttribute(
  'data-theme',
  'dark'
)
```

## Configuración dinámica

Se incluyó:

```text
compartido/configuracion/configuracion-visual.js
compartido/configuracion/tema.js
```

Esto permite que toda la interfaz cambie desde una sola configuración.

Por ahora persiste en `localStorage` para no alterar la base V3.2.1.

Más adelante puede conectarse al panel administrativo de Supabase si el equipo
decide permitir personalización de colores/logo desde la web.

## Recursos

Usar siempre:

```text
recursos/logos/
recursos/imagenes/
recursos/iconos/
```

No copiar el mismo logo en cada módulo.

## Demo

Abrir:

```text
compartido/demo-estilos.html
```

con Live Server.

## Regla para ramas existentes

Antes de que cada desarrollador siga diseñando su módulo:

```bash
git switch main
git pull

git switch feature/NOMBRE
git merge main
```

Después deberá reemplazar gradualmente sus estilos propios por las clases
compartidas.

No reescribir todo el módulo de golpe.
