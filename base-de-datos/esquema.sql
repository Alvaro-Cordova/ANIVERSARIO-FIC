-- ============================================================
-- BASE DE DATOS V2 - ANIVERSARIO FIC / PRECONGRESO CONEIC 2027
-- Archivo: esquema.sql
-- Ejecutar PRIMERO en Supabase > SQL Editor
-- ============================================================

create extension if not exists pgcrypto;

-- ============================================================
-- 1. PERFILES
-- Supabase Auth guarda correo, contraseña y sesión en auth.users.
-- Aquí SOLO se guardan datos adicionales del participante.
-- ============================================================

create table if not exists public.perfiles (
    id uuid primary key references auth.users(id) on delete cascade,
    nombres text not null default '',
    apellidos text not null default '',
    tipo_documento text not null default 'DNI',
    documento_identidad text unique,
    telefono text,
    institucion text,
    carrera text,
    correo text,
    rol text not null default 'participante'
        check (rol in ('participante', 'control', 'admin')),
    activo boolean not null default true,
    creado_en timestamptz not null default now(),
    actualizado_en timestamptz not null default now()
);

-- ============================================================
-- 2. EVENTOS
-- La misma plataforma puede servir para varios eventos.
-- es_prueba permite separar eventos ficticios de eventos reales.
-- ============================================================

create table if not exists public.eventos (
    id uuid primary key default gen_random_uuid(),
    nombre text not null,
    slug text not null unique,
    descripcion text,
    fecha_inicio timestamptz not null,
    fecha_fin timestamptz,
    lugar text,
    direccion text,
    estado text not null default 'borrador'
        check (estado in ('borrador', 'publicado', 'finalizado', 'cancelado')),
    es_prueba boolean not null default false,

    requiere_pago boolean not null default false,
    enlace_pago text,
    enlace_formulario_pago text,

    porcentaje_minimo_certificado numeric(5,2) not null default 70
        check (porcentaje_minimo_certificado between 0 and 100),

    creado_por uuid references public.perfiles(id) on delete set null,
    creado_en timestamptz not null default now(),
    actualizado_en timestamptz not null default now(),

    check (fecha_fin is null or fecha_fin >= fecha_inicio)
);

-- ============================================================
-- 3. INSCRIPCIÓN GENERAL AL EVENTO
-- Tener una cuenta no significa automáticamente estar inscrito.
-- ============================================================

create table if not exists public.inscripciones_evento (
    id uuid primary key default gen_random_uuid(),
    evento_id uuid not null references public.eventos(id) on delete cascade,
    usuario_id uuid not null references public.perfiles(id) on delete cascade,

    estado text not null default 'pendiente'
        check (estado in ('pendiente', 'inscrito', 'cancelado')),

    estado_pago text not null default 'no_requiere'
        check (estado_pago in ('no_requiere', 'pendiente', 'verificado', 'rechazado')),

    medio_pago text,
    referencia_pago text,

    inscrito_en timestamptz not null default now(),
    actualizado_en timestamptz not null default now(),

    unique (evento_id, usuario_id)
);

-- ============================================================
-- 4. ACTIVIDADES
-- Una sola tabla para ponencias, concursos, talleres, etc.
-- ============================================================

create table if not exists public.actividades (
    id uuid primary key default gen_random_uuid(),
    evento_id uuid not null references public.eventos(id) on delete cascade,

    tipo text not null
        check (tipo in ('ponencia', 'concurso', 'taller', 'ceremonia', 'otro')),

    titulo text not null,
    descripcion text,

    fecha_inicio timestamptz,
    fecha_fin timestamptz,
    lugar text,

    -- En actividades individuales representa personas.
    -- En actividades por equipo representa cantidad máxima de equipos.
    capacidad integer,

    requiere_inscripcion boolean not null default true,

    modalidad_inscripcion text not null default 'individual'
        check (modalidad_inscripcion in ('individual', 'equipo', 'ambos')),

    minimo_integrantes_equipo integer,
    maximo_integrantes_equipo integer,

    cuenta_para_certificado boolean not null default false,

    estado text not null default 'borrador'
        check (estado in ('borrador', 'publicado', 'finalizado', 'cancelado')),

    creado_en timestamptz not null default now(),
    actualizado_en timestamptz not null default now(),

    check (capacidad is null or capacidad >= 0),
    check (fecha_fin is null or fecha_inicio is null or fecha_fin >= fecha_inicio),
    check (
        minimo_integrantes_equipo is null
        or minimo_integrantes_equipo >= 1
    ),
    check (
        maximo_integrantes_equipo is null
        or maximo_integrantes_equipo >= 1
    ),
    check (
        minimo_integrantes_equipo is null
        or maximo_integrantes_equipo is null
        or maximo_integrantes_equipo >= minimo_integrantes_equipo
    )
);

