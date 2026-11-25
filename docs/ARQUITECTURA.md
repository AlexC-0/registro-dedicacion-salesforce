# Arquitectura y guardado

## Componentes implementados

El modelo declarativo instalado en fase 1B se conserva. La fase 2A añade P07_DedicacionService, los triggers P07_SemanaGuard y P07_DedicacionGuard, dos permisos personalizados, dos Permission Sets sin asignaciones y P07_DedicacionServiceTest. El manifiesto [fase-2a.xml](../manifest/fase-2a.xml) contiene únicamente esos ocho miembros; no reinstala objetos, reglas, grupos ni los permisos anteriores.

Fase 3A incorpora p07DedicacionSemanal, su borrador y pruebas Jest. Quedan pendientes el informe y las sesiones funcionales. No hay Flow, Batch, programación ni integraciones. La única dependencia directa nueva es de desarrollo para las pruebas locales.

## Contrato del servicio

Dos métodos estáticos @AuraEnabled devuelven texto JSON. El LWC los invoca de forma imperativa; leerSemana no es cacheable porque obtiene un bloqueo transaccional. Se evita usar clases internas de Apex como parámetros o respuestas del LWC. [Tipos admitidos por LWC](https://developer.salesforce.com/docs/platform/lwc/guide/apex-expose-method.html).

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

Las horas son texto decimal con punto, sin signo, exponente, coma ni ceros iniciales; hasta dos decimales y múltiplos exactos de 0.25, entre 0 y 24. Se rechaza la precisión inválida antes de DML y sin redondear. Un número JSON, por ejemplo 1.25 sin comillas, se rechaza. La interfaz convierte coma decimal válida al contrato con punto; el servidor sigue validando la entrada original.

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

## Borrador y resultado desconocido

Una pérdida de comunicación puede ocurrir después de confirmar en servidor. El cliente conserva los cambios y exige reconciliación sin reenvío automático. Fase 3A implementa el contrato siguiente y lo prueba con dependencias simuladas; las sesiones integradas y la concurrencia real siguen pendientes en [ACEPTACION.md](ACEPTACION.md).

## Cuadrícula y estado de fase 3A

p07DedicacionSemanal es un único bundle expuesto en lightning__AppPage, API 65.0. El módulo local modelo.js contiene calendario, análisis de cantidades, validación de respuestas, totales y petición; no es una biblioteca externa. El componente utiliza componentes base Lightning, tabla semántica y SLDS. No añade una vista de coordinación.

La carga muestra todas las filas con dedicación persistida, incluido el histórico inactivo. El catálogo activo accesible se ofrece en un selector; no se convierte en cientos de filas vacías. Quitar fila solo retira una fila vacía sin registros ni cambios. Eliminar dedicación exige vaciar celdas o introducir cero y guardar el conjunto.

Se separan confirmado, borrador y estado de petición. El borrador guarda texto por proyecto/fecha y nunca modifica el estado confirmado. Volver al valor original retira el cambio; la omisión conserva el dato y el vacío se envía como eliminación explícita. Coma o punto decimal se admiten únicamente en formatos no ambiguos y cuartos de hora exactos. El texto inválido se conserva para corregirlo.

Los totales por fila, día y semana incorporan las líneas omitidas e inactivas. Se etiquetan como provisionales cuando hay cambios; una cantidad inválida hace indeterminado el total de su fila, día y semana, en lugar de presentar una cifra exacta. La validación local comprueba editabilidad, límite diario y límites del conjunto de 140 celdas, veinte proyectos y 60.000 caracteres. No divide el guardado en varias transacciones.

La semana inicial usa @salesforce/i18n/timeZone y el reloj del cliente convertido a esa zona. La primera respuesta corrige la semana si hoy del servidor difiere. Después, hoy y las banderas de edición devueltas por Apex determinan los días editables. Las fechas ISO se descomponen como calendario; la aritmética y presentación fijan UTC sobre componentes numéricos, sin interpretar una fecha civil como un instante en la zona del navegador. [Zona horaria del usuario](https://developer.salesforce.com/docs/platform/lwc/guide/create-i18n.html).

## Peticiones y recuperación del cliente

Guardar genera una única llamada imperativa con semana, revisionEsperada textual y cambios explícitos. Mientras está en vuelo se bloquean edición, navegación, descarte y doble envío. La respuesta debe ser texto JSON con un sobre válido. También se contrastan semana, revisión textual, fechas, catálogo sin duplicados, líneas y totales coherentes. Una confirmación debe cambiar la revisión e incluir los valores enviados; de lo contrario se considera resultado desconocido y se conserva el borrador.

Un contador de peticiones invalida respuestas de lecturas anteriores y respuestas posteriores a desconectar el componente. La navegación sin cambios puede iniciar otra lectura mientras la anterior sigue pendiente. Solo la respuesta vigente puede adoptar estado o mostrar errores. Las lecturas fallidas no se presentan como una semana vacía confirmada.

Los errores del servidor se muestran por celda, día o conjunto, con contexto de proyecto y fecha cuando existe. En una respuesta de guardado, ok=false conserva el borrador aunque la promesa se haya resuelto. CONTENCION informa del fallo y permite un nuevo intento manual, sin reintentos automáticos.

REVISION_DESACTUALIZADA y CONFLICTO_CREACION bloquean otro guardado hasta consultar el estado actual. La comparación muestra valor anterior, cambio solicitado y valor actual para cada celda del borrador original. Ninguna casilla está seleccionada por defecto. Incorporar selección al borrador adopta la revisión actual y conserva solo las celdas elegidas que siguen editables; no guarda automáticamente ni modifica celdas ajenas al borrador original. Proyectos desactivados, permisos retirados o fechas no editables impiden reaplicar esas celdas. Los cambios no seleccionados se descartan mediante esa acción explícita, advertida junto al control.

Un rechazo de transporte o una respuesta de guardado inválida se trata como resultado desconocido. Se exige lectura de reconciliación antes de permitir otro guardado. Si falla esa lectura, persisten incertidumbre y borrador. Si los valores solicitados ya están presentes, se informa de esa coincidencia sin atribuirla a una petición concreta. Adoptar el estado actual y descartar el borrador exige confirmación.

Cambiar de semana, actualizar o descartar con cambios pendientes abre LightningConfirm. Cancelar conserva borrador y texto visible, sin iniciar una lectura. Aceptar el descarte limpia ambos antes de consultar: un rechazo de transporte o una respuesta ok=false no recupera el texto descartado. Si sigue visible la misma semana, sus celdas y totales proceden del estado previamente confirmado, con el error de lectura presente. El texto transitorio necesario para escribir decimales carácter a carácter se conserva mientras se edita; no se confunde con un cambio significativo pendiente. No se utiliza almacenamiento persistente del navegador: cerrar o recargar puede perder el borrador, como indica la interfaz.

## Accesibilidad y límites de verificación

La tabla tiene caption y encabezados de fila/columna. Cada entrada identifica proyecto y fecha; los controles base admiten teclado. La región horizontal es enfocable. Estado y errores se anuncian con status/alert y texto, sin depender exclusivamente del color. El foco pasa al resumen ante errores y a la comparación al recuperar datos; el diálogo base gestiona su interacción modal.

Jest comprueba estructura, etiquetas y decisiones de foco en DOM simulado. Los componentes base, Apex, zona horaria y confirmación están simulados. No se atribuye accesibilidad completa, interacción real de esos controles, seguridad efectiva ni transacciones a estas pruebas. La demostración con identidades funcionales, teclado, lector de pantalla, tamaños de ventana y servicio real queda para la siguiente entrega.


## Contrato de consulta operativa de fase 4B

Servicio independiente P07_InformeService.consultar(String peticionJson), API 65.0 y solo lectura. Entrada JSON con exactamente desde y hasta, ambos lunes ISO AAAA-MM-DD y desde <= hasta. Para una semana se repite el lunes. No admite identidad, objetos, campos o criterios arbitrarios. No se impone una duración máxima del intervalo; sí capacidad explícita de 1.000 líneas visibles.

Respuesta JSON: ok, resultado y errores. En éxito, resultado contiene desde, hasta, completo=true, limiteLineas=1000, numeroLineas, totalMinutos y semanas. Cada semana contiene inicio, totalMinutos y miembros; cada miembro, id, nombre, totalMinutos y proyectos; cada proyecto, id, nombre, codigo, activo, totalMinutos y detalle; cada detalle contiene id, fecha y minutos. Todos los totales se calculan desde esas mismas líneas. Una consulta vacía es éxito con semanas=[], numeroLineas=0 y totalMinutos=0.

En error: ok=false, resultado=null y errores con codigo y mensaje seguros. Códigos previstos: VALIDACION, ACCESO_DENEGADO, LIMITE_VOLUMEN y FALLO_TECNICO. La consulta solicita como máximo 1.001 líneas; al superar 1.000 rechaza el conjunto, sin presentar totales parciales. No usa paginación de servidor: detalle y sumas se entregan juntos. La interfaz informa del límite y permite acotar el intervalo; una semana individual que lo supere también devuelve error. Este límite es visible y comprobable, no una promesa de volumen ilimitado ni una reducción silenciosa.

La clase requiere P07_Consultar y acceso de plataforma a Apex. with sharing, comprobaciones de esquema y USER_MODE explícito en las consultas; sin DML, bloqueos o Analytics API. Los miembros con P07_GuardarPropia consultan únicamente sus propias semanas; las identidades de lectura consultan las semanas accesibles por compartición. El permiso de guardado no habilita edición en esta vista. Los proyectos relacionados se contrastan en una consulta USER_MODE acotada: si falta acceso a una relación necesaria, se rechaza el conjunto. Las etiquetas de miembro proceden de la relación de usuario de las semanas, sin ampliar permisos de User.

El cliente distingue filtros pendientes y consultados. Cambiar un filtro invalida la petición previa y retira sus resultados; un fallo no mantiene datos anteriores como si pertenecieran al filtro nuevo. Las respuestas fuera de orden se ignoran. La consulta no crea semanas vacías ni incluye líneas eliminadas; conserva el histórico inactivo. No altera el contrato de lectura o guardado de la cuadrícula existente.

Los límites no capturables de plataforma pueden abortar la llamada: el cliente debe mostrar un error sin resultados previos. No se promete instantánea global ante cambios concurrentes del catálogo; detalle y totales siempre derivan de las mismas líneas recuperadas.
