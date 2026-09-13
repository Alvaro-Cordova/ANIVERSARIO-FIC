// ============================================================
// modulos/autenticacion/interfaz.js
//
// Controla botones, formularios y eventos del módulo Auth.
//
// Páginas:
//   - iniciar-sesion.html
//   - registro.html
//   - recuperar-contrasena.html
//   - actualizar-contrasena.html
//   - perfil.html
//
// Nunca llama directamente a Supabase.
// Usa datos.js y servicios/sesion.js.
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





// ============================================================
// UTILIDADES GENERALES
// ============================================================



function mostrarMensaje(
    elemento,
    texto,
    tipo = 'error'
) {

    if (!elemento) return


    elemento.textContent = texto


    elemento.classList.remove(
        'mensaje-error',
        'mensaje-exito'
    )


    elemento.classList.add(
        tipo === 'exito'
            ? 'mensaje-exito'
            : 'mensaje-error'
    )


    elemento.hidden = false

}





function limpiarMensaje(elemento) {

    if (!elemento) return


    elemento.textContent = ''

    elemento.hidden = true

}





function bloquearBoton(
    boton,
    textoCargando
) {

    if (!boton) return


    boton.disabled = true


    boton.dataset.textoOriginal =
        boton.textContent


    boton.textContent =
        textoCargando

}





function liberarBoton(boton) {

    if (!boton) return


    boton.disabled = false


    boton.textContent =
        boton.dataset.textoOriginal ||
        boton.textContent

}





function campoVacio(valor) {

    return (
        !valor ||
        valor.trim().length === 0
    )

}





function correoValido(correo) {

    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/
        .test(correo)

}





// ============================================================
// VALIDACIÓN DE MATRÍCULA
// Formato:
// 10 números + 1 letra final
//
// Ejemplo:
// 2026100000M
// ============================================================


function codigoMatriculaValido(codigo) {

    return /^[0-9]{10}[A-Za-z]$/
        .test(codigo)

}

function telefonoPeruValido(telefono) {

    return /^9[0-9]{8}$/.test(telefono)

}



function mensajeDeError(error) {

    if (!error) {

        return 'Ocurrió un error inesperado.'

    }



    const mensaje =
        error.message || ''



    if (
        mensaje.includes(
            'Invalid login credentials'
        )
    ) {

        return 'Correo o contraseña incorrectos.'

    }



    if (
        mensaje.includes(
            'User already registered'
        )
    ) {

        return (
            'Ya existe una cuenta registrada con ese correo.'
        )

    }



    if (
        mensaje.includes(
            'Password should be at least'
        )
    ) {

        return (
            'La contraseña debe tener al menos 6 caracteres.'
        )

    }



    return (
        mensaje ||
        'Ocurrió un error inesperado.'
    )

}





// ============================================================
// PÁGINA: registro.html
// ============================================================



