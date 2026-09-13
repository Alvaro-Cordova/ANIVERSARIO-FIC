# Módulo de Administración

Responsable: Desarrollador 9

## Objetivo

Permitir que los responsables del evento puedan consultar y administrar la información de la plataforma.

## Archivos principales

index.html
estilos.css
interfaz.js
datos.js

## Qué debe desarrollar

Panel administrativo para consultar:

- usuarios; (cualquier usuario puede consultar su asistencia)
- ponencias; (cualquier usuario puede consultar su asistencia)
- concursos; (leer archivos pdf, que la base de datos lo almacene los archivos que se le solicita al usuario para poder inscribirse )
- inscripciones;
- asistencia;
- certificados.
- configurar funciones solo para administradores y control (administradores pueden modificar el sistema, la pagina, en general tienen acceso a toda la pagina sin restricciones incluyendo los mismos permisos que tiene control. Los de control son solamente gente que pueda consultar inscripciones a ponentes - concursos, descargar listas excel de asistencias, que usuarios se registraron, si estan aptos para generarles certificado, si realizaron la paga para el certificado de paga y el sistema registra si pagaron o no, pero no puede modificar / eliminar la pagina o sistema)

También podrá incorporar funciones básicas de administración cuando sean necesarias.

## index.html

Debe mostrar el panel principal.

Puede contener:

- número de usuarios;
- inscritos;
- asistentes;
- accesos a cada sección;
- información general.

## estilos.css

Diseño exclusivo del panel administrativo.

## interfaz.js

Controla:

- menús;
- botones;
- tablas;
- filtros;
- ventanas;
- mensajes.

## datos.js

Consulta información desde Supabase.

Ejemplos:

- obtener usuarios;
- obtener inscripciones;
- obtener asistencia;
- obtener certificados.

## Dependencias

Depende de los módulos principales porque mostrará información generada por ellos.

Puede comenzar desarrollando la interfaz con información ficticia.

## Seguridad

El panel no debe estar disponible para cualquier participante.

Los permisos solo para administradores serán definidos junto con los responsables de arquitectura.

## Comunicación

Debe coordinar con los responsables que utilizarán el panel para conocer qué información necesitan visualizar.

## No hacer

- No crear otra base de datos.
- No modificar directamente las funciones internas de los demás módulos.
- No crear otro sistema de login.