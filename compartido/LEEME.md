# Código compartido

Esta carpeta contiene código y estilos reutilizables por varios módulos.

## Estructura

```text
compartido/
├── estilos/
│   ├── variables.css
│   ├── global.css
│   └── componentes.css
├── componentes/
├── utilidades/
└── demo-estilos.html
```

## Orden obligatorio de CSS

Cada página de un módulo debe cargar:

```html
<link rel="stylesheet" href="../../compartido/estilos/variables.css">
<link rel="stylesheet" href="../../compartido/estilos/global.css">
<link rel="stylesheet" href="../../compartido/estilos/componentes.css">

<!-- Al final, CSS exclusivo del módulo -->
<link rel="stylesheet" href="./estilos.css">
```

## Regla

El CSS del módulo debe contener únicamente lo que es exclusivo de ese módulo.

No volver a crear globalmente:

- colores;
- font-family;
- botones;
- inputs;
- tarjetas;
- tablas;
- alertas;
- badges;
- contenedores generales.

Para esos elementos se utilizan las clases compartidas.
