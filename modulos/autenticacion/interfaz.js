// ============================================================
// modulos/autenticacion/interfaz.js
//
// Controla botones, formularios, mensajes y redirecciones de:
//   - iniciar-sesion.html
//   - registro.html
//   - recuperar-contrasena.html
//   - actualizar-contrasena.html
//   - perfil.html
//
// Nunca llama a supabase directamente: usa datos.js y
// servicios/sesion.js.
// ============================================================

import {
    registrarUsuario,
    iniciarSesion,
    obtenerPerfilPropio,
    actualizarPerfil,
    solicitarRecuperacionContrasena,
    actualizarContrasena
} from './datos.js'

import {
    verificarSesion,
    cerrarSesion
} from '../../servicios/sesion.js'


// ------------------------------------------------------------
// Utilidades de interfaz
// ------------------------------------------------------------

// Muestra un mensaje de error o éxito dentro de la página.
function mostrarMensaje(elemento, texto, tipo = 'error') {
    if (!elemento) return

    elemento.textContent = texto
    elemento.classList.remove('mensaje-error', 'mensaje-exito')
    elemento.classList.add(
        tipo === 'exito'
            ? 'mensaje-exito'
            : 'mensaje-error'
    )
    elemento.hidden = false
}


// Limpia y oculta un mensaje mostrado anteriormente.
function limpiarMensaje(elemento) {
    if (!elemento) return

    elemento.textContent = ''
    elemento.hidden = true
}


// Desactiva temporalmente un botón mientras se procesa una acción.
function bloquearBoton(boton, textoCargando) {
    if (!boton) return

    boton.disabled = true
    boton.dataset.textoOriginal = boton.textContent
    boton.textContent = textoCargando
}


// Reactiva un botón después de terminar una acción.
function liberarBoton(boton) {
    if (!boton) return

    boton.disabled = false
    boton.textContent =
        boton.dataset.textoOriginal ||
        boton.textContent
}


// Comprueba si un valor está vacío.
function campoVacio(valor) {
    return !valor || valor.trim().length === 0
}


// Validación básica del formato de correo electrónico.
function correoValido(correo) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(correo)
}


// Convierte algunos mensajes comunes de Supabase Auth
// en mensajes más claros para el usuario.
function mensajeDeError(error) {
    if (!error) {
        return 'Ocurrió un error inesperado.'
    }

    const mensaje = error.message || ''

    if (mensaje.includes('Invalid login credentials')) {
        return 'Correo o contraseña incorrectos.'
    }

    if (mensaje.includes('User already registered')) {
        return 'Ya existe una cuenta registrada con ese correo.'
    }

    if (mensaje.includes('Password should be at least')) {
        return 'La contraseña debe tener al menos 6 caracteres.'
    }

    return mensaje || 'Ocurrió un error inesperado.'
}


// ------------------------------------------------------------
// Página: registro.html
// ------------------------------------------------------------

