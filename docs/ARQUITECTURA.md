# Arquitectura y guardado

## Componentes previstos

- LWC para selección de semana, cuadrícula, borrador y presentación de errores.
- Servicio Apex de lectura y guardado, con autorización y validación en servidor.
- Modelo declarativo con claves únicas, relaciones y restricciones locales.
- Protección de invariantes en las rutas de escritura habilitadas.
- Consulta de coordinación e informe operativo respetando acceso a registros y campos.

No hay componentes implementados en esta entrega. No se añaden Flow, Batch Apex, programación ni servicios externos.

## Contrato de escritura

El cliente envía la semana seleccionada, revisión esperada y cambios explícitos de celdas. No envía una revisión nueva ni decide usuario, propietario o claves persistidas. Una celda omitida se conserva; una celda modificada a cero o vacío solicita eliminación.

El servidor debe realizar, en una única transacción:

1. Identificar al solicitante y comprobar permisos y semana.
2. Localizar la cabecera; resolver de forma controlada una creación simultánea apoyándose en su clave única.
3. Bloquear la cabecera existente y comparar la revisión esperada con la persistida.
4. Releer datos y proyectos necesarios para construir el estado final de la semana.
5. Validar propiedad, acceso, proyecto activo, fechas, incrementos, identidades y suma diaria.
6. Aplicar altas, cambios y bajas con semántica de todo o nada; incrementar la revisión una vez si hay un cambio persistido.
7. Devolver el estado canónico confirmado y la revisión resultante.

Un bloqueo de fila no protege por sí solo una cabecera todavía inexistente. La creación simultánea necesita una respuesta de conflicto controlada sin perder el borrador ni duplicar semanas.

No se realizarán reintentos automáticos que apliquen cambios sobre otra revisión. Un guardado sin cambios no necesita incrementar la revisión, pero tampoco elude autorización ni la comprobación de revisión.

## Rutas alternativas

Validar solo el método llamado por el LWC no satisface el alcance. Al implementar habrá que inventariar las rutas habilitadas, impedir las que eludan el protocolo de guardado y proteger las invariantes persistentes también frente a DML por API u otras superficies accesibles.

La revisión se debe actualizar ante toda modificación autorizada de dedicación. No se permitirá su edición arbitraria. Las operaciones de borrar, restaurar, reparentar o transferir deben evaluarse expresamente; una ruta no necesaria puede quedar denegada en V1.

La activación de proyectos y su edición concurrente con un guardado necesitan un orden de bloqueos consistente. No se afirmará cobertura de concurrencia a partir de ejecuciones consecutivas.

## Borrador y errores

El LWC conserva por separado valores confirmados y cambios pendientes. Una respuesta fallida no sustituye el borrador ni muestra el guardado como correcto. Los errores distinguen validación, acceso, revisión desactualizada y fallo técnico sin revelar información de registros ajenos.

Al cambiar de semana con modificaciones pendientes debe ofrecerse conservar la selección actual o descartar explícitamente el borrador. Un conflicto permite revisar el estado vigente antes de volver a aplicar cambios; no fusiona datos silenciosamente.

## Pruebas previstas

Pruebas Apex para invariantes y transacciones; Jest para borrador, conversiones, errores y conflictos; recorridos funcionales con identidades ordinarias y prueba negativa fuera del ámbito. La compilación de Salesforce, las pruebas unitarias y la evidencia funcional se registrarán por separado.
