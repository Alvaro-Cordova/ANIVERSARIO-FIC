-- ============================================================
-- BASE DE DATOS V3 - COMPROBACIONES ESTRUCTURALES
-- Archivo: comprobaciones.sql
-- Ejecutar después de instalar V3.
-- ============================================================
-- Este archivo NO reemplaza las pruebas funcionales con usuarios reales
-- de prueba. Sirve para detectar fallos de estructura/configuración.
-- ============================================================

-- ============================================================
-- 1. TABLAS ESPERADAS
-- Resultado esperado: 12 filas y ninguna con existe = false.
-- ============================================================

with esperadas(nombre) as (
    values
        ('perfiles'),
        ('eventos'),
        ('inscripciones_evento'),
        ('actividades'),
        ('ponentes'),
        ('actividad_ponentes'),
        ('equipos'),
        ('miembros_equipo'),
        ('inscripciones_actividad'),
        ('credenciales_qr'),
        ('asistencias'),
        ('certificados')
)
select
    nombre,
    to_regclass('public.' || nombre) is not null as existe
from esperadas
order by nombre;

-- ============================================================
-- 2. RLS
-- Resultado esperado: todas las tablas muestran rls_activo = true.
-- ============================================================

select
    c.relname as tabla,
    c.relrowsecurity as rls_activo
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where n.nspname = 'public'
  and c.relkind = 'r'
  and c.relname in (
      'perfiles',
      'eventos',
      'inscripciones_evento',
      'actividades',
      'ponentes',
      'actividad_ponentes',
      'equipos',
      'miembros_equipo',
      'inscripciones_actividad',
      'credenciales_qr',
      'asistencias',
      'certificados'
  )
order by c.relname;

-- ============================================================
-- 3. FUNCIONES PÚBLICAS ESPERADAS
-- Resultado esperado: todas existen.
-- ============================================================

with funciones(firma) as (
    values
        ('public.inscribirse_evento(uuid)'),
        ('public.verificar_pago_evento(uuid,boolean,text)'),
        ('public.inscribirse_actividad(uuid)'),
        ('public.crear_equipo(uuid,text)'),
        ('public.unirse_equipo(uuid)'),
        ('public.inscribir_equipo_actividad(uuid)'),
        ('public.obtener_o_crear_qr(uuid)'),
        ('public.regenerar_qr(uuid)'),
        ('public.registrar_escaneo_qr(uuid,uuid)'),
        ('public.emitir_certificado_manual(uuid,uuid,text,uuid,text)'),
        ('public.verificar_certificado(text)')
)
select
    firma,
    to_regprocedure(firma) is not null as existe
from funciones
order by firma;

-- ============================================================
-- 4. BUSCAR CERTIFICADOS CON EVENTO/ACTIVIDAD INCOHERENTE
-- Resultado esperado: 0 filas.
-- ============================================================

select
    c.id,
    c.evento_id,
    c.actividad_id,
    a.evento_id as evento_real_actividad
from public.certificados c
join public.actividades a on a.id = c.actividad_id
where c.actividad_id is not null
  and c.evento_id <> a.evento_id;

-- ============================================================
-- 5. BUSCAR EQUIPOS INSCRITOS EN ACTIVIDAD EQUIVOCADA
-- Resultado esperado: 0 filas.
-- La FK compuesta debería hacerlo imposible.
-- ============================================================

select
    ia.id,
    ia.actividad_id,
    ia.equipo_id,
    e.actividad_id as actividad_real_equipo
from public.inscripciones_actividad ia
join public.equipos e on e.id = ia.equipo_id
where ia.equipo_id is not null
  and ia.actividad_id <> e.actividad_id;

-- ============================================================
-- 6. BUSCAR USUARIO EN DOS EQUIPOS DE LA MISMA ACTIVIDAD
-- Resultado esperado: 0 filas.
-- ============================================================

select
    actividad_id,
    usuario_id,
    count(*) as cantidad
from public.miembros_equipo
group by actividad_id, usuario_id
having count(*) > 1;

-- ============================================================
-- 7. BUSCAR ASISTENCIAS TEMPORALMENTE INVÁLIDAS
-- Resultado esperado: 0 filas.
-- ============================================================

select *
from public.asistencias
where (salida_en is not null and entrada_en is null)
   or (salida_en is not null and salida_en < entrada_en);

-- ============================================================
-- 8. BUSCAR QR DUPLICADOS POR USUARIO/EVENTO
-- Resultado esperado: 0 filas.
-- ============================================================

select
    evento_id,
    usuario_id,
    count(*) as cantidad
from public.credenciales_qr
group by evento_id, usuario_id
having count(*) > 1;

-- ============================================================
-- 9. BUSCAR TOKENS QR DUPLICADOS
-- Resultado esperado: 0 filas.
-- ============================================================

select
    token,
    count(*) as cantidad
from public.credenciales_qr
group by token
having count(*) > 1;

-- ============================================================
-- 10. EVENTOS REALES MARCADOS COMO PRUEBA / REVISIÓN VISUAL
-- Revisar manualmente esta lista.
-- ============================================================

select
    id,
    nombre,
    slug,
    es_prueba,
    estado
from public.eventos
order by es_prueba desc, nombre;