function inicializarRegistro() {


    const formulario =
        document.getElementById(
            'formulario-registro'
        )



    if (!formulario) return




    const mensaje =
        document.getElementById(
            'mensaje-registro'
        )



    const boton =
        document.getElementById(
            'btn-registro'
        )




    const selectorTipo =
        document.getElementById(
            'reg-tipo-participante'
        )



    const camposEstudiante =
        document.getElementById(
            'campos-estudiante'
        )



    const camposOtro =
        document.getElementById(
            'campos-otro'
        )



    const campoCodigoMatricula =
        document.getElementById(
            'reg-codigo-matricula'
        )



    const campoSemestre =
        document.getElementById(
            'reg-semestre'
        )



    const campoDetalleTipo =
        document.getElementById(
            'reg-detalle-tipo'
        )





    function actualizarCamposTipoParticipante() {


        const tipoParticipante =
            selectorTipo.value



        const esEstudiante =
            tipoParticipante === 'ESTUDIANTE'



        const esOtro =
            tipoParticipante === 'OTRO'



        camposEstudiante.hidden =
            !esEstudiante



        camposOtro.hidden =
            !esOtro



        campoCodigoMatricula.disabled =
            !esEstudiante



        campoSemestre.disabled =
            !esEstudiante



        campoDetalleTipo.disabled =
            !esOtro




        if (!esEstudiante) {

            campoCodigoMatricula.value = ''

            campoSemestre.value = ''

        }



        if (!esOtro) {

            campoDetalleTipo.value = ''

        }


    }




    selectorTipo.addEventListener(
        'change',
        actualizarCamposTipoParticipante
    )



    actualizarCamposTipoParticipante()
    formulario.addEventListener(
        'submit',
        async (evento) => {


            evento.preventDefault()


            limpiarMensaje(mensaje)




            const nombres =
                document
                    .getElementById(
                        'reg-nombres'
                    )
                    .value
                    .trim()



            const apellidos =
                document
                    .getElementById(
                        'reg-apellidos'
                    )
                    .value
                    .trim()



            const correo =
                document
                    .getElementById(
                        'reg-correo'
                    )
                    .value
                    .trim()
            
            const telefono =
                document
                    .getElementById(
                        'reg-telefono'
                    )
                    .value
                    .trim()        



            const password =
                document
                    .getElementById(
                        'reg-password'
                    )
                    .value



            const confirmarPassword =
                document
                    .getElementById(
                        'reg-confirmar-password'
                    )
                    .value



            const tipoParticipante =
                selectorTipo.value



            const codigoMatricula =
                campoCodigoMatricula
                    .value
                    .trim()



            const semestre =
                campoSemestre.value



            const detalleTipo =
                campoDetalleTipo
                    .value
                    .trim()





            if (
                campoVacio(nombres) ||
                campoVacio(apellidos) ||
                campoVacio(correo) ||
                campoVacio(password) ||
                campoVacio(confirmarPassword) ||
                campoVacio(tipoParticipante)
            ) {


                mostrarMensaje(
                    mensaje,
                    'Completa todos los campos obligatorios.'
                )


                return

            }





            if (
                !correoValido(correo)
            ) {


                mostrarMensaje(
                    mensaje,
                    'Ingresa un correo válido.'
                )


                return

            }
            if (
                !telefonoPeruValido(telefono)
            ) {

                mostrarMensaje(
                    mensaje,
                    'El teléfono debe tener 9 dígitos y comenzar con 9.'
                )


                return

            }





            if (
                password.length < 6
            ) {


                mostrarMensaje(
                    mensaje,
                    'La contraseña debe tener al menos 6 caracteres.'
                )


                return

            }





            if (
                password !== confirmarPassword
            ) {


                mostrarMensaje(
                    mensaje,
                    'Las contraseñas no coinciden.'
                )


                return

            }







            // ----------------------------------------
            // Validación estudiante
            // ----------------------------------------


            if (
                tipoParticipante === 'ESTUDIANTE'
            ) {


                if (
                    campoVacio(codigoMatricula)
                ) {


                    mostrarMensaje(
                        mensaje,
                        'Ingresa tu código de matrícula.'
                    )


                    return

                }





                if (
                    !codigoMatriculaValido(
                        codigoMatricula
                    )
                ) {


                    mostrarMensaje(
                        mensaje,
                        'El código de matrícula debe tener 10 números y una letra final.'
                    )


                    return

                }





                if (
                    campoVacio(semestre)
                ) {


                    mostrarMensaje(
                        mensaje,
                        'Selecciona tu semestre.'
                    )


                    return

                }


            }







            // ----------------------------------------
            // Validación otro participante
            // ----------------------------------------


            if (
                tipoParticipante === 'OTRO'
            ) {


                if (
                    campoVacio(detalleTipo)
                ) {


                    mostrarMensaje(
                        mensaje,
                        'Especifica tu tipo de participante.'
                    )


                    return

                }


            }








            bloquearBoton(
                boton,
                'Creando cuenta...'
            )








            const resultado =
                await registrarUsuario({

                    nombres,

                    apellidos,

                    correo,

                    password,

                    telefono,


                    tipoParticipante,


                    codigoMatricula:
                        tipoParticipante === 'ESTUDIANTE'
                            ? codigoMatricula
                            : null,


                    semestre:
                        tipoParticipante === 'ESTUDIANTE'
                            ? semestre
                            : null,


                    detalleTipo:
                        tipoParticipante === 'OTRO'
                            ? detalleTipo
                            : null

                })







            liberarBoton(
                boton
            )







            if (
                !resultado.ok
            ) {


                mostrarMensaje(
                    mensaje,
                    mensajeDeError(
                        resultado.error
                    )
                )


                return

            }







            if (
                resultado.requiereConfirmacionCorreo
            ) {


                mostrarMensaje(
                    mensaje,
                    'Cuenta creada. Revisa tu correo para confirmar tu cuenta antes de iniciar sesión.',
                    'exito'
                )



                formulario.reset()



                actualizarCamposTipoParticipante()



                return


            }







            mostrarMensaje(
                mensaje,
                'Cuenta creada correctamente. Redirigiendo...',
                'exito'
            )






            setTimeout(
                () => {


                    window.location.href =
                        'perfil.html'


                },
                1200
            )



        }
    )



}









