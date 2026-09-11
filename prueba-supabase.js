import { supabase } from './servicios/supabase.js'

const resultado = document.getElementById('resultado')

function mostrar(data) {
    resultado.textContent = JSON.stringify(data, null, 2)
}

document
    .getElementById('btnLogin')
    .addEventListener('click', async () => {

        const email =
            document.getElementById('correo').value

        const password =
            document.getElementById('password').value

        const { data, error } =
            await supabase.auth.signInWithPassword({
                email,
                password
            })

        mostrar({
            data,
            error
        })
    })


document
    .getElementById('btnSesion')
    .addEventListener('click', async () => {

        const { data, error } =
            await supabase.auth.getUser()

        mostrar({
            data,
            error
        })
    })


document
    .getElementById('btnInscribir')
    .addEventListener('click', async () => {

        const EVENTO_GRATUITO =
            '10000000-0000-0000-0000-000000000001'

        const { data, error } =
            await supabase.rpc(
                'inscribirse_evento',
                {
                    p_evento_id: EVENTO_GRATUITO
                }
            )

        mostrar({
            data,
            error
        })
    })

document
    .getElementById('btnLogout')
    .addEventListener('click', async () => {

        const { error } = await supabase.auth.signOut()

        mostrar({
            mensaje: 'Sesión cerrada',
            error
        })
    })

document
    .getElementById('btnEventoPago')
    .addEventListener('click', async () => {

        const EVENTO_CON_PAGO =
            '10000000-0000-0000-0000-000000000002'

        const { data, error } =
            await supabase.rpc(
                'inscribirse_evento',
                {
                    p_evento_id: EVENTO_CON_PAGO
                }
            )

        mostrar({
            data,
            error
        })
    })

document
    .getElementById('btnQrPago')
    .addEventListener('click', async () => {

        const EVENTO_CON_PAGO =
            '10000000-0000-0000-0000-000000000002'

        const { data, error } =
            await supabase.rpc(
                'obtener_o_crear_qr',
                {
                    p_evento_id: EVENTO_CON_PAGO
                }
            )

        mostrar({
            data,
            error
        })
    })

document
    .getElementById('btnVerificarPago')
    .addEventListener('click', async () => {

        const INSCRIPCION_ID =
            'a1ac3d57-2f6d-4903-bd78-9f94a30372fb'

        const { data, error } =
            await supabase.rpc(
                'verificar_pago_evento',
                {
                    p_inscripcion_id: INSCRIPCION_ID,
                    p_aprobado: true,
                    p_referencia: 'PRUEBA-001'
                }
            )

        mostrar({
            data,
            error
        })
    })

document
    .getElementById('btnPonencia')
    .addEventListener('click', async () => {

        const PONENCIA =
            '30000000-0000-0000-0000-000000000001'

        const { data, error } =
            await supabase.rpc(
                'inscribirse_actividad',
                {
                    p_actividad_id: PONENCIA
                }
            )

        mostrar({
            data,
            error
        })
    })

const CONCURSO_EQUIPOS =
    '30000000-0000-0000-0000-000000000002'


// CREAR EQUIPO
document
    .getElementById('btnCrearEquipo')
    .addEventListener('click', async () => {

        const { data, error } =
            await supabase.rpc(
                'crear_equipo',
                {
                    p_actividad_id: CONCURSO_EQUIPOS,
                    p_nombre: 'Equipo Prueba 1'
                }
            )

        mostrar({
            data,
            error
        })
    })


// UNIRSE A EQUIPO
document
    .getElementById('btnUnirseEquipo')
    .addEventListener('click', async () => {

        const codigo =
            document.getElementById('codigoEquipo').value

        const { data, error } =
            await supabase.rpc(
                'unirse_equipo',
                {
                    p_codigo_invitacion: codigo
                }
            )

        mostrar({
            data,
            error
        })
    })


// INSCRIBIR EQUIPO AL CONCURSO
document
    .getElementById('btnInscribirEquipo')
    .addEventListener('click', async () => {

        const equipoId =
            document.getElementById('idEquipo').value

        const { data, error } =
            await supabase.rpc(
                'inscribir_equipo_actividad',
                {
                    p_equipo_id: equipoId
                }
            )

        mostrar({
            data,
            error
        })
    })

const EVENTO_GRATUITO =
    '10000000-0000-0000-0000-000000000001'

const PONENCIA_PRUEBA =
    '30000000-0000-0000-0000-000000000001'


// OBTENER QR DEL EVENTO GRATUITO
document
    .getElementById('btnQrGratuito')
    .addEventListener('click', async () => {

        const { data, error } =
            await supabase.rpc(
                'obtener_o_crear_qr',
                {
                    p_evento_id: EVENTO_GRATUITO
                }
            )

        mostrar({
            data,
            error
        })
    })


// ESCANEAR QR EN LA PONENCIA
document
    .getElementById('btnEscanearPonencia')
    .addEventListener('click', async () => {

        const token =
            document.getElementById('tokenQr').value

        const { data, error } =
            await supabase.rpc(
                'registrar_escaneo_qr',
                {
                    p_token: token,
                    p_actividad_id: PONENCIA_PRUEBA
                }
            )

        mostrar({
            data,
            error
        })
    })