// Controla el formulario utilizado para crear una cuenta.
//
// Los datos solicitados actualmente en la interfaz son:
// nombres, apellidos, correo, contraseña,
// confirmación de contraseña, código de matrícula y semestre.
//
// Confirmar contraseña solo se utiliza para comprobar que el
// usuario escribió correctamente su contraseña. No se guarda.
//
// Código de matrícula y semestre todavía no se envían a Supabase
// porque esas columnas aún no existen en public.perfiles.
// Cuando Base de Datos las agregue, se incorporarán a datos.js.
function inicializarRegistro() {
    const formulario =
        document.getElementById('formulario-registro')

    if (!formulario) return

    const mensaje =
        document.getElementById('mensaje-registro')

    const boton =
        document.getElementById('btn-registro')

    formulario.addEventListener(
        'submit',
        async (evento) => {
            evento.preventDefault()
            limpiarMensaje(mensaje)

            const nombres =
                document
                    .getElementById('reg-nombres')
                    .value
                    .trim()

            const apellidos =
                document
                    .getElementById('reg-apellidos')
                    .value
                    .trim()

            const correo =
                document
                    .getElementById('reg-correo')
                    .value
                    .trim()

            const password =
                document
                    .getElementById('reg-password')
                    .value

            const confirmarPassword =
                document
                    .getElementById('reg-confirmar-password')
                    .value

            const codigoMatricula =
                document
                    .getElementById('reg-codigo-matricula')
                    .value
                    .trim()

            const semestre =
                document
                    .getElementById('reg-semestre')
                    .value
                    .trim()


            // Todos los campos visibles del formulario
            // son obligatorios.
            if (
                campoVacio(nombres) ||
                campoVacio(apellidos) ||
                campoVacio(correo) ||
                campoVacio(password) ||
                campoVacio(confirmarPassword) ||
                campoVacio(codigoMatricula) ||
                campoVacio(semestre)
            ) {
                mostrarMensaje(
                    mensaje,
                    'Completa todos los campos.'
                )
                return
            }


            // Validación básica del correo.
            if (!correoValido(correo)) {
                mostrarMensaje(
                    mensaje,
                    'Ingresa un correo válido.'
                )
                return
            }


            // Supabase requiere como mínimo 6 caracteres
            // para la contraseña con la configuración actual.
            if (password.length < 6) {
                mostrarMensaje(
                    mensaje,
                    'La contraseña debe tener al menos 6 caracteres.'
                )
                return
            }


            // La confirmación solo valida que ambas
            // contraseñas hayan sido escritas igual.
            if (password !== confirmarPassword) {
                mostrarMensaje(
                    mensaje,
                    'Las contraseñas no coinciden.'
                )
                return
            }


            bloquearBoton(
                boton,
                'Creando cuenta...'
            )


            // Por ahora se envían únicamente los campos que
            // la estructura actual de Supabase puede registrar.
            //
            // codigoMatricula y semestre se incorporarán cuando
            // existan sus columnas correspondientes en perfiles.
            const resultado =
                await registrarUsuario({
                    nombres,
                    apellidos,
                    correo,
                    password
                })


            liberarBoton(boton)


            if (!resultado.ok) {
                mostrarMensaje(
                    mensaje,
                    mensajeDeError(resultado.error)
                )
                return
            }


            // Si Supabase tiene activada la confirmación
            // de correo, el usuario deberá confirmar su cuenta
            // antes de poder iniciar sesión.
            if (resultado.requiereConfirmacionCorreo) {
                mostrarMensaje(
                    mensaje,
                    'Cuenta creada. Revisa tu correo para confirmar tu cuenta antes de iniciar sesión.',
                    'exito'
                )

                formulario.reset()
                return
            }


            mostrarMensaje(
                mensaje,
                'Cuenta creada correctamente. Redirigiendo...',
                'exito'
            )


            setTimeout(() => {
                window.location.href = 'perfil.html'
            }, 1200)
        }
    )
}


// ------------------------------------------------------------
// Página: iniciar-sesion.html
// ------------------------------------------------------------

// Controla el formulario de inicio de sesión.
function inicializarLogin() {
    const formulario =
        document.getElementById('formulario-login')

    if (!formulario) return

    const mensaje =
        document.getElementById('mensaje-login')

    const boton =
        document.getElementById('btn-login')


    formulario.addEventListener(
        'submit',
        async (evento) => {
            evento.preventDefault()
            limpiarMensaje(mensaje)

            const correo =
                document
                    .getElementById('login-correo')
                    .value
                    .trim()

            const password =
                document
                    .getElementById('login-password')
                    .value


            if (
                campoVacio(correo) ||
                campoVacio(password)
            ) {
                mostrarMensaje(
                    mensaje,
                    'Ingresa tu correo y tu contraseña.'
                )
                return
            }


            if (!correoValido(correo)) {
                mostrarMensaje(
                    mensaje,
                    'Ingresa un correo válido.'
                )
                return
            }


            bloquearBoton(
                boton,
                'Ingresando...'
            )


            const resultado =
                await iniciarSesion(
                    correo,
                    password
                )


            liberarBoton(boton)


            if (!resultado.ok) {
                mostrarMensaje(
                    mensaje,
                    mensajeDeError(resultado.error)
                )
                return
            }


            mostrarMensaje(
                mensaje,
                'Sesión iniciada. Redirigiendo...',
                'exito'
            )


            setTimeout(() => {
                window.location.href = 'perfil.html'
            }, 800)
        }
    )
}


// Si alguien con sesión activa visita login o registro,
// lo enviamos directamente a su perfil.
async function redirigirSiYaTieneSesion() {
    const enPaginaPublica =
        document.getElementById('formulario-login') ||
        document.getElementById('formulario-registro')

    if (!enPaginaPublica) return


    const haySesion =
        await verificarSesion()


    if (haySesion) {
        window.location.href = 'perfil.html'
    }
}


