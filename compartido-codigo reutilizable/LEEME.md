# COMPARTIDO — Sistema visual basado en precongreso-Coneic

Este paquete fue preparado a partir de los archivos del proyecto enviado por el usuario.

## CSS

Orden obligatorio:

```html
<link rel="stylesheet" href="../../compartido/estilos/tokens.css">
<link rel="stylesheet" href="../../compartido/estilos/base.css">
<link rel="stylesheet" href="../../compartido/estilos/layout.css">
<link rel="stylesheet" href="../../compartido/estilos/components.css">
<link rel="stylesheet" href="../../compartido/estilos/pages.css">

<!-- Al final -->
<link rel="stylesheet" href="./estilos.css">
```

## Función de cada archivo

```text
tokens.css
→ colores, tipografías, espacios, radios, sombras, motion y tema oscuro.

base.css
→ reset, body, headings, accesibilidad y estados focus.

layout.css
→ contenedores, grids, navbar, footer y layout administrativo.

components.css
→ botones, cards, badges, hero, timeline, forms, toast, modal,
  skeleton, QR, tabs, tablas, uploads y banner offline.

pages.css
→ auth, perfil, dashboard, ajustes, preview de certificado y PWA.
```

## Regla

Los módulos no deben redefinir estos componentes globales.

Si un estilo se usa en dos o más módulos, debe vivir aquí.
