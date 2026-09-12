# GUÍA PARA DESARROLLAR CÓDIGO CON IA

## 1. Objetivo

Esta guía explica cómo debe trabajar cada desarrollador cuando utilice inteligencia artificial para crear o corregir código.

La meta es evitar código duplicado, cambios en carpetas ajenas, nuevas conexiones innecesarias a Supabase y errores difíciles de integrar.

Regla principal:

> Cada desarrollador trabaja principalmente dentro de su módulo y debe saber exactamente qué archivo está modificando antes de copiar código generado por IA.

## 2. Antes de pedir código a la IA

Antes de solicitar código, identificar:

1. Módulo asignado.
2. Carpeta del módulo.
3. Función que se quiere implementar.
4. Archivos y funciones que ya existen.
5. Archivos que no se deben modificar.
6. Que no debe duplicar código.
7. Que no debe crear una nueva conexión a Supabase.

Ejemplo:

```text
Módulo: Ponencias
Carpeta: modulos/ponencias/
Archivos: index.html, estilos.css, interfaz.js, datos.js, LEEME.md
Función: permitir que un usuario se inscriba a una ponencia.
```

No pedir solamente: “Hazme un sistema de ponencias completo”.

## 3. Prompt recomendado (instrucciones para la IA)

Estoy trabajando en una plataforma web creada con HTML, CSS, JavaScript y Supabase.

El proyecto está dividido en módulos.

Mi responsabilidad es únicamente el módulo:

[ESCRIBIR MODULO]

Mi carpeta es:

[ESCRIBIR RUTA]

Dentro de mi carpeta existen:

[ESCRIBIR ARCHIVOS]

REGLAS:

1. No modifiques otros módulos.
2. No crees una nueva conexión con Supabase.
3. La conexión ya existe en servicios/supabase.js.
4. Las funciones de sesión están en servicios/sesion.js.
5. No dupliques funciones.
6. Mantén HTML, CSS y JavaScript separados.
7. Si necesitas una función compartida por varios módulos, indícalo antes de crearla.
8. Antes de darme código, indícame exactamente en qué archivo debo colocarlo.
9. Si debes reemplazar código, dime qué parte debo reemplazar.
10. No cambies la estructura del proyecto sin indicármelo primero.
11. No uses service_role.
12. No desactives RLS.
13. No insertes directamente en tablas si existe una función RPC.
14. No modifiques funciones SQL existentes sin indicármelo primero.
15. Si la parte de diseño (modulos - informacion o compartido-codigo reutilizable) no tienen definido el diseño final que tendra toda la pagina, no hacer el archivo .css (hacer recordar al usuario). Cuando se haya comprobado que si existe un diseño, puedes hacer el apartado visual sin problemas. De todas maneras dejalo configurado ya para que cuando el diseño este listo, automaticamente el archivo css se actualice (de ser posible)

Quiero implementar lo siguiente: (mas informacion ver los LEEME.md de cada apartado de modulo)

[EXPLICAR FUNCIÓN] 

Antes de darme código:
1. dime qué archivo debo modificar;
2. dime si reemplazo o agrego código (si solo se modifica una parte del codigo, de preferencia reenviarlo de nuevo porque es molesto estar buscando donde exactamente se debe colocar);
3. utiliza únicamente las RPC documentadas en GUIA_CONEXION_SUPABASE_V3_2_1.md. (de ser necesario utilizar RPC no documentadas pero justificar el porque y avisar al desarrollador)
4. Indicame que si la instruccion que te di no se sale fuera de mis funciones como desarrollador, en caso lo haga, dime el porque no entra a mis funciones y como continuo avanzando solamente con mi parte para no desviarme.
5. En caso detectes que alguna parte de el codigo que te estoy pidiendo se pueda utilizar en la carpeta compartido-codigo reutilizable o en la carpeta recursos, añade instrucciones para colocarlos ahi, pero ya sabes que solamente hay codigo exclusivo que debe ir en cada carpeta y no se puede duplicar en otras. 

Y adjuntas todos los documentos NECESARIOS para que la IA pueda hacerlo con la mayor calidad posible y para evitar duplicados, confusiones, etc. (ADJUNTAR REPOSITORIO Y DECIRLE QUE LO LEA, LUEGO ADJUNTAR ESTE DOCUMENTO Y GUIA_CONEXION_SUPABASE_V3_2_1.md)

## 4. Dónde colocar cada tipo de código

### HTML

Va en archivos `.html`.

Contiene estructura visible: títulos, formularios, botones, tablas, tarjetas y campos.

No colocar consultas directas a Supabase ni grandes bloques de JavaScript.

### CSS

Va en `estilos.css`.

Contiene diseño exclusivo del módulo.

Si un estilo se usa en varios módulos, debe evaluarse moverlo a `compartido/estilos/`.

### interfaz.js

