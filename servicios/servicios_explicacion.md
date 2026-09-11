## 3. Servicios

Carpeta:

servicios/

Contiene funciones centrales utilizadas por diferentes módulos.

### servicios/supabase.js

Será la única conexión del proyecto con Supabase.

Ningún otro módulo debe volver a configurar Supabase.

Todos los módulos que necesiten la base de datos utilizarán esta conexión.

### servicios/sesion.js

Contiene funciones relacionadas con el usuario conectado.

Ejemplos:

obtenerUsuarioActual()
verificarSesion()
cerrarSesion()

Los módulos no deben crear sus propias versiones de estas funciones.