// ============================================================
// PÁGINA: iniciar-sesion.html
// ============================================================



function inicializarLogin() {


    const formulario =
        document.getElementById(
            'formulario-login'
        )



    if (!formulario) return





    const mensaje =
        document.getElementById(
            'mensaje-login'
        )



    const boton =
        document.getElementById(
            'btn-login'
        )







    formulario.addEventListener(
        'submit',
        async (evento) => {


            evento.preventDefault()



            limpiarMensaje(
                mensaje
            )




            const correo =
                document
                    .getElementById(
                        'login-correo'
                    )
                    .value
                    .trim()



            const password =
                document
                    .getElementById(
                        'login-password'
                    )
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






            if (
                !correoValido(correo)
            ) {


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





            liberarBoton(
                boton
            )





            if (
                !resultado.ok
            ) {


                mostrarMensaje(
                    mensaje,
                    mensajeDeError(
                        resultado.error
                    )
                )


                return

            }





            mostrarMensaje(
                mensaje,
                'Sesión iniciada. Redirigiendo...',
                'exito'
            )





            setTimeout(
                () => {

                    window.location.href =
                        'perfil.html'

                },
                800
            )



        }
    )



}






// ============================================================
// REDIRECCIÓN SI YA EXISTE SESIÓN
// ============================================================



async function redirigirSiYaTieneSesion() {


    const enPaginaPublica =
        document.getElementById(
            'formulario-login'
        ) ||
        document.getElementById(
            'formulario-registro'
        )



    if (!enPaginaPublica) return





    const haySesion =
        await verificarSesion()





    if (haySesion) {


        window.location.href =
            'perfil.html'


    }


}
// ============================================================
// PÁGINA: recuperar-contrasena.html
// ============================================================


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


            limpiarMensaje(
                mensaje
            )



            const correo =
                document
                    .getElementById(
                        'recuperacion-correo'
                    )
                    .value
                    .trim()





            if (
                campoVacio(correo)
            ) {


                mostrarMensaje(
                    mensaje,
                    'Ingresa tu correo.'
                )


                return

            }





            if (
                !correoValido(correo)
            ) {


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





            liberarBoton(
                boton
            )





            if (
                !resultado.ok
            ) {


                mostrarMensaje(
                    mensaje,
                    mensajeDeError(
                        resultado.error
                    )
                )


                return

            }





            mostrarMensaje(
                mensaje,
                'Si existe una cuenta asociada a ese correo, recibirás un enlace para cambiar tu contraseña.',
                'exito'
            )



            formulario.reset()



        }
    )


}









// ============================================================
// PÁGINA: actualizar-contrasena.html
// ============================================================


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


            limpiarMensaje(
                mensaje
            )





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





            if (
                password.length < 6
            ) {


                mostrarMensaje(
                    mensaje,
                    'La contraseña debe tener al menos 6 caracteres.'
                )


                return

            }





            if (
                password !== confirmarPassword
            ) {


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
                await actualizarContrasena(
                    password
                )





            liberarBoton(
                boton
            )





            if (
                !resultado.ok
            ) {


                mostrarMensaje(
                    mensaje,
                    mensajeDeError(
                        resultado.error
                    )
                )


                return

            }





            mostrarMensaje(
                mensaje,
                'Contraseña actualizada correctamente. Redirigiendo...',
                'exito'
            )





            setTimeout(
                () => {

                    window.location.href =
                        'iniciar-sesion.html'

                },
                1500
            )



        }
    )



}









// ============================================================
// PÁGINA: perfil.html
// ============================================================



