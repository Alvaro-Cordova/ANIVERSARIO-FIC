## 5. Módulos

Carpeta:

modulos/

Cada módulo representa una función principal de la plataforma.

Los módulos deben permanecer separados.
## . Principio principal

Los módulos comparten información mediante la base de datos y los servicios comunes, no copiando código entre ellos.

## División interna de cada módulo

### index.html

Contiene lo que aparece en pantalla. (informacion)

Ejemplos:

- títulos;
- botones;
- formularios;
- tablas;
- tarjetas;
- campos de texto.

No colocar consultas a Supabase directamente en HTML.

### estilos.css

Contiene únicamente el diseño del módulo. (visual - lo que el usuario ve)
Ejemplos:

- tamaños;
- márgenes;
- colores;
- posiciones;
- diseño responsive.

No colocar estilos de otros módulos.

### interfaz.js

Controla las acciones visibles para el usuario. (interaccion de la pagina)

Ejemplos:

- detectar un clic;
- abrir una ventana;
- mostrar información;
- ocultar elementos;
- mostrar mensajes.

No debe configurar nuevamente Supabase.

### datos.js

Controla comunicación con la base de datos correspondiente al módulo.
Se utiliza para leer, guardar, modificar o eliminar información relacionada con el módulo.

Ejemplos:

- obtener ponencias;
- registrar una inscripción;
- consultar asistencia;
- guardar un concurso.

Debe utilizar la conexión común ubicada en servicios/supabase.js.


### LEEME.md

Contiene instrucciones del módulo.
Explica:

- quién es responsable del módulo;
- qué funciones debe desarrollar;
- qué información necesita;
- de qué otros módulos depende.

No debe contener código funcional.

## Comunicación entre módulos

Los módulos deben comunicarse principalmente mediante:

1. servicios comunes;
2. base de datos.

Ejemplo correcto:

AUTENTICACION
      ↓
BASE DE DATOS
      ↑
PONENCIAS

Ponencias consulta quién está conectado mediante servicios/sesion.js.

Ejemplo incorrecto:

PONENCIAS
      ↓
archivo interno de AUTENTICACION

No importar directamente código interno de otro módulo salvo que los responsables de arquitectura lo definan expresamente.

## . Ejemplo QR y certificados

El módulo QR registra:

usuario
entrada
salida
asistencia

en la base de datos.

Después Certificados consulta esa información.

Flujo:

QR
↓
Base de datos
↑
Certificados

Certificados no necesita ejecutar el código del escáner QR.

## Regla para evitar duplicaciones

Antes de crear una función:

1. Revisar el propio módulo.
2. Revisar comun/.
3. Revisar servicios/.
4. Preguntar a los Desarrolladores 1 o 2 si existe una función similar.

Si ya existe:

se reutiliza.

No se copia.

## Regla para nuevos archivos

No crear nuevas carpetas o archivos generales sin comunicarlo a los responsables de arquitectura.

Los archivos internos del propio módulo pueden agregarse cuando sean realmente necesarios, manteniendo una estructura clara.

## Código compartido

El código utilizado por varios módulos debe colocarse en:

compartido/

Ejemplos:

- validaciones;
- cabecera;
- pie de página;
- funciones de fechas;
- componentes reutilizables.

No duplicar funciones en distintos módulos. Para evaluar esto, consultar con desarrollador 1 y 2
