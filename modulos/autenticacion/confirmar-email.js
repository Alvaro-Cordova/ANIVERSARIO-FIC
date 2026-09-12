import { supabase } from "../../servicios/supabase.js";


const mensaje = document.getElementById(
    "mensaje-confirmacion"
);


const botonLogin = document.getElementById(
    "btn-login"
);



async function verificarConfirmacion(){

    const { data, error } = await supabase.auth.getSession();


    if(error){

        mensaje.textContent =
        "Ocurrió un error al confirmar el correo.";

        return;
    }


    // Supabase crea una sesión automática al confirmar correo.
    // La cerramos para obligar al usuario a iniciar sesión manualmente.

    if(data.session){

        await supabase.auth.signOut();

    }


    mensaje.textContent =
    "Tu correo fue confirmado correctamente. Ya puedes iniciar sesión.";


}



botonLogin.addEventListener(
    "click",
    ()=>{

        window.location.href =
        "iniciar-sesion.html";

    }
);



verificarConfirmacion();