function rellenarPerfil(perfil) {



    const camposTexto = {


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
        of Object.entries(camposTexto)
    ) {


        const elemento =
            document.getElementById(
                id
            )



        if (elemento) {


            elemento.textContent =
                valor || '—'


        }


    }







    const camposFormulario = {



        'perfil-nombres-editar':
            perfil.nombres,



        'perfil-apellidos-editar':
            perfil.apellidos,



        'perfil-telefono':
            perfil.telefono,



        'perfil-tipo-participante':
            perfil.tipo_participante,



        'perfil-codigo-matricula':
            perfil.codigo_matricula,



        'perfil-semestre':
            perfil.semestre,



        'perfil-detalle-tipo':
            perfil.detalle_tipo_participante



    }





    for (
        const [id, valor]
        of Object.entries(camposFormulario)
    ) {


        const elemento =
            document.getElementById(
                id
            )



        if (elemento) {


            elemento.value =
                valor || ''


        }


    }



}





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





    if (
        !resultado.ok
    ) {


        mostrarMensaje(
            mensaje,
            mensajeDeError(
                resultado.error
            )
        )


        return

    }





    rellenarPerfil(
        resultado.perfil
    )



    contenedor.hidden = false







    const selectorTipo =
        document.getElementById(
            'perfil-tipo-participante'
        )



    const camposEstudiante =
        document.getElementById(
            'perfil-campos-estudiante'
        )



    const camposOtro =
        document.getElementById(
            'perfil-campos-otro'
        )





    function actualizarCamposPerfil() {



        const estudiante =
            selectorTipo.value === 'ESTUDIANTE'





        camposEstudiante.hidden =
            !estudiante





        camposOtro.hidden =
            estudiante





    }






    if (selectorTipo) {


        selectorTipo.addEventListener(
            'change',
            actualizarCamposPerfil
        )


        actualizarCamposPerfil()

    }









    const formulario =
        document.getElementById(
            'formulario-perfil'
        )





    if (formulario) {



        formulario.addEventListener(
            'submit',
            async (evento) => {


                evento.preventDefault()


                limpiarMensaje(
                    mensaje
                )






                const nombres =
                    document
                        .getElementById(
                            'perfil-nombres-editar'
                        )
                        .value
                        .trim()




                const apellidos =
                    document
                        .getElementById(
                            'perfil-apellidos-editar'
                        )
                        .value
                        .trim()





                const telefono =
                    document
                        .getElementById(
                            'perfil-telefono'
                        )
                        .value
                        .trim()
                if (
                    !telefonoPeruValido(telefono)
                ) {

                    mostrarMensaje(
                    mensaje,
                    'El teléfono debe tener 9 dígitos y comenzar con 9.'
                    )


                    return

                }





                const tipoParticipante =
                    document
                        .getElementById(
                            'perfil-tipo-participante'
                        )
                        .value





                const codigoMatricula =
                    document
                        .getElementById(
                            'perfil-codigo-matricula'
                        )
                        .value
                        .trim()





                const semestre =
                    document
                        .getElementById(
                            'perfil-semestre'
                        )
                        .value





                const detalleTipo =
                    document
                        .getElementById(
                            'perfil-detalle-tipo'
                        )
                        .value
                        .trim()








                if (
                    tipoParticipante === 'ESTUDIANTE'
                ) {



                    if (
                        !codigoMatriculaValido(
                            codigoMatricula
                        )
                    ) {


                        mostrarMensaje(
                            mensaje,
                            'El código de matrícula debe tener 10 números y una letra final.'
                        )


                        return

                    }



                    if (
                        campoVacio(semestre)
                    ) {


                        mostrarMensaje(
                            mensaje,
                            'Selecciona tu semestre.'
                        )


                        return

                    }


                }








                if (
                    tipoParticipante === 'OTRO'
                    &&
                    campoVacio(detalleTipo)
                ) {


                    mostrarMensaje(
                        mensaje,
                        'Especifica tu tipo de participante.'
                    )


                    return

                }








                const boton =
                    document.getElementById(
                        'btn-guardar-perfil'
                    )





                bloquearBoton(
                    boton,
                    'Guardando...'
                )








                const cambios = {


                    nombres,


                    apellidos,


                    telefono,



                    tipo_participante:
                        tipoParticipante,



                    codigo_matricula:
                        tipoParticipante === 'ESTUDIANTE'
                            ? codigoMatricula
                            : null,



                    semestre:
                        tipoParticipante === 'ESTUDIANTE'
                            ? semestre
                            : null,



                    detalle_tipo_participante:
                        tipoParticipante === 'OTRO'
                            ? detalleTipo
                            : null


                }





                const respuesta =
                    await actualizarPerfil(
                        cambios
                    )





                liberarBoton(
                    boton
                )





                if (
                    !respuesta.ok
                ) {


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









    const botonCerrar =
        document.getElementById(
            'btn-cerrar-sesion'
        )




    if (botonCerrar) {



        botonCerrar.addEventListener(
            'click',
            async () => {


                bloquearBoton(
                    botonCerrar,
                    'Cerrando...'
                )



                await cerrarSesion()



                window.location.href =
                    'iniciar-sesion.html'


            }
        )


    }



}









// ============================================================
// INICIO DEL MÓDULO
// ============================================================



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