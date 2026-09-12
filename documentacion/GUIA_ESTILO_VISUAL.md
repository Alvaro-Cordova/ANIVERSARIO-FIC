# GUÍA DE ESTILO VISUAL DEL PROYECTO

## Objetivo

Evitar que cada desarrollador cree una interfaz diferente.

A partir de la integración de este sistema, todos los módulos deben reutilizar:

```text
compartido/estilos/variables.css
compartido/estilos/global.css
compartido/estilos/componentes.css
```

El archivo `estilos.css` de cada módulo queda reservado para necesidades
exclusivas de ese módulo.

---

## Regla 1 — No inventar colores

No escribir dentro de módulos:

```css
background: #123456;
color: red;
```

cuando el color tiene una finalidad general.

Utilizar:

```css
background: var(--color-primario-600);
color: var(--color-error);
```

Si el comité cambia la identidad visual, se modifica `variables.css` una sola vez.

---

## Regla 2 — Una sola familia tipográfica

Todos los módulos usan:

```css
font-family: var(--fuente-principal);
```

Normalmente no será necesario escribirlo porque `global.css` ya lo aplica a
todo el documento.

No importar una fuente diferente dentro de un módulo sin aprobación.

---

## Regla 3 — Reutilizar clases

Botón principal:

```html
<button class="btn btn--primario">
    Guardar
</button>
```

Botón secundario:

```html
<button class="btn btn--secundario">
    Cancelar
</button>
```

Tarjeta:

```html
<article class="tarjeta">
    ...
</article>
```

Input:

```html
<input class="campo">
```

Tabla:

```html
<div class="tabla-contenedor">
    <table class="tabla">
        ...
    </table>
</div>
```

---

## Regla 4 — CSS del módulo solo para su módulo

Correcto:

```css
/* modulos/qr-asistencia/estilos.css */

.escaner-video {
    aspect-ratio: 1;
}
```

Incorrecto:

```css
/* No volver a redefinir globalmente botones */
button {
    background: green;
}
```

---

## Regla 5 — Recursos centralizados

Los módulos no deben contener copias separadas del mismo logo.

Usar:

```text
recursos/logos/
recursos/imagenes/
recursos/iconos/
recursos/documentos/
```

---

## Regla 6 — Nuevos componentes reutilizables

Si dos módulos necesitan la misma pieza visual o JavaScript:

```text
módulo A
módulo B
```

no copiar y pegar.

Comunicar al Desarrollador 1 o 2 y mover la pieza a:

```text
compartido/
```

---

## Regla 7 — Antes de hacer Pull Request

Verificar:

```text
[ ] cargué variables.css
[ ] cargué global.css
[ ] cargué componentes.css
[ ] no inventé otra tipografía
[ ] no inventé botones globales
[ ] no dupliqué logos
[ ] no usé colores HEX generales dentro de mi módulo
[ ] mi interfaz funciona en móvil
[ ] revisé demo-estilos.html
```

---

## Importación estándar

Para una página ubicada directamente en:

```text
modulos/autenticacion/registro.html
```

usar:

```html
<link rel="stylesheet" href="../../compartido/estilos/variables.css">
<link rel="stylesheet" href="../../compartido/estilos/global.css">
<link rel="stylesheet" href="../../compartido/estilos/componentes.css">
<link rel="stylesheet" href="./estilos.css">
```

Siempre colocar el CSS particular del módulo al final.

---

## Página de referencia

Abrir con Live Server:

```text
compartido/demo-estilos.html
```

Antes de crear un botón, formulario, tarjeta, alerta o tabla diferente,
revisar si ya existe allí.

---

## Cambios al diseño global

No modificar directamente el diseño global desde una rama de un módulo sin
coordinarlo.

Si se necesita cambiar el sistema visual:

```text
1. informar al Desarrollador 1 / Desarrollador 2;
2. modificar la rama de diseño compartido;
3. probar varios módulos;
4. integrar mediante Pull Request;
5. el resto de desarrolladores actualiza sus ramas.
```
