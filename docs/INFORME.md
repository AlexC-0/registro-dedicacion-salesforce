# Informe operativo de dedicación

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

P07_InformesLectura concede únicamente RunReports y visibilidad de la pestaña Informes. No incorpora CRUD, FLS, acceso a clases, API, creación o administración de informes, exportación ni suscripciones. Se asignó a las tres identidades existentes, además de sus permisos anteriores. El perfil P07_AccesoMinimo sigue sin RunReports.

La carpeta concede View exclusivamente a P07_Participantes. Esta concesión permite consultar su contenido; no concede edición de informes ni acceso a semanas ajenas. Los permisos de lectura, la relación maestro-detalle y las reglas de compartición conservan su función independiente.

RunReports es una capacidad general de Salesforce, no un permiso restringido al informe P07. El inventario previo contiene cinco informes de ejemplo de orquestación en Informes públicos. No se modificaron esas carpetas. La revisión de permisos no encuentra lectura de objetos ajenos a P07 ni pertenencia de estas identidades a grupos P06; la carpeta P06 mantiene sus destinatarios anteriores. La visibilidad efectiva de otros informes públicos después de conceder RunReports requiere comprobación en las sesiones ordinarias pendientes. No se declara demostrado el aislamiento completo de esa superficie.

Referencias oficiales: [Report](https://developer.salesforce.com/docs/platform/api-metadata/references/meta-types/metadata-report.html), [FolderShare](https://developer.salesforce.com/docs/platform/api-metadata/references/meta-types/metadata-foldershare.html) y [tipos estándar disponibles por API](https://developer.salesforce.com/docs/analytics/salesforce-analytics-rest-api/guide/analytics-api-reporttypes-reference-list.html).

## Resultado técnico del 25/11/2026

La consulta inicial de cabeceras y líneas coincide con la referencia publicada de fase 3B. Los cambios de filtro siguientes se ejecutaron mediante Analytics API con la cuenta técnica; no se guardaron cambios en la definición.

| Intervalo de lunes | Filas | Minutos | Resultado |
|---|---:|---:|---|
| 23/11/2026 a 23/11/2026 | 4 | 165 | A: 3 líneas y 105; B: 1 línea y 60 |
| 16/11/2026 a 16/11/2026 | 0 | 0 | La cabecera vacía de A permanece, revisión 2 |
| 16/11/2026 a 23/11/2026 | 4 | 165 | Solo hay detalle en la semana del 23 |

Las tres respuestas indican allData=true. Los subtotales son 45 minutos de histórico y 60 de revisión para A; 60 de desarrollo para B. El detalle histórico conserva sus dos líneas de 30 y 15 minutos. La revisión real de la pantalla del informe bajo la cuenta técnica mostró esos valores, fechas y subtotales.

Los 105 y 60 minutos concuerdan con las líneas actuales y con los resúmenes y cuadrículas documentados en fase 3B. No se ha vuelto a conciliar resumen, cuadrícula e informe bajo cada identidad en esta fase. La cuenta técnica carece de FLS sobre Activo__c, Usuario__c y TotalMinutos__c; no se ampliaron sus permisos para suplir las sesiones funcionales. El estado inactivo y los resúmenes mantienen la evidencia histórica, mientras que proyectos, cabeceras y líneas conservan sus SystemModstamp durante esta fase.

UserRecordAccess, sobre las tres cabeceras y cuatro líneas activas, devuelve cinco registros legibles para A, dos para B y cinco para coordinación; ninguno editable. Esta consulta complementa la configuración, pero no acredita ejecución del informe como cada función.

## Comprobaciones funcionales pendientes

La sesión disponible y verificada es técnica. La ficha de Miembro A no ofrece acceso delegado y Login As continúa desactivado. No se cambiaron políticas, contraseñas o autenticación ni se enviaron comunicaciones. Se necesita una sesión legítima de las identidades existentes para continuar.

En A, B y coordinación: abrir la carpeta y el informe; comprobar respectivamente 105, 60 y 105 minutos en la semana del 23; excluir la dedicación ajena conforme al ámbito; verificar el histórico, el filtro de semana vacía, subtotales y total; conciliar resumen y cuadrícula de la misma identidad y comprobar que coordinación no obtiene edición. Revisar también las carpetas y los informes públicos ajenos. Estos valores son referencias esperadas, no resultados de sesiones nuevas.

Para AC-20, en una sesión funcional real: recorrer con Tab y Shift+Tab el selector de semana, proyecto, celdas habilitadas y acciones; introducir un borrador inválido y recuperar la entrada afectada; alcanzar Guardar y Descartar mediante teclado; cancelar diálogos y comprobar retorno de foco; descartar expresamente el borrador. A anchura reducida, alcanzar columnas finales y totales mediante teclado y observar foco visible, desplazamiento y ausencia de atrapamiento. Registrar el foco antes y después de cada transición y confirmar que minutos y revisión persistidos no cambian. Un desplazamiento asignado por código no acredita este recorrido.

No se ejecutó una nueva prueba de teclado funcional. AC-16 y AC-20 siguen pendientes de cierre; AC-25 mantiene conciliación integrada parcial. V1 continúa abierta, con los límites anteriores de concurrencia, resultado desconocido y jerarquía.