-- ============================================================
-- 5. PONENTES
-- Información pública de ponentes.
-- ============================================================

create table if not exists public.ponentes (
    id uuid primary key default gen_random_uuid(),
    nombres text not null,
    apellidos text,
    cargo text,
    institucion text,
    biografia text,
    foto_url text,
    creado_en timestamptz not null default now(),
    actualizado_en timestamptz not null default now()
);

create table if not exists public.actividad_ponentes (
    actividad_id uuid not null references public.actividades(id) on delete cascade,
    ponente_id uuid not null references public.ponentes(id) on delete cascade,
    primary key (actividad_id, ponente_id)
);

-- ============================================================
-- 6. EQUIPOS PARA CONCURSOS / ACTIVIDADES GRUPALES
-- ============================================================

create table if not exists public.equipos (
    id uuid primary key default gen_random_uuid(),
    actividad_id uuid not null references public.actividades(id) on delete cascade,
    nombre text not null,
    lider_usuario_id uuid not null references public.perfiles(id) on delete cascade,
    codigo_invitacion uuid not null default gen_random_uuid() unique,
    estado text not null default 'formando'
        check (estado in ('formando', 'listo', 'cancelado')),
    creado_en timestamptz not null default now(),
    actualizado_en timestamptz not null default now(),
    unique (actividad_id, nombre)
);

create table if not exists public.miembros_equipo (
    id uuid primary key default gen_random_uuid(),
    equipo_id uuid not null references public.equipos(id) on delete cascade,
    usuario_id uuid not null references public.perfiles(id) on delete cascade,
    rol_equipo text not null default 'miembro'
        check (rol_equipo in ('lider', 'miembro')),
    unido_en timestamptz not null default now(),
    unique (equipo_id, usuario_id)
);

-- ============================================================
-- 7. INSCRIPCIONES A ACTIVIDADES
-- Puede ser individual O por equipo.
-- Nunca ambas al mismo tiempo.
-- ============================================================

create table if not exists public.inscripciones_actividad (
    id uuid primary key default gen_random_uuid(),
    actividad_id uuid not null references public.actividades(id) on delete cascade,

    usuario_id uuid references public.perfiles(id) on delete cascade,
    equipo_id uuid references public.equipos(id) on delete cascade,

    estado text not null default 'inscrito'
        check (estado in ('pendiente', 'inscrito', 'lista_espera', 'cancelado')),

    inscrito_en timestamptz not null default now(),
    actualizado_en timestamptz not null default now(),

    check (
        (usuario_id is not null and equipo_id is null)
        or
        (usuario_id is null and equipo_id is not null)
    )
);

create unique index if not exists uq_inscripcion_individual
on public.inscripciones_actividad (actividad_id, usuario_id)
where usuario_id is not null;

create unique index if not exists uq_inscripcion_equipo
on public.inscripciones_actividad (actividad_id, equipo_id)
where equipo_id is not null;

-- ============================================================
-- 8. CREDENCIALES QR
-- El QR guarda un token aleatorio, NO nombre/correo/DNI.
-- ============================================================

create table if not exists public.credenciales_qr (
    id uuid primary key default gen_random_uuid(),
    evento_id uuid not null references public.eventos(id) on delete cascade,
    usuario_id uuid not null references public.perfiles(id) on delete cascade,
    token uuid not null default gen_random_uuid() unique,
    activo boolean not null default true,
    creado_en timestamptz not null default now(),
    unique (evento_id, usuario_id)
);

-- ============================================================
-- 9. ASISTENCIA
-- Una sola fila por usuario + actividad.
-- Primer escaneo = entrada.
-- Segundo escaneo = salida.
-- ============================================================

