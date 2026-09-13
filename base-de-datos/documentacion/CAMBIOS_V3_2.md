# CAMBIOS V3.2

## Cambio principal

La V3.2 reemplaza el modelo:

```text
QR -> asistencia de una ponencia -> una sola entrada/salida
```

por:

```text
QR -> presencia en una sala -> múltiples entradas/salidas
                       ↓
               cruce con horarios
                       ↓
             asistencia a ponencias
```

## Almuerzo, pausas y reingresos

Un participante puede registrar:

```text
08:50 entrada
12:00 salida
14:00 entrada
17:30 salida
```

Cada par es una fila en `sesiones_presencia`.

## Cambio de ponencia sin volver a escanear

Si dos ponencias son consecutivas en la misma sala, el usuario NO se vuelve
a escanear. El sistema calcula su presencia cruzando:

```text
sesiones_presencia
+
sala de la actividad
+
fecha_inicio / fecha_fin
```

## Cambio de sala

Si el participante tiene una sesión abierta en Sala A y escanea en Sala B:

```text
Sala A -> salida automática
Sala B -> entrada automática
```

La función devuelve `accion = cambio_sala`.

## Cursos académicos

Se agregan:

```text
cursos
curso_participantes
asignaciones_asistencia_curso
```

### Regla solicitada

NO existe una tabla `actividad_cursos`.

Por tanto, una ponencia NO está limitada a cursos "relacionados con el tema".

Un alumno puede elegir cualquier curso activo que lleve y asignar a ese curso
cualquier ponencia que tenga control de asistencia.

También puede usar la misma ponencia para más de un curso si lo necesita.

Ejemplo:

```text
Ponencia X
├── Mecánica de Suelos
└── Diseño Vial
```

aunque el tema no tenga relación académica con ambos cursos.

## Seguridad

Elegir un curso NO marca al alumno como presente.

La presencia sigue dependiendo exclusivamente de:

```text
QR
+
sala
+
hora real de entrada/salida
```

El usuario solo decide para qué curso desea utilizar esa presencia.

## Reporte académico

`reporte_asistencia_curso(curso, actividad)` devuelve todos los alumnos del
curso y diferencia:

```text
ASISTIO
ASISTENCIA_PARCIAL
NO_ASISTIO
NO_REGISTRADO
```

`NO_REGISTRADO` significa que el alumno pertenece al curso pero no seleccionó
esa ponencia para ese curso.

El módulo Reportes podrá convertir esta respuesta a XLSX/CSV sin usar listas
físicas de firmas.


## Aclaración solicitada: libertad total para elegir curso

La V3.2 NO valida si el tema de una ponencia "corresponde" académicamente a
un curso.

La única condición es que:

```text
el usuario lleve/registre el curso
+
la actividad tenga control de asistencia
+
ambos pertenezcan al mismo evento
```

Por tanto, técnicamente es válido:

```text
Ponencia de estructuras
→ marcarla para Mecánica de Suelos

Ponencia de geotecnia
→ marcarla para Diseño Vial
```

si el alumno así lo necesita.

La misma asistencia física también puede asociarse a varios cursos del usuario.
