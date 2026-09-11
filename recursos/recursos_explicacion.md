# Carpeta Recursos

## Objetivo

La carpeta `recursos/` contiene archivos que serán utilizados por diferentes partes de la plataforma.

Aquí se almacenan principalmente imágenes, iconos y documentos.

Esta carpeta NO debe contener lógica del sistema ni código JavaScript relacionado con funcionalidades.

## Estructura

recursos/
├── imagenes/
├── iconos/
├── documentos/
└── LEEME.md

## 1. imagenes/

Esta carpeta contiene las imágenes utilizadas por la plataforma.

Ejemplos:

- logo de la Facultad de Ingeniería Civil;
- logo del evento;
- fotografías de ponentes;
- imágenes del aniversario;
- fotografías de actividades;
- banners;
- fondos;
- imágenes institucionales.

Ejemplo:

recursos/imagenes/logo-fic.png

Todos los módulos deben utilizar esta misma imagen cuando necesiten mostrar el logo.

No se debe copiar nuevamente el logo dentro de:

modulos/ponencias/
modulos/concursos/
modulos/certificados/

Debe reutilizarse siempre el archivo existente.

## 2. iconos/

Esta carpeta contiene iconos utilizados por diferentes partes de la plataforma.

Ejemplos:

- icono de usuario;
- icono de calendario;
- icono de ubicación;
- icono de descarga;
- icono de certificado;
- icono de QR.

Ejemplo:

recursos/iconos/calendario.svg

Si varios módulos necesitan el mismo icono, todos deben utilizar el archivo ubicado aquí.

No crear copias innecesarias.

## 3. documentos/

Esta carpeta contiene archivos que los usuarios pueden consultar o descargar.

Ejemplos:

- bases de concursos;
- reglamentos;
- cronogramas PDF;
- programas del evento;
- documentos informativos;
- plantillas oficiales.

Ejemplo:

recursos/documentos/bases-concurso-puentes.pdf

## Qué debe guardarse en recursos/

Guardar aquí archivos que sean utilizados por la plataforma pero que no formen parte de la programación.

Ejemplos correctos:

- PNG
- JPG
- SVG
- PDF
- documentos descargables

## Qué NO debe guardarse aquí

No colocar:

- funciones JavaScript;
- conexiones a Supabase;
- consultas a la base de datos;
- archivos de autenticación;
- código de ponencias;
- código de QR;
- código de certificados;
- estilos CSS generales.

## Regla para evitar duplicados

Antes de agregar una nueva imagen, icono o documento:

1. Revisar si ya existe dentro de `recursos/`.
2. Si ya existe, utilizar ese archivo.
3. No crear una copia con otro nombre.
4. Si se necesita reemplazar un recurso utilizado por varios módulos, comunicarlo al equipo.

## Ejemplo

Incorrecto:

modulos/ponencias/logo.png
modulos/concursos/logo.png
modulos/certificados/logo.png

Correcto:

recursos/imagenes/logo-fic.png

Todos los módulos utilizan el mismo archivo.

## Responsabilidad

Los desarrolladores pueden utilizar los recursos existentes.

Si se desea eliminar o reemplazar un recurso utilizado por varios módulos, se debe comunicar primero a los responsables de arquitectura.