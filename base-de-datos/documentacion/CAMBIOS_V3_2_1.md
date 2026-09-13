# CAMBIOS V3.2.1

## Autoemisión de certificados

La V3.2.1 permite que un participante genere su propio certificado cuando
la base de datos confirma que cumple los requisitos.

El administrador mantiene la emisión manual como respaldo.

## Flujo

```text
Participante
↓
Mi asistencia
↓
mi_elegibilidad_certificado(evento)
↓
¿cumple?
├── No -> se informa porcentaje actual y requerido
└── Sí -> emitir_mi_certificado(evento)
             ↓
         CERT-XXXXXXXXXXXX
```

## Regla de elegibilidad

Solo se consideran actividades que tengan simultáneamente:

```text
cuenta_para_certificado = true
controla_asistencia = true
estado = publicado o finalizado
sala y horario válidos
```

El porcentaje se pondera por duración:

```text
minutos presentes
------------------ x 100
minutos programados
```

Todas las actividades que cuentan para certificado deben haber terminado antes
de habilitar la autoemisión.

El mínimo se toma de:

```text
eventos.porcentaje_minimo_certificado
```

Por tanto cada evento puede tener un mínimo distinto sin modificar código.

## Seguridad

El participante:

- solo puede emitir su propio certificado;
- debe tener cuenta activa;
- debe estar correctamente inscrito al evento;
- debe tener nombres y apellidos completos;
- debe alcanzar el porcentaje mínimo;
- no puede insertar directamente en `certificados`;
- no puede generar certificados para otros usuarios.

La función de autoemisión es:

```text
emitir_mi_certificado(evento_id)
```

La emisión manual administrativa se mantiene:

```text
emitir_certificado_manual(...)
```

## Duplicados

Pulsar varias veces `Generar mi certificado` no crea certificados duplicados.
Si ya existe uno emitido, se devuelve el mismo código.

## Auditoría

Se agregan snapshots:

```text
origen_emision
porcentaje_asistencia
porcentaje_requerido
```

`origen_emision` puede ser:

```text
automatico_usuario
manual_admin
```

Esto permite conocer cómo se emitió cada certificado y cuál fue el criterio
de asistencia aplicado en ese momento.

## Consideración de configuración

Las actividades marcadas `cuenta_para_certificado = true` deben representar
el itinerario que realmente se exige para el certificado.

Si existen ponencias paralelas incompatibles entre sí, no conviene marcar todas
como obligatorias para el mismo certificado sin definir previamente una regla
por rutas o grupos. Esa lógica de tracks no forma parte de V3.2.1.
