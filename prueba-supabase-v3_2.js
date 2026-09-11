import { supabase } from './servicios/supabase.js'

// ============================================================
// IDs FIJOS DE LOS DATOS DE PRUEBA V3.2
// ============================================================
const EVENTO_GRATUITO = '10000000-0000-0000-0000-000000000001'
const EVENTO_CON_PAGO = '10000000-0000-0000-0000-000000000002'
const PONENCIA_PRUEBA = '30000000-0000-0000-0000-000000000001'
const CONCURSO_EQUIPOS = '30000000-0000-0000-0000-000000000002'
const AUDITORIO_PRUEBA = '11000000-0000-0000-0000-000000000001'
const SALA_SECUNDARIA = '11000000-0000-0000-0000-000000000002'
const CURSO_SUELOS = '12000000-0000-0000-0000-000000000001'
const CURSO_VIAL = '12000000-0000-0000-0000-000000000002'

const resultado = document.getElementById('resultado')

function mostrar(data) {
    resultado.textContent = JSON.stringify(data, null, 2)
}

function mostrarError(error) {
    mostrar({
        data: null,
        error: error
            ? {
                code: error.code ?? null,
                message: error.message ?? String(error),
                details: error.details ?? null,
                hint: error.hint ?? null
            }
            : null
    })
}

async function ejecutarRpc(nombre, parametros = {}) {
    const { data, error } = await supabase.rpc(nombre, parametros)

    if (error) {
        mostrarError(error)
        return { data: null, error }
    }

    mostrar({ data, error: null })
    return { data, error: null }
}

// ============================================================
// 1. AUTENTICACIÓN
// ============================================================
document.getElementById('btnLogin').addEventListener('click', async () => {
    const email = document.getElementById('correo').value.trim()
    const password = document.getElementById('password').value

    const { data, error } = await supabase.auth.signInWithPassword({ email, password })

    if (error) {
        mostrarError(error)
        return
    }

    mostrar({
        data: {
            id: data.user?.id ?? null,
            email: data.user?.email ?? null,
            role: data.user?.role ?? null,
            sesion_activa: Boolean(data.session)
        },
        error: null
    })
})

document.getElementById('btnLogout').addEventListener('click', async () => {
    const { error } = await supabase.auth.signOut()

    if (error) {
        mostrarError(error)
        return
    }

    mostrar({ data: { mensaje: 'Sesión cerrada correctamente.' }, error: null })
})

document.getElementById('btnSesion').addEventListener('click', async () => {
    const { data, error } = await supabase.auth.getUser()

    if (error) {
        mostrarError(error)
        return
    }

    mostrar({
        data: {
            id: data.user?.id ?? null,
            email: data.user?.email ?? null
        },
        error: null
    })
})

// ============================================================
// 2. INSCRIPCIÓN GENERAL
// ============================================================
document.getElementById('btnEventoGratuito').addEventListener('click', async () => {
    await ejecutarRpc('inscribirse_evento', { p_evento_id: EVENTO_GRATUITO })
})

document.getElementById('btnEventoPago').addEventListener('click', async () => {
    await ejecutarRpc('inscribirse_evento', { p_evento_id: EVENTO_CON_PAGO })
})

document.getElementById('btnVerificarPago').addEventListener('click', async () => {
    const inscripcionId = document.getElementById('idInscripcionPago').value.trim()
    const referencia = document.getElementById('referenciaPago').value.trim()

    if (!inscripcionId) {
        mostrar({ data: null, error: { message: 'Debes pegar el ID de la inscripción.' } })
        return
    }

    await ejecutarRpc('verificar_pago_evento', {
        p_inscripcion_id: inscripcionId,
        p_aprobado: true,
        p_referencia: referencia || null
    })
})

// ============================================================
// 3. PONENCIAS
// ============================================================
document.getElementById('btnPonencia').addEventListener('click', async () => {
    await ejecutarRpc('inscribirse_actividad', { p_actividad_id: PONENCIA_PRUEBA })
})

// ============================================================
// 4. EQUIPOS
// ============================================================
document.getElementById('btnCrearEquipo').addEventListener('click', async () => {
    const nombre = document.getElementById('nombreEquipo').value.trim()

    if (!nombre) {
        mostrar({ data: null, error: { message: 'Debes indicar un nombre para el equipo.' } })
        return
    }

    const { data, error } = await ejecutarRpc('crear_equipo', {
        p_actividad_id: CONCURSO_EQUIPOS,
        p_nombre: nombre
    })

    if (!error && data?.equipo_id) {
        document.getElementById('idEquipo').value = data.equipo_id
    }

    if (!error && data?.codigo_invitacion) {
        document.getElementById('codigoEquipo').value = data.codigo_invitacion
    }
})

document.getElementById('btnUnirseEquipo').addEventListener('click', async () => {
    const codigo = document.getElementById('codigoEquipo').value.trim()

    if (!codigo) {
        mostrar({ data: null, error: { message: 'Debes pegar el código de invitación.' } })
        return
    }

    await ejecutarRpc('unirse_equipo', { p_codigo_invitacion: codigo })
})

document.getElementById('btnInscribirEquipo').addEventListener('click', async () => {
    const equipoId = document.getElementById('idEquipo').value.trim()

    if (!equipoId) {
        mostrar({ data: null, error: { message: 'Debes pegar el ID del equipo.' } })
        return
    }

    await ejecutarRpc('inscribir_equipo_actividad', { p_equipo_id: equipoId })
})

// ============================================================
// 5. QR
// ============================================================
document.getElementById('btnQrGratuito').addEventListener('click', async () => {
    const { data, error } = await ejecutarRpc('obtener_o_crear_qr', {
        p_evento_id: EVENTO_GRATUITO
    })

    if (!error && data) {
        document.getElementById('tokenQrSala').value = data
    }
})

