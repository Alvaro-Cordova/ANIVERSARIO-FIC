-- ============================================================
-- BASE DE DATOS V3 - DATOS DE PRUEBA
-- Archivo: datos-prueba.sql
-- Ejecutar SOLO después de esquema.sql + funciones.sql + permisos.sql.
-- ============================================================
-- No crea usuarios. Las cuentas de prueba deben crearse con Supabase Auth.
-- Los eventos ficticios tienen es_prueba = true y NO se muestran a anon.
-- ============================================================

-- ============================================================
-- 1. EVENTO GRATUITO DE PRUEBA
-- ============================================================

insert into public.eventos (
    id,
    nombre,
    slug,
    descripcion,
    fecha_inicio,
    fecha_fin,
    lugar,
    estado,
    es_prueba,
    inscripciones_abiertas,
    requiere_pago,
    porcentaje_minimo_certificado
)
values (
    '10000000-0000-0000-0000-000000000001',
    'EVENTO GRATUITO DE PRUEBA',
    'evento-gratuito-prueba',
    'Evento ficticio para probar registro, actividades, QR y asistencia.',
    '2026-09-20 08:00:00-05',
    '2026-09-20 20:00:00-05',
    'Lugar de prueba',
    'publicado',
    true,
    true,
    false,
    70
)
on conflict (id) do nothing;

-- ============================================================
-- 2. EVENTO CON PAGO DE PRUEBA
-- ============================================================

insert into public.eventos (
    id,
    nombre,
    slug,
    descripcion,
    fecha_inicio,
    fecha_fin,
    lugar,
    estado,
    es_prueba,
    inscripciones_abiertas,
    requiere_pago,
    enlace_pago,
    enlace_formulario_pago,
    porcentaje_minimo_certificado
)
values (
    '10000000-0000-0000-0000-000000000002',
    'EVENTO CON PAGO DE PRUEBA',
    'evento-pago-prueba',
    'Evento ficticio para verificar el flujo de pago manual.',
    '2026-09-20 08:00:00-05',
    '2026-09-20 20:00:00-05',
    'Lugar de prueba',
    'publicado',
    true,
    true,
    true,
    'https://ejemplo.invalid/pago',
    'https://ejemplo.invalid/formulario',
    70
)
on conflict (id) do nothing;

-- ============================================================
-- 3. PONENTE FICTICIO
-- ============================================================

insert into public.ponentes (
    id,
    nombres,
    apellidos,
    cargo,
    institucion,
    biografia
)
values (
    '20000000-0000-0000-0000-000000000001',
    'Ponente',
    'De Prueba',
    'Cargo ficticio',
    'Institución ficticia',
    'Registro utilizado únicamente para comprobar el sistema.'
)
on conflict (id) do nothing;

-- ============================================================
-- 4. PONENCIA INDIVIDUAL
-- ============================================================

insert into public.actividades (
    id,
    evento_id,
    tipo,
    titulo,
    descripcion,
    fecha_inicio,
    fecha_fin,
    lugar,
    capacidad,
    requiere_inscripcion,
    inscripciones_abiertas,
    modalidad_inscripcion,
    cuenta_para_certificado,
    estado
)
values (
    '30000000-0000-0000-0000-000000000001',
    '10000000-0000-0000-0000-000000000001',
    'ponencia',
    'Ponencia interna de prueba',
    'Sirve para probar inscripción, QR, asistencia y certificados.',
    '2026-09-20 09:00:00-05',
    '2026-09-20 10:30:00-05',
    'Auditorio de prueba',
    100,
    true,
    true,
    'individual',
    true,
    'publicado'
)
on conflict (id) do nothing;

-- ============================================================
-- 5. CONCURSO POR EQUIPO
-- ============================================================

insert into public.actividades (
    id,
    evento_id,
    tipo,
    titulo,
    descripcion,
    fecha_inicio,
    fecha_fin,
    lugar,
    capacidad,
    requiere_inscripcion,
    inscripciones_abiertas,
    modalidad_inscripcion,
    minimo_integrantes_equipo,
    maximo_integrantes_equipo,
    cuenta_para_certificado,
    estado
)
values (
    '30000000-0000-0000-0000-000000000002',
    '10000000-0000-0000-0000-000000000001',
    'concurso',
    'Concurso interno por equipos',
    'Sirve para probar creación, invitación e inscripción de equipos.',
    '2026-09-20 11:00:00-05',
    '2026-09-20 13:00:00-05',
    'Zona de prueba',
    20,
    true,
    true,
    'equipo',
    2,
    4,
    false,
    'publicado'
)
on conflict (id) do nothing;

-- ============================================================
-- 6. ACTIVIDAD QUE NO REQUIERE INSCRIPCIÓN
-- ============================================================

insert into public.actividades (
    id,
    evento_id,
    tipo,
    titulo,
    descripcion,
    fecha_inicio,
    fecha_fin,
    lugar,
    requiere_inscripcion,
    inscripciones_abiertas,
    modalidad_inscripcion,
    cuenta_para_certificado,
    estado
)
values (
    '30000000-0000-0000-0000-000000000003',
    '10000000-0000-0000-0000-000000000001',
    'ceremonia',
    'Ceremonia abierta de prueba',
    'Permite comprobar asistencia sin inscripción específica a la actividad.',
    '2026-09-20 15:00:00-05',
    '2026-09-20 16:00:00-05',
    'Patio de prueba',
    false,
    false,
    'individual',
    false,
    'publicado'
)
on conflict (id) do nothing;

insert into public.actividad_ponentes (
    actividad_id,
    ponente_id
)
values (
    '30000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000001'
)
on conflict do nothing;
