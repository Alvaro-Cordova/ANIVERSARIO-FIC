# AUDITORÍA EXTERNA DE LA BASE DE DATOS V2

## Resultado

La V2 tenía una arquitectura general razonable, pero **no la consideraría lista para congelarse** sin modificaciones.

La revisión se realizó suponiendo que el sistema ya estaba dando problemas y buscando fallos desde una perspectiva externa, no tratando de defender el diseño original.

La V3 corrige problemas de integridad, concurrencia, seguridad y operación.

---

## Hallazgos críticos

### 1. El QR desactivado podía romper `obtener_o_crear_qr()`

En V2 existía:

```text
unique (evento_id, usuario_id)
```

pero la función buscaba únicamente un QR con:

```text
activo = true
```

Si un QR existente era desactivado, la función no lo encontraba e intentaba insertar otro registro para el mismo usuario/evento.

Eso podía chocar contra la restricción UNIQUE.

**V3:** reutiliza la fila existente y rota el token al reactivarla.

---

### 2. `inscribirse_evento()` podía devolver un estado distinto al realmente guardado

V2 protegía correctamente una inscripción ya verificada durante el `ON CONFLICT`, pero después devolvía las variables calculadas antes del `UPSERT`.

Ejemplo posible:

```text
BD real: estado = inscrito / pago = verificado
respuesta de la función: pendiente / pendiente
```

El frontend podía mostrar información incorrecta.

**V3:** usa `RETURNING estado, estado_pago` después del UPSERT y devuelve el estado real de PostgreSQL.

---

### 3. Un equipo podía inscribirse en una actividad diferente a la que pertenecía

V2 tenía:

```text
inscripciones_actividad.actividad_id
inscripciones_actividad.equipo_id
```

como relaciones independientes.

La base no impedía técnicamente guardar:

```text
equipo del Concurso A
+
actividad Concurso B
```

si se realizaba una inserción fuera de las funciones previstas.

**V3:** usa una clave foránea compuesta `(equipo_id, actividad_id)`.

---

### 4. La base no garantizaba que un usuario perteneciera a un solo equipo por actividad

La función V2 lo comprobaba, pero la estructura de tablas no lo garantizaba por sí misma.

Dos operaciones simultáneas o una edición administrativa incorrecta podían romper la regla.

**V3:** `miembros_equipo` incluye `actividad_id` y tiene:

```text
UNIQUE (actividad_id, usuario_id)
```

---

### 5. Dos usuarios podían unirse al mismo tiempo y superar el máximo de integrantes

V2 hacía:

```text
COUNT integrantes
→ comprobar máximo
→ INSERT
```

sin bloquear el equipo.

Dos solicitudes simultáneas podían contar el mismo número y ambas entrar.

**V3:** bloquea la fila del equipo con `FOR UPDATE` antes de contar e insertar.

---

### 6. El segundo escaneo accidental podía convertirse en una salida

En V2:

```text
primer escaneo = entrada
segundo escaneo = salida
```

Si el lector o el operador escaneaba dos veces por accidente en pocos segundos, el segundo registro podía cerrar inmediatamente la asistencia.

**V3:** un segundo escaneo dentro de 30 segundos se trata como duplicado y se rechaza.

También se usa un advisory lock por `actividad + usuario` para reducir problemas de concurrencia.

---

### 7. Certificados podían relacionar actividad y evento incompatibles

V2 permitía almacenar:

```text
evento_id = Evento A
actividad_id = actividad del Evento B
```

porque ambas claves foráneas eran válidas individualmente.

**V3:** incorpora una validación de integridad que impide esa combinación.

---

### 8. El certificado dependía demasiado de datos que podían cambiar

V2 verificaba el certificado haciendo JOIN con el nombre actual del participante y el nombre actual del evento.

Si meses después se corregía el nombre del perfil o se renombraba algo, la información mostrada al verificar un certificado antiguo podía cambiar.

**V3:** guarda snapshots:

```text
nombre_participante
nombre_evento
nombre_actividad
```

en el momento de emisión.

---

## Hallazgos importantes

### 9. No existía separación entre “evento publicado” e “inscripciones abiertas”

V2 asumía que un evento publicado estaba disponible para inscripción.

Eso no siempre es cierto.

