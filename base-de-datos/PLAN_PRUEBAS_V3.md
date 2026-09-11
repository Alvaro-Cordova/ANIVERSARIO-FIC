# PLAN DE PRUEBAS DE LA BASE DE DATOS V3

La V3 no se declarará estable solo porque los scripts SQL se ejecuten sin errores.

Debe superar estas pruebas en Supabase.

---

## Fase 1 — Instalación

Ejecutar:

```text
1. esquema.sql
2. funciones.sql
3. permisos.sql
4. comprobaciones.sql
```

Resultado esperado:

```text
sin errores SQL
12 tablas presentes
RLS activo en todas
funciones públicas presentes
```

Después ejecutar opcionalmente:

```text
datos-prueba.sql
```

---

## Fase 2 — Cuentas de prueba

Crear mediante Supabase Auth:

```text
participante1
participante2
participante3
control1
admin1
```

No insertar contraseñas manualmente por SQL.

Comprobar que cada cuenta cree automáticamente su fila en:

```text
perfiles
```

---

## Fase 3 — Roles

Asignar desde SQL Editor o administración:

```text
participante1 → participante
participante2 → participante
participante3 → participante
control1 → control
admin1 → admin
```

Comprobar:

- participante no puede convertirse en admin;
- participante no puede modificar `activo`;
- participante solo lee su perfil;
- admin puede leer los perfiles.

---

## Fase 4 — Inscripción gratuita

Con `participante1`:

```text
inscribirse_evento(evento gratuito)
```

Esperado:

```text
estado = inscrito
estado_pago = no_requiere
```

Repetir la llamada.

Esperado:

```text
no crea duplicado
mantiene el mismo estado
```

---

## Fase 5 — Evento con pago

Con `participante2`:

```text
inscribirse_evento(evento con pago)
```

Esperado:

```text
estado = pendiente
estado_pago = pendiente
```

Intentar obtener QR.

Esperado:

```text
rechazado
```

Con `admin1`:

```text
verificar_pago_evento(..., true, ...)
```

Esperado:

```text
estado = inscrito
estado_pago = verificado
pago_verificado_por = admin1
pago_verificado_en != null
```

Repetir `inscribirse_evento()`.

Esperado:

```text
la respuesta sigue indicando inscrito/verificado
```

Esta prueba comprueba un error detectado en V2.

---

## Fase 6 — Ponencia individual

Con `participante1`:

```text
inscribirse_actividad(ponencia)
```

Esperado:

```text
una inscripción
sin duplicados
```

Repetir.

Esperado:

```text
sigue existiendo una sola inscripción
```

Llenar capacidad con usuarios de prueba y comprobar que el siguiente sea rechazado.

---

## Fase 7 — Equipos

Con `participante1`:

```text
crear_equipo()
```

Esperado:

```text
equipo estado = formando
participante1 = líder
código de invitación generado
```

Con `participante2`:

```text
unirse_equipo(código)
```

Esperado:

```text
queda como miembro
```

Intentar con `participante2` crear/unirse a otro equipo de la misma actividad.

Esperado:

```text
rechazado
```

Intentar superar `maximo_integrantes_equipo`.

Esperado:

```text
rechazado
```

Inscribir equipo con menos del mínimo.

Esperado:

```text
rechazado
```

Completar mínimo e inscribir.

Esperado:

```text
equipo estado = inscrito
inscripciones_actividad contiene una inscripción por equipo
```

Intentar añadir otro miembro después.

Esperado:

```text
rechazado
```

---

## Fase 8 — QR

Con un participante inscrito:

```text
obtener_o_crear_qr()
```

Esperado:

```text
token UUID
```

Repetir.

Esperado:

```text
mismo token mientras siga activo
```

Ejecutar:

```text
regenerar_qr()
```

Esperado:

```text
token nuevo
token anterior deja de ser válido
```

Desactivar el QR como administrador y volver a llamar:

```text
obtener_o_crear_qr()
```

Esperado:

```text
reactiva la fila
genera token nuevo
NO aparece error UNIQUE
```

Esta prueba comprueba otro fallo detectado en V2.

---

## Fase 9 — Asistencia

Con `control1`, actividad y token válidos:

Primer escaneo:

```text
entrada
```

Escanear inmediatamente otra vez (<30 s).

Esperado:

```text
error de escaneo duplicado
NO registra salida
```

Esperar más de 30 segundos o ajustar temporalmente el test.

Segundo escaneo válido:

```text
salida
```

Tercer escaneo:

```text
rechazado
```

Comprobar:

```text
salida >= entrada
```

Intentar usar:

- QR de otro evento;
- QR desactivado;
- participante no inscrito en actividad obligatoria.

Todos deben ser rechazados.

---

## Fase 10 — RLS

Esta fase NO debe probarse únicamente desde SQL Editor como `postgres`,
porque `postgres` puede saltarse RLS.

Probar desde:

```text
frontend
o cliente Supabase autenticado
```

Participante debe poder:

```text
leer su perfil
leer sus inscripciones
leer su QR
leer su asistencia
leer sus certificados
```

Participante NO debe poder:

```text
leer perfil ajeno
leer QR ajeno
crear asistencia
emitir certificado
administrar eventos
```

Control debe poder:

```text
registrar_escaneo_qr()
```

pero no:

```text
administrar eventos
emitir certificados
leer masivamente perfiles
```

Admin debe tener las operaciones administrativas previstas.

---

## Fase 11 — Certificados

Como participante:

```text
emitir_certificado_manual()
```

Esperado:

```text
rechazado
```

Como admin:

```text
emitir_certificado_manual()
```

Esperado:

```text
código CERT-...
```

Repetir con mismo evento/usuario/tipo.

Esperado:

```text
devuelve certificado existente
no duplica
```

Cambiar posteriormente el nombre del participante.

Ejecutar:

```text
verificar_certificado(código)
```

Esperado:

```text
conserva el nombre con el que fue emitido
```

---

## Fase 12 — Datos de prueba y datos reales

Visitante anónimo:

```text
NO debe ver eventos con es_prueba = true
```

Usuario autenticado de desarrollo:

```text
sí puede consultar los eventos publicados de prueba
```

La web de producción debe filtrar también:

```text
es_prueba = false
```

como una segunda protección visual.

---

# Criterio para declarar V3 estable

Solo se considera estable cuando:

```text
scripts SQL: OK
comprobaciones estructurales: OK
registro/Auth: OK
RLS: OK
inscripciones: OK
pagos: OK
equipos: OK
QR: OK
asistencia: OK
certificados: OK
pruebas negativas: OK
```

Si aparece un fallo durante estas pruebas:

```text
V3 candidata
→ corregir
→ V3.1
→ repetir pruebas afectadas
```
