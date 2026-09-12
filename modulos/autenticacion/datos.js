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
    tipo_participante,
    detalle_tipo_participante,
    codigo_matricula,
    semestre,
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
// Además, el formulario actual puede enviar:
// tipoParticipante, codigoMatricula, semestre y detalleTipo.
//
// nombres/apellidos se envían en options.data porque el trigger de
// la base de datos (private.crear_perfil_nuevo_usuario) los lee de
// raw_user_meta_data para crear el perfil automáticamente.
//
// El resto de campos (documento, teléfono, institución, carrera) se
// guardan con una segunda llamada, actualizando el perfil recién
// creado (requiere que exista sesión, cosa que signUp ya deja lista
// cuando la confirmación de correo no es obligatoria).
//
// Los datos de tipo de participante también se guardan temporalmente
// en user_metadata. Esto permite recuperarlos después del primer inicio
// de sesión cuando Supabase exige confirmación de correo.
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
        carrera,
        tipoParticipante,
        codigoMatricula,
        semestre,
        detalleTipo
    } = datosRegistro

    const { data, error } = await supabase.auth.signUp({
        email: correo,
        password: password,
        options: {
            emailRedirectTo:
            "http://127.0.0.1:5500/modulos/autenticacion/confirmar-email.html",

            data: {
                nombres: nombres,
                apellidos: apellidos,
                tipo_participante: tipoParticipante || null,
                codigo_matricula: codigoMatricula || null,
                semestre: semestre || null,
                detalle_tipo_participante: detalleTipo || null
            }
        }
    })

    if (error) {
        return {
            ok: false,
            error,
            requiereConfirmacionCorreo: false
        }
    }

    // Si el proyecto exige confirmar el correo, todavía no hay sesión.
    // En ese caso no se puede actualizar el resto del perfil todavía.
    //
    // Los nuevos datos no se pierden porque quedaron almacenados
    // temporalmente en user_metadata y se sincronizarán al iniciar sesión.
    const haySesion = Boolean(data.session)

    if (!haySesion) {
        return {
            ok: true,
            error: null,
            requiereConfirmacionCorreo: true
        }
    }

    const datosAdicionales = {}

    if (tipoDocumento) {
        datosAdicionales.tipo_documento =
            tipoDocumento
    }

    if (documentoIdentidad) {
        datosAdicionales.documento_identidad =
            documentoIdentidad
    }

    if (telefono) {
        datosAdicionales.telefono =
            telefono
    }

    if (institucion) {
        datosAdicionales.institucion =
            institucion
    }

    if (carrera) {
        datosAdicionales.carrera =
            carrera
    }


    // --------------------------------------------------------
    // Datos del tipo de participante
    // --------------------------------------------------------
    //
    // Estos datos describen al participante del evento.
    // NO representan el rol de seguridad del sistema.

    if (tipoParticipante) {
        datosAdicionales.tipo_participante =
            tipoParticipante
    }

    if (codigoMatricula) {
        datosAdicionales.codigo_matricula =
            codigoMatricula
    }

    if (semestre) {
        datosAdicionales.semestre =
            semestre
    }

    if (detalleTipo) {
        datosAdicionales.detalle_tipo_participante =
            detalleTipo
    }


    if (Object.keys(datosAdicionales).length > 0) {
        const {
            error: errorPerfil
        } = await actualizarPerfil(
            datosAdicionales
        )

        if (errorPerfil) {
            // La cuenta ya se creó; solo falló guardar los datos extra.
            // Se informa para que la persona pueda completarlos luego
            // desde perfil.html.
            return {
                ok: true,
                error: null,
                requiereConfirmacionCorreo: false,
                avisoPerfilIncompleto: true
            }
        }
    }

    return {
        ok: true,
        error: null,
        requiereConfirmacionCorreo: false
    }
}


