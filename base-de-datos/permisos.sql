-- ============================================================
-- BASE DE DATOS V2
-- Archivo: permisos.sql
-- Ejecutar DESPUÉS de esquema.sql
-- ============================================================

-- ============================================================
-- 1. FUNCIONES AUXILIARES DE SEGURIDAD
-- ============================================================

create or replace function public.usuario_tiene_rol(p_roles text[])
returns boolean
language sql
stable
security definer
set search_path = public
as $$
    select exists (
        select 1
        from public.perfiles
        where id = auth.uid()
          and rol = any(p_roles)
          and activo = true
    );
$$;

create or replace function public.usuario_pertenece_equipo(p_equipo_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
    select exists (
        select 1
        from public.miembros_equipo
        where equipo_id = p_equipo_id
          and usuario_id = auth.uid()
    )
    or exists (
        select 1
        from public.equipos
        where id = p_equipo_id
          and lider_usuario_id = auth.uid()
    );
$$;

-- ============================================================
-- 2. ACTIVAR RLS EN TODAS LAS TABLAS
-- ============================================================

alter table public.perfiles enable row level security;
alter table public.eventos enable row level security;
alter table public.inscripciones_evento enable row level security;
alter table public.actividades enable row level security;
alter table public.ponentes enable row level security;
alter table public.actividad_ponentes enable row level security;
alter table public.equipos enable row level security;
alter table public.miembros_equipo enable row level security;
alter table public.inscripciones_actividad enable row level security;
alter table public.credenciales_qr enable row level security;
alter table public.asistencias enable row level security;
alter table public.certificados enable row level security;

-- ============================================================
-- 3. PERFILES
-- ============================================================

drop policy if exists perfiles_leer on public.perfiles;
create policy perfiles_leer
on public.perfiles
for select
to authenticated
using (
    id = auth.uid()
    or public.usuario_tiene_rol(array['admin'])
);

drop policy if exists perfiles_actualizar on public.perfiles;
create policy perfiles_actualizar
on public.perfiles
for update
to authenticated
using (
    id = auth.uid()
    or public.usuario_tiene_rol(array['admin'])
)
with check (
    id = auth.uid()
    or public.usuario_tiene_rol(array['admin'])
);

-- Impide que un participante cambie su propio rol o active/desactive su cuenta.
create or replace function public.proteger_campos_perfil()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    if auth.uid() = old.id
       and not public.usuario_tiene_rol(array['admin']) then
        new.rol = old.rol;
        new.activo = old.activo;
    end if;

    return new;
end;
$$;

drop trigger if exists trg_proteger_campos_perfil on public.perfiles;
create trigger trg_proteger_campos_perfil
before update on public.perfiles
for each row execute function public.proteger_campos_perfil();

-- ============================================================
-- 4. EVENTOS
-- ============================================================

drop policy if exists eventos_publicos on public.eventos;
create policy eventos_publicos
on public.eventos
for select
to anon, authenticated
using (
    estado = 'publicado'
    or public.usuario_tiene_rol(array['admin'])
);

drop policy if exists eventos_admin_todo on public.eventos;
create policy eventos_admin_todo
on public.eventos
for all
to authenticated
using (public.usuario_tiene_rol(array['admin']))
with check (public.usuario_tiene_rol(array['admin']));

-- ============================================================
-- 5. INSCRIPCIÓN GENERAL AL EVENTO
-- Participante lee la suya.
-- Crear inscripción se hace mediante inscribirse_evento().
-- ============================================================

drop policy if exists ins_evento_leer on public.inscripciones_evento;
create policy ins_evento_leer
on public.inscripciones_evento
for select
to authenticated
using (
    usuario_id = auth.uid()
    or public.usuario_tiene_rol(array['admin'])
);

drop policy if exists ins_evento_admin_todo on public.inscripciones_evento;
create policy ins_evento_admin_todo
on public.inscripciones_evento
for all
to authenticated
using (public.usuario_tiene_rol(array['admin']))
with check (public.usuario_tiene_rol(array['admin']));

-- ============================================================
-- 6. ACTIVIDADES
-- ============================================================

drop policy if exists actividades_publicas on public.actividades;
create policy actividades_publicas
on public.actividades
for select
to anon, authenticated
using (
    estado = 'publicado'
    or public.usuario_tiene_rol(array['admin'])
);

drop policy if exists actividades_admin_todo on public.actividades;
create policy actividades_admin_todo
on public.actividades
for all
to authenticated
using (public.usuario_tiene_rol(array['admin']))
with check (public.usuario_tiene_rol(array['admin']));

-- ============================================================
-- 7. PONENTES
-- ============================================================

drop policy if exists ponentes_publicos on public.ponentes;
create policy ponentes_publicos
on public.ponentes
for select
to anon, authenticated
using (true);

drop policy if exists ponentes_admin_todo on public.ponentes;
create policy ponentes_admin_todo
on public.ponentes
for all
to authenticated
using (public.usuario_tiene_rol(array['admin']))
with check (public.usuario_tiene_rol(array['admin']));

drop policy if exists actividad_ponentes_publico on public.actividad_ponentes;
create policy actividad_ponentes_publico
on public.actividad_ponentes
for select
to anon, authenticated
using (true);

drop policy if exists actividad_ponentes_admin_todo on public.actividad_ponentes;
create policy actividad_ponentes_admin_todo
on public.actividad_ponentes
for all
to authenticated
using (public.usuario_tiene_rol(array['admin']))
with check (public.usuario_tiene_rol(array['admin']));

-- ============================================================
-- 8. EQUIPOS
-- Los miembros ven su equipo.
-- Los cambios normales se hacen mediante las funciones seguras.
-- ============================================================

drop policy if exists equipos_leer on public.equipos;
create policy equipos_leer
on public.equipos
for select
to authenticated
using (
    public.usuario_pertenece_equipo(id)
    or public.usuario_tiene_rol(array['admin'])
);

drop policy if exists equipos_admin_todo on public.equipos;
create policy equipos_admin_todo
on public.equipos
for all
to authenticated
using (public.usuario_tiene_rol(array['admin']))
with check (public.usuario_tiene_rol(array['admin']));

drop policy if exists miembros_equipo_leer on public.miembros_equipo;
create policy miembros_equipo_leer
on public.miembros_equipo
for select
to authenticated
using (
    public.usuario_pertenece_equipo(equipo_id)
    or public.usuario_tiene_rol(array['admin'])
);

drop policy if exists miembros_equipo_admin_todo on public.miembros_equipo;
create policy miembros_equipo_admin_todo
on public.miembros_equipo
for all
to authenticated
using (public.usuario_tiene_rol(array['admin']))
with check (public.usuario_tiene_rol(array['admin']));

-- ============================================================
-- 9. INSCRIPCIONES A ACTIVIDADES
-- ============================================================

drop policy if exists ins_actividad_leer on public.inscripciones_actividad;
create policy ins_actividad_leer
on public.inscripciones_actividad
for select
to authenticated
using (
    usuario_id = auth.uid()
    or (
        equipo_id is not null
        and public.usuario_pertenece_equipo(equipo_id)
    )
    or public.usuario_tiene_rol(array['admin'])
);

drop policy if exists ins_actividad_admin_todo on public.inscripciones_actividad;
create policy ins_actividad_admin_todo
on public.inscripciones_actividad
for all
to authenticated
using (public.usuario_tiene_rol(array['admin']))
with check (public.usuario_tiene_rol(array['admin']));

-- ============================================================
-- 10. QR
-- El participante ve solo su QR.
-- Control no necesita leer la tabla directamente:
-- usará registrar_escaneo_qr().
-- ============================================================

drop policy if exists qr_leer on public.credenciales_qr;
create policy qr_leer
on public.credenciales_qr
for select
to authenticated
using (
    usuario_id = auth.uid()
    or public.usuario_tiene_rol(array['admin'])
);

drop policy if exists qr_admin_todo on public.credenciales_qr;
create policy qr_admin_todo
on public.credenciales_qr
for all
to authenticated
using (public.usuario_tiene_rol(array['admin']))
with check (public.usuario_tiene_rol(array['admin']));

-- ============================================================
-- 11. ASISTENCIA
-- Participante ve la suya.
-- Control/Admin registran asistencia mediante la función segura.
-- ============================================================

drop policy if exists asistencia_leer on public.asistencias;
create policy asistencia_leer
on public.asistencias
for select
to authenticated
using (
    usuario_id = auth.uid()
    or public.usuario_tiene_rol(array['admin'])
);

drop policy if exists asistencia_admin_todo on public.asistencias;
create policy asistencia_admin_todo
on public.asistencias
for all
to authenticated
using (public.usuario_tiene_rol(array['admin']))
with check (public.usuario_tiene_rol(array['admin']));

-- ============================================================
-- 12. CERTIFICADOS
-- ============================================================

drop policy if exists certificados_leer on public.certificados;
create policy certificados_leer
on public.certificados
for select
to authenticated
using (
    usuario_id = auth.uid()
    or public.usuario_tiene_rol(array['admin'])
);

drop policy if exists certificados_admin_todo on public.certificados;
create policy certificados_admin_todo
on public.certificados
for all
to authenticated
using (public.usuario_tiene_rol(array['admin']))
with check (public.usuario_tiene_rol(array['admin']));

-- ============================================================
-- 13. VERIFICAR PAGO MANUAL
-- Mantiene consistentes estado_pago y estado de inscripción.
-- Solo ADMIN.
-- ============================================================

create or replace function public.verificar_pago_evento(
    p_inscripcion_id uuid,
    p_aprobado boolean,
    p_referencia text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
    if not public.usuario_tiene_rol(array['admin']) then
        raise exception 'No tienes permiso para verificar pagos.';
    end if;

    if not exists (
        select 1
        from public.inscripciones_evento
        where id = p_inscripcion_id
    ) then
        raise exception 'La inscripción no existe.';
    end if;

    update public.inscripciones_evento
    set
        estado_pago = case when p_aprobado then 'verificado' else 'rechazado' end,
        estado = case when p_aprobado then 'inscrito' else 'pendiente' end,
        referencia_pago = coalesce(p_referencia, referencia_pago),
        actualizado_en = now()
    where id = p_inscripcion_id;

    return jsonb_build_object(
        'ok', true,
        'aprobado', p_aprobado
    );
end;
$$;

-- ============================================================
-- 14. REGISTRAR ESCANEO QR
-- Primer escaneo = entrada.
-- Segundo escaneo = salida.
-- Tercer escaneo = error para evitar registros accidentales.
-- ============================================================

create or replace function public.registrar_escaneo_qr(
    p_token uuid,
    p_actividad_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_operador uuid := auth.uid();
    v_usuario uuid;
    v_evento_qr uuid;
    v_actividad public.actividades%rowtype;
    v_asistencia public.asistencias%rowtype;
    v_participante text;
    v_requiere_inscripcion boolean;
    v_tiene_inscripcion boolean;
begin
    if v_operador is null then
        raise exception 'Debes iniciar sesión.';
    end if;

    if not public.usuario_tiene_rol(array['admin', 'control']) then
        raise exception 'No tienes permiso para registrar asistencia.';
    end if;

    select usuario_id, evento_id
    into v_usuario, v_evento_qr
    from public.credenciales_qr
    where token = p_token
      and activo = true;

    if v_usuario is null then
        raise exception 'QR inválido o desactivado.';
    end if;

    select *
    into v_actividad
    from public.actividades
    where id = p_actividad_id;

    if not found then
        raise exception 'La actividad no existe.';
    end if;

    if v_actividad.evento_id <> v_evento_qr then
        raise exception 'El QR no corresponde al evento de esta actividad.';
    end if;

    if not exists (
        select 1
        from public.inscripciones_evento
        where evento_id = v_actividad.evento_id
          and usuario_id = v_usuario
          and estado = 'inscrito'
    ) then
        raise exception 'El participante no tiene una inscripción válida al evento.';
    end if;

    v_requiere_inscripcion := v_actividad.requiere_inscripcion;

    if v_requiere_inscripcion then
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
                join public.miembros_equipo me on me.equipo_id = ia.equipo_id
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

    select trim(nombres || ' ' || apellidos)
    into v_participante
    from public.perfiles
    where id = v_usuario;

    select *
    into v_asistencia
    from public.asistencias
    where actividad_id = p_actividad_id
      and usuario_id = v_usuario
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
            now(),
            v_operador,
            'registrada'
        );

        return jsonb_build_object(
            'ok', true,
            'accion', 'entrada',
            'participante', v_participante,
            'momento', now()
        );
    end if;

    if v_asistencia.entrada_en is not null
       and v_asistencia.salida_en is null then

        update public.asistencias
        set
            salida_en = now(),
            salida_registrada_por = v_operador,
            actualizado_en = now()
        where id = v_asistencia.id;

        return jsonb_build_object(
            'ok', true,
            'accion', 'salida',
            'participante', v_participante,
            'momento', now()
        );
    end if;

    raise exception 'La entrada y salida ya fueron registradas para esta actividad.';
end;
$$;

-- ============================================================
-- 15. PERMISOS PARA FUNCIONES RPC
-- ============================================================

revoke all on function public.inscribirse_evento(uuid) from public;
revoke all on function public.inscribirse_actividad(uuid) from public;
revoke all on function public.crear_equipo(uuid, text) from public;
revoke all on function public.unirse_equipo(uuid) from public;
revoke all on function public.inscribir_equipo_actividad(uuid) from public;
revoke all on function public.obtener_o_crear_qr(uuid) from public;
revoke all on function public.verificar_certificado(text) from public;
revoke all on function public.verificar_pago_evento(uuid, boolean, text) from public;
revoke all on function public.registrar_escaneo_qr(uuid, uuid) from public;

grant execute on function public.inscribirse_evento(uuid) to authenticated;
grant execute on function public.inscribirse_actividad(uuid) to authenticated;
grant execute on function public.crear_equipo(uuid, text) to authenticated;
grant execute on function public.unirse_equipo(uuid) to authenticated;
grant execute on function public.inscribir_equipo_actividad(uuid) to authenticated;
grant execute on function public.obtener_o_crear_qr(uuid) to authenticated;

grant execute on function public.verificar_certificado(text) to anon, authenticated;

grant execute on function public.verificar_pago_evento(uuid, boolean, text) to authenticated;
grant execute on function public.registrar_escaneo_qr(uuid, uuid) to authenticated;
