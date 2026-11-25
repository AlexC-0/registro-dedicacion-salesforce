# Informe operativo de dedicación

Estado actual: informe instalado sin habilitación para A, B y coordinación. Las tres asignaciones de ejecución se retiraron por permitir acceso a un informe público ajeno; los resultados funcionales siguientes son anteriores a esa retirada.

## Diseño instalado

La aplicación P07 Dedicación incorpora la pestaña Informes. El informe «Dedicación semanal en minutos» está en la carpeta «P07 Dedicación», con nombre completo P07_Dedicacion/DedicacionSemanal.

Se utiliza el tipo estándar «Semanas de dedicación con Dedicaciones diarias y Proyecto». La descripción obtenida de API 65.0 ofrece todos los campos necesarios; no se creó un tipo personalizado ni se modificó el modelo.

Las agrupaciones son lunes de inicio, propietario de la semana y proyecto. El propietario identifica al miembro conforme a la invariante de identidad de la cabecera; no se utiliza el propietario del catálogo. El detalle muestra código de proyecto, fecha y minutos. Los campos agrupados se muestran en sus encabezados, sin duplicarlos en la lista de columnas.

La medida es SUM(DedicacionDiaria__c.Minutos__c), con subtotales y total general. No se incluye TotalMinutos__c en la agregación: repetir el total de una cabecera por cada línea multiplicaría indebidamente su valor. La duración se presenta en minutos enteros; no hay fórmulas de horas ni redondeos.

## Selección de semana y consulta

1. Abrir P07 Dedicación → Informes → Todas las carpetas → P07 Dedicación → Dedicación semanal en minutos.
2. Revisar el filtro «Lunes de inicio». El valor guardado es «Esta semana»; los usuarios ficticios conservan la configuración regional española. En el destino observado el intervalo comprende el 23 al 29/11/2026.
3. Para consultar una semana concreta, utilizar un intervalo personalizado con el lunes deseado como fecha inicial y final. Así se selecciona una cabecera semanal completa. Cambiar el filtro de ejecución no requiere guardar otra definición del informe.
4. Leer los subtotales de miembro y proyecto dentro de cada agrupación de lunes. Si se amplía el intervalo a varias semanas, el total general acumula todas las semanas seleccionadas; no debe interpretarse como el total de una sola.
5. Mantener visibles filas de detalle, subtotales y suma total para conciliar las cantidades.

El ámbito «Todas las semanas de dedicación» selecciona todos los registros que puede leer el solicitante. No contiene identificadores fijos de A o B y no sustituye la seguridad de registros.

No se filtra Activo__c: se conservan líneas históricas de proyectos inactivos. El informe ordinario excluye registros eliminados. El tipo requiere líneas de detalle, por lo que una semana sin líneas no aparece. Su cabecera puede seguir existiendo con total cero y revisión propia; se consulta en Semanas de dedicación o en la cuadrícula.

## Permisos y límites de aislamiento

P07_InformesLectura concede únicamente RunReports y visibilidad de la pestaña Informes. No incorpora CRUD, FLS, acceso a clases, API, creación o administración de informes, exportación ni suscripciones. Se asignó inicialmente a las tres identidades; esas asignaciones se retiraron al terminar la comprobación por el alcance de los informes públicos. El perfil P07_AccesoMinimo sigue sin RunReports.

La carpeta concede View exclusivamente a P07_Participantes. Esta concesión permite consultar su contenido; no concede edición de informes ni acceso a semanas ajenas. Los permisos de lectura, la relación maestro-detalle y las reglas de compartición conservan su función independiente.

RunReports es una capacidad general de Salesforce, no un permiso restringido al informe P07. El inventario previo contiene cinco informes de ejemplo de orquestación en Informes públicos. No se modificaron esas carpetas. La revisión de permisos no encuentra lectura de objetos ajenos a P07 ni pertenencia de estas identidades a grupos P06; la carpeta P06 mantiene sus destinatarios anteriores. Las tres sesiones abrieron un informe público estándar de orquestación, vacío. El aislamiento estricto no se cumple con esa concesión; las tres asignaciones se retiraron y RunReports queda desactivado.

