# CAMBIOS V3.1

Esta revisión se hizo específicamente antes de instalar la base en Supabase.

Se corrigieron tres casos operativos que todavía podían causar problemas:

1. **Usuarios desactivados**
   - `perfiles.activo = false` ahora bloquea operaciones del participante.
   - Un QR emitido anteriormente deja de servir para registrar asistencia.

2. **Equipos cancelados**
   - Al cancelar un equipo, su inscripción pasa a `cancelado`.
   - Sus miembros se liberan para poder crear o unirse a otro equipo de la misma actividad.

3. **Reinscripción después de cancelación**
   - Si una inscripción con pago se cancela y luego se vuelve a iniciar,
     se limpian la referencia y los datos anteriores de verificación de pago.

Además, el QR solo puede obtenerse/regenerarse cuando el evento continúa
en estado `publicado`, y el escáner solo registra actividades/eventos
publicados.

Estado:

```text
V3.1 = CANDIDATA PARA PRUEBAS EN SUPABASE
```