Controla lo que sucede en pantalla:

- clics;
- mensajes;
- mostrar u ocultar elementos;
- llenar tablas;
- actualizar elementos visuales.

No debe configurar Supabase.

### datos.js

Contiene las funciones para leer, guardar, modificar o eliminar datos del módulo.

Debe utilizar la conexión existente en:

```text
servicios/supabase.js
```

### LEEME.md

Explica qué debe hacer el módulo, sus dependencias y sus límites.

No contiene código funcional de la aplicación.

## 5. Diferencia entre carpetas

### recursos/

Archivos que no son código:

- logos;
- fotografías;
- iconos;
- PDFs;
- documentos.

### compartido/

Código que usan dos o más módulos:

- componentes;
- validaciones;
- funciones de fechas;
- estilos comunes.

### servicios/

Funciones centrales del sistema:

- conexión a Supabase;
- sesión del usuario.

### modulos/

Código específico de cada parte de la plataforma.

## 6. Cómo probar el código

Todo desarrollador debe probar antes de hacer Commit.

Flujo:

```text
Crear función
↓
Guardar archivos
↓
Ejecutar página
↓
Probar
↓
Revisar errores
↓
Corregir
↓
Volver a probar
↓
Commit
```

## 7. Ejecutar la página

Se recomienda utilizar la extensión **Live Server** en Visual Studio Code.

Pasos:

1. Abrir el archivo HTML.
2. Clic derecho.
3. Elegir `Open with Live Server`.
4. Probar en el navegador.

Para módulos JavaScript y Supabase, usar Live Server es preferible a abrir el HTML con doble clic.

## 8. Revisar errores

En Chrome o Edge:

1. Abrir la página.
2. Presionar `F12`.
3. Abrir `Console / Consola`.

Si aparece un error en rojo, copiarlo y entregarlo a la IA junto con el archivo relacionado.

Ejemplo:

```text
Estoy probando modulos/ponencias/interfaz.js.

Aparece este error:
[PEGAR ERROR]

Este es mi código actual:
[PEGAR CÓDIGO]

Explícame el error y dime exactamente qué debo cambiar.
No modifiques otros módulos.
```

## 9. Probar por partes

No desarrollar todo el módulo y probar al final.

Ejemplo en Ponencias:

1. ¿Se muestran las ponencias?
2. ¿El botón funciona?
3. ¿Reconoce al usuario?
4. ¿Guarda la inscripción?
5. ¿Evita duplicados?
6. ¿Actualiza los cupos?

Corregir una etapa antes de continuar.

## 10. Usar datos de prueba

Si otro módulo todavía no está listo, se pueden usar datos ficticios.

```javascript
const usuarioPrueba = {
    id: "usuario-prueba-01",
    nombre: "Usuario de prueba"
};
```

Cuando la dependencia real esté lista, sustituir esos datos por información real de Supabase.

No dejar datos ficticios en la versión final.

## 11. Dependencias entre módulos

Que un módulo dependa de otro no significa que tenga que quedarse detenido.

Ejemplo: Ponencias depende de Login.

Mientras Login no esté listo puede desarrollar:

- diseño;
- botones;
- tarjetas;
- formularios;
- datos ficticios.

Cuando Login esté listo, se reemplazan los datos de prueba por `servicios/sesion.js`.

Lo mismo aplica a Certificados respecto a Asistencia.

## 12. Prueba y error con IA

La primera respuesta de una IA no debe asumirse como correcta.

Proceso:

```text
Pedir código
↓
Revisar archivo destino
↓
Copiar solo lo necesario
↓
Guardar
↓
Probar
↓
Revisar consola
↓
Corregir con IA
↓
Volver a probar
```

Repetir hasta obtener una versión estable.

## 13. Si la IA pide modificar otro módulo

No aceptar inmediatamente.

Consultar al responsable o preguntar a la IA:

```text
¿Se puede implementar sin modificar directamente ese módulo, usando servicios/sesion.js, servicios/supabase.js o una función compartida?
```

## 14. Evitar duplicados

Si dos módulos necesitan la misma función, no copiarla.

Ejemplo:

```text
formatearFecha()
```

Si la necesitan Ponencias y Concursos, informar a los responsables de arquitectura para evaluar moverla a:

```text
compartido/utilidades/fechas.js
```

## 15. Lista antes de hacer Commit

```text
[ ] Guardé todos los archivos.
[ ] Probé la función.
[ ] Revisé la consola.
[ ] No hay errores graves conocidos.
[ ] No modifiqué carpetas ajenas sin coordinación.
[ ] No dupliqué funciones.
[ ] No agregué claves privadas ni contraseñas.
[ ] Sé exactamente qué cambios voy a guardar.
```

Solo después pasar al proceso de Git. (VER ARCHIVO GUIA_GIT_GITHUB_VSCODE.md)