**V3 agrega:**

```text
inscripciones_abiertas
inscripcion_inicio
inscripcion_fin
```

también a actividades.

---

### 10. El límite de capacidad era ambiguo en modalidad `ambos`

V2 contaba solo inscripciones individuales cuando se inscribía un individuo y solo equipos cuando se inscribía un equipo.

En una actividad que permitiera ambos tipos, el máximo total podía superarse.

**V3:** `capacidad` significa cantidad máxima total de inscripciones.

```text
1 persona = 1 inscripción
1 equipo = 1 inscripción
```

---

### 11. Se podía pertenecer a un equipo y además inscribirse individualmente

Especialmente problemático cuando:

```text
modalidad_inscripcion = ambos
```

**V3:** las funciones impiden ambas situaciones simultáneas.

---

### 12. Un equipo ya inscrito podía continuar recibiendo integrantes

En V2 el estado `listo` no impedía `unirse_equipo()`.

Eso permitía modificar el equipo después de inscribirlo.

**V3:**

```text
formando
→ admite integrantes

inscrito
→ plantilla cerrada

cancelado
→ no utilizable
```

---

### 13. El correo de `perfiles` podía quedar diferente al correo real de Auth

V2 copiaba el correo al crear el usuario, pero no lo sincronizaba posteriormente.

**V3:** agrega un trigger cuando cambia `auth.users.email`.

Además, una petición normal del frontend no puede editar directamente la copia del correo del perfil.

---

### 14. Pagos sin trazabilidad suficiente

V2 guardaba el estado y una referencia, pero no quién verificó ni cuándo.

**V3 agrega:**

```text
pago_verificado_por
pago_verificado_en
```

---

### 15. Los datos de prueba podían aparecer públicamente

El evento ficticio de V2 estaba:

```text
estado = publicado
es_prueba = true
```

pero la política pública solo comprobaba el estado.

Un visitante anónimo podía recibir el evento de prueba.

**V3:** las políticas anónimas excluyen `es_prueba = true`.

---

## Seguridad

### 16. Las funciones `SECURITY DEFINER` usaban `search_path = public`

Se cambió a:

```text
set search_path = ''
```

y se califican explícitamente las tablas con sus schemas.

Esto reduce riesgos de resolución de objetos inesperados.

---

### 17. Funciones internas estaban en un schema expuesto

V3 crea:

```text
private
```

para helpers e implementaciones privilegiadas.

El frontend utiliza wrappers públicos controlados.

---

### 18. Permisos de ejecución demasiado implícitos

PostgreSQL concede EXECUTE a funciones a `PUBLIC` por defecto.

V3 revoca la ejecución general y vuelve a conceder únicamente las funciones necesarias a:

```text
anon
authenticated
```

según corresponda.

---

## Mejoras adicionales

- Índices para consultas frecuentes y RLS.
- Nombre de equipo único sin distinguir mayúsculas/minúsculas.
- Documento y correo normalizados para evitar duplicados triviales.
- Regla: actividad publicada requiere fecha de inicio.
- `enlace_bases` para concursos.
- `imagen_url` para contenido.
- Función `regenerar_qr()`.
- Función controlada para emitir certificados manualmente.
- Archivo de limpieza de datos ficticios.
- Archivo de comprobaciones estructurales.

---


### 19. Un certificado anulado debía poder reemitirse

En una revisión adicional de la candidata V3 se detectó que un índice único
sin filtrar por estado habría impedido emitir un nuevo certificado después de
anular el anterior.

La V3 entregada corrige esto haciendo que la unicidad se aplique solamente a:

```text
estado = emitido
```

Por tanto:

```text
certificado emitido → no se duplica
certificado anulado → puede emitirse uno nuevo
```

---

# Conclusión

La V2 era útil como prototipo de arquitectura, pero tenía varios puntos donde la aplicación podía comportarse correctamente durante pruebas simples y fallar en casos reales:

```text
concurrencia
doble escaneo
QR desactivado
equipos
integridad cruzada
seguridad de funciones
estados devueltos
datos históricos
```

La V3 debe seguir considerándose:

```text
CANDIDATA PARA PRUEBAS
```

hasta ejecutarla en Supabase y superar el plan de pruebas funcionales y de seguridad.
