-- ============================================================
-- BASE DE DATOS V3 - FUNCIONES
-- Archivo: funciones.sql
-- Ejecutar DESPUÉS de esquema.sql
-- ============================================================

-- ============================================================
-- 1. HELPERS PRIVADOS
-- ============================================================

create or replace function private.usuario_tiene_rol(p_roles text[])
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
    select exists (
        select 1
        from public.perfiles p
        where p.id = (select auth.uid())
          and p.rol = any(p_roles)
          and p.activo = true
    );
$$;

create or replace function private.usuario_esta_activo()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
    select exists (
        select 1
        from public.perfiles p
        where p.id = (select auth.uid())
          and p.activo = true
    );
$$;

create or replace function private.usuario_pertenece_equipo(p_equipo_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
    select exists (
        select 1
        from public.miembros_equipo me
        where me.equipo_id = p_equipo_id
          and me.usuario_id = (select auth.uid())
    );
$$;

-- ============================================================
-- 2. PROTEGER CAMPOS SENSIBLES DEL PERFIL
-- El correo se cambia en Auth; rol/activo solo por administrador.
-- ============================================================

create or replace function private.proteger_campos_perfil()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_uid uuid := auth.uid();
begin
    -- Una petición autenticada no modifica directamente la copia del correo.
    -- El correo se sincroniza desde auth.users.
    if v_uid is not null and new.correo is distinct from old.correo then
        new.correo := old.correo;
    end if;

    if v_uid = old.id
       and not private.usuario_tiene_rol(array['admin']::text[]) then
        new.rol := old.rol;
        new.activo := old.activo;
    end if;

    return new;
end;
$$;

create trigger trg_proteger_campos_perfil
before update on public.perfiles
for each row execute function private.proteger_campos_perfil();

-- ============================================================
-- 3. INSCRIPCIÓN GENERAL AL EVENTO - IMPLEMENTACIÓN PRIVADA
-- ============================================================

create or replace function private.inscribirse_evento_impl(p_evento_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_usuario uuid := auth.uid();
    v_evento public.eventos%rowtype;
    v_estado_inicial text;
    v_pago_inicial text;
    v_estado_real text;
    v_pago_real text;
begin
    if v_usuario is null then
        raise exception 'Debes iniciar sesión.';
    end if;

    if not private.usuario_esta_activo() then
        raise exception 'Tu cuenta está desactivada.';
    end if;

    select e.*
    into v_evento
    from public.eventos e
    where e.id = p_evento_id;

    if not found then
        raise exception 'El evento no existe.';
    end if;

    if v_evento.estado <> 'publicado' then
        raise exception 'El evento no está publicado.';
    end if;

    if not v_evento.inscripciones_abiertas then
        raise exception 'Las inscripciones al evento están cerradas.';
    end if;

    if v_evento.inscripcion_inicio is not null
       and now() < v_evento.inscripcion_inicio then
        raise exception 'Las inscripciones todavía no han iniciado.';
    end if;

    if v_evento.inscripcion_fin is not null
       and now() > v_evento.inscripcion_fin then
        raise exception 'El periodo de inscripción ya terminó.';
    end if;

    if v_evento.requiere_pago then
        v_estado_inicial := 'pendiente';
        v_pago_inicial := 'pendiente';
    else
        v_estado_inicial := 'inscrito';
        v_pago_inicial := 'no_requiere';
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
        v_estado_inicial,
        v_pago_inicial
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
        referencia_pago = case
            when public.inscripciones_evento.estado = 'cancelado'
                then null
            else public.inscripciones_evento.referencia_pago
        end,
        pago_verificado_por = case
            when public.inscripciones_evento.estado = 'cancelado'
                then null
            else public.inscripciones_evento.pago_verificado_por
        end,
        pago_verificado_en = case
            when public.inscripciones_evento.estado = 'cancelado'
                then null
            else public.inscripciones_evento.pago_verificado_en
        end,
        actualizado_en = now()
    returning estado, estado_pago
    into v_estado_real, v_pago_real;

    return jsonb_build_object(
        'ok', true,
        'estado', v_estado_real,
        'estado_pago', v_pago_real
    );
end;
$$;

create or replace function public.inscribirse_evento(p_evento_id uuid)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
    select private.inscribirse_evento_impl(p_evento_id);
$$;

-- ============================================================
-- 4. VERIFICAR PAGO EXTERNO - ADMIN
-- ============================================================

create or replace function private.verificar_pago_evento_impl(
    p_inscripcion_id uuid,
    p_aprobado boolean,
    p_referencia text default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_admin uuid := auth.uid();
    v_requiere_pago boolean;
begin
    if v_admin is null
       or not private.usuario_tiene_rol(array['admin']::text[]) then
        raise exception 'No tienes permiso para verificar pagos.';
    end if;

    select e.requiere_pago
    into v_requiere_pago
    from public.inscripciones_evento ie
    join public.eventos e on e.id = ie.evento_id
    where ie.id = p_inscripcion_id;

    if not found then
        raise exception 'La inscripción no existe.';
    end if;

    if not v_requiere_pago then
        raise exception 'Este evento no requiere pago.';
    end if;

    update public.inscripciones_evento
    set
        estado_pago = case when p_aprobado then 'verificado' else 'rechazado' end,
        estado = case when p_aprobado then 'inscrito' else 'pendiente' end,
        referencia_pago = coalesce(nullif(trim(p_referencia), ''), referencia_pago),
        pago_verificado_por = v_admin,
        pago_verificado_en = now(),
        actualizado_en = now()
    where id = p_inscripcion_id;

    return jsonb_build_object(
        'ok', true,
        'aprobado', p_aprobado
    );
end;
$$;

create or replace function public.verificar_pago_evento(
    p_inscripcion_id uuid,
    p_aprobado boolean,
    p_referencia text default null
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
    select private.verificar_pago_evento_impl(
        p_inscripcion_id,
        p_aprobado,
        p_referencia
    );
$$;

-- ============================================================
-- 5. INSCRIPCIÓN INDIVIDUAL A ACTIVIDAD
-- ============================================================

create or replace function private.inscribirse_actividad_impl(p_actividad_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_usuario uuid := auth.uid();
    v_actividad public.actividades%rowtype;
    v_total integer;
begin
    if v_usuario is null then
        raise exception 'Debes iniciar sesión.';
    end if;

    if not private.usuario_esta_activo() then
        raise exception 'Tu cuenta está desactivada.';
    end if;

    select a.*
    into v_actividad
    from public.actividades a
    where a.id = p_actividad_id
    for update;

    if not found then
        raise exception 'La actividad no existe.';
    end if;

    if v_actividad.estado <> 'publicado' then
        raise exception 'La actividad no está publicada.';
    end if;

    if not v_actividad.requiere_inscripcion then
        raise exception 'Esta actividad no requiere inscripción.';
    end if;

    if not v_actividad.inscripciones_abiertas then
        raise exception 'Las inscripciones de esta actividad están cerradas.';
    end if;

    if v_actividad.inscripcion_inicio is not null
       and now() < v_actividad.inscripcion_inicio then
        raise exception 'Las inscripciones todavía no han iniciado.';
    end if;

    if v_actividad.inscripcion_fin is not null
       and now() > v_actividad.inscripcion_fin then
        raise exception 'El periodo de inscripción ya terminó.';
    end if;

    if v_actividad.modalidad_inscripcion not in ('individual', 'ambos') then
        raise exception 'Esta actividad solo admite equipos.';
    end if;

    if not exists (
        select 1
        from public.inscripciones_evento ie
        where ie.evento_id = v_actividad.evento_id
          and ie.usuario_id = v_usuario
          and ie.estado = 'inscrito'
    ) then
        raise exception 'Debes estar inscrito correctamente al evento.';
    end if;

    -- En modalidad "ambos" no permitimos estar como individuo y equipo a la vez.
    if exists (
        select 1
        from public.miembros_equipo me
        join public.equipos eq on eq.id = me.equipo_id
        where me.actividad_id = p_actividad_id
          and me.usuario_id = v_usuario
          and eq.estado <> 'cancelado'
    ) then
        raise exception 'Ya perteneces a un equipo de esta actividad.';
    end if;

    if v_actividad.capacidad is not null then
        select count(*)
        into v_total
        from public.inscripciones_actividad ia
        where ia.actividad_id = p_actividad_id
          and ia.estado = 'inscrito';

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
    set
        estado = 'inscrito',
        actualizado_en = now();

    return jsonb_build_object(
        'ok', true,
        'mensaje', 'Inscripción realizada correctamente.'
    );
end;
$$;

create or replace function public.inscribirse_actividad(p_actividad_id uuid)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
    select private.inscribirse_actividad_impl(p_actividad_id);
$$;

-- ============================================================
-- 6. CREAR EQUIPO
-- ============================================================

create or replace function private.crear_equipo_impl(
    p_actividad_id uuid,
    p_nombre text
)
returns jsonb
language plpgsql
security definer
set search_path = ''
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

    if not private.usuario_esta_activo() then
        raise exception 'Tu cuenta está desactivada.';
    end if;

    if nullif(trim(p_nombre), '') is null then
        raise exception 'Debes indicar un nombre para el equipo.';
    end if;

    select a.*
    into v_actividad
    from public.actividades a
    where a.id = p_actividad_id;

    if not found then
        raise exception 'La actividad no existe.';
    end if;

    if v_actividad.estado <> 'publicado'
       or not v_actividad.requiere_inscripcion
       or not v_actividad.inscripciones_abiertas then
        raise exception 'La actividad no admite nuevas inscripciones.';
    end if;

    if v_actividad.inscripcion_inicio is not null
       and now() < v_actividad.inscripcion_inicio then
        raise exception 'Las inscripciones todavía no han iniciado.';
    end if;

    if v_actividad.inscripcion_fin is not null
       and now() > v_actividad.inscripcion_fin then
        raise exception 'El periodo de inscripción ya terminó.';
    end if;

    if v_actividad.modalidad_inscripcion not in ('equipo', 'ambos') then
        raise exception 'Esta actividad no permite inscripción por equipos.';
    end if;

    if not exists (
        select 1
        from public.inscripciones_evento ie
        where ie.evento_id = v_actividad.evento_id
          and ie.usuario_id = v_usuario
          and ie.estado = 'inscrito'
    ) then
        raise exception 'Debes estar inscrito correctamente al evento.';
    end if;

    if exists (
        select 1
        from public.inscripciones_actividad ia
        where ia.actividad_id = p_actividad_id
          and ia.usuario_id = v_usuario
          and ia.estado <> 'cancelado'
    ) then
        raise exception 'Ya tienes una inscripción individual en esta actividad.';
    end if;

    -- La restricción UNIQUE (actividad_id, usuario_id) en miembros_equipo
    -- también protege contra carreras/concurrencia.
    if exists (
        select 1
        from public.miembros_equipo me
        where me.actividad_id = p_actividad_id
          and me.usuario_id = v_usuario
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
        actividad_id,
        usuario_id,
        rol_equipo
    )
    values (
        v_equipo_id,
        p_actividad_id,
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

create or replace function public.crear_equipo(
    p_actividad_id uuid,
    p_nombre text
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
    select private.crear_equipo_impl(p_actividad_id, p_nombre);
$$;

-- ============================================================
-- 7. UNIRSE A EQUIPO
-- El bloqueo FOR UPDATE evita superar el máximo por concurrencia.
-- ============================================================

create or replace function private.unirse_equipo_impl(p_codigo_invitacion uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
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

    if not private.usuario_esta_activo() then
        raise exception 'Tu cuenta está desactivada.';
    end if;

    select eq.*
    into v_equipo
    from public.equipos eq
    where eq.codigo_invitacion = p_codigo_invitacion
    for update;

    if not found then
        raise exception 'El código del equipo no es válido.';
    end if;

    if v_equipo.estado <> 'formando' then
        raise exception 'El equipo ya no acepta nuevos integrantes.';
    end if;

    select a.*
    into v_actividad
    from public.actividades a
    where a.id = v_equipo.actividad_id;

    if not found
       or v_actividad.estado <> 'publicado'
       or not v_actividad.inscripciones_abiertas then
        raise exception 'La actividad no admite nuevas inscripciones.';
    end if;

    if v_actividad.inscripcion_inicio is not null
       and now() < v_actividad.inscripcion_inicio then
        raise exception 'Las inscripciones todavía no han iniciado.';
    end if;

    if v_actividad.inscripcion_fin is not null
       and now() > v_actividad.inscripcion_fin then
        raise exception 'El periodo de inscripción ya terminó.';
    end if;

    if not exists (
        select 1
        from public.inscripciones_evento ie
        where ie.evento_id = v_actividad.evento_id
          and ie.usuario_id = v_usuario
          and ie.estado = 'inscrito'
    ) then
        raise exception 'Debes estar inscrito correctamente al evento.';
    end if;

    if exists (
        select 1
        from public.inscripciones_actividad ia
        where ia.actividad_id = v_actividad.id
          and ia.usuario_id = v_usuario
          and ia.estado <> 'cancelado'
    ) then
        raise exception 'Ya tienes una inscripción individual en esta actividad.';
    end if;

    if exists (
        select 1
        from public.miembros_equipo me
        where me.actividad_id = v_actividad.id
          and me.usuario_id = v_usuario
    ) then
        raise exception 'Ya perteneces a un equipo de esta actividad.';
    end if;

    select count(*)
    into v_total
    from public.miembros_equipo me
    where me.equipo_id = v_equipo.id;

    if v_total >= v_actividad.maximo_integrantes_equipo then
        raise exception 'El equipo ya alcanzó el máximo de integrantes.';
    end if;

    insert into public.miembros_equipo (
        equipo_id,
        actividad_id,
        usuario_id,
        rol_equipo
    )
    values (
        v_equipo.id,
        v_actividad.id,
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

create or replace function public.unirse_equipo(p_codigo_invitacion uuid)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
    select private.unirse_equipo_impl(p_codigo_invitacion);
$$;

-- ============================================================
-- 8. INSCRIBIR EQUIPO A ACTIVIDAD
-- ============================================================

create or replace function private.inscribir_equipo_actividad_impl(p_equipo_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_usuario uuid := auth.uid();
    v_equipo public.equipos%rowtype;
    v_actividad public.actividades%rowtype;
    v_integrantes integer;
    v_total_inscripciones integer;
begin
    if v_usuario is null then
        raise exception 'Debes iniciar sesión.';
    end if;

    if not private.usuario_esta_activo() then
        raise exception 'Tu cuenta está desactivada.';
    end if;

    select eq.*
    into v_equipo
    from public.equipos eq
    where eq.id = p_equipo_id
    for update;

    if not found then
        raise exception 'El equipo no existe.';
    end if;

    if v_equipo.lider_usuario_id <> v_usuario then
        raise exception 'Solo el líder puede inscribir al equipo.';
    end if;

    if v_equipo.estado = 'cancelado' then
        raise exception 'El equipo está cancelado.';
    end if;

    if v_equipo.estado = 'inscrito' then
        return jsonb_build_object(
            'ok', true,
            'mensaje', 'El equipo ya estaba inscrito.'
        );
    end if;

    select a.*
    into v_actividad
    from public.actividades a
    where a.id = v_equipo.actividad_id
    for update;

    if not found
       or v_actividad.estado <> 'publicado'
       or not v_actividad.inscripciones_abiertas then
        raise exception 'La actividad no admite nuevas inscripciones.';
    end if;

    if v_actividad.modalidad_inscripcion not in ('equipo', 'ambos') then
        raise exception 'La actividad no admite inscripción por equipo.';
    end if;

    if v_actividad.inscripcion_inicio is not null
       and now() < v_actividad.inscripcion_inicio then
        raise exception 'Las inscripciones todavía no han iniciado.';
    end if;

    if v_actividad.inscripcion_fin is not null
       and now() > v_actividad.inscripcion_fin then
        raise exception 'El periodo de inscripción ya terminó.';
    end if;

    select count(*)
    into v_integrantes
    from public.miembros_equipo me
    where me.equipo_id = p_equipo_id;

    if v_integrantes < v_actividad.minimo_integrantes_equipo then
        raise exception 'El equipo todavía no cumple el mínimo de integrantes.';
    end if;

    if v_integrantes > v_actividad.maximo_integrantes_equipo then
        raise exception 'El equipo supera el máximo de integrantes.';
    end if;

    -- Todos los integrantes deben seguir inscritos correctamente al evento.
    if exists (
        select 1
        from public.miembros_equipo me
        where me.equipo_id = p_equipo_id
          and not exists (
              select 1
              from public.inscripciones_evento ie
              where ie.evento_id = v_actividad.evento_id
                and ie.usuario_id = me.usuario_id
                and ie.estado = 'inscrito'
          )
    ) then
        raise exception 'Uno o más integrantes no tienen una inscripción válida al evento.';
    end if;

    -- Ningún integrante puede estar simultáneamente inscrito como individuo.
    if exists (
        select 1
        from public.miembros_equipo me
        join public.inscripciones_actividad ia
          on ia.actividad_id = v_actividad.id
         and ia.usuario_id = me.usuario_id
        where me.equipo_id = p_equipo_id
          and ia.estado <> 'cancelado'
    ) then
        raise exception 'Un integrante ya está inscrito individualmente en esta actividad.';
    end if;

    if v_actividad.capacidad is not null then
        select count(*)
        into v_total_inscripciones
        from public.inscripciones_actividad ia
        where ia.actividad_id = v_actividad.id
          and ia.estado = 'inscrito';

        if v_total_inscripciones >= v_actividad.capacidad then
            raise exception 'No quedan cupos disponibles.';
        end if;
    end if;

    insert into public.inscripciones_actividad (
        actividad_id,
        equipo_id,
        estado
    )
    values (
        v_actividad.id,
        p_equipo_id,
        'inscrito'
    )
    on conflict (actividad_id, equipo_id)
    where equipo_id is not null
    do update
    set
        estado = 'inscrito',
        actualizado_en = now();

    update public.equipos
    set estado = 'inscrito'
    where id = p_equipo_id;

    return jsonb_build_object(
        'ok', true,
        'mensaje', 'Equipo inscrito correctamente.'
    );
end;
$$;

create or replace function public.inscribir_equipo_actividad(p_equipo_id uuid)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
    select private.inscribir_equipo_actividad_impl(p_equipo_id);
$$;

-- ============================================================
-- 9. OBTENER O CREAR QR
-- Corrige el problema de un QR previamente desactivado:
-- se reactiva y rota el token en vez de intentar insertar un duplicado.
-- ============================================================

create or replace function private.obtener_o_crear_qr_impl(p_evento_id uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_usuario uuid := auth.uid();
    v_token uuid;
begin
    if v_usuario is null then
        raise exception 'Debes iniciar sesión.';
    end if;

    if not private.usuario_esta_activo() then
        raise exception 'Tu cuenta está desactivada.';
    end if;

    if not exists (
        select 1
        from public.inscripciones_evento ie
        join public.eventos e on e.id = ie.evento_id
        where ie.evento_id = p_evento_id
          and ie.usuario_id = v_usuario
          and ie.estado = 'inscrito'
          and e.estado = 'publicado'
    ) then
        raise exception 'Tu inscripción al evento todavía no está habilitada.';
    end if;

    insert into public.credenciales_qr (
        evento_id,
        usuario_id,
        token,
        activo
    )
    values (
        p_evento_id,
        v_usuario,
        gen_random_uuid(),
        true
    )
    on conflict (evento_id, usuario_id)
    do update
    set
        token = case
            when public.credenciales_qr.activo
                then public.credenciales_qr.token
            else gen_random_uuid()
        end,
        activo = true,
        actualizado_en = now()
    returning token into v_token;

    return v_token;
end;
$$;

create or replace function public.obtener_o_crear_qr(p_evento_id uuid)
returns uuid
language sql
security invoker
set search_path = ''
as $$
    select private.obtener_o_crear_qr_impl(p_evento_id);
$$;

-- Permite invalidar una captura antigua del QR y generar otro token.
create or replace function private.regenerar_qr_impl(p_evento_id uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_usuario uuid := auth.uid();
    v_token uuid;
begin
    if v_usuario is null then
        raise exception 'Debes iniciar sesión.';
    end if;

    if not private.usuario_esta_activo() then
        raise exception 'Tu cuenta está desactivada.';
    end if;

    if not exists (
        select 1
        from public.inscripciones_evento ie
        join public.eventos e on e.id = ie.evento_id
        where ie.evento_id = p_evento_id
          and ie.usuario_id = v_usuario
          and ie.estado = 'inscrito'
          and e.estado = 'publicado'
    ) then
        raise exception 'Tu inscripción al evento no está habilitada.';
    end if;

    insert into public.credenciales_qr (
        evento_id,
        usuario_id,
        token,
        activo
    )
    values (
        p_evento_id,
        v_usuario,
        gen_random_uuid(),
        true
    )
    on conflict (evento_id, usuario_id)
    do update
    set
        token = gen_random_uuid(),
        activo = true,
        actualizado_en = now()
    returning token into v_token;

    return v_token;
end;
$$;

create or replace function public.regenerar_qr(p_evento_id uuid)
returns uuid
language sql
security invoker
set search_path = ''
as $$
    select private.regenerar_qr_impl(p_evento_id);
$$;

-- ============================================================
-- 10. REGISTRAR ESCANEO QR
-- Primer escaneo: entrada.
-- Segundo escaneo: salida.
-- Un escaneo repetido en menos de 30 s se considera duplicado.
-- ============================================================

create or replace function private.registrar_escaneo_qr_impl(
    p_token uuid,
    p_actividad_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_operador uuid := auth.uid();
    v_usuario uuid;
    v_evento_qr uuid;
    v_actividad public.actividades%rowtype;
    v_asistencia public.asistencias%rowtype;
    v_participante text;
    v_tiene_inscripcion boolean;
    v_momento timestamptz := now();
begin
    if v_operador is null then
        raise exception 'Debes iniciar sesión.';
    end if;

    if not private.usuario_tiene_rol(array['admin', 'control']::text[]) then
        raise exception 'No tienes permiso para registrar asistencia.';
    end if;

    select q.usuario_id, q.evento_id
    into v_usuario, v_evento_qr
    from public.credenciales_qr q
    where q.token = p_token
      and q.activo = true;

    if v_usuario is null then
        raise exception 'QR inválido o desactivado.';
    end if;

    select a.*
    into v_actividad
    from public.actividades a
    where a.id = p_actividad_id;

    if not found then
        raise exception 'La actividad no existe.';
    end if;

    if v_actividad.estado <> 'publicado' then
        raise exception 'La actividad no está habilitada para registrar asistencia.';
    end if;

    if v_actividad.evento_id <> v_evento_qr then
        raise exception 'El QR no corresponde al evento de esta actividad.';
    end if;

    if not exists (
        select 1
        from public.perfiles p
        where p.id = v_usuario
          and p.activo = true
    ) then
        raise exception 'La cuenta del participante está desactivada.';
    end if;

    if not exists (
        select 1
        from public.eventos e
        where e.id = v_actividad.evento_id
          and e.estado = 'publicado'
    ) then
        raise exception 'El evento no está habilitado para registrar asistencia.';
    end if;

    if not exists (
        select 1
        from public.inscripciones_evento ie
        where ie.evento_id = v_actividad.evento_id
          and ie.usuario_id = v_usuario
          and ie.estado = 'inscrito'
    ) then
        raise exception 'El participante no tiene una inscripción válida al evento.';
    end if;

    if v_actividad.requiere_inscripcion then
        select (
            exists (
                select 1
                from public.inscripciones_actividad ia
                where ia.actividad_id = p_actividad_id
                  and ia.usuario_id = v_usuario
                  and ia.estado = 'inscrito'
            )
            or
            exists (
                select 1
                from public.inscripciones_actividad ia
                join public.miembros_equipo me
                  on me.equipo_id = ia.equipo_id
                 and me.actividad_id = ia.actividad_id
                where ia.actividad_id = p_actividad_id
                  and me.usuario_id = v_usuario
                  and ia.estado = 'inscrito'
            )
        )
        into v_tiene_inscripcion;

        if not v_tiene_inscripcion then
            raise exception 'El participante no está inscrito en esta actividad.';
        end if;
    end if;

    select trim(p.nombres || ' ' || p.apellidos)
    into v_participante
    from public.perfiles p
    where p.id = v_usuario;

    -- Bloqueo solo para la combinación usuario+actividad.
    -- Evita carreras sin bloquear a todos los asistentes.
    perform pg_advisory_xact_lock(
        hashtext(p_actividad_id::text),
        hashtext(v_usuario::text)
    );

    select asi.*
    into v_asistencia
    from public.asistencias asi
    where asi.actividad_id = p_actividad_id
      and asi.usuario_id = v_usuario
    for update;

    if not found then
        insert into public.asistencias (
            actividad_id,
            usuario_id,
            entrada_en,
            entrada_registrada_por,
            estado
        )
        values (
            p_actividad_id,
            v_usuario,
            v_momento,
            v_operador,
            'registrada'
        );

        return jsonb_build_object(
            'ok', true,
            'accion', 'entrada',
            'participante', v_participante,
            'momento', v_momento
        );
    end if;

    if v_asistencia.entrada_en is not null
       and v_asistencia.salida_en is null then

        if v_momento - v_asistencia.entrada_en < interval '30 seconds' then
            raise exception 'Escaneo duplicado. Espera unos segundos antes de volver a escanear.';
        end if;

        update public.asistencias
        set
            salida_en = v_momento,
            salida_registrada_por = v_operador,
            actualizado_en = v_momento
        where id = v_asistencia.id;

        return jsonb_build_object(
            'ok', true,
            'accion', 'salida',
            'participante', v_participante,
            'momento', v_momento
        );
    end if;

    raise exception 'La entrada y salida ya fueron registradas para esta actividad.';
end;
$$;

create or replace function public.registrar_escaneo_qr(
    p_token uuid,
    p_actividad_id uuid
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
    select private.registrar_escaneo_qr_impl(p_token, p_actividad_id);
$$;

-- ============================================================
-- 11. EMISIÓN MANUAL CONTROLADA DE CERTIFICADO - ADMIN
-- La regla automática de elegibilidad se añadirá cuando la organización
-- confirme el porcentaje/horas/requisitos definitivos.
-- ============================================================

create or replace function private.emitir_certificado_manual_impl(
    p_evento_id uuid,
    p_usuario_id uuid,
    p_tipo text default 'participacion',
    p_actividad_id uuid default null,
    p_pdf_url text default null
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_admin uuid := auth.uid();
    v_nombre_participante text;
    v_nombre_evento text;
    v_nombre_actividad text;
    v_codigo text;
begin
    if v_admin is null
       or not private.usuario_tiene_rol(array['admin']::text[]) then
        raise exception 'No tienes permiso para emitir certificados.';
    end if;

    if nullif(trim(p_tipo), '') is null then
        raise exception 'El tipo de certificado es obligatorio.';
    end if;

    select trim(p.nombres || ' ' || p.apellidos)
    into v_nombre_participante
    from public.perfiles p
    where p.id = p_usuario_id;

    if not found then
        raise exception 'El participante no existe.';
    end if;

    select e.nombre
    into v_nombre_evento
    from public.eventos e
    where e.id = p_evento_id;

    if not found then
        raise exception 'El evento no existe.';
    end if;

    if p_actividad_id is not null then
        select a.titulo
        into v_nombre_actividad
        from public.actividades a
        where a.id = p_actividad_id
          and a.evento_id = p_evento_id;

        if not found then
            raise exception 'La actividad no pertenece al evento indicado.';
        end if;
    end if;

    if p_actividad_id is null then
        select c.codigo
        into v_codigo
        from public.certificados c
        where c.evento_id = p_evento_id
          and c.usuario_id = p_usuario_id
          and c.actividad_id is null
          and c.tipo = p_tipo
          and c.estado = 'emitido'
        limit 1;
    else
        select c.codigo
        into v_codigo
        from public.certificados c
        where c.actividad_id = p_actividad_id
          and c.usuario_id = p_usuario_id
          and c.tipo = p_tipo
          and c.estado = 'emitido'
        limit 1;
    end if;

    if v_codigo is not null then
        return jsonb_build_object(
            'ok', true,
            'codigo', v_codigo,
            'mensaje', 'El certificado ya estaba emitido.'
        );
    end if;

    insert into public.certificados (
        evento_id,
        actividad_id,
        usuario_id,
        tipo,
        nombre_participante,
        nombre_evento,
        nombre_actividad,
        pdf_url,
        emitido_por
    )
    values (
        p_evento_id,
        p_actividad_id,
        p_usuario_id,
        trim(p_tipo),
        v_nombre_participante,
        v_nombre_evento,
        v_nombre_actividad,
        p_pdf_url,
        v_admin
    )
    returning codigo into v_codigo;

    return jsonb_build_object(
        'ok', true,
        'codigo', v_codigo,
        'mensaje', 'Certificado emitido correctamente.'
    );
end;
$$;

create or replace function public.emitir_certificado_manual(
    p_evento_id uuid,
    p_usuario_id uuid,
    p_tipo text default 'participacion',
    p_actividad_id uuid default null,
    p_pdf_url text default null
)
returns jsonb
language sql
security invoker
set search_path = ''
as $$
    select private.emitir_certificado_manual_impl(
        p_evento_id,
        p_usuario_id,
        p_tipo,
        p_actividad_id,
        p_pdf_url
    );
$$;

-- ============================================================
-- 12. VERIFICACIÓN PÚBLICA DE CERTIFICADO
-- Usa snapshots históricos y no expone DNI, correo ni teléfono.
-- ============================================================

create or replace function private.verificar_certificado_impl(p_codigo text)
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
set search_path = ''
as $$
    select
        (c.estado = 'emitido') as valido,
        c.codigo,
        c.nombre_participante as participante,
        c.nombre_evento as evento,
        c.nombre_actividad as actividad,
        c.emitido_en
    from public.certificados c
    where c.codigo = upper(trim(p_codigo))
    limit 1;
$$;

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
security invoker
set search_path = ''
as $$
    select *
    from private.verificar_certificado_impl(p_codigo);
$$;
