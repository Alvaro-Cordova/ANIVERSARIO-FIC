// ============================================================
// modulos/autenticacion/datos.js
//
// Toda la comunicación con Supabase para el módulo de
// Autenticación pasa por aquí. interfaz.js NUNCA debe llamar
// a supabase directamente.
//
// Usa la única conexión del proyecto: servicios/supabase.js
// Usa las funciones generales de sesión: servicios/sesion.js
// ============================================================

import { supabase } from '../../servicios/supabase.js'
import { obtenerUsuarioActual } from '../../servicios/sesion.js'

// Columnas del perfil que este módulo puede leer/mostrar.
// (rol y activo son de solo lectura: los protege la base de datos)
const COLUMNAS_PERFIL = `
    id,
    nombres,
    apellidos,
    tipo_documento,
    documento_identidad,
    telefono,
    institucion,
    carrera,
    correo,
    rol,
    activo
`

// ------------------------------------------------------------
// Registro de usuario
// ------------------------------------------------------------
// datosRegistro = {
//     nombres, apellidos, correo, password,
//     tipoDocumento, documentoIdentidad, telefono, institucion, carrera
// }
//
// nombres/apellidos se envían en options.data porque el trigger de
// la base de datos (private.crear_perfil_nuevo_usuario) los lee de
// raw_user_meta_data para crear el perfil automáticamente.
//
// El resto de campos (documento, teléfono, institución, carrera) se
// guardan con una segunda llamada, actualizando el perfil recién
// creado (requiere que exista sesión, cosa que signUp ya deja lista
// cuando la confirmación de correo no es obligatoria).
export async function registrarUsuario(datosRegistro) {
    const {
        nombres,
        apellidos,
        correo,
        password,
        tipoDocumento,
        documentoIdentidad,
        telefono,
        institucion,
        carrera
    } = datosRegistro

    const { data, error } = await supabase.auth.signUp({
        email: correo,
        password: password,
        options: {
            data: {
                nombres: nombres,
                apellidos: apellidos
            }
        }
    })

    if (error) {
        return { ok: false, error, requiereConfirmacionCorreo: false }
    }

    // Si el proyecto exige confirmar el correo, todavía no hay sesión.
    // En ese caso no se puede actualizar el resto del perfil todavía.
    const haySesion = Boolean(data.session)

    if (!haySesion) {
        return { ok: true, error: null, requiereConfirmacionCorreo: true }
    }

    const datosAdicionales = {}
    if (tipoDocumento) datosAdicionales.tipo_documento = tipoDocumento
    if (documentoIdentidad) datosAdicionales.documento_identidad = documentoIdentidad
    if (telefono) datosAdicionales.telefono = telefono
    if (institucion) datosAdicionales.institucion = institucion
    if (carrera) datosAdicionales.carrera = carrera

    if (Object.keys(datosAdicionales).length > 0) {
        const { error: errorPerfil } = await actualizarPerfil(datosAdicionales)

        if (errorPerfil) {
            // La cuenta ya se creó; solo falló guardar los datos extra.
            // Se informa para que la persona pueda completarlos luego
            // desde perfil.html.
            return { ok: true, error: null, requiereConfirmacionCorreo: false, avisoPerfilIncompleto: true }
        }
    }

    return { ok: true, error: null, requiereConfirmacionCorreo: false }
}

// ------------------------------------------------------------
// Inicio de sesión
// ------------------------------------------------------------
export async function iniciarSesion(correo, password) {
    const { data, error } = await supabase.auth.signInWithPassword({
        email: correo,
        password: password
    })

    if (error) {
        return { ok: false, error }
    }

    return { ok: true, error: null, usuario: data.user }
}
// ------------------------------------------------------------
// Recuperación de contraseña
// ------------------------------------------------------------

// Envía al correo del usuario un enlace de recuperación.
// urlRedireccion debe apuntar a actualizar-contrasena.html.
export async function solicitarRecuperacionContrasena(correo, urlRedireccion) {
    const { error } = await supabase.auth.resetPasswordForEmail(correo, {
        redirectTo: urlRedireccion
    })

    if (error) {
        return { ok: false, error }
    }

    return { ok: true, error: null }
}

// Actualiza la contraseña cuando el usuario ha llegado desde
// el enlace de recuperación enviado por Supabase.
export async function actualizarContrasena(nuevaContrasena) {
    const { error } = await supabase.auth.updateUser({
        password: nuevaContrasena
    })

    if (error) {
        return { ok: false, error }
    }

    return { ok: true, error: null }
}

// ------------------------------------------------------------
// Lectura del perfil del participante conectado
// ------------------------------------------------------------
export async function obtenerPerfilPropio() {
    const usuario = await obtenerUsuarioActual()

    if (!usuario) {
        return { ok: false, error: { message: 'No hay una sesión activa.' }, perfil: null }
    }

    const { data, error } = await supabase
        .from('perfiles')
        .select(COLUMNAS_PERFIL)
        .eq('id', usuario.id)
        .single()

    if (error) {
        return { ok: false, error, perfil: null }
    }

    return { ok: true, error: null, perfil: data }
}

// ------------------------------------------------------------
// Actualización de información del perfil
// ------------------------------------------------------------
// campos puede incluir: tipo_documento, documento_identidad,
// telefono, institucion, carrera, nombres, apellidos.
//
// rol y activo NO se pueden cambiar desde aquí: la base de datos
// los protege aunque se intenten enviar (trigger
// private.proteger_campos_perfil).
export async function actualizarPerfil(campos) {
    const usuario = await obtenerUsuarioActual()

    if (!usuario) {
        return { ok: false, error: { message: 'No hay una sesión activa.' } }
    }

    const { error } = await supabase
        .from('perfiles')
        .update(campos)
        .eq('id', usuario.id)

    if (error) {
        return { ok: false, error }
    }

    return { ok: true, error: null }
}