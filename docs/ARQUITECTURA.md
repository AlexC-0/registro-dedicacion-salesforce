# Arquitectura y guardado

## Componentes implementados

El modelo declarativo instalado en fase 1B se conserva. La fase 2A añade P07_DedicacionService, los triggers P07_SemanaGuard y P07_DedicacionGuard, dos permisos personalizados, dos Permission Sets sin asignaciones y P07_DedicacionServiceTest. El manifiesto [fase-2a.xml](../manifest/fase-2a.xml) contiene únicamente esos ocho miembros; no reinstala objetos, reglas, grupos ni los permisos anteriores.

Quedan pendientes la cuadrícula LWC, su borrador y pruebas Jest, el informe operativo y las sesiones funcionales. No hay Flow, Batch, programación, integraciones ni dependencias nuevas.

## Contrato del servicio

Dos métodos estáticos @AuraEnabled devuelven texto JSON. Se invocarán de forma imperativa; leerSemana no es cacheable porque obtiene un bloqueo transaccional. Se evita usar clases internas de Apex como parámetros o respuestas del futuro LWC. [Tipos admitidos por LWC](https://developer.salesforce.com/docs/platform/lwc/guide/apex-expose-method.html).

- leerSemana(String inicioSemana): lunes ISO AAAA-MM-DD. Identifica siempre al usuario conectado.
- guardarSemana(String peticionJson): objeto JSON con exactamente semana, revisionEsperada y cambios. Cada cambio contiene exactamente proyectoId, fecha y horas. No se admiten usuario, propietario, clave persistida, revisión nueva ni otros campos.

Ejemplo ilustrativo; PROYECTO_ID debe sustituirse por un identificador accesible del catálogo:

~~~json
{
  "semana": "2026-11-16",
  "revisionEsperada": "0",
  "cambios": [
    { "proyectoId": "PROYECTO_ID", "fecha": "2026-11-16", "horas": "1.25" }
  ]
}
~~~

Las horas son texto decimal con punto, sin signo, exponente, coma ni ceros iniciales; hasta dos decimales y múltiplos exactos de 0.25, entre 0 y 24. Se rechaza la precisión inválida antes de DML y sin redondear. Un número JSON, por ejemplo 1.25 sin comillas, se rechaza. La interfaz futura deberá convertir la presentación local al contrato; el servidor sigue validando la entrada original.

Una celda omitida se conserva. Cero, null o texto vacío/blanco solicitan eliminar una celda editable. Una petición no puede repetir proyecto y fecha, aunque utilice distintas representaciones de un mismo Id. Cada guardado admite 140 cambios y 20 proyectos distintos como máximo; son límites de petición, no del total de proyectos históricos de una semana. El texto completo no supera 60.000 caracteres.

La revisión es texto decimal entero no negativo, sin ceros iniciales, de hasta 18 dígitos. Así no depende de la precisión numérica de JavaScript. Una semana inexistente requiere revisión esperada "0". Una petición sin cambios efectivos comprueba permisos y revisión, pero no crea cabecera ni incrementa revisión.

Respuesta satisfactoria:

~~~json
{
  "ok": true,
  "estado": {
    "semana": "2026-11-16",
    "hoy": "2026-11-24",
    "revision": "1",
    "existe": true,
    "puedeGuardar": true,
    "proyectos": [],
    "entradas": [],
    "dias": [],
    "totalMinutos": 75
  },
  "errores": []
}
~~~

Las listas vacías del ejemplo abrevian la estructura: proyectos contiene id, nombre, codigo, activo y editable; entradas contiene proyectoId, fecha, minutos y editable; dias devuelve siete elementos con fecha, minutos y editable. La edición de una celda requiere permiso de guardado, proyecto activo y fecha no futura. Una semana sin cabecera devuelve existe=false, revision="0", entradas vacías y totales cero, sin crear registros.

El catálogo incluye los proyectos activos accesibles y los inactivos referenciados por esa semana. Si falta acceso a un proyecto histórico necesario, se rechaza la lectura completa sin revelar sus datos. El límite defensivo es de 1.000 proyectos devueltos y 700 líneas por semana; al superarlo se devuelve error, nunca un estado truncado. El máximo de líneas no vacías permitido por siete días de 1.440 minutos y cuartos de hora es 672.

Respuesta de error:

~~~json
{
  "ok": false,
  "estado": null,
  "errores": [{
    "codigo": "REVISION_DESACTUALIZADA",
    "mensaje": "La semana ha cambiado. Recarga antes de guardar.",
    "proyectoId": null,
    "fecha": null
  }]
}
~~~

Se devuelve el primer error detectado. Los códigos son VALIDACION, ACCESO_DENEGADO, REVISION_DESACTUALIZADA, CONFLICTO_CREACION, CONTENCION y FALLO_TECNICO. Proyecto y fecha se asocian cuando se conocen; el exceso agregado se asocia al día. Los errores de plataforma no exponen mensajes internos, consultas, trazas ni datos ajenos. Fallos de límites no capturables abortan la transacción por plataforma; no se promete un sobre JSON para toda interrupción posible.

## Autorización y escritura acotada

La clase declara with sharing. Se exige P07_Consultar y, al guardar, P07_GuardarPropia. Se comprueba Read del objeto y FLS de todos los campos consultados; las consultas usan explícitamente AccessLevel.USER_MODE. La cabecera se selecciona por clave canónica, Usuario__c y OwnerId del solicitante, incluso si este puede leer semanas compartidas.

Los Permission Sets existentes conservan solo lectura. Los nuevos permisos habilitan la clase y las operaciones, sin Create, Edit, Delete ni permisos de edición de campos. El DML interno utiliza SYSTEM_MODE deliberadamente para escribir el estado calculado de la semana propia. No recibe sObjects arbitrarios ni acepta identidades del cliente. Esta capacidad queda limitada por la autorización previa, los registros leídos en modo usuario y el contexto privado de los triggers. Se documentan las concesiones y pruebas negativas en [ACCESO.md](ACCESO.md).

La administración del catálogo permanece fuera del servicio. No se incorporan funciones para crear o editar proyectos.

## Transacción y concurrencia

1. Capturar Date.today() del solicitante una vez, validar forma, lunes, fechas y precisión.
2. Crear savepoint. Buscar y bloquear la cabecera propia existente con FOR UPDATE; releerla bajo ese bloqueo y comparar revisión. La lectura de semana usa el mismo bloqueo.
3. Leer todas sus líneas. Bloquear los proyectos modificados uno a uno, ordenados por Id; FOR UPDATE no admite ORDER BY. El límite de veinte proyectos mantiene acotadas las consultas. La cabecera existente se bloquea antes de los proyectos.
4. Construir el estado final, incluyendo celdas omitidas e histórico inactivo. Rechazar todo cambio dirigido a un proyecto inactivo, también cero o un valor idéntico. Verificar fechas e identidades y sumar hasta 1.440 minutos por día.
5. Si existen cambios efectivos y falta cabecera, crear la propia con identidad canónica y revisión cero. Aplicar bajas, modificaciones y altas; incrementar una sola vez la revisión. Releer y comprobar que el resumen almacenado coincide con las líneas antes de responder.
6. Ante un error capturable, rollback hasta el savepoint. Limpiar el contexto privado y liberar el savepoint al salir. No hay reintentos automáticos ni éxitos parciales.

La clave única impide dos cabeceras para usuario/lunes y dos líneas para semana/proyecto/fecha. El bloqueo no protege una fila inexistente: una carrera de creación se resuelve por esa unicidad y devuelve CONFLICTO_CREACION o CONTENCION si la plataforma informa tales condiciones, sin reintento ciego. La clasificación se prueba con códigos simulados; no se ha provocado una carrera real.

La revisión detecta peticiones basadas en una versión anterior. Repetir una petición confirmada con su revisión original produce conflicto sin otra modificación. El bloqueo serializa el trabajo sobre la cabecera existente e impide mezclar revisión, líneas y resumen entre guardados que respetan este protocolo. Una lectura que no encuentra cabecera puede devolver el estado vacío anterior a una creación concurrente.

Los proyectos modificados permanecen bloqueados para que una desactivación no se interponga entre su comprobación y el DML. La lectura del catálogo es una consulta separada; no se promete una instantánea global de toda la organización. Automatizaciones futuras que escriban estos objetos deberán revisar el orden de bloqueos. No se han ejecutado transacciones paralelas, una carrera de creación, una espera real de bloqueo ni cambios simultáneos del catálogo.

## Protección de rutas alternativas

Los triggers solo admiten las operaciones y valores previstos por el contexto privado del servicio. No existe un flag público ni un permiso de bypass. Sus métodos públicos de entrada comprueban Trigger.isExecuting y no habilitan el contexto.

- Cabecera: alta propia canónica; incremento de revisión previsto; actualización de resumen causada por los detalles del guardado. La identidad y el nombre permanecen inmutables.
- Detalles: altas, cambios de minutos y bajas exactamente previstas. Se conservan semana, proyecto, fecha, clave y nombre.
- DML directo de alta, edición o eliminación: denegado, también desde SYSTEM_MODE.
- Transferencia, reparentado, borrado de cabecera y su cascada: denegados. La relación conserva además su prohibición de reparentado.
- Restauraciones: denegadas mediante after undelete. Se prueba la restauración real de un detalle eliminado por el servicio; no se fabrica una cabecera borrada eludiendo la defensa para ensayar su restauración.

No hay ruta legítima para cambiar identidades o borrar cabeceras. Eliminar la última celda conserva la cabecera y su revisión. Los triggers permiten los cambios de resumen legítimos sin habilitar edición arbitraria de revisión o identidad.

## Prueba de rollback

Un punto privado @TestVisible solo provoca fallos cuando Test.isRunningTest() es verdadero; no desactiva controles. Observa el resumen y la revisión después de DML y lanza un error dentro del savepoint.

La prueba de alta observa 60 minutos después de crear cabecera y detalle, provoca el fallo y comprueba que ambos desaparecen. La prueba mixta parte de 90 minutos y revisión 1; elimina, modifica y crea líneas, observa 135 minutos y revisión 2, provoca el fallo y comprueba las líneas originales, 90 minutos y revisión 1. Un guardado posterior con revisión 1 vuelve a funcionar. El resultado remoto y la cobertura constan en [STATUS.md](STATUS.md).

## Borrador y resultado desconocido pendientes

El futuro LWC conservará por separado valores confirmados y cambios pendientes. Error o conflicto no sustituirán el borrador ni mostrarán éxito. Cambiar de semana exigirá resolver los cambios pendientes. Una pérdida de comunicación puede ocurrir después de confirmar en servidor: el cliente deberá mostrar incertidumbre y reconciliar mediante lectura, sin reenviar sobre una revisión nueva automáticamente.

No se ha implementado ni probado todavía esa interfaz, la pérdida de respuesta, la accesibilidad o el informe. Las pruebas Apex aisladas y secuenciales no sustituyen sesiones ordinarias ni concurrencia real. La relación con AC-01 a AC-25 figura en [ACEPTACION.md](ACEPTACION.md).