create table if not exists public.asistencias (
    id uuid primary key default gen_random_uuid(),
    actividad_id uuid not null references public.actividades(id) on delete cascade,
    usuario_id uuid not null references public.perfiles(id) on delete cascade,

    entrada_en timestamptz,
    salida_en timestamptz,

    entrada_registrada_por uuid references public.perfiles(id) on delete set null,
    salida_registrada_por uuid references public.perfiles(id) on delete set null,

    estado text not null default 'registrada'
        check (estado in ('registrada', 'validada', 'observada')),

    observacion text,

    creado_en timestamptz not null default now(),
    actualizado_en timestamptz not null default now(),

    unique (actividad_id, usuario_id),
    check (salida_en is null or entrada_en is null or salida_en >= entrada_en)
);

-- ============================================================
-- 10. CERTIFICADOS
-- El participante puede consultar sus certificados,
-- pero no crearlos manualmente.
-- ============================================================

create table if not exists public.certificados (
    id uuid primary key default gen_random_uuid(),
    evento_id uuid not null references public.eventos(id) on delete cascade,
    actividad_id uuid references public.actividades(id) on delete cascade,
    usuario_id uuid not null references public.perfiles(id) on delete cascade,

    tipo text not null default 'participacion',

    codigo text not null unique default
        ('CERT-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 12))),

    estado text not null default 'emitido'
        check (estado in ('emitido', 'anulado')),

    pdf_url text,
    emitido_en timestamptz not null default now(),
    emitido_por uuid references public.perfiles(id) on delete set null
);

create unique index if not exists uq_certificado_evento_usuario
on public.certificados (evento_id, usuario_id, tipo)
where actividad_id is null;

create unique index if not exists uq_certificado_actividad_usuario
on public.certificados (actividad_id, usuario_id, tipo)
where actividad_id is not null;

-- ============================================================
-- 11. ÍNDICES
-- ============================================================

create index if not exists idx_actividades_evento
on public.actividades(evento_id);

create index if not exists idx_actividades_tipo
on public.actividades(tipo);

create index if not exists idx_inscripciones_evento_usuario
on public.inscripciones_evento(usuario_id);

create index if not exists idx_inscripciones_actividad_usuario
on public.inscripciones_actividad(usuario_id);

create index if not exists idx_inscripciones_actividad_equipo
on public.inscripciones_actividad(equipo_id);

create index if not exists idx_asistencias_usuario
on public.asistencias(usuario_id);

create index if not exists idx_asistencias_actividad
on public.asistencias(actividad_id);

create index if not exists idx_certificados_usuario
on public.certificados(usuario_id);

create index if not exists idx_equipos_lider
on public.equipos(lider_usuario_id);

create index if not exists idx_miembros_equipo_usuario
on public.miembros_equipo(usuario_id);

-- ============================================================
-- 12. ACTUALIZAR "actualizado_en" AUTOMÁTICAMENTE
-- ============================================================

create or replace function public.actualizar_fecha_modificacion()
returns trigger
language plpgsql
as $$
begin
    new.actualizado_en = now();
    return new;
end;
$$;

drop trigger if exists trg_perfiles_actualizado on public.perfiles;
create trigger trg_perfiles_actualizado
before update on public.perfiles
for each row execute function public.actualizar_fecha_modificacion();

drop trigger if exists trg_eventos_actualizado on public.eventos;
create trigger trg_eventos_actualizado
before update on public.eventos
for each row execute function public.actualizar_fecha_modificacion();

drop trigger if exists trg_inscripciones_evento_actualizado on public.inscripciones_evento;
create trigger trg_inscripciones_evento_actualizado
before update on public.inscripciones_evento
for each row execute function public.actualizar_fecha_modificacion();

drop trigger if exists trg_actividades_actualizado on public.actividades;
create trigger trg_actividades_actualizado
before update on public.actividades
for each row execute function public.actualizar_fecha_modificacion();

drop trigger if exists trg_ponentes_actualizado on public.ponentes;
create trigger trg_ponentes_actualizado
before update on public.ponentes
for each row execute function public.actualizar_fecha_modificacion();

drop trigger if exists trg_equipos_actualizado on public.equipos;
create trigger trg_equipos_actualizado
before update on public.equipos
for each row execute function public.actualizar_fecha_modificacion();

drop trigger if exists trg_inscripciones_actividad_actualizado on public.inscripciones_actividad;
create trigger trg_inscripciones_actividad_actualizado
before update on public.inscripciones_actividad
for each row execute function public.actualizar_fecha_modificacion();

drop trigger if exists trg_asistencias_actualizado on public.asistencias;
create trigger trg_asistencias_actualizado
before update on public.asistencias
for each row execute function public.actualizar_fecha_modificacion();

-- ============================================================
-- 13. CREAR PERFIL AUTOMÁTICAMENTE AL REGISTRARSE
-- ============================================================

create or replace function public.crear_perfil_nuevo_usuario()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    insert into public.perfiles (
        id,
        nombres,
        apellidos,
        correo
    )
    values (
        new.id,
        coalesce(new.raw_user_meta_data->>'nombres', ''),
        coalesce(new.raw_user_meta_data->>'apellidos', ''),
        new.email
    )
    on conflict (id) do nothing;

    return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.crear_perfil_nuevo_usuario();

-- ============================================================
-- 14. INSCRIBIRSE AL EVENTO
-- Centraliza la lógica para que ningún módulo invente su propia regla.
-- ============================================================

create or replace function public.inscribirse_evento(p_evento_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_usuario uuid := auth.uid();
    v_evento public.eventos%rowtype;
    v_estado text;
    v_estado_pago text;
begin
    if v_usuario is null then
        raise exception 'Debes iniciar sesión.';
    end if;

    select *
    into v_evento
    from public.eventos
    where id = p_evento_id;

    if not found then
        raise exception 'El evento no existe.';
    end if;

    if v_evento.estado <> 'publicado' then
        raise exception 'El evento no está disponible para inscripción.';
    end if;

    if v_evento.requiere_pago then
        v_estado := 'pendiente';
        v_estado_pago := 'pendiente';
    else
        v_estado := 'inscrito';
        v_estado_pago := 'no_requiere';
    end if;

    insert into public.inscripciones_evento (
        evento_id,
        usuario_id,
        estado,
        estado_pago
    )
    values (
        p_evento_id,
        v_usuario,
        v_estado,
        v_estado_pago
    )
    on conflict (evento_id, usuario_id)
    do update
    set
        estado = case
            when public.inscripciones_evento.estado = 'cancelado'
                then excluded.estado
            else public.inscripciones_evento.estado
        end,
        estado_pago = case
            when public.inscripciones_evento.estado = 'cancelado'
                then excluded.estado_pago
            else public.inscripciones_evento.estado_pago
        end,
        actualizado_en = now();

    return jsonb_build_object(
        'ok', true,
        'estado', v_estado,
        'estado_pago', v_estado_pago
    );
end;
$$;

-- ============================================================
-- 15. INSCRIPCIÓN INDIVIDUAL A ACTIVIDAD
-- ============================================================

create or replace function public.inscribirse_actividad(p_actividad_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_usuario uuid := auth.uid();
    v_actividad public.actividades%rowtype;
    v_total integer;
begin
    if v_usuario is null then
        raise exception 'Debes iniciar sesión.';
    end if;

    select *
    into v_actividad
    from public.actividades
    where id = p_actividad_id
    for update;

    if not found then
        raise exception 'La actividad no existe.';
    end if;

    if v_actividad.estado <> 'publicado' then
        raise exception 'La actividad no está disponible.';
    end if;

    if v_actividad.modalidad_inscripcion not in ('individual', 'ambos') then
        raise exception 'Esta actividad solo permite inscripción por equipo.';
    end if;

    if not exists (
        select 1
        from public.inscripciones_evento
        where evento_id = v_actividad.evento_id
          and usuario_id = v_usuario
          and estado = 'inscrito'
    ) then
        raise exception 'Debes estar inscrito correctamente al evento.';
    end if;

    if v_actividad.capacidad is not null then
        select count(*)
        into v_total
        from public.inscripciones_actividad
        where actividad_id = p_actividad_id
          and usuario_id is not null
          and estado = 'inscrito';

        if v_total >= v_actividad.capacidad then
            raise exception 'No quedan cupos disponibles.';
        end if;
    end if;

    insert into public.inscripciones_actividad (
        actividad_id,
        usuario_id,
        estado
    )
    values (
        p_actividad_id,
        v_usuario,
        'inscrito'
    )
    on conflict (actividad_id, usuario_id)
    where usuario_id is not null
    do update
    set estado = 'inscrito',
        actualizado_en = now();

    return jsonb_build_object(
        'ok', true,
        'mensaje', 'Inscripción realizada correctamente.'
    );
end;
$$;

-- ============================================================
-- 16. CREAR EQUIPO
-- El creador pasa automáticamente a ser líder y miembro.
-- ============================================================

create or replace function public.crear_equipo(
    p_actividad_id uuid,
    p_nombre text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_usuario uuid := auth.uid();
    v_actividad public.actividades%rowtype;
    v_equipo_id uuid;
    v_codigo uuid;
begin
    if v_usuario is null then
        raise exception 'Debes iniciar sesión.';
    end if;

    if nullif(trim(p_nombre), '') is null then
        raise exception 'Debes indicar un nombre para el equipo.';
    end if;

    select *
    into v_actividad
    from public.actividades
    where id = p_actividad_id;

    if not found then
        raise exception 'La actividad no existe.';
    end if;

    if v_actividad.estado <> 'publicado' then
        raise exception 'La actividad no está disponible.';
    end if;

    if v_actividad.modalidad_inscripcion not in ('equipo', 'ambos') then
        raise exception 'Esta actividad no permite inscripción por equipo.';
    end if;

    if not exists (
        select 1
        from public.inscripciones_evento
        where evento_id = v_actividad.evento_id
          and usuario_id = v_usuario
          and estado = 'inscrito'
    ) then
        raise exception 'Debes estar inscrito correctamente al evento.';
    end if;

    if exists (
        select 1
        from public.miembros_equipo me
        join public.equipos e on e.id = me.equipo_id
        where me.usuario_id = v_usuario
          and e.actividad_id = p_actividad_id
          and e.estado <> 'cancelado'
    ) then
        raise exception 'Ya perteneces a un equipo de esta actividad.';
    end if;

    insert into public.equipos (
        actividad_id,
        nombre,
        lider_usuario_id
    )
    values (
        p_actividad_id,
        trim(p_nombre),
        v_usuario
    )
    returning id, codigo_invitacion
    into v_equipo_id, v_codigo;

    insert into public.miembros_equipo (
        equipo_id,
        usuario_id,
        rol_equipo
    )
    values (
        v_equipo_id,
        v_usuario,
        'lider'
    );

    return jsonb_build_object(
        'ok', true,
        'equipo_id', v_equipo_id,
        'codigo_invitacion', v_codigo
    );
end;
$$;

-- ============================================================
-- 17. UNIRSE A UN EQUIPO MEDIANTE CÓDIGO
-- ============================================================

create or replace function public.unirse_equipo(p_codigo_invitacion uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_usuario uuid := auth.uid();
    v_equipo public.equipos%rowtype;
    v_actividad public.actividades%rowtype;
    v_total integer;
begin
    if v_usuario is null then
        raise exception 'Debes iniciar sesión.';
    end if;

    select *
    into v_equipo
    from public.equipos
    where codigo_invitacion = p_codigo_invitacion
      and estado <> 'cancelado';

    if not found then
        raise exception 'El código del equipo no es válido.';
    end if;

    select *
    into v_actividad
    from public.actividades
    where id = v_equipo.actividad_id;

    if not exists (
        select 1
        from public.inscripciones_evento
        where evento_id = v_actividad.evento_id
          and usuario_id = v_usuario
          and estado = 'inscrito'
    ) then
        raise exception 'Debes estar inscrito correctamente al evento.';
    end if;

    if exists (
        select 1
        from public.miembros_equipo me
        join public.equipos e on e.id = me.equipo_id
        where me.usuario_id = v_usuario
          and e.actividad_id = v_equipo.actividad_id
          and e.estado <> 'cancelado'
    ) then
        raise exception 'Ya perteneces a un equipo de esta actividad.';
    end if;

    select count(*)
    into v_total
    from public.miembros_equipo
    where equipo_id = v_equipo.id;

    if v_actividad.maximo_integrantes_equipo is not null
       and v_total >= v_actividad.maximo_integrantes_equipo then
        raise exception 'El equipo ya alcanzó el número máximo de integrantes.';
    end if;

    insert into public.miembros_equipo (
        equipo_id,
        usuario_id,
        rol_equipo
    )
    values (
        v_equipo.id,
        v_usuario,
        'miembro'
    );

    return jsonb_build_object(
        'ok', true,
        'equipo_id', v_equipo.id,
        'mensaje', 'Te uniste al equipo correctamente.'
    );
end;
$$;

-- ============================================================
-- 18. INSCRIBIR EQUIPO A LA ACTIVIDAD
-- Solo el líder puede hacerlo.
-- ============================================================

create or replace function public.inscribir_equipo_actividad(p_equipo_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_usuario uuid := auth.uid();
    v_equipo public.equipos%rowtype;
    v_actividad public.actividades%rowtype;
    v_integrantes integer;
    v_equipos_inscritos integer;
begin
    if v_usuario is null then
        raise exception 'Debes iniciar sesión.';
    end if;

    select *
    into v_equipo
    from public.equipos
    where id = p_equipo_id
      and estado <> 'cancelado';

    if not found then
        raise exception 'El equipo no existe.';
    end if;

    if v_equipo.lider_usuario_id <> v_usuario then
        raise exception 'Solo el líder puede inscribir al equipo.';
    end if;

    select *
    into v_actividad
    from public.actividades
    where id = v_equipo.actividad_id
    for update;

    if v_actividad.estado <> 'publicado' then
        raise exception 'La actividad no está disponible.';
    end if;

    select count(*)
    into v_integrantes
    from public.miembros_equipo
    where equipo_id = p_equipo_id;

    if v_actividad.minimo_integrantes_equipo is not null
       and v_integrantes < v_actividad.minimo_integrantes_equipo then
        raise exception 'El equipo todavía no tiene el mínimo de integrantes.';
    end if;

    if v_actividad.maximo_integrantes_equipo is not null
       and v_integrantes > v_actividad.maximo_integrantes_equipo then
        raise exception 'El equipo supera el máximo de integrantes.';
    end if;

    if v_actividad.capacidad is not null then
        select count(*)
        into v_equipos_inscritos
        from public.inscripciones_actividad
        where actividad_id = v_equipo.actividad_id
          and equipo_id is not null
          and estado = 'inscrito';

        if v_equipos_inscritos >= v_actividad.capacidad then
            raise exception 'No quedan cupos para más equipos.';
        end if;
    end if;

    insert into public.inscripciones_actividad (
        actividad_id,
        equipo_id,
        estado
    )
    values (
        v_equipo.actividad_id,
        p_equipo_id,
        'inscrito'
    )
    on conflict (actividad_id, equipo_id)
    where equipo_id is not null
    do update
    set estado = 'inscrito',
        actualizado_en = now();

    update public.equipos
    set estado = 'listo'
    where id = p_equipo_id;

    return jsonb_build_object(
        'ok', true,
        'mensaje', 'Equipo inscrito correctamente.'
    );
end;
$$;

-- ============================================================
-- 19. OBTENER O CREAR QR
-- Solo se habilita si la inscripción al evento está correcta.
-- ============================================================

create or replace function public.obtener_o_crear_qr(p_evento_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
    v_usuario uuid := auth.uid();
    v_token uuid;
begin
    if v_usuario is null then
        raise exception 'Debes iniciar sesión.';
    end if;

    if not exists (
        select 1
        from public.inscripciones_evento
        where evento_id = p_evento_id
          and usuario_id = v_usuario
          and estado = 'inscrito'
    ) then
        raise exception 'Tu inscripción al evento todavía no está habilitada.';
    end if;

    select token
    into v_token
    from public.credenciales_qr
    where evento_id = p_evento_id
      and usuario_id = v_usuario
      and activo = true;

    if v_token is null then
        insert into public.credenciales_qr (
            evento_id,
            usuario_id
        )
        values (
            p_evento_id,
            v_usuario
        )
        returning token into v_token;
    end if;

    return v_token;
end;
$$;

-- ============================================================
-- 20. VERIFICACIÓN PÚBLICA DE CERTIFICADO
-- Devuelve solo información necesaria.
-- ============================================================

create or replace function public.verificar_certificado(p_codigo text)
returns table (
    valido boolean,
    codigo text,
    participante text,
    evento text,
    actividad text,
    emitido_en timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
    select
        (c.estado = 'emitido') as valido,
        c.codigo,
        trim(p.nombres || ' ' || p.apellidos) as participante,
        e.nombre as evento,
        a.titulo as actividad,
        c.emitido_en
    from public.certificados c
    join public.perfiles p on p.id = c.usuario_id
    join public.eventos e on e.id = c.evento_id
    left join public.actividades a on a.id = c.actividad_id
    where c.codigo = p_codigo
    limit 1;
$$;