Referencias oficiales: [Report](https://developer.salesforce.com/docs/platform/api-metadata/references/meta-types/metadata-report.html), [FolderShare](https://developer.salesforce.com/docs/platform/api-metadata/references/meta-types/metadata-foldershare.html) y [tipos estándar disponibles por API](https://developer.salesforce.com/docs/analytics/salesforce-analytics-rest-api/guide/analytics-api-reporttypes-reference-list.html).

## Resultado técnico del 25/11/2026

La consulta inicial de cabeceras y líneas coincide con la referencia publicada de fase 3B. Los cambios de filtro siguientes se ejecutaron mediante Analytics API con la cuenta técnica; no se guardaron cambios en la definición.

| Intervalo de lunes | Filas | Minutos | Resultado |
|---|---:|---:|---|
| 23/11/2026 a 23/11/2026 | 4 | 165 | A: 3 líneas y 105; B: 1 línea y 60 |
| 16/11/2026 a 16/11/2026 | 0 | 0 | La cabecera vacía de A permanece, revisión 2 |
| 16/11/2026 a 23/11/2026 | 4 | 165 | Solo hay detalle en la semana del 23 |

Las tres respuestas indican allData=true. Los subtotales son 45 minutos de histórico y 60 de revisión para A; 60 de desarrollo para B. El detalle histórico conserva sus dos líneas de 30 y 15 minutos. La revisión real de la pantalla del informe bajo la cuenta técnica mostró esos valores, fechas y subtotales.

Los 105 y 60 minutos concuerdan con las líneas actuales y con los resúmenes y cuadrículas documentados en fase 3B. La continuación concilia esos totales como A y B y contrasta cabecera de A e informe como coordinación. La cuenta técnica carece de FLS sobre Activo__c, Usuario__c y TotalMinutos__c; no se ampliaron sus permisos para suplir las sesiones funcionales. El estado inactivo y los resúmenes mantienen la evidencia histórica, mientras que proyectos, cabeceras y líneas conservan sus SystemModstamp durante esta fase.

UserRecordAccess, sobre las tres cabeceras y cuatro líneas activas, devuelve cinco registros legibles para A, dos para B y cinco para coordinación; ninguno editable. Esta consulta complementa la configuración, pero no acredita ejecución del informe como cada función.

## Comprobación funcional y disponibilidad final

Sesiones reales: A obtiene tres líneas y 105 minutos, B una y 60, coordinación tres de A y 105 sin B. A concilia cuadrícula 1,75 h y cabecera 105/revisión 5; B, 1 h y cabecera 60/revisión 2. Coordinación consulta la cabecera de A con 105/revisión 5 y recibe denegación al editarla. Su cuadrícula propia muestra 0 h y no representa la dedicación de A.

Como A, la semana anterior devuelve cero filas y cero minutos; Siempre conserva tres y 105. Se incluyen las dos líneas históricas, con 30 y 15 minutos. Los filtros de ejecución no alteraron la definición.

El informe P06 conocido queda denegado para las tres identidades. Las tres abren «Sample Report: Orchestration Runs», público y sin resultados. Como A se ven nombres de carpetas Enablement, aunque el informe concreto ensayado deniega acceso. No hay exclusividad de informes P07.

Las tres asignaciones de P07_InformesLectura se retiraron tras comprobar acceso a un informe público ajeno. Permanecen las seis asignaciones explícitas anteriores y RunReports=false en los conjuntos efectivos, incluido el perfil, de A, B y coordinación. El informe, la carpeta y la pestaña permanecen instalados; su ejecución funcional queda deshabilitada. No se modificaron carpetas de otros proyectos.

Estos resultados acreditan el comportamiento anterior a la retirada, no la disponibilidad actual. No reasignar el permiso como paso rutinario de instalación: falta resolver el requisito de aislamiento. La fase permanece abierta.

## Teclado y corrección

Se corrigió la pérdida del cero inicial al escribir un decimal en una celda vacía: el LWC conserva el texto en edición separado del borrador significativo. La regresión nueva falló antes de corregir; después, 49/49 pruebas Jest en dos suites satisfactorias. Validación 0Afg700000LIaTyCAL y despliegue 0Afg700000LIPVKCA5: Succeeded, un bundle, NoTestRun. Recuperación 09Sg700000bjuwnEAA: cinco archivos coincidentes. Sin cambios de Apex o modelo ni pruebas Apex nuevas.

Como A se recorrieron semana, selector de proyecto, celdas habilitadas, Guardar, error, recuperación de la entrada y Descartar. Tras la corrección y recarga completa, 0 seguido de ,5 produce 0,5. Cancelar conserva el borrador y devuelve foco a Descartar cambios. A 900 × 700, las flechas desplazan la región de 0 a 366,4 píxeles y End permite alcanzar el total final; Tab sale sin atrapamiento. Se observó foco en controles y región. El descarte final recupera 1,75 h y celda vacía, con cero peticiones de guardado. Cobertura básica de teclado, no auditoría completa de accesibilidad ni lector de pantalla.

Login As terminó desactivado y SecuritySettings restaurado; sesión técnica recuperada. Datos y revisiones conservados. V1 sigue abierta, con los límites de concurrencia, resultado desconocido y jerarquía.
