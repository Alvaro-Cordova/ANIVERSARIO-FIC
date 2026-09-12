# COMPARACIÓN PRELIMINAR DE LOS DOS SISTEMAS VISUALES

## Sistema A — paquete creado anteriormente

Fortalezas:

- más simple;
- nombres y clases más fáciles para principiantes;
- pocos archivos;
- fácil de enseñar al equipo;
- menor riesgo al integrar;
- suficiente para botones, tarjetas, formularios, tablas y alertas.

Limitaciones:

- menos componentes;
- no tenía hero completo;
- no tenía tema oscuro;
- no tenía modales/toasts/skeleton/tabs;
- no tenía layout administrativo completo;
- no tenía identidad visual proveniente de una web ya desarrollada;
- no incluía recursos PWA reales.

## Sistema B — basado en precongreso-Coneic

Fortalezas:

- mucho más completo;
- design tokens más maduros;
- paleta institucional guinda/dorado/negro;
- tipografía fluida;
- responsive más desarrollado;
- hero completo;
- cards con estados;
- timeline;
- formularios;
- toast;
- modal;
- skeleton;
- QR box;
- tabs;
- data tables;
- uploads;
- layout administrativo;
- tema oscuro;
- soporte visual para PWA;
- logo e imagen hero reales del proyecto enviado;
- contempla personalización dinámica del tema.

Limitaciones:

- mayor complejidad;
- clases en inglés;
- más archivos CSS;
- el proyecto original utiliza arquitectura SPA/router propia;
- el backend y schema SQL originales NO son compatibles directamente con
  la base V3.2.1 actual;
- requiere disciplina para que desarrolladores principiantes no mezclen
  arquitectura visual con arquitectura de negocio.

## Recomendación

Para ANIVERSARIO-FIC:

```text
MANTENER:
arquitectura modular actual
+
Supabase V3.2.1 validado
+
servicios actuales
+
ramas feature actuales

ADOPTAR DEL SISTEMA B:
tokens.css
base.css
layout.css
components.css
pages.css
recursos gráficos
componentes visuales reutilizables

NO ADOPTAR AUTOMÁTICAMENTE:
schema SQL original
supabase.js original
router SPA original
servicios de negocio originales
```

En términos visuales y de componentes:

```text
Sistema B > Sistema A
```

En simplicidad para desarrolladores principiantes:

```text
Sistema A > Sistema B
```

La mejor solución es usar la riqueza visual del Sistema B sin sustituir la
arquitectura y la base de datos ya probadas del proyecto actual.