// ------------------------------------------------------------
// Página: recuperar-contrasena.html
// ------------------------------------------------------------

// Solicita a Supabase el envío del correo que contiene
// el enlace necesario para recuperar la contraseña.
function inicializarRecuperacionContrasena() {
    const formulario =
        document.getElementById(
            'formulario-recuperacion'
        )

    if (!formulario) return

    const mensaje =
        document.getElementById(
            'mensaje-recuperacion'
        )

    const boton =
        document.getElementById(
            'btn-recuperacion'
        )


    formulario.addEventListener(
        'submit',
        async (evento) => {
            evento.preventDefault()
            limpiarMensaje(mensaje)


            const correo =
                document
                    .getElementById(
                        'recuperacion-correo'
                    )
                    .value
                    .trim()


            if (campoVacio(correo)) {
                mostrarMensaje(
                    mensaje,
                    'Ingresa tu correo.'
                )
                return
            }


            if (!correoValido(correo)) {
                mostrarMensaje(
                    mensaje,
                    'Ingresa un correo válido.'
                )
                return
            }


            bloquearBoton(
                boton,
                'Enviando...'
            )


            // Genera la dirección de esta misma aplicación
            // a la que Supabase debe regresar después de que
            // el usuario abra el enlace recibido por correo.
            const urlRedireccion =
                new URL(
                    'actualizar-contrasena.html',
                    window.location.href
                ).href


            const resultado =
                await solicitarRecuperacionContrasena(
                    correo,
                    urlRedireccion
                )


            liberarBoton(boton)


            if (!resultado.ok) {
                mostrarMensaje(
                    mensaje,
                    mensajeDeError(resultado.error)
                )
                return
            }


            // Se utiliza un mensaje genérico para no revelar
            // si una dirección de correo está registrada.
            mostrarMensaje(
                mensaje,
                'Si existe una cuenta asociada a ese correo, recibirás un enlace para cambiar tu contraseña.',
                'exito'
            )


            formulario.reset()
        }
    )
}


// ------------------------------------------------------------
// Página: actualizar-contrasena.html
// ------------------------------------------------------------

// Permite establecer una nueva contraseña después de entrar
// mediante el enlace de recuperación enviado por Supabase.
function inicializarActualizacionContrasena() {
    const formulario =
        document.getElementById(
            'formulario-actualizar-contrasena'
        )

    if (!formulario) return

    const mensaje =
        document.getElementById(
            'mensaje-actualizar-contrasena'
        )

    const boton =
        document.getElementById(
            'btn-actualizar-contrasena'
        )


    formulario.addEventListener(
        'submit',
        async (evento) => {
            evento.preventDefault()
            limpiarMensaje(mensaje)


            const password =
                document
                    .getElementById(
                        'nueva-password'
                    )
                    .value

            const confirmarPassword =
                document
                    .getElementById(
                        'confirmar-nueva-password'
                    )
                    .value


            if (
                campoVacio(password) ||
                campoVacio(confirmarPassword)
            ) {
                mostrarMensaje(
                    mensaje,
                    'Completa ambos campos de contraseña.'
                )
                return
            }


            if (password.length < 6) {
                mostrarMensaje(
                    mensaje,
                    'La contraseña debe tener al menos 6 caracteres.'
                )
                return
            }


            if (password !== confirmarPassword) {
                mostrarMensaje(
                    mensaje,
                    'Las contraseñas no coinciden.'
                )
                return
            }


            bloquearBoton(
                boton,
                'Actualizando...'
            )


            const resultado =
                await actualizarContrasena(password)


            liberarBoton(boton)


            if (!resultado.ok) {
                mostrarMensaje(
                    mensaje,
                    mensajeDeError(resultado.error)
                )
                return
            }


            mostrarMensaje(
                mensaje,
                'Contraseña actualizada correctamente. Redirigiendo...',
                'exito'
            )


            setTimeout(() => {
                window.location.href =
                    'iniciar-sesion.html'
            }, 1500)
        }
    )
}


// ------------------------------------------------------------
// Página: perfil.html
// ------------------------------------------------------------

