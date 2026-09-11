-- ============================================================
-- DATOS INICIALES REALES
-- Archivo: datos-iniciales.sql
-- ============================================================
-- IMPORTANTE:
-- Este archivo NO inserta información inventada.
-- Debe completarse únicamente con datos OFICIALES confirmados
-- por las gerencias correspondientes.
--
-- Recomendación:
-- 1. Completar la sección EVENTO.
-- 2. Completar PONENTES confirmados.
-- 3. Completar ACTIVIDADES confirmadas.
-- 4. Ejecutar recién cuando la información sea oficial.
--
-- Los participantes reales NO se colocan aquí.
-- Ellos crearán sus cuentas mediante el módulo de registro.
-- ============================================================


-- ============================================================
-- 1. EVENTO REAL
-- Descomentar y reemplazar los valores cuando sean oficiales.
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
    requiere_pago,
    enlace_pago,
    enlace_formulario_pago,
    porcentaje_minimo_certificado
)
values (
    'NOMBRE OFICIAL DEL EVENTO',
    'slug-del-evento',
    'DESCRIPCIÓN OFICIAL',
    'AAAA-MM-DD HH:MM:SS-05',
    'AAAA-MM-DD HH:MM:SS-05',
    'LUGAR OFICIAL',
    'DIRECCIÓN OFICIAL',
    'publicado',
    false,
    false,
    null,
    null,
    70
);
*/


-- ============================================================
-- 2. PONENTES REALES
-- Agregar únicamente cuando la Gerencia de Ponencias confirme.
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
    'RUTA O URL DE FOTO'
);
*/


-- ============================================================
-- 3. PONENCIAS REALES
-- Primero obtener el id del evento real desde Supabase.
-- modalidad_inscripcion normalmente será 'individual'.
-- ============================================================

/*
insert into public.actividades (
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
    'UUID-DEL-EVENTO',
    'ponencia',
    'TÍTULO OFICIAL',
    'DESCRIPCIÓN OFICIAL',
    'AAAA-MM-DD HH:MM:SS-05',
    'AAAA-MM-DD HH:MM:SS-05',
    'LUGAR',
    100,
    true,
    'individual',
    true,
    'publicado'
);
*/


-- ============================================================
-- 4. CONCURSOS REALES
-- Si es por equipos, definir mínimo y máximo de integrantes.
-- capacidad = cantidad máxima de equipos cuando la modalidad es equipo.
-- ============================================================

/*
insert into public.actividades (
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
    'UUID-DEL-EVENTO',
    'concurso',
    'NOMBRE OFICIAL DEL CONCURSO',
    'DESCRIPCIÓN / BASE RESUMIDA',
    'AAAA-MM-DD HH:MM:SS-05',
    'AAAA-MM-DD HH:MM:SS-05',
    'LUGAR',
    20,
    true,
    'equipo',
    3,
    5,
    false,
    'publicado'
);
*/


-- ============================================================
-- 5. RELACIONAR PONENTE CON PONENCIA
-- Ejecutar cuando ambos registros ya existan.
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


-- ============================================================
-- REGLA
-- No agregar aquí:
-- - usuarios reales;
-- - contraseñas;
-- - codigo de matricula de participantes;
-- - asistencia real;
-- - certificados reales.
--
-- Esa información se generará desde la propia plataforma.
-- ============================================================
