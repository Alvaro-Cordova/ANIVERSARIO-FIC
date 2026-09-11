-- ============================================================
-- DATOS DE PRUEBA
-- Archivo: datos-prueba.sql
-- ============================================================
-- Estos registros SOLO sirven para desarrollo.
-- Todo el evento de prueba queda marcado con es_prueba = true.
-- Al borrar ese evento, PostgreSQL eliminará en cascada
-- sus actividades y relaciones dependientes.
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
    requiere_pago,
    porcentaje_minimo_certificado
)
values (
    '10000000-0000-0000-0000-000000000001',
    'EVENTO INTERNO DE PRUEBAS',
    'evento-interno-pruebas',
    'Evento ficticio utilizado únicamente para desarrollo y pruebas.',
    '2026-09-20 08:00:00-05',
    '2026-09-20 18:00:00-05',
    'Lugar de prueba',
    'publicado',
    true,
    false,
    70
)
on conflict (id) do nothing;

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
    'Cargo de prueba',
    'Institución de prueba',
    'Registro ficticio utilizado únicamente para verificar el sistema.'
)
on conflict (id) do nothing;

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
    'individual',
    true,
    'publicado'
)
on conflict (id) do nothing;

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
    'Concurso interno de prueba',
    'Sirve para probar creación e inscripción de equipos.',
    '2026-09-20 11:00:00-05',
    '2026-09-20 13:00:00-05',
    'Zona de prueba',
    20,
    true,
    'equipo',
    2,
    4,
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

-- No se crean usuarios aquí.
-- Crear cuentas de prueba mediante Supabase Auth o el módulo de registro.