// Coloca en la interfaz los datos del perfil
// obtenidos desde Supabase.
function rellenarPerfil(perfil) {
    const campos = {
        'perfil-nombres':
            perfil.nombres,

        'perfil-apellidos':
            perfil.apellidos,

        'perfil-correo':
            perfil.correo,

        'perfil-rol':
            perfil.rol
    }


    for (
        const [id, valor]
        of Object.entries(campos)
    ) {
        const elemento =
            document.getElementById(id)

        if (elemento) {
            elemento.textContent =
                valor || '—'
        }
    }


    const camposEditables = {
        'perfil-tipo-documento':
            perfil.tipo_documento,

        'perfil-documento':
            perfil.documento_identidad,

        'perfil-telefono':
            perfil.telefono,

        'perfil-institucion':
            perfil.institucion,

        'perfil-carrera':
            perfil.carrera
    }


    for (
        const [id, valor]
        of Object.entries(camposEditables)
    ) {
        const elemento =
            document.getElementById(id)

        if (elemento) {
            elemento.value =
                valor || ''
        }
    }
}


// Protege perfil.html para que solamente pueda
// acceder una persona que tenga una sesión activa.
async function inicializarPerfil() {
    const contenedor =
        document.getElementById(
            'perfil-contenido'
        )

    if (!contenedor) return


    const haySesion =
        await verificarSesion()


    if (!haySesion) {
        window.location.href =
            'iniciar-sesion.html'

        return
    }


    const mensaje =
        document.getElementById(
            'mensaje-perfil'
        )


    const resultado =
        await obtenerPerfilPropio()


    if (!resultado.ok) {
        mostrarMensaje(
            mensaje,
            mensajeDeError(resultado.error)
        )
        return
    }


    rellenarPerfil(resultado.perfil)
    contenedor.hidden = false


    // --------------------------------------------------------
    // Edición de la información del perfil
    // --------------------------------------------------------

    const formularioEdicion =
        document.getElementById(
            'formulario-perfil'
        )


    if (formularioEdicion) {
        formularioEdicion.addEventListener(
            'submit',
            async (evento) => {
                evento.preventDefault()
                limpiarMensaje(mensaje)


                const boton =
                    document.getElementById(
                        'btn-guardar-perfil'
                    )


                bloquearBoton(
                    boton,
                    'Guardando...'
                )


                const cambios = {
                    tipo_documento:
                        document
                            .getElementById(
                                'perfil-tipo-documento'
                            )
                            .value,

                    documento_identidad:
                        document
                            .getElementById(
                                'perfil-documento'
                            )
                            .value
                            .trim(),

                    telefono:
                        document
                            .getElementById(
                                'perfil-telefono'
                            )
                            .value
                            .trim(),

                    institucion:
                        document
                            .getElementById(
                                'perfil-institucion'
                            )
                            .value
                            .trim(),

                    carrera:
                        document
                            .getElementById(
                                'perfil-carrera'
                            )
                            .value
                            .trim()
                }


                const respuesta =
                    await actualizarPerfil(
                        cambios
                    )


                liberarBoton(boton)


                if (!respuesta.ok) {
                    mostrarMensaje(
                        mensaje,
                        mensajeDeError(
                            respuesta.error
                        )
                    )
                    return
                }


                mostrarMensaje(
                    mensaje,
                    'Perfil actualizado correctamente.',
                    'exito'
                )
            }
        )
    }


    // --------------------------------------------------------
    // Cierre de sesión
    // --------------------------------------------------------

    const botonCerrarSesion =
        document.getElementById(
            'btn-cerrar-sesion'
        )


    if (botonCerrarSesion) {
        botonCerrarSesion.addEventListener(
            'click',
            async () => {
                bloquearBoton(
                    botonCerrarSesion,
                    'Cerrando...'
                )


                await cerrarSesion()


                window.location.href =
                    'iniciar-sesion.html'
            }
        )
    }
}


// ------------------------------------------------------------
// Arranque
// ------------------------------------------------------------

// interfaz.js se carga en todas las páginas del módulo.
// Cada inicializador comprueba primero si los elementos
// correspondientes existen, por lo que únicamente se ejecuta
// la lógica necesaria para la página que está abierta.
document.addEventListener(
    'DOMContentLoaded',
    () => {
        redirigirSiYaTieneSesion()
        inicializarRegistro()
        inicializarLogin()
        inicializarRecuperacionContrasena()
        inicializarActualizacionContrasena()
        inicializarPerfil()
    }
)