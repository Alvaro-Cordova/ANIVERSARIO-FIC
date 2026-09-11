# BASE DE DATOS V2 - DOCUMENTACIÓN DEL EQUIPO

## 1. Qué se modificó

Esta es la versión revisada de la base de datos antes de crear el proyecto real en Supabase.

Los cambios son exclusivamente de la **base de datos y sus reglas de acceso**.

No se está modificando todavía el HTML, CSS ni los módulos del frontend.

Se hicieron estos cambios principales:

- Separación clara entre datos reales y datos ficticios.
- Campo `es_prueba` para identificar eventos internos de prueba.
- Inscripción general al evento centralizada.
- Validación manual de pagos externos.
- Concursos individuales o por equipos.
- Tablas `equipos` y `miembros_equipo`.
- QR por usuario y evento.
- QR sin DNI, correo ni nombre dentro del código.
- Registro seguro de entrada y salida.
- Certificados separados de la lógica del QR.
- RLS para proteger información privada.
- Funciones comunes para evitar que cada módulo programe reglas diferentes.

---

# 2. Archivos

## esquema.sql

Crea:

- tablas;
- relaciones;
- índices;
- funciones principales.

Se ejecuta primero.

## permisos.sql

Crea:

- reglas de seguridad;
- roles;
- permisos;
- función para verificar pagos;
- función segura para escanear QR.

Se ejecuta segundo.

## datos-iniciales.sql

Plantilla para cargar información REAL confirmada.

Ejemplos:

- evento;
- ponentes;
- ponencias;
- concursos;
- horarios;
- lugares.

No contiene información inventada.

## datos-prueba.sql

Crea un evento ficticio separado para pruebas.

Se utiliza únicamente durante desarrollo.

---

# 3. Estructura principal

```text
Supabase Auth
      ↓
   perfiles
      ↓
inscripciones_evento
      ↓
    eventos
      ↓
  actividades
      │
      ├────────────── ponentes
      │                   ↑
      │           actividad_ponentes
      │
      ├──────── inscripciones_actividad
      │                  ↑
      │                  │
      │        ┌─────────┴────────┐
      │        │                  │
      │    usuario            equipo
      │                           │
      │                    miembros_equipo
      │
      └──────── credenciales_qr
                       ↓
                  asistencias
                       ↓
                  certificados
```

---

# 4. Tablas y módulos

| Módulo | Tablas principales |
|---|---|
| Información | eventos, actividades, ponentes |
| Autenticación | auth.users, perfiles |
| Ponencias | actividades, actividad_ponentes, inscripciones_actividad |
| Concursos | actividades, equipos, miembros_equipo, inscripciones_actividad |
| QR | credenciales_qr |
| Asistencia | asistencias |
| Certificados | certificados, asistencias |
| Administración | varias tablas según permisos |
| Reportes | consulta las tablas anteriores |

No existe una tabla `reportes`, porque los reportes son consultas de información existente.

---

# 5. Datos reales y datos de prueba

La estructura es exactamente la misma.

No se programa dos veces.

Ejemplo:

```text
actividades
```

puede contener:

```text
Ponencia interna de prueba
```

o:

```text
Ponencia oficial del evento
```

El módulo utiliza la misma tabla y las mismas funciones.

La diferencia está únicamente en los registros.

---

# 6. Evento de prueba

Los registros ficticios pertenecen a un evento con:

```text
es_prueba = true
```

Los eventos oficiales usan:

es_prueba = false


Esto permite distinguir fácilmente ambas clases de datos.

Antes del evento se puede eliminar el evento ficticio junto con sus datos dependientes.

---

# 7. Inscripción general

Función:

```text
inscribirse_evento()
```

Flujo sin pago:

```text
Usuario
↓
Inscripción
↓
estado = inscrito
estado_pago = no_requiere
```

Flujo con pago externo:

```text
Usuario
↓
Inscripción
↓
estado = pendiente
estado_pago = pendiente
↓
Yape / formulario externo
↓
Administrador verifica
↓
estado = inscrito
estado_pago = verificado
```

Ningún módulo debe inventar una segunda lógica de inscripción general.

---

# 8. Actividades

Todo se guarda en:

```text
actividades
```

El campo:

```text
tipo
```

puede ser:

```text
ponencia
concurso
taller
ceremonia
otro
```

El campo:

```text
modalidad_inscripcion
```

puede ser:

```text
individual
equipo
ambos
```

---

# 9. Concursos por equipo

Tablas:

```text
equipos
miembros_equipo
```

Flujo:

```text
Usuario líder
↓
crear_equipo()
↓
obtiene código de invitación
↓
otros usuarios usan unirse_equipo()
↓
el líder ejecuta inscribir_equipo_actividad()
```

La cantidad mínima y máxima de miembros se configura en `actividades`.

---

# 10. QR

Tabla:

```text
credenciales_qr
```

El QR contiene solamente:

```text
token UUID
```

No debe contener:

- DNI;
- correo;
- teléfono;
- contraseña.

Función:

```text
obtener_o_crear_qr()
```

Solo funciona cuando la inscripción general del usuario está habilitada.

---

# 11. Asistencia

Función:

```text
registrar_escaneo_qr()
```

Puede ser utilizada solamente por usuarios con rol:

```text
control
admin
```

Comportamiento:

```text
Primer escaneo
→ entrada

Segundo escaneo
→ salida

Tercer escaneo
→ error
```

La función también comprueba:

- QR válido;
- mismo evento;
- inscripción válida al evento;
- inscripción en la actividad si es obligatoria.

---

# 12. Certificados

Los certificados NO se crean desde el QR.

El QR únicamente genera asistencia.

Después:

```text
Asistencia
↓
Base de datos
↓
Certificado
```

La tabla `certificados` permite guardar:

- usuario;
- evento;
- actividad opcional;
- código;
- estado;
- PDF.

La regla final para decidir quién merece un certificado se definirá con la organización.

---

# 13. Seguridad

Se utiliza Row Level Security (RLS).

## participante

Puede ver principalmente:

- su perfil;
- sus inscripciones;
- su QR;
- su asistencia;
- sus certificados.

## control

Utiliza la función segura del escáner QR.

No necesita acceso directo a todos los datos personales.

## admin

Puede administrar el sistema.

---

# 14. Regla obligatoria para los desarrolladores

La estructura de la base de datos queda bajo responsabilidad de arquitectura.

Ningún desarrollador debe:

- crear tablas por su cuenta;
- renombrar columnas;
- eliminar columnas;
- cambiar tipos de datos;
- desactivar RLS;
- crear otra base paralela.

Si necesita un nuevo dato:

```text
1. Explica qué necesita.
2. Arquitectura revisa si ya existe.
3. Se decide si realmente hace falta.
4. Se modifica esquema.sql.
5. Se prueba.
6. Se integra.
```

---

# 15. Regla para la IA

Cuando un desarrollador pida código a una IA debe indicar:

```text
La estructura de Supabase ya está definida.
No debes crear tablas nuevas ni modificar columnas.
Debes utilizar las tablas y funciones existentes.
Si consideras que falta un campo, indícalo antes de generar una modificación.
```

---

# 16. Orden de instalación en Supabase

Cuando la estructura sea aprobada:

```text
1. Crear proyecto Supabase.
2. Ejecutar esquema.sql.
3. Ejecutar permisos.sql.
4. Crear usuario administrador de prueba.
5. Ejecutar datos-prueba.sql si se desea.
6. Completar datos-iniciales.sql con información oficial.
7. Configurar servicios/supabase.js.
8. Probar módulos.
```

No ejecutar `datos-iniciales.sql` hasta completar información real confirmada.
