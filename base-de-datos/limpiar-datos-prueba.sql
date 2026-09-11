-- ============================================================
-- BASE DE DATOS V3 - LIMPIAR DATOS DE PRUEBA
-- Archivo: limpiar-datos-prueba.sql
-- ============================================================
-- Ejecutar únicamente cuando ya no se necesiten los eventos ficticios.
-- ============================================================

-- Los certificados usan ON DELETE RESTRICT para proteger el historial,
-- por eso deben eliminarse explícitamente cuando pertenecen a eventos
-- marcados como prueba.
delete from public.certificados
where evento_id in (
    select id
    from public.eventos
    where es_prueba = true
);

-- Después se pueden borrar los eventos ficticios.
-- Sus actividades, inscripciones, QR y asistencias dependientes se
-- eliminarán mediante sus reglas ON DELETE.
delete from public.eventos
where es_prueba = true;

-- El ponente ficticio no depende directamente del evento.
delete from public.ponentes
where id = '20000000-0000-0000-0000-000000000001';
