# Carpeta Compartido

## Objetivo

La carpeta `compartido/` contiene código, estilos y funciones que pueden ser utilizados por varios módulos de la plataforma.

Su finalidad principal es evitar duplicar código.

Si una misma función, componente o estilo es necesario en diferentes partes del sistema, debe evaluarse colocarlo dentro de esta carpeta.

## Estructura

compartido/
├── componentes/
│   ├── cabecera.js
│   └── pie-pagina.js
│
├── estilos/
│   ├── global.css
│   └── componentes.css
│
├── utilidades/
│   ├── validaciones.js
│   └── fechas.js
│
└── LEEME.md

## 1. componentes/

Contiene partes de la interfaz que se utilizan en varias páginas.

Ejemplos:

- cabecera;
- menú de navegación;
- pie de página;
- mensajes generales;
- ventanas reutilizables.

### cabecera.js

Se encarga de crear o administrar la cabecera general de la plataforma.

Puede contener:

- logo;
- menú;
- acceso al perfil;
- botón de iniciar sesión;
- botón de cerrar sesión.

La finalidad es evitar que cada módulo cree su propia cabecera.

### pie-pagina.js

Se encarga del pie de página general.

Puede contener:

- información institucional;
- redes sociales;
- contacto;
- derechos o información del evento.

Todos los módulos que necesiten un pie de página deben utilizar este componente.

## 2. estilos/

Contiene estilos utilizados por varias páginas.

### global.css

Contiene las reglas generales de diseño de toda la plataforma.

Ejemplos:

- tipo de letra;
- configuración general del body;
- tamaños generales;
- variables de diseño;
- comportamiento general de enlaces;
- configuración básica responsive.

No colocar aquí estilos exclusivos de un módulo.

Ejemplo incorrecto:

.ponencia-especial {
    ...
}

Ese estilo debería estar en:

modulos/ponencias/estilos.css

### componentes.css

Contiene estilos relacionados con componentes reutilizables.

Ejemplos:

- cabecera;
- botones generales;
- pie de página;
- tarjetas comunes;
- ventanas;
- mensajes.

## 3. utilidades/

Contiene pequeñas funciones JavaScript que pueden ser utilizadas por varios módulos.

No están relacionadas directamente con una sola funcionalidad del sistema.

## validaciones.js

Contiene funciones para comprobar datos.

Ejemplos:

- validar correo;
- validar DNI;
- comprobar campos vacíos;
- validar número de celular;
- comprobar longitud de texto.

Ejemplo:

validarCorreo(correo)

Si Autenticación, Concursos y Ponencias necesitan validar un correo, todos deben utilizar la misma función.

No crear tres funciones diferentes.

## fechas.js

Contiene funciones relacionadas con fechas y horarios.

Ejemplos:

- mostrar una fecha correctamente;
- comparar fechas;
- obtener hora;
- transformar formato de fecha;
- calcular duración.

Ejemplo:

formatearFecha(fecha)

## Cuándo colocar código en compartido/

Una función puede permanecer dentro de un módulo si solamente ese módulo la utiliza.

Ejemplo:

calcularCuposPonencia()

Puede permanecer en:

modulos/ponencias/

Pero si una función empieza a ser utilizada por varios módulos:

formatearFecha()

debe evaluarse moverla a:

compartido/utilidades/fechas.js

## Regla general

Si algo es utilizado por:

1 módulo
→ puede permanecer en ese módulo.

Si algo es utilizado por:

2 o más módulos
→ considerar colocarlo en `compartido/`.

Antes de moverlo, comunicarlo a los responsables de arquitectura.

## Qué NO debe colocarse aquí

No colocar:

- conexión con Supabase;
- funciones exclusivas de ponencias;
- funciones exclusivas de concursos;
- generación de QR;
- generación de certificados;
- lógica exclusiva de administración.

La conexión con Supabase pertenece a:

servicios/supabase.js

Las funciones de sesión pertenecen a:

servicios/sesion.js

## Ejemplo de código duplicado

Incorrecto:

modulos/ponencias/interfaz.js

function validarCorreo() {
    ...
}

modulos/concursos/interfaz.js

function validarCorreo() {
    ...
}

modulos/autenticacion/interfaz.js

function validarCorreo() {
    ...
}

Correcto:

compartido/utilidades/validaciones.js

function validarCorreo() {
    ...
}

Los diferentes módulos utilizan esa misma función.

## Importante

Los archivos de esta carpeta pueden afectar a varios módulos.

Por este motivo, no deben realizarse cambios importantes sin revisar primero qué partes del sistema utilizan ese código.

## Responsabilidad

Los Desarrolladores 1 y 2 deben supervisar los cambios importantes dentro de esta carpeta.

Los demás desarrolladores pueden solicitar agregar una función compartida cuando detecten que la misma función será utilizada por varios módulos.