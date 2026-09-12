// ============================================================
// servicios/sesion.js
// Funciones generales relacionadas con la sesión del usuario.
//
// Estas funciones son utilizadas por varios módulos del proyecto,
// no solo por Autenticación. Por eso viven aquí y no dentro de
// modulos/autenticacion/.
//
// No duplicar estas funciones dentro de otros módulos.
// ============================================================

import { supabase } from './supabase.js'

// Devuelve el usuario autenticado actual (o null si no hay sesión).
//
// Usa supabase.auth.getUser() porque valida el token contra el
// servidor de Supabase (a diferencia de getSession(), que solo lee
// lo que hay guardado localmente).
export async function obtenerUsuarioActual() {
    const { data, error } = await supabase.auth.getUser()

    if (error) {
        return null
    }

    return data.user ?? null
}

// Comprueba si existe una sesión activa.
// Devuelve true o false.
export async function verificarSesion() {
    const usuario = await obtenerUsuarioActual()
    return usuario !== null
}

// Cierra la sesión del usuario actual.
// Devuelve { ok, error }.
export async function cerrarSesion() {
    const { error } = await supabase.auth.signOut()

    if (error) {
        return { ok: false, error }
    }

    return { ok: true, error: null }
}