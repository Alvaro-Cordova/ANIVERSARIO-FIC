DOCUMENTACIÓN MÓDULO AUTH
ANIVERSARIO FIC
1. Descripción del módulo

El módulo Auth es responsable de la gestión de identidad de los usuarios dentro de la plataforma.

Su función principal es:

Registrar usuarios.
Autenticar usuarios.
Gestionar sesiones.
Permitir actualización del perfil.
Validar información personal.
Proporcionar información del usuario autenticado a otros módulos.

El módulo NO administra:

concursos.
asistencia.
cursos.
actividades.
certificados.

Estos pertenecen a otros módulos.

2. Tecnologías utilizadas

Frontend:

HTML
CSS
JavaScript

Backend:

Supabase Auth
Supabase Database

Arquitectura:

HTML
 |
 ↓
interfaz.js
 |
 ↓
datos.js
 |
 ↓
Supabase
3. Estructura del módulo

Ubicación:

/modulos/autenticacion/

Archivos:

autenticacion/

├── iniciar-sesion.html
├── registro.html
├── perfil.html
├── recuperar-contrasena.html
├── actualizar-contrasena.html
│
├── interfaz.js
├── datos.js
└── estilos.css
4. Responsabilidad de cada archivo
registro.html

Responsable de:

Mostrar formulario de registro.
Capturar información del usuario.

Campos:

Nombres
Apellidos
Correo
Contraseña
Teléfono
Tipo participante
Código matrícula
Semestre
Detalle participante
iniciar-sesion.html

Responsable de:

Ingreso mediante:

Correo
Contraseña
perfil.html

Permite modificar datos personales.

Campos editables:

Nombres
Apellidos
Teléfono
Código matrícula
Semestre
Detalle participante

Campos protegidos:

Correo
Rol
Estado
5. Validaciones implementadas
Correo

Formato válido:

usuario@dominio.com
Contraseña

Requisito:

mínimo 6 caracteres
Teléfono Perú

Formato:

9 dígitos
Empieza con 9

Ejemplo válido:

987654321

Regex:

/^9[0-9]{8}$/
Código matrícula

Formato:

10 números + letra final

Ejemplo:

2026100000M

Regex:

/^[0-9]{10}[A-Za-z]$/
6. Base de datos

Tabla principal:

public.perfiles

Estructura utilizada:

Campo	Descripción
id	Identificador usuario
nombres	Nombre del usuario
apellidos	Apellidos
correo	Correo electrónico
telefono	Número celular
tipo_participante	Tipo de usuario dentro del evento
detalle_tipo_participante	Descripción adicional
codigo_matricula	Código académico
semestre	Semestre actual
rol	Permiso del sistema
activo	Estado usuario
7. Tipos de participante

Este campo NO representa permisos.

Representa la condición del participante.

Valores:

ESTUDIANTE
OTRO

Ejemplo:

Juan Pérez

tipo_participante:
ESTUDIANTE

codigo_matricula:
2026100000M

Otro ejemplo:

Pedro López

tipo_participante:
OTRO

detalle:
Docente
8. Roles del sistema

El campo:

rol

controla permisos.

Valores recomendados:

participante
administrador
superadmin
Participante

Usuario registrado común.

Puede:

- Ver perfil
- Actualizar datos
- Participar en actividades

No puede:

- Administrar usuarios
- Crear eventos
- Modificar información global
Administrador

Usuario con funciones administrativas.

Ejemplo:

rol:
administrador

Los módulos externos decidirán qué puede administrar.

Ejemplo:

Módulo concursos:

Administrador concursos

Módulo asistencia:

Administrador asistencia
Superadmin

Usuario con control completo.

Responsabilidades:

- Crear administradores
- Modificar roles
- Configuración global
9. Integración con otros módulos

Los demás módulos NO deben crear otra autenticación.

Deben utilizar la sesión existente.

Ejemplo:

const usuario =
    await obtenerPerfilPropio()

Obtendrán:

{
 id,
 nombres,
 apellidos,
 correo,
 rol
}

Ejemplo módulo concursos:

if(
 usuario.rol === "administrador"
){

    cargarPanelConcursos()

}
10. Creación de usuarios administrativos

Recomendación:

Los administradores NO se registran desde el formulario público.

Proceso:

Superadmin crea usuario.
Se registra en Supabase Auth.
Se crea perfil.
Se asigna:
rol = administrador

Ejemplo:

correo:
admin@fic.com

rol:
administrador
11. Reglas para otros desarrolladores
NO hacer:

❌ Crear otra conexión Supabase.

❌ Crear otro sistema login.

❌ Crear otra tabla usuarios.

❌ Guardar contraseñas manualmente.

SÍ hacer:

✅ Usar servicios/sesion.js

✅ Usar datos.js

✅ Obtener usuario actual desde Auth.

✅ Respetar columna:

public.perfiles.rol
12. Estado actual del módulo

Implementado:

✅ Registro usuarios
✅ Inicio sesión
✅ Cierre sesión
✅ Recuperación contraseña
✅ Perfil editable
✅ Validación teléfono Perú
✅ Validación matrícula
✅ Integración Supabase
✅ Gestión básica de roles preparada

Pendiente (fuera del alcance actual):

⏳ Panel administrativo
⏳ Gestión permisos avanzados
⏳ Auditoría acciones