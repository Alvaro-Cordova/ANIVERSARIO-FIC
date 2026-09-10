# ANIVERSARIO-FIC

Plataforma web desarrollada como prueba para la organización de eventos de la Facultad de Ingeniería Civil y como preparación para el PRECONGRESO CONEIC 2027.

El proyecto utilizará como base el prototipo web existente y se reemplazarán progresivamente las funciones simuladas por funciones reales.

## Tecnologías utilizadas

- HTML
- CSS
- JavaScript
- Supabase
- GitHub

## Objetivo del proyecto

La plataforma deberá permitir:

- Mostrar información del evento.
- Registrar participantes.
- Iniciar sesión.
- Inscribirse a ponencias.
- Inscribirse a concursos.
- Generar códigos QR para participantes.
- Registrar ingreso y salida mediante QR.
- Generar certificados digitales.
- Administrar información del evento.
- Obtener reportes de participantes y asistencia.
- Mostrar enlaces o formularios externos para pagos mediante Yape u otros medios.

## Organización general

Cada desarrollador tiene asignada una parte específica del proyecto.

No se debe modificar el módulo de otro desarrollador sin coordinación previa.

### Desarrollador 1

Área:

Arquitectura del proyecto.

Trabaja principalmente en:

- servicios/
- base-de-datos/
- comun/
- estructura general del proyecto

Funciones:

- Mantener organizada la estructura.
- Configurar Supabase.
- Preparar la base de datos.
- Crear funciones comunes cuando sean necesarias.
- Evitar duplicación de código.
- Apoyar en la integración de módulos.

### Desarrollador 2

Área:

Integración y organización.

Trabaja principalmente en:

- GitHub
- comun/
- servicios/
- integración entre módulos

Funciones:

- Administrar las ramas de GitHub.
- Revisar cambios antes de integrarlos.
- Ayudar a resolver conflictos.
- Apoyar al Desarrollador 1.
- Revisar que los módulos funcionen juntos.

### Desarrollador 3

Área:

Página informativa.

Trabaja principalmente en:

- index.html
- recursos/
- modulos/informacion/

Funciones:

- Página principal.
- Información del evento.
- Cronograma.
- Ubicación.
- Contacto.
- Contenido público.

### Desarrollador 4

Área:

Registro e inicio de sesión.

Trabaja principalmente en:

- modulos/autenticacion/

Funciones:

- Registro de usuarios.
- Inicio de sesión.
- Perfil.
- Cierre de sesión.
- Recuperación de cuenta si se implementa.
- Permisos básicos de usuario.

### Desarrollador 5

Área:

Ponencias.

Trabaja principalmente en:

- modulos/ponencias/

Funciones:

- Mostrar ponencias.
- Mostrar información de cada ponencia.
- Inscripción.
- Cancelación de inscripción si se implementa.

Debe mantener comunicación con la Gerencia de Ponencias.

### Desarrollador 6

Área:

Concursos.

Trabaja principalmente en:

- modulos/concursos/

Funciones:

- Mostrar concursos.
- Mostrar bases y requisitos.
- Formularios de inscripción.
- Registro individual o por equipos.
- Control de participantes.

Debe mantener comunicación con la Gerencia de Concursos.

### Desarrollador 7

Área:

QR y asistencia.

Trabaja principalmente en:

- modulos/qr-asistencia/

Funciones:

- Mostrar el QR personal.
- Leer códigos QR.
- Registrar ingreso.
- Registrar salida.
- Consultar asistencia.
- Que la persona cuando ya haya registrado su ingreso, solo mientras este dentro de el establecimiento, pueda registrar su asistencia en la pagina automaticamente sin la necesidad de registar su QR nuevamente. Si registra su salida, esta funcion ya no estará disponible y deberá de ingresar nuevamente escaneando su QR. (esto es para evitar que a cada rato la persona scanee el QR, que puede llegar a ser muy fastidioso)
- (opcional), al momento de registrar su asistencia, el usuario escoge para que evento quiere registrarlo, por ejemplo, quiere asistencia para un curso en especifico, para evitar estar haciendo la lista en una hoja esto sera automatizado, cosa que las personas que se registren para un mismo curso, al inge se le manda esa lista y el comprueba la asistencia. 

Debe coordinar con los responsables del control de ingreso y asistencia. (Recursos humanos?)

### Desarrollador 8

Área:

Certificados digitales.

Trabaja principalmente en:

- modulos/certificados/

Funciones:

- Crear certificados.
- Generar PDF.
- Descargar certificados.
- Crear código de validación.
- Verificar certificados.

Debe coordinar los requisitos de certificación con los responsables correspondientes.

### Desarrollador 9

Área:

Administración y reportes.

Trabaja principalmente en:

- modulos/administracion/
- modulos/reportes/

Funciones:

- Ver participantes.
- Ver inscripciones.
- Ver asistencia.
- Administrar información.
- Mostrar estadísticas.
- Crear reportes.
- Exportar información de asistencia principalmente (excel o alguna forma conveniente)

### Desarrollador 10

Área:

Seguimiento y control del proyecto.

Trabaja principalmente en:

- documentacion/seguimiento.md

Funciones:

- Revisar el avance de cada desarrollador.
- Registrar qué día trabajó cada desarrollador.
- Registrar actividades terminadas.
- Registrar actividades pendientes.
- Identificar retrasos.
- Registrar problemas.
- Elaborar reportes de avance.
- Comunicar problemas al equipo.

## Regla principal

Cada desarrollador debe trabajar únicamente en los archivos relacionados con su módulo.

Si necesita modificar otro módulo, primero debe comunicarse con el desarrollador responsable.

## Organización de archivos dentro de los módulos

La mayoría de módulos utilizan la siguiente estructura:

index.html
estilos.css
interfaz.js
datos.js
LEEME.md

### index.html

Contiene únicamente la estructura visible de la página.

### estilos.css

Contiene únicamente el diseño visual del módulo.

### interfaz.js

Controla las acciones visibles para el usuario.

### datos.js

Se utiliza para leer, guardar, modificar o eliminar información relacionada con el módulo.

Ejemplos:

- obtener ponencias;
- registrar una inscripción;
- consultar asistencia;
- guardar un concurso.

Debe utilizar la conexión común ubicada en servicios/supabase.js.

### LEEME.md

Explica:

- quién es responsable del módulo;
- qué funciones debe desarrollar;
- qué información necesita;
- de qué otros módulos depende.

No debe contener código funcional.

## Supabase

Existe una sola configuración general:

servicios/supabase.js

Ningún desarrollador debe crear otra conexión independiente a Supabase.

## Sesión del usuario

Las funciones comunes relacionadas con la sesión estarán en:

servicios/sesion.js

Ejemplos:

- obtener usuario actual;
- comprobar si existe una sesión;
- cerrar sesión.

Los demás módulos utilizarán estas funciones cuando las necesiten.

## Base de datos

Los archivos relacionados con la estructura de la base de datos se encuentran en:

base-de-datos/

No modificar estos archivos sin coordinar con los Desarrolladores 1 y 2.

## GitHub

La rama principal contiene la versión estable del proyecto.

No trabajar directamente en main.

Cada módulo deberá utilizar una rama separada.

Ejemplos:

feature/autenticacion
feature/ponencias
feature/concursos
feature/qr
feature/certificados
feature/administracion

Antes de integrar cambios se debe comprobar que el módulo funciona.
