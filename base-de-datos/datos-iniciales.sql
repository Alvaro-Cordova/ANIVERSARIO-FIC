-- ============================================================
-- BASE DE DATOS V3 - DATOS INICIALES REALES
-- Archivo: datos-iniciales.sql
-- ============================================================
-- Este archivo es una PLANTILLA.
-- No contiene nombres, fechas, ponentes ni concursos inventados.
-- Completar únicamente con información OFICIAL confirmada.
--
-- Los usuarios/participantes reales NO se insertan aquí.
-- Ellos se registran mediante Supabase Auth.
-- ============================================================

-- ============================================================
-- 1. EVENTO REAL
-- ============================================================

/*
insert into public.eventos (
    nombre,
    slug,
    descripcion,
    fecha_inicio,
    fecha_fin,
    lugar,
    direccion,
    estado,
    es_prueba,
    inscripciones_abiertas,
    inscripcion_inicio,
    inscripcion_fin,
    requiere_pago,
    enlace_pago,
    enlace_formulario_pago,
    porcentaje_minimo_certificado
)
values (
    'NOMBRE OFICIAL',
    'slug-oficial-en-minusculas',
    'DESCRIPCIÓN OFICIAL',
    'AAAA-MM-DD HH:MM:SS-05',
    'AAAA-MM-DD HH:MM:SS-05',
    'LUGAR',
    'DIRECCIÓN',
    'publicado',
    false,
    true,
    'AAAA-MM-DD HH:MM:SS-05',
    'AAAA-MM-DD HH:MM:SS-05',
    false,
    null,
    null,
    70
);
*/

-- ============================================================
-- 2. PONENTES
-- ============================================================

/*
insert into public.ponentes (
    nombres,
    apellidos,
    cargo,
    institucion,
    biografia,
    foto_url
)
values (
    'NOMBRES',
    'APELLIDOS',
    'CARGO',
    'INSTITUCIÓN',
    'BIOGRAFÍA',
    'URL O RUTA DE FOTO'
);
*/

-- ============================================================
-- 3. PONENCIA
-- modalidad_inscripcion = individual
-- ============================================================

/*
insert into public.actividades (
    evento_id,
    tipo,
    titulo,
    descripcion,
    imagen_url,
    fecha_inicio,
    fecha_fin,
    lugar,
    capacidad,
    requiere_inscripcion,
    inscripciones_abiertas,
    inscripcion_inicio,
    inscripcion_fin,
    modalidad_inscripcion,
    cuenta_para_certificado,
    estado
)
values (
    'UUID-DEL-EVENTO',
    'ponencia',
    'TÍTULO OFICIAL',
    'DESCRIPCIÓN',
    null,
    'AAAA-MM-DD HH:MM:SS-05',
    'AAAA-MM-DD HH:MM:SS-05',
    'LUGAR',
    100,
    true,
    true,
    'AAAA-MM-DD HH:MM:SS-05',
    'AAAA-MM-DD HH:MM:SS-05',
    'individual',
    true,
    'publicado'
);
*/

-- ============================================================
-- 4. CONCURSO POR EQUIPO
-- capacidad = cantidad máxima de EQUIPOS inscritos.
-- ============================================================

/*
insert into public.actividades (
    evento_id,
    tipo,
    titulo,
    descripcion,
    enlace_bases,
    fecha_inicio,
    fecha_fin,
    lugar,
    capacidad,
    requiere_inscripcion,
    inscripciones_abiertas,
    inscripcion_inicio,
    inscripcion_fin,
    modalidad_inscripcion,
    minimo_integrantes_equipo,
    maximo_integrantes_equipo,
    cuenta_para_certificado,
    estado
)
values (
    'UUID-DEL-EVENTO',
    'concurso',
    'NOMBRE OFICIAL DEL CONCURSO',
    'DESCRIPCIÓN',
    'URL-DE-LAS-BASES',
    'AAAA-MM-DD HH:MM:SS-05',
    'AAAA-MM-DD HH:MM:SS-05',
    'LUGAR',
    20,
    true,
    true,
    'AAAA-MM-DD HH:MM:SS-05',
    'AAAA-MM-DD HH:MM:SS-05',
    'equipo',
    3,
    5,
    false,
    'publicado'
);
*/

-- ============================================================
-- 5. RELACIÓN PONENTE-PONENCIA
-- ============================================================

/*
insert into public.actividad_ponentes (
    actividad_id,
    ponente_id
)
values (
    'UUID-DE-LA-PONENCIA',
    'UUID-DEL-PONENTE'
);
*/

-- Nunca colocar aquí:
-- contraseñas, claves Supabase, service_role, DNI masivos,
-- asistencias reales ni certificados reales.