document.getElementById('btnQrPago').addEventListener('click', async () => {
    const { data, error } = await ejecutarRpc('obtener_o_crear_qr', {
        p_evento_id: EVENTO_CON_PAGO
    })

    if (!error && data) {
        document.getElementById('tokenQrSala').value = data
    }
})

document.getElementById('btnRegenerarQrGratuito').addEventListener('click', async () => {
    const { data, error } = await ejecutarRpc('regenerar_qr', {
        p_evento_id: EVENTO_GRATUITO
    })

    if (!error && data) {
        document.getElementById('tokenQrSala').value = data
    }
})

// ============================================================
// 6. CURSOS
// ============================================================
document.getElementById('btnAgregarCursoSuelos').addEventListener('click', async () => {
    await ejecutarRpc('agregar_mi_curso', { p_curso_id: CURSO_SUELOS })
})

document.getElementById('btnAgregarCursoVial').addEventListener('click', async () => {
    await ejecutarRpc('agregar_mi_curso', { p_curso_id: CURSO_VIAL })
})

document.getElementById('btnCursoSuelos').addEventListener('click', async () => {
    await ejecutarRpc('seleccionar_curso_asistencia', {
        p_actividad_id: PONENCIA_PRUEBA,
        p_curso_id: CURSO_SUELOS
    })
})

document.getElementById('btnCursoVial').addEventListener('click', async () => {
    await ejecutarRpc('seleccionar_curso_asistencia', {
        p_actividad_id: PONENCIA_PRUEBA,
        p_curso_id: CURSO_VIAL
    })
})

// ============================================================
// 7. PRESENCIA POR SALA V3.2
// ============================================================
document.getElementById('btnEscanearAuditorio').addEventListener('click', async () => {
    const token = document.getElementById('tokenQrSala').value.trim()

    if (!token) {
        mostrar({ data: null, error: { message: 'Debes pegar el token QR del participante.' } })
        return
    }

    await ejecutarRpc('registrar_escaneo_sala', {
        p_token: token,
        p_sala_id: AUDITORIO_PRUEBA
    })
})

document.getElementById('btnEscanearSala2').addEventListener('click', async () => {
    const token = document.getElementById('tokenQrSala').value.trim()

    if (!token) {
        mostrar({ data: null, error: { message: 'Debes pegar el token QR del participante.' } })
        return
    }

    await ejecutarRpc('registrar_escaneo_sala', {
        p_token: token,
        p_sala_id: SALA_SECUNDARIA
    })
})

// ============================================================
// 8. MI ASISTENCIA
// ============================================================
document.getElementById('btnMiAsistencia').addEventListener('click', async () => {
    await ejecutarRpc('mi_asistencia_evento', { p_evento_id: EVENTO_GRATUITO })
})

// ============================================================
// 9. REPORTES
// ============================================================
async function obtenerReporteCurso(cursoId) {
    const { data, error } = await supabase.rpc('reporte_asistencia_curso', {
        p_curso_id: cursoId,
        p_actividad_id: PONENCIA_PRUEBA
    })

    return { data, error }
}

document.getElementById('btnReporteSuelos').addEventListener('click', async () => {
    const { data, error } = await obtenerReporteCurso(CURSO_SUELOS)

    if (error) {
        mostrarError(error)
        return
    }

    mostrar({ data, error: null })
})

document.getElementById('btnReporteVial').addEventListener('click', async () => {
    const { data, error } = await obtenerReporteCurso(CURSO_VIAL)

    if (error) {
        mostrarError(error)
        return
    }

    mostrar({ data, error: null })
})

// ============================================================
// 10. EXPORTACIÓN XLSX
// ============================================================
async function descargarReporteExcel(cursoId, nombreArchivo) {
    const { data, error } = await obtenerReporteCurso(cursoId)

    if (error) {
        mostrarError(error)
        return
    }

    if (!Array.isArray(data)) {
        mostrar({ data: null, error: { message: 'El reporte no devolvió una lista válida.' } })
        return
    }

    const filas = data.map((registro, index) => ({
        'N°': index + 1,
        'Correo': registro.correo ?? '',
        'Participante': registro.participante ?? '',
        'Curso': registro.curso ?? '',
        'Docente': registro.docente ?? '',
        'Ponencia': registro.actividad ?? '',
        'Registró esta ponencia para el curso': registro.seleccionado_para_curso ? 'Sí' : 'No',
        'Primera entrada': registro.primera_entrada ?? '',
        'Última salida': registro.ultima_salida ?? '',
        'Minutos presentes': registro.minutos_presentes ?? 0,
        'Porcentaje de asistencia': `${registro.porcentaje_presencia ?? 0}%`,
        'Estado': registro.estado_academico ?? ''
    }))

    if (!window.XLSX) {
        mostrar({ data: null, error: { message: 'La librería XLSX no se cargó correctamente.' } })
        return
    }

    const hoja = window.XLSX.utils.json_to_sheet(filas)
    const libro = window.XLSX.utils.book_new()

    window.XLSX.utils.book_append_sheet(libro, hoja, 'Asistencia')
    window.XLSX.writeFile(libro, nombreArchivo)

    mostrar({
        data: {
            mensaje: 'Excel generado correctamente.',
            archivo: nombreArchivo,
            filas: filas.length
        },
        error: null
    })
}

document.getElementById('btnExcelSuelos').addEventListener('click', async () => {
    await descargarReporteExcel(CURSO_SUELOS, 'asistencia_mecanica_de_suelos.xlsx')
})

document.getElementById('btnExcelVial').addEventListener('click', async () => {
    await descargarReporteExcel(CURSO_VIAL, 'asistencia_diseno_vial.xlsx')
})
