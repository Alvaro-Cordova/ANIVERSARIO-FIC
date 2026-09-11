# BASE DE DATOS V3.1 — CANDIDATA PARA PRUEBAS

Esta carpeta reemplaza la V2.

## Orden de instalación

En un proyecto nuevo de Supabase:

```text
1. esquema.sql
2. funciones.sql
3. permisos.sql
4. comprobaciones.sql
5. datos-prueba.sql        (opcional)
6. datos-iniciales.sql     (cuando haya información real confirmada)
```

## Importante

No cargar V2 y después V3 sobre la misma base esperando que `CREATE TABLE`
actualice automáticamente las tablas.

La V3 fue preparada para instalarse inicialmente sobre una base nueva.

## Archivos

- `AUDITORIA_V2.md`: errores y mejoras encontrados.
- `esquema.sql`: tablas, relaciones, restricciones y triggers.
- `funciones.sql`: lógica segura de inscripciones, equipos, QR, asistencia y certificados.
- `permisos.sql`: RLS y permisos.
- `datos-prueba.sql`: datos ficticios aislados.
- `datos-iniciales.sql`: plantilla para datos reales.
- `comprobaciones.sql`: consultas de revisión estructural.
- `PLAN_PRUEBAS_V3.md`: pruebas funcionales y de seguridad.
- `limpiar-datos-prueba.sql`: eliminación de datos ficticios cuando ya no se necesiten.

## Estado

```text
V3 = CANDIDATA PARA PRUEBAS
```

Todavía no debe llamarse “versión estable” hasta ejecutarla en Supabase y
completar el plan de pruebas.


## Dos reglas adicionales

1. **No agregar el schema `private` a los schemas expuestos de la API de Supabase.**
   Las funciones internas privilegiadas se guardan ahí intencionalmente.

2. **No borrar usuarios reales para “desactivarlos”.**
   Utilizar `perfiles.activo = false`. El borrado de una cuenta de Auth puede
   eliminar datos operativos dependientes por cascada; la desactivación
   conserva el historial.


Ver `CAMBIOS_V3_1.md` para los ajustes previos a la instalación en Supabase.
