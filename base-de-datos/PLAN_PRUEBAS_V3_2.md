# PLAN DE PRUEBAS V3.2

## 1. Migración

En el proyecto Supabase DEV que actualmente tiene V3.1 ejecutar:

```text
1. MIGRACION_V3_1_A_V3_2.sql
2. funciones-v3_2-migracion.sql
3. permisos-v3_2-migracion.sql
4. adaptar-datos-prueba-v3_2.sql
5. comprobaciones.sql
```

No ejecutar nuevamente `esquema.sql`, `funciones.sql` ni `permisos.sql`
completos sobre el proyecto existente.

## 2. Presencia por sala

Con participante1 y su QR:

```text
control1 escanea en Auditorio
-> entrada

segundo escaneo <30 s
-> rechazado

segundo escaneo >30 s
-> salida

nuevo escaneo después
-> NUEVA entrada
```

Debe ser posible repetir entrada/salida varias veces.

## 3. Cambio de sala

Abrir presencia en Auditorio y luego escanear el mismo QR en Sala secundaria.

Esperado:

```text
accion = cambio_sala
```

y solo una sesión queda abierta.

## 4. Cambio de ponencia sin escaneo

Crear una sesión que cubra dos ponencias consecutivas de la misma sala.

`mi_asistencia_evento()` debe mostrar presencia en ambas actividades sin haber
escaneado nuevamente al iniciar la segunda.

## 5. Cursos

Con participante1:

```text
agregar_mi_curso(Mecánica de Suelos)
agregar_mi_curso(Diseño Vial)
```

Luego usar la MISMA ponencia:

```text
seleccionar_curso_asistencia(ponencia, Mecánica de Suelos)
seleccionar_curso_asistencia(ponencia, Diseño Vial)
```

Ambas operaciones deben funcionar.

Esto prueba que NO existe restricción temática.

## 6. Reporte por curso

Como admin:

```text
reporte_asistencia_curso(curso, ponencia)
```

Debe devolver todos los alumnos activos del curso.

Estados posibles:

```text
ASISTIO
ASISTENCIA_PARCIAL
NO_ASISTIO
NO_REGISTRADO
```

## 7. RLS

Participante:

```text
ve sus sesiones
ve sus cursos
ve sus asignaciones
NO ve sesiones ajenas
NO genera reporte académico
```

Control:

```text
puede registrar_escaneo_sala()
NO genera reporte académico
```

Admin:

```text
puede gestionar salas/cursos
puede generar reportes
```
