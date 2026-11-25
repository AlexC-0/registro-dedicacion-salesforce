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

## Diagnóstico de aislamiento del 25/11/2026

Base revisada de9047d228eb22849577b5b8d01802a4d05a51b2, rama main, remoto registro-dedicacion-salesforce y árbol inicialmente limpio. Inspección remota exclusivamente de lectura en p06-renovaciones-dev, Developer Edition, API 65.0; organización y cuenta técnica contrastadas con el registro privado. Sin pruebas, despliegues, nuevas sesiones funcionales ni cambios de permisos o datos en esta entrega.

### Configuración comprobada ahora

| Capa | Resultado de la inspección | Qué acredita |
|---|---|---|
| Ejecutar informes | Cero asignaciones de P07_InformesLectura; seis asignaciones explícitas anteriores. Los 35 campos disponibles de permisos de informes, paneles, API y acceso amplio revisados están desactivados en los conjuntos efectivos, incluido el perfil | RunReports=false para A, B y coordinación; no existe una concesión alternativa amplia entre los permisos revisados |
| Carpeta y definición P07 | View exclusivamente a P07_Participantes; definición y Permission Set sin cambios respecto a la revisión anterior | Compartir esa carpeta no configura una exclusión sobre otras |
| Informes públicos | Seis definiciones: una de flujos de pantalla y cinco de orquestación; todas estaban ya en el inventario inicial | El ejemplo «Sample Report: Orchestration Runs» permanece en Informes públicos; no se ha ejecutado ahora |
| Carpeta P06 | View para sus tres grupos P06 anteriores; sin cambios. Las pertenencias de A, B y coordinación siguen limitadas a grupos P07 | No hay incorporación nueva de estas identidades a los destinatarios P06 |
| Objetos y campos | Read sobre los tres objetos P07, sin Create/Edit/Delete ni View All/Modify All; FLS adicional de lectura en Activo__c, Usuario__c y TotalMinutos__c, sin escritura | El acceso a definiciones de informes y el acceso a sus datos son controles diferentes |
| Registros P07 | UserRecordAccess sobre siete registros inventariados: A=5 legibles, B=2, coordinación=5; cero editables | Comprobación técnica del ámbito actual, no una nueva sesión funcional |
| Configuración global | Login As=false; SecuritySettings coincide con la referencia anterior | No se reabrió la excepción temporal |

Folder.AccessType devuelve Hidden para P07 y P06, pero ambas conservan FolderShare. No se interpreta ese atributo aislado como una denegación: se contrastan los destinatarios efectivos. No se afirma una auditoría de todas las carpetas o permisos de la organización.

El resultado funcional anterior sigue siendo relevante: con RunReports concedido, A, B y coordinación abrieron un informe público ajeno y recibieron cero filas. Fue acceso a su definición y ejecución, no acceso denegado. La denegación del informe P06 y la lectura del ejemplo público proceden de aquellas sesiones conservadas en [FASE-4.json](evidencias/FASE-4.json); no se han repetido.

### Conclusión y fundamento

**El informe estándar no puede habilitarse para las tres identidades cumpliendo simultáneamente el aislamiento de definiciones exigido y la conservación de las carpetas compartidas actuales.** Es una conclusión para esta configuración y estas restricciones, no una imposibilidad general de los informes estándar.