// ------------------------------------------------------------
// Sincronización de datos pendientes del registro
// ------------------------------------------------------------
//
// Cuando la confirmación de correo está activada, signUp()
// crea el usuario pero todavía no existe una sesión.
//
// Por ese motivo no podemos actualizar public.perfiles en ese
// momento.
//
// Los datos quedan en user_metadata y, después del primer inicio
// de sesión, esta función completa los campos que todavía estén
// vacíos en public.perfiles.
//
// Nunca modifica el campo rol.
async function sincronizarDatosRegistroPendientes(usuario) {
    if (!usuario) {
        return {
            ok: false,
            error: {
                message: 'No hay un usuario autenticado.'
            }
        }
    }


    const { data: perfil, error: errorLectura } =
        await supabase
            .from('perfiles')
            .select(`
                tipo_participante,
                detalle_tipo_participante,
                codigo_matricula,
                semestre
            `)
            .eq('id', usuario.id)
            .single()


    if (errorLectura) {
        return {
            ok: false,
            error: errorLectura
        }
    }


    const metadatos =
        usuario.user_metadata || {}

    const cambios = {}


    // Solamente completamos campos que todavía no tienen valor.
    // Esto evita sobrescribir información del perfil en futuros
    // inicios de sesión.

    if (
        !perfil.tipo_participante &&
        metadatos.tipo_participante
    ) {
        cambios.tipo_participante =
            metadatos.tipo_participante
    }


    if (
        !perfil.codigo_matricula &&
        metadatos.codigo_matricula
    ) {
        cambios.codigo_matricula =
            metadatos.codigo_matricula
    }


    if (
        !perfil.semestre &&
        metadatos.semestre
    ) {
        cambios.semestre =
            metadatos.semestre
    }


    if (
        !perfil.detalle_tipo_participante &&
        metadatos.detalle_tipo_participante
    ) {
        cambios.detalle_tipo_participante =
            metadatos.detalle_tipo_participante
    }


    if (Object.keys(cambios).length === 0) {
        return {
            ok: true,
            error: null
        }
    }


    const { error } =
        await supabase
            .from('perfiles')
            .update(cambios)
            .eq('id', usuario.id)


    if (error) {
        return {
            ok: false,
            error
        }
    }


    return {
        ok: true,
        error: null
    }
}


// ------------------------------------------------------------
// Inicio de sesión
// ------------------------------------------------------------
export async function iniciarSesion(correo, password) {
    const { data, error } =
        await supabase.auth.signInWithPassword({
            email: correo,
            password: password
        })

    if (error) {
        return {
            ok: false,
            error
        }
    }


    // Si durante el registro había confirmación de correo,
    // los datos adicionales quedaron temporalmente almacenados
    // en user_metadata.
    //
    // Ahora que ya existe una sesión válida, se sincronizan con
    // public.perfiles.
    const resultadoSincronizacion =
        await sincronizarDatosRegistroPendientes(
            data.user
        )


    if (!resultadoSincronizacion.ok) {
        return {
            ok: false,
            error: resultadoSincronizacion.error
        }
    }


    return {
        ok: true,
        error: null,
        usuario: data.user
    }
}


// ------------------------------------------------------------
// Recuperación de contraseña
// ------------------------------------------------------------

// Envía al correo del usuario un enlace de recuperación.
// urlRedireccion debe apuntar a actualizar-contrasena.html.
export async function solicitarRecuperacionContrasena(
    correo,
    urlRedireccion
) {
    const { error } =
        await supabase.auth.resetPasswordForEmail(
            correo,
            {
                redirectTo: urlRedireccion
            }
        )

    if (error) {
        return {
            ok: false,
            error
        }
    }

    return {
        ok: true,
        error: null
    }
}


// Actualiza la contraseña cuando el usuario ha llegado desde
// el enlace de recuperación enviado por Supabase.
export async function actualizarContrasena(
    nuevaContrasena
) {
    const { error } =
        await supabase.auth.updateUser({
            password: nuevaContrasena
        })

    if (error) {
        return {
            ok: false,
            error
        }
    }

    return {
        ok: true,
        error: null
    }
}


// ------------------------------------------------------------
// Lectura del perfil del participante conectado
// ------------------------------------------------------------
export async function obtenerPerfilPropio() {
    const usuario =
        await obtenerUsuarioActual()

    if (!usuario) {
        return {
            ok: false,
            error: {
                message: 'No hay una sesión activa.'
            },
            perfil: null
        }
    }


    const { data, error } =
        await supabase
            .from('perfiles')
            .select(COLUMNAS_PERFIL)
            .eq('id', usuario.id)
            .single()


    if (error) {
        return {
            ok: false,
            error,
            perfil: null
        }
    }


    return {
        ok: true,
        error: null,
        perfil: data
    }
}


// ------------------------------------------------------------
// Actualización de información del perfil
// ------------------------------------------------------------
// campos puede incluir: tipo_documento, documento_identidad,
// telefono, institucion, carrera, nombres, apellidos.
//
// También puede incluir los campos del participante:
// tipo_participante, codigo_matricula, semestre y
// detalle_tipo_participante.
//
// rol y activo NO se pueden cambiar desde aquí: la base de datos
// los protege aunque se intenten enviar (trigger
// private.proteger_campos_perfil).
export async function actualizarPerfil(campos) {
    const usuario =
        await obtenerUsuarioActual()

    if (!usuario) {
        return {
            ok: false,
            error: {
                message: 'No hay una sesión activa.'
            }
        }
    }


    const { error } =
        await supabase
            .from('perfiles')
            .update(campos)
            .eq('id', usuario.id)


    if (error) {
        return {
            ok: false,
            error
        }
    }


    return {
        ok: true,
        error: null
    }
}