const PONENCIA_V32 =
    '30000000-0000-0000-0000-000000000001'

const CURSO_SUELOS =
    '12000000-0000-0000-0000-000000000001'

const CURSO_VIAL =
    '12000000-0000-0000-0000-000000000002'


document
    .getElementById('btnCursoSuelos')
    .addEventListener('click', async () => {

        const { data, error } =
            await supabase.rpc(
                'seleccionar_curso_asistencia',
                {
                    p_actividad_id: PONENCIA_V32,
                    p_curso_id: CURSO_SUELOS
                }
            )

        mostrar({ data, error })
    })


document
    .getElementById('btnCursoVial')
    .addEventListener('click', async () => {

        const { data, error } =
            await supabase.rpc(
                'seleccionar_curso_asistencia',
                {
                    p_actividad_id: PONENCIA_V32,
                    p_curso_id: CURSO_VIAL
                }
            )

        mostrar({ data, error })
    })

const AUDITORIO_PRUEBA =
    '11000000-0000-0000-0000-000000000001'

const SALA_SECUNDARIA =
    '11000000-0000-0000-0000-000000000002'


document
    .getElementById('btnEscanearAuditorio')
    .addEventListener('click', async () => {

        const token =
            document.getElementById('tokenQrSala').value

        const { data, error } =
            await supabase.rpc(
                'registrar_escaneo_sala',
                {
                    p_token: token,
                    p_sala_id: AUDITORIO_PRUEBA
                }
            )

        mostrar({ data, error })
    })


document
    .getElementById('btnEscanearSala2')
    .addEventListener('click', async () => {

        const token =
            document.getElementById('tokenQrSala').value

        const { data, error } =
            await supabase.rpc(
                'registrar_escaneo_sala',
                {
                    p_token: token,
                    p_sala_id: SALA_SECUNDARIA
                }
            )

        mostrar({ data, error })
    })

document
    .getElementById('btnMiAsistencia')
    .addEventListener('click', async () => {

        const EVENTO =
            '10000000-0000-0000-0000-000000000001'

        const { data, error } =
            await supabase.rpc(
                'mi_asistencia_evento',
                {
                    p_evento_id: EVENTO
                }
            )

        mostrar({ data, error })
    })

const CURSO_SUELOS_REPORTE =
    '12000000-0000-0000-0000-000000000001'

const CURSO_VIAL_REPORTE =
    '12000000-0000-0000-0000-000000000002'

const PONENCIA_REPORTE =
    '30000000-0000-0000-0000-000000000001'


document
    .getElementById('btnReporteSuelos')
    .addEventListener('click', async () => {

        const { data, error } =
            await supabase.rpc(
                'reporte_asistencia_curso',
                {
                    p_curso_id: CURSO_SUELOS_REPORTE,
                    p_actividad_id: PONENCIA_REPORTE
                }
            )

        mostrar({ data, error })
    })


document
    .getElementById('btnReporteVial')
    .addEventListener('click', async () => {

        const { data, error } =
            await supabase.rpc(
                'reporte_asistencia_curso',
                {
                    p_curso_id: CURSO_VIAL_REPORTE,
                    p_actividad_id: PONENCIA_REPORTE
                }
            )

        mostrar({ data, error })
    })

async function descargarReporteExcel(
    cursoId,
    actividadId,
    nombreArchivo
) {

    const { data, error } =
        await supabase.rpc(
            'reporte_asistencia_curso',
            {
                p_curso_id: cursoId,
                p_actividad_id: actividadId
            }
        )

    if (error) {
        mostrar({
            data: null,
            error
        })
        return
    }

    const filas = data.map((registro, index) => ({
        "N°": index + 1,
        "Correo": registro.correo,
        "Participante": registro.participante,
        "Curso": registro.curso,
        "Docente": registro.docente,
        "Ponencia": registro.actividad,

        "Registró esta ponencia para el curso":
            registro.seleccionado_para_curso
                ? "Sí"
                : "No",

        "Primera entrada":
            registro.primera_entrada ?? "",

        "Última salida":
            registro.ultima_salida ?? "",

        "Minutos presentes":
            registro.minutos_presentes,

        "Porcentaje de asistencia":
            `${registro.porcentaje_presencia}%`,

        "Estado":
            registro.estado_academico
    }))

    const hoja =
        XLSX.utils.json_to_sheet(filas)

    const libro =
        XLSX.utils.book_new()

    XLSX.utils.book_append_sheet(
        libro,
        hoja,
        "Asistencia"
    )

    XLSX.writeFile(
        libro,
        nombreArchivo
    )
}

document
    .getElementById('btnExcelSuelos')
    .addEventListener('click', async () => {

        await descargarReporteExcel(
            '12000000-0000-0000-0000-000000000001',
            '30000000-0000-0000-0000-000000000001',
            'asistencia_mecanica_de_suelos.xlsx'
        )
    })


document
    .getElementById('btnExcelVial')
    .addEventListener('click', async () => {

        await descargarReporteExcel(
            '12000000-0000-0000-0000-000000000002',
            '30000000-0000-0000-0000-000000000001',
            'asistencia_diseno_vial.xlsx'
        )
    })