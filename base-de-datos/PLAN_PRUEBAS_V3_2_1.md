# PLAN DE PRUEBAS V3.2.1

## Instalación sobre el proyecto DEV actual

Ejecutar en este orden:

```text
1. MIGRACION_V3_2_A_V3_2_1.sql
2. funciones-v3_2_1-migracion.sql
3. permisos-v3_2_1-migracion.sql
4. comprobaciones.sql
```

No volver a ejecutar `esquema.sql`, `funciones.sql` ni `permisos.sql` completos
sobre la base ya instalada.

## Prueba 1 - Consultar elegibilidad

Como participante:

```text
mi_elegibilidad_certificado(EVENTO)
```

Debe devolver:

```text
apto
ya_emitido
codigo_existente
porcentaje_obtenido
porcentaje_requerido
minutos_presentes
minutos_programados
actividades_consideradas
actividades_pendientes
motivo
```

## Prueba 2 - Actividades pendientes

Si una actividad certificable aún no terminó:

```text
apto = false
```

y el motivo debe indicar que todavía existen actividades pendientes.

## Prueba 3 - Porcentaje insuficiente

Con todas las actividades terminadas, pero porcentaje menor al mínimo:

```text
apto = false
```

## Prueba 4 - Autoemisión

Cuando:

```text
porcentaje_obtenido >= porcentaje_requerido
```

el participante ejecuta:

```text
emitir_mi_certificado(EVENTO)
```

y obtiene un código `CERT-...`.

## Prueba 5 - Duplicado

Ejecutar nuevamente `emitir_mi_certificado(EVENTO)`.

Debe devolver el mismo código, sin crear otra fila.

## Prueba 6 - Otro participante

Un participante no recibe ningún parámetro `usuario_id`, por lo que no existe
forma de pedir desde la función un certificado para otra persona.

## Prueba 7 - INSERT directo

Un participante intenta insertar directamente en `public.certificados`.

RLS debe rechazarlo.

## Prueba 8 - Cuenta desactivada

Con `perfiles.activo = false`:

```text
emitir_mi_certificado()
```

debe ser rechazado.

## Prueba 9 - Verificación pública

El código generado debe seguir funcionando con:

```text
verificar_certificado(CERT-...)
```

sin iniciar sesión.
