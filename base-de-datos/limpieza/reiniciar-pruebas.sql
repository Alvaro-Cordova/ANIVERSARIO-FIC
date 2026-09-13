-- =====================================================
-- REINICIO DE DATOS DE PRUEBA
-- ANIVERSARIO FIC
-- NO EJECUTAR EN PRODUCCIÓN
-- =====================================================


BEGIN;


-- ======================================
-- ASISTENCIA QR
-- ======================================

DELETE FROM public.asistencias;


-- ======================================
-- CERTIFICADOS GENERADOS
-- ======================================

DELETE FROM public.certificados;


-- ======================================
-- INSCRIPCIONES A ACTIVIDADES
-- ======================================

DELETE FROM public.inscripciones_actividad;


-- ======================================
-- EQUIPOS DE CONCURSOS
-- ======================================

DELETE FROM public.equipos;


-- ======================================
-- CURSOS ASIGNADOS A PARTICIPANTES
-- ======================================

DELETE FROM public.curso_participantes;


COMMIT;


SELECT 
'Base de pruebas reiniciada correctamente'
AS mensaje;