Salesforce exige acceso a la carpeta y el permiso de ejecución. La documentación de carpetas públicas incluye RunReports entre las capacidades que permiten leerlas; una concesión en P07 no limita ese permiso a P07. Esta descripción concuerda con la evidencia funcional anterior. Fuentes oficiales consultadas el 25/11/2026: [Report and Dashboard Folders](https://help.salesforce.com/s/articleView?id=sf.analytics_sharing.htm&language=en_US&type=5) y [Access to Report Folders](https://help.salesforce.com/s/articleView?id=analytics.access_report_folders.htm&language=en_US&type=5).

No resuelven la incompatibilidad:

- Otra carpeta P07, un enlace directo o esconder la pestaña: no revocan acceso a las definiciones públicas existentes.
- Omitir View Reports in Public Folders: ya estaba desactivado en la comprobación anterior; RunReports bastó para abrir el ejemplo.
- Otro Permission Set o muting: los permisos concedidos no funcionan como una denegación por informe; retirar RunReports también impide la ejecución estándar P07. Véanse [Revoke Permissions and Access](https://help.salesforce.com/s/articleView?id=permissions_revoking_access.htm&language=en_US&type=5) y [Muting Permission Sets](https://help.salesforce.com/s/articleView?id=sf.perm_set_groups_muting.htm&language=en_US&type=5).
- Reducir filas con CRUD, FLS, filtros o reglas de restricción: protege datos, pero no satisface por sí mismo la prohibición de abrir la definición ajena. Las [reglas de restricción](https://help.salesforce.com/s/articleView?id=platform.security_restriction_rule.htm&language=en_US&type=5) actúan sobre registros de objetos admitidos.
- Mover informes públicos, cambiar sus destinatarios o trasladar P07 a otra organización: excede la conservación del destino acordado; no es una corrección limitada al paquete P07.

Se mantiene el informe instalado y sin habilitación. No se propone ejecutarlo con una cuenta administrativa para devolver resultados a usuarios ordinarios.

### Propuesta técnica mínima, pendiente de decisión

Recomendación: una consulta operativa P07 de solo lectura mediante LWC y un servicio Apex específico, sin usar el motor de informes ni RunReports. Debe conservar la selección semanal o por intervalo de lunes, detalle diario, agrupaciones por semana/miembro/proyecto, subtotales, total en minutos, histórico inactivo y ámbito del solicitante. No se presenta como una función ya disponible.

El servicio existente leerSemana está limitado a la identidad propia y utiliza bloqueo de cabecera. No sirve como consulta del ámbito de coordinación sin alterar su contrato. La alternativa separa esa lectura y conserva intactos la cuadrícula, el guardado y sus defensas.

| Componente propuesto | Responsabilidad y coste de cambio |
|---|---|
| P07_InformeService y P07_InformeServiceTest | Nuevo servicio sin DML y pruebas aisladas de seguridad, fechas, detalle y totales |
| p07InformeDedicacion y sus pruebas Jest | Nueva vista de consulta, filtros, tabla, errores y teclado; sin edición, exportación o constructor de informes |
| P07_ConsultaInforme | Nuevo permiso con acceso a la nueva clase y pestaña; sin RunReports ni ampliación de CRUD/FLS. Tres asignaciones futuras a las identidades ya existentes |
| P07_InformeOperativo, FlexiPage y CustomTab | Entrada propia a la consulta, siguiendo el mecanismo de página/pestaña ya utilizado |
| P07_Dedicacion, CustomApplication | Sustituir la entrada estándar Informes por la consulta propia; este cambio de navegación no se considera control de seguridad |
| Manifiesto acotado | Seis componentes nuevos y una aplicación modificada, además de pruebas locales; sin reinstalar fases anteriores |

El nuevo endpoint debe exigir P07_Consultar, ya concedido a las tres identidades, y acceso explícito a su clase. En API 65.0 se declararán with sharing y USER_MODE de forma explícita para respetar registros, CRUD y FLS; with sharing por sí solo no cubre estos dos últimos niveles. La [guía oficial de seguridad Apex para LWC](https://developer.salesforce.com/docs/platform/lwc/guide/apex-security.html) distingue el comportamiento anterior a API 67.0. No se actualizará la versión ni se consultará en SYSTEM_MODE para suplir un permiso ausente.

Aceptar únicamente fechas como selección inicial; no admitir usuario ejecutor, objetos, campos o consultas arbitrarios. Miembros y etiquetas deben derivarse de las semanas accesibles, sin ampliar la lectura de User. Una denegación debe producir error explícito, no un resultado vacío aparentemente satisfactorio. Los totales deben corresponder al conjunto completo seleccionado, no solo a la página visible; cualquier límite de consulta debe detectarse sin truncamiento silencioso. El diseño concreto de paginación y límites se revisará antes de implementar, sin dar por aceptada una reducción de alcance.

Coste: desarrollo, mantenimiento y pruebas de la consulta propia, de su seguridad y de la navegación. No se prevén servicios externos o licencias adicionales para las tres identidades actuales; no es una cotización ni una promesa de plazo o capacidad. La alternativa no ofrece el constructor, exportaciones, suscripciones o paneles del motor estándar. Esas capacidades no se incorporan de forma implícita.

### Verificación prevista y decisiones pendientes

La siguiente ejecución deberá separar pruebas aisladas, validación remota, despliegue y sesiones reales:

1. Contrastar identidad, configuración, datos, papelera y revisiones antes de escribir; mantener RunReports=false, los seis permisos anteriores y las carpetas existentes. Inventariar las tres asignaciones nuevas por separado.
2. Probar con Apex SeeAllData=false la ausencia de permiso de operación, acceso a clase, CRUD/FLS y acceso fuera de ámbito; no considerar runAs suficiente por sí solo. Comprobar consultas manipuladas, histórico, semana vacía y sumas. Añadir Jest para filtros, errores, orden de respuestas, teclado y resultados completos.
3. Validar y desplegar únicamente los componentes nuevos/modificados con pruebas P07 pertinentes; esperar estados finales y recuperar fuentes para contrastarlas. No ejecutar pruebas P06.
4. En sesiones legítimas, comprobar A=105, B=60 y coordinación=105 de A para la referencia conservada del 23/11; histórico=45, semana anterior vacía sin borrar cabecera y conciliación con detalle/cabecera. Coordinación no debe obtener edición ni datos de B. Volver a inventariar antes de usar esos números como referencia.
5. Con RunReports=false, verificar acceso efectivo a la nueva consulta y denegación de ejecución de informes estándar ajenos por navegación y ruta conocida. No equiparar ocultar una pestaña, cero filas o una inspección administrativa con esa denegación.
6. Contrastar conservación de P07 y P06, permisos y configuración global. Registrar límites reales y conservar fallos; no cerrar fase 4 o V1 por el mero despliegue.

Decisión material pendiente: autorizar una consulta propia como sustitución del mecanismo estándar manteniendo los criterios funcionales y de aislamiento. Si el artefacto Report estándar sigue siendo obligatorio, no hay una solución compatible con todas las restricciones actuales; no se modifica ese requisito por inferencia. También falta disponer de acceso legítimo para las comprobaciones funcionales: no se reabre Login As con la autorización histórica. Esta propuesta no autoriza aún implementación, asignaciones ni nuevas excepciones.

Las matrices de aceptación conservan sus resultados y pendientes. El diagnóstico aporta una recomendación y condiciones de verificación, no una aceptación de la alternativa ni una demostración de capacidades nuevas.
