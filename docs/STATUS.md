# Estado del proyecto

## Resultado vigente de fase 4B

Consulta operativa propia instalada sobre 14dc47a8b68a4b1d062ed11a8ac3bc13b07d4edf. Validación 0Afg700000LJDjpCAH y despliegue 0Afg700000LJEUbCAP: Succeeded, 7/7 componentes y 26/26 pruebas Apex en ambos. Jest: 92/92, cuatro suites. Recuperación 09Sg700000bktiXEAQ: trece archivos coincidentes tras normalizaciones identificadas.

P07_ConsultaInforme está asignado a las tres identidades existentes y conserva las seis asignaciones previas. RunReports=false, P07_InformesLectura sin asignaciones y Login As=false. P07 conserva datos, revisiones y papelera; el inventario de P06 conserva 432 registros y cuatro comparticiones manuales, sin diferencias.

La consulta está configurada, pero no demostrada en sesiones ordinarias nuevas. Solo estaba disponible la cuenta técnica; no se amplió su acceso ni se reactivó Login As. Faltan los recorridos de A, B y coordinación y la denegación real de informes ajenos con el estado final. Fase 4 y V1 abiertas; se conservan los demás pendientes de aceptación.

[FASE-4B.md](FASE-4B.md) y [evidencia](evidencias/FASE-4B.json) detallan contrato, límite explícito de 1.000 líneas, pruebas, despliegue, asignaciones y límites. Los apartados siguientes conservan los estados históricos; la elección del mecanismo descrita en el diagnóstico anterior ya está resuelta.

Fecha: 25/11/2026.

## Diagnóstico de aislamiento del informe

Revisión del 25/11/2026 sobre de9047d228eb22849577b5b8d01802a4d05a51b2, main y árbol limpio. Identidad de la Developer Edition compartida verificada; consultas remotas de lectura, sin despliegues, pruebas ni cambios de datos o permisos.

Permanecen seis asignaciones explícitas, cero de P07_InformesLectura, RunReports=false y Login As=false. Carpeta e informe P07, permiso retirado, carpeta P06 y SecuritySettings coinciden con la referencia anterior. Los seis informes públicos localizados —uno de flujos y cinco de orquestación— ya estaban en el inventario inicial. UserRecordAccess conserva A=5, B=2 y coordinación=5 registros legibles entre siete inventariados; ninguno editable. La inspección técnica no repite las sesiones funcionales previas.

La documentación oficial y el acceso público demostrado anteriormente confirman la incompatibilidad entre habilitar el informe estándar y exigir exclusividad de informes P07 sin alterar las carpetas compartidas. Se recomienda una consulta P07 de solo lectura con LWC y Apex, sin RunReports; no se ha implementado ni aceptado esa sustitución.

[INFORME.md](INFORME.md#diagnóstico-de-aislamiento-del-25112026) concentra configuración, fuentes, alternativas descartadas, componentes, coste, límites y verificación prevista. La decisión pendiente es autorizar el cambio de mecanismo conservando los criterios; también debe resolverse el acceso legítimo para futuras sesiones. Si debe mantenerse obligatoriamente el artefacto Report estándar, las restricciones actuales no permiten habilitarlo.

Revisión editorial general sobre los 100 archivos propios versionados, incluidos instrucciones, código, metadatos y evidencias, y sobre los cambios documentales: sin atribuciones impropias detectadas. Se conservan identificadores y dependencias legítimos. No se revisó ni reescribió el historial remoto. Las 57 pruebas Jest y el despliegue anterior siguen siendo evidencia histórica, no pruebas nuevas. Fase 4 y V1 abiertas.

## Corrección de estado tras actualización fallida

Revisión del 25/11/2026 sobre 9f259d665671814964ef9a762f4a4c83c28284e8, rama main y árbol inicialmente limpio. El destino compartido p06-renovaciones-dev, Developer Edition y API 65.0, se contrastó con el registro privado antes de operar.

La reproducción parte de 60 minutos confirmados y una edición a «2». Aceptar descartar al actualizar vaciaba el borrador, pero dejaba el texto visible. Si leerSemana fallaba por rechazo de promesa o respuesta válida ok=false, la celda mostraba «2», el total «1 h» y Guardar permanecía deshabilitado. La misma omisión aparecía al cambiar de semana y volver tras lecturas fallidas.

Se añadieron ocho casos Jest. Antes de corregir, fallaron los cuatro de actualización/cambio de semana con ambos tipos de error; pasaron los cuatro de cancelación y adopción, y quedaron 49 omitidos en esa ejecución selectiva. La corrección añade la limpieza de textoEnEdicion junto al borrador en las dos rutas, después de aceptar el descarte y antes de iniciar la lectura. No depende del éxito posterior, no añade estados funcionales ni modifica Apex.

Después pasan 57/57 pruebas, en dos suites, incluida la escritura decimal carácter a carácter. Cancelar conserva texto «2,00», total «2 h» y borrador pendiente, sin iniciar lectura. Se revisaron descarte directo, adopción por carga/guardado, aceptación del estado actual, reaplicación y retirada de fila: ya limpiaban o sustituían la presentación. Los errores de guardado o reconciliación sin descarte continúan conservando el borrador.

| Operación | Identificador | Resultado final |
|---|---|---|
| Recuperación previa | 09Sg700000bkXJpEAM | Succeeded; cinco archivos coinciden con la base |
| Validación | 0Afg700000LIvmvCAD | Succeeded, checkOnly=true; 1/1 |
| Despliegue | 0Afg700000LIQcgCAH | Succeeded, checkOnly=false; 1/1 |
| Recuperación final | 09Sg700000bkRuMEAU | Succeeded; cinco archivos coinciden con las fuentes |

Se reutiliza [revision-fase-4.xml](../manifest/revision-fase-4.xml), limitado al bundle. NoTestRun: cero pruebas Apex nuevas. Las seis huellas de fuentes/manifiesto se mantienen. El contraste normaliza únicamente CRLF/LF y la ausencia del salto final en los archivos recuperados.

No se ejecutó una demostración nueva en sesión funcional: no hay una sesión funcional verificada para este recorrido y la excepción anterior de Login As permanece cerrada. Los fallos de lectura se simularon en Jest; no se atribuye demostración real a la compilación remota.

El contraste conserva tres proyectos, tres semanas, cuatro líneas activas y tres eliminadas P07, con revisiones y SystemModstamp; 432 registros y cuatro comparticiones manuales P06, además del inventario de configuración revisado. Informe y carpeta sin cambios, seis asignaciones explícitas y RunReports=false. SecuritySettings sin diferencias; Login As=false durante esta revisión.

Corrección terminada dentro de este alcance; fase 4 y V1 abiertas. La habilitación del informe y los límites anteriores siguen pendientes. [Evidencia de esta corrección](evidencias/FASE-4-ACTUALIZACION-FALLIDA.json) conserva el fallo previo, las pruebas finales y el contraste; las evidencias anteriores no se reemplazan.

## Fase 4: comprobación realizada; informe sin habilitación

Base de instalación: 00d731463fca5567a4ea01cbaebb23895c1e5d11. Continuación sobre 2a647640858f80a8b3c701ecbfb37c6867def0a8, rama main, remoto registro-dedicacion-salesforce y árbol inicialmente limpio. Se conserva jsconfig.json ya versionado. Destino contrastado: Developer Edition compartida con P06, alias p06-renovaciones-dev, API 65.0.

### Antecedente: preparación e instalación del informe

El inventario inicial contiene 25 carpetas y 31 informes. No existían la carpeta ni el informe P07. El tipo estándar de semanas con dedicaciones y proyecto permite el diseño completo; no se añadió ReportType personalizado. [INFORME.md](INFORME.md) detalla ubicación, filtros, sumas y límites.

El manifiesto [fase-4.xml](../manifest/fase-4.xml) selecciona cuatro componentes: informe, carpeta, Permission Set y aplicación. La aplicación añade la pestaña Informes. El informe agrupa por lunes, propietario de la semana y proyecto; muestra detalle diario y suma los minutos de las líneas. No suma el resumen de cabecera ni excluye proyectos inactivos. Una semana sin líneas no genera detalle.

P07_InformesLectura habilita RunReports y la pestaña; se asignó exclusivamente a las tres identidades P07 existentes. En ese momento había nueve asignaciones explícitas; el estado final tras la retirada se describe más adelante. La carpeta concede View a P07_Participantes. El perfil, los permisos de objetos, grupos y pertenencias anteriores se conservan; no se añadieron privilegios de edición, API o acceso global.

### Validación, despliegue y recuperación

| Operación | Identificador | Resultado final |
|---|---|---|
| Validación inicial | 0Afg700000LGyfGCAT | Failed, checkOnly=true; referencia del código de proyecto no válida en Metadata API |
| Segunda validación | 0Afg700000LHeD4CAL | Failed, checkOnly=true; campos agrupados duplicados en las columnas |
| Validación corregida | 0Afg700000LHNsACAX | Succeeded, success=true, checkOnly=true; 4/4 |
| Despliegue | 0Afg700000LHgI5CAL | Succeeded, success=true, checkOnly=false; 4/4 |
| Recuperación | 09Sg700000bh8jOEAQ | Succeeded; cuatro archivos contrastados |

Se corrigió la referencia de columna relacionada a FK_$ProyectoDedicacion__c.Codigo__c y se retiraron de las columnas los tres campos ya presentes en las agrupaciones. No se cambió el contrato de datos.

Las cinco huellas de fuentes y manifiesto coinciden antes y después del despliegue. El contraste semántico acepta únicamente los valores predeterminados recuperados: Day en agrupaciones no temporales, parámetro co=1, dos opciones de navegación false y nombre canónico standard-report. No hay diferencias inesperadas.

En la instalación inicial del informe: NoTestRun, cero pruebas Apex nuevas; sin cambios de Apex, LWC o modelo ni repetición de Jest y Apex históricos. La validación remota, la recuperación y la ejecución técnica del informe se documentan como comprobaciones distintas.

### Resultados obtenidos

Las cabeceras y líneas coinciden con la referencia anterior: A, semana 23/11, tres líneas y 105 minutos, revisión 5; A, semana 16/11, cero líneas, revisión 2; B, semana 23/11, una línea y 60 minutos, revisión 2.

Tres ejecuciones técnicas del informe: semana 23/11 → cuatro filas y 165 minutos; semana 16/11 → cero filas y cero minutos; ambas semanas → cuatro filas y 165 minutos. Todas indican allData=true. Subtotales: A histórico 45 y revisión 60; B desarrollo 60. La interfaz real bajo la cuenta técnica muestra los mismos valores y las dos líneas históricas.

La consulta técnica UserRecordAccess conserva A=5, B=2 y coordinación=5 registros legibles entre las siete cabeceras/líneas activas; cero editables. Los Permission Sets y el perfil mantienen lectura exclusivamente de los tres objetos P07. Antes de la retirada final, RunReports era el único privilegio habilitado entre las capacidades de informes y acceso amplio revisadas.

### Continuación funcional

Sesiones reales: A obtiene tres líneas y 105 minutos, B una y 60, coordinación tres de A y 105 sin B. A concilia cuadrícula 1,75 h y cabecera 105/revisión 5; B, 1 h y cabecera 60/revisión 2. Coordinación consulta la cabecera de A con 105/revisión 5 y recibe denegación al editarla. Su cuadrícula propia muestra 0 h y no representa la dedicación de A.

Como A, «La semana pasada» devuelve cero filas y cero minutos; «Siempre» conserva tres y 105. La cabecera vacía mantiene revisión 2. Las dos líneas históricas suman 45 minutos. Los filtros de ejecución no modificaron la definición instalada.

Los contadores de coordinación mostraron cifras transitorias durante el render; la lectura estable confirma tres filas y 105. El control estándar de modificación no ofreció controles de edición de datos; la ruta directa de edición de A fue denegada.

### Corrección y comprobación de teclado

Se corrigió la pérdida del cero inicial al escribir un decimal en una celda vacía: el LWC conserva el texto en edición separado del borrador significativo. La regresión nueva falló antes de corregir; después, 49/49 pruebas Jest en dos suites satisfactorias. Validación 0Afg700000LIaTyCAL y despliegue 0Afg700000LIPVKCA5: Succeeded, un bundle, NoTestRun. Recuperación 09Sg700000bjuwnEAA: cinco archivos coincidentes. Sin cambios de Apex o modelo ni pruebas Apex nuevas.

Al corregir 0,3, escribir 0 eliminaba el borrador por equivaler a la base y el render borraba ese carácter. Continuar con ,5 producía un valor inválido. El texto de presentación se limpia al adoptar estado confirmado, descartar o retirar una fila. No cambia el contrato de guardado.

[revision-fase-4.xml](../manifest/revision-fase-4.xml) contiene únicamente el bundle. Validación con checkOnly=true y despliegue con checkOnly=false, ambos finalizados. Las seis huellas de fuentes/manifiesto se conservaron. El primer recorrido posterior al despliegue aún utilizó el módulo anterior almacenado en el navegador; la recarga completa y repetición confirmaron el código actualizado.

Como A se recorrieron semana, selector de proyecto, celdas habilitadas, Guardar, error, recuperación de la entrada y Descartar. Tras la corrección y recarga completa, 0 seguido de ,5 produce 0,5. Cancelar conserva el borrador y devuelve foco a Descartar cambios. A 900 × 700, las flechas desplazan la región de 0 a 366,4 píxeles y End permite alcanzar el total final; Tab sale sin atrapamiento. Se observó foco en controles y región. El descarte final recupera 1,75 h y celda vacía, con cero peticiones de guardado. Cobertura básica de teclado, no auditoría completa de accesibilidad ni lector de pantalla.

### Informes ajenos y retirada de habilitación

A, B y coordinación no abren el informe P06 conocido: el visor devuelve recurso no existente. Las mismas tres identidades sí abren «Sample Report: Orchestration Runs», público y con cero filas. Cero filas no equivale a acceso denegado. Como A se ven nombres de carpetas Enablement; el informe concreto ensayado deniega acceso. No se extrapola a todos los informes ajenos.

Las tres asignaciones de P07_InformesLectura se retiraron tras comprobar acceso a un informe público ajeno. Permanecen las seis asignaciones explícitas anteriores y RunReports=false en los conjuntos efectivos, incluido el perfil, de A, B y coordinación. El informe, la carpeta y la pestaña permanecen instalados; su ejecución funcional queda deshabilitada. No se modificaron carpetas de otros proyectos.

Los resultados del informe por función corresponden al estado anterior a la retirada. La ausencia final de RunReports se comprobó en todas las asignaciones efectivas; no se realizó otra sesión funcional posterior. La habilitación operativa sigue pendiente bajo el requisito de no habilitar informes ajenos.

### Conservación y pendientes

P07 conserva tres proyectos, tres semanas, cuatro líneas activas y tres eliminadas, incluidos campos inventariados y SystemModstamp. P06 conserva 432 registros, cuatro comparticiones manuales, grupos, pertenencias, asignaciones, usuarios preexistentes, objetos y permisos del inventario; también su carpeta, informe y nueve entradas no P07 del inventario Apex. Login As se utilizó temporalmente para las tres identidades y se restauró a false; SecuritySettings coincide con la referencia inicial y la sesión técnica está recuperada. No se crearon usuarios, contraseñas ni dedicaciones. Licencias: Salesforce 4/4 y Salesforce Platform 3/6.

La fase y V1 permanecen abiertas. AC-20 incorpora teclado básico real; AC-25, conciliación integrada de A y B. Accesibilidad completa, concurrencia, resultado desconocido y jerarquía conservan sus límites. No se declara disponible el informe tras retirar su permiso.

[Evidencia sanitizada de fase 4](evidencias/FASE-4.json). Se conservan errores de validación, regresión inicial, intentos y recibos privados.

## Antecedente: fase 3B, habilitación y demostración funcional ejecutadas

Base revisada: 20a9be9e9847d36732acc092e09afae2bbcd483b, rama main y remoto registro-dedicacion-salesforce. Se conservaron los avances locales de preparación. Destino y cuenta técnica contrastados con el registro privado: Developer Edition compartida con P06, alias p06-renovaciones-dev y API 65.0.

### Configuración final

Aplicación P07_Dedicacion, página con el LWC existente, cuatro pestañas, tres layouts, tres vistas P07_Accesibles y perfil P07_AccesoMinimo. El manifiesto [fase-3b.xml](../manifest/fase-3b.xml) contiene trece componentes; no reinstala objetos, campos, reglas, Apex ni LWC.

Tres identidades ficticias nuevas con licencia Salesforce Platform: A, B y coordinación. Seis asignaciones explícitas de Permission Sets y cinco pertenencias: los tres en participantes, solo A en miembros del ámbito y solo coordinación en el grupo receptor. Las asignaciones internas del perfil se distinguen de esos seis permisos explícitos. El perfil no concede CRUD sobre objetos ni privilegios administrativos o API; los permisos de lectura y operación proceden de los conjuntos P07 existentes.

Se consumen tres de las seis licencias Platform. Salesforce mantiene cuatro de cuatro usadas. Los usuarios nuevos no tienen rol, licencia adicional de Content ni permisos generales de escritura. No se enviaron notificaciones ni se establecieron o restablecieron contraseñas.

### Validación, despliegue y contraste

| Operación | Identificador | Resultado final |
|---|---|---|
| Primera validación | 0Afg700000L9ahjCAB | Failed, checkOnly=true; nombre de proyecto Readonly y Chatter no desactivable |
| Segunda validación | 0Afg700000LA8Y5CAL | Failed, checkOnly=true; ActivitiesAccess exigido por la licencia |
| Validación de habilitación | 0Afg700000LA8rSCAT | Succeeded; 10/10 componentes |
| Despliegue de habilitación | 0Afg700000LA9qjCAD | Succeeded; 10/10 componentes |
| Recuperación inicial | 09Sg700000bWJWrEAO | Succeeded; diez archivos |
| Validación final de navegación | 0Afg700000LAPh1CAH | Succeeded, success=true, checkOnly=true; 13/13 |
| Despliegue final | 0Afg700000L9NhGCAV | Succeeded, success=true, checkOnly=false; 13/13 |
| Recuperación final | 09Sg700000bWXjVEAW | Succeeded; trece archivos contrastados |

NoTestRun se utilizó exclusivamente para estos metadatos de interfaz y perfil. Cero pruebas Apex ejecutadas en estos trabajos. No se modificó código ni se repitieron Jest o Apex: 48 pruebas Jest y 18 Apex siguen siendo evidencia histórica de fase 3A, no ejecuciones nuevas.

Las catorce huellas de fuentes y manifiesto coinciden con el paquete final validado. El contraste acepta únicamente normalizaciones identificadas: campos obligatorios convertidos por Salesforce a Required, claves obligatorias añadidas a los layouts, sección de enlaces y minilayout predeterminados, y omisiones de permisos desactivados o aplicaciones fuera del manifiesto. Los campos obligatorios de un layout no conceden CRUD. La lectura completa del perfil y las sesiones confirman ausencia de edición ordinaria.

Antes de operar se recuperaron y contrastaron 48 archivos existentes: 31 declarativos, doce de backend y cinco del LWC. El backend y el bundle coinciden con las fuentes; en el esquema se revisaron los valores predeterminados y omisiones de serialización. No se sobrescribieron esas fuentes.

### Correcciones y preparación de datos

Se corrigió el comportamiento del campo Name en el layout de proyecto y se conservaron ChatterInternalUser y ActivitiesAccess, exigidos por la licencia. FlowUFLRequired permanece como restricción de licencia, no como concesión de ejecución de flujos. La creación inicial de usuarios falló por el límite de licencia Content y Salesforce revirtió los tres registros; al declarar UserPermissionsSFContentUser=false se crearon correctamente.

El recorrido de coordinación mostró que solo existía «Vistos recientemente», sin columnas suficientes. Se añadieron vistas de registros accesibles, compartidas exclusivamente con P07_Participantes, y se retiró el botón estándar de aprobación de los tres layouts. La vista final de coordinación muestra las dos semanas de A, incluida la vacía, y excluye B. La ruta directa de edición continúa denegada.

La cuenta técnica carecía de FLS sobre Activo__c. La lectura REST y el intento de preparación por Apex anónimo fueron rechazados antes de crear datos. El catálogo se administró con un Permission Set temporal limitado al objeto de proyecto y ese campo; asignación y componente fueron retirados y su ausencia se verificó. Se repitió ese acceso acotado para desactivar el proyecto histórico después de sus guardados legítimos. No se añadieron clases ni endpoints.

Catálogo final: tres proyectos ficticios con códigos P07_3B_DESARROLLO, P07_3B_REVISION y P07_3B_HISTORICO; los dos primeros activos y el tercero inactivo. Todas las semanas y líneas se crearon por el servicio desde sesiones funcionales, sin DML manual de claves, revisión o identidad.

### Resultados funcionales

| Recorrido real | Resultado observado |
|---|---|
| A: guardado conjunto y coma decimal | Cuatro celdas en un guardado; 240 minutos persistidos, revisión 1; valores recuperados tras recarga |
| A: cero, vacío y omisión | Eliminadas las dos celdas de desarrollo; las omitidas permanecen; dos líneas y 45 minutos, revisión 3 |
| Validación visual | 0,3 y exceso agregado de 24 horas rechazados; sin éxito y con borrador conservado |
| Decisiones de borrador | Cancelar cambio de semana, actualización y descarte conserva 24; aceptar descarte recupera 0,25 |
| Servicio bajo A | Rechazo VALIDACION sin cambios persistidos para petición inválida, incluida otra con un cambio válido y otro inválido |
| Dos pantallas de A | Revisión antigua rechazada; borrador conservado; consulta actual y dos opciones inicialmente desmarcadas |
| Reaplicación y doble envío | Seleccionado solo el histórico del martes; el valor 1 de revisión del lunes se conserva; una sola petición al pulsar dos veces, revisión 5 |
| Semana vacía | Semana anterior: alta de 15 minutos y borrado de la última línea; cabecera conservada, revisión 2 y total 0 |
| Histórico y futuro | Dos líneas históricas visibles y deshabilitadas tras desactivar el proyecto; días 25 a 29 bloqueados en la semana observada |
| B | Alta de 45 minutos y modificación a 60, revisión 2; no abre semana ni detalle de A |
| A frente a B | No abre la semana ni el detalle conocidos de B |
| Coordinación | Lee semana y detalle de A; no abre los de B; edición estándar denegada y servicio devuelve ACCESO_DENEGADO |
| Retirada y restauración | Al retirar A del grupo, recálculo observado y denegación real de semana y detalle; al restaurarlo, vuelve la lectura sin edición |
| Navegación estándar | Lista de coordinación con dos semanas de A, totales 105 y 0, revisiones 5 y 2; vistas de catálogo y detalle disponibles, sin alta directa |

Las denegaciones de lectura por URL se contrastan con la existencia del registro y UserRecordAccess: la pantalla genérica de registro no disponible no se interpreta por sí sola como diagnóstico de permisos. En el inventario de siete registros de semana/detalle, A lee cinco, B dos y coordinación cinco; ninguno tiene edición directa.

### Datos finales y conservación

| Función | Semana | Líneas activas | Minutos | Revisión |
|---|---|---:|---:|---:|
| A | 23/11/2026 | 3 | 105 | 5 |
| A | 16/11/2026 | 0 | 0 | 2 |
| B | 23/11/2026 | 1 | 60 | 2 |

Tres proyectos, tres semanas y cuatro líneas activas. Las tres líneas eliminadas durante los recorridos siguen en la papelera; no se purgaron. No hay duplicados de claves en las líneas activas ni cabecera de coordinación. Los rechazos posteriores conservan revisiones y minutos. Las pantallas de detalle y lista contrastan el resumen semanal con las líneas.

P06 conserva 432 registros de negocio y cuatro comparticiones manuales, sin diferencias en el inventario acotado de datos, definiciones, grupos, asignaciones y usuarios preexistentes. Los tres usuarios P07 nuevos se separan expresamente del inventario anterior. El contraste adicional de nueve entradas Apex ajenas a P07, incluidas las clases de renovaciones sin prefijo P06, tampoco presenta diferencias. Esta comprobación no es una auditoría general de la organización.

Login As se habilitó temporalmente para estas sesiones y terminó en false. SecuritySettings coincide íntegramente con la referencia inicial. La sesión final vuelve a la cuenta técnica; las concesiones temporales de catálogo no existen. Los identificadores de usuarios, registros, recibos completos y diagnósticos de operación permanecen privados y excluidos de Git.

### Revisión local y editorial

Revisados los 23 archivos afectados: catorce XML válidos, un JSON legible y 55 enlaces locales existentes. git diff --check sin incidencias tras corregir saltos finales. Sin atribuciones automáticas ni patrones de secretos detectados en este alcance. Las fuentes conservan las huellas contrastadas; no se presenta esta revisión como auditoría exhaustiva de seguridad.

### Límites y continuidad

Las pruebas acreditan una pantalla desactualizada, no inserción simultánea, carga o concurrencia real de transacciones. El rechazo inválido se produjo antes de escribir; el rollback después de DML conserva únicamente la evidencia Apex anterior. No se simula aquí pérdida real de respuesta después de confirmar.

Comprobación básica de etiquetas, controles, diálogos reales, foco visible y paso con Tab. El contenedor presenta desbordamiento y admite desplazamiento programático con lectura de sus totales. El desplazamiento mediante flechas o rueda no quedó acreditado por la automatización; tampoco lector de pantalla, contraste completo, navegación integral por teclado o auditoría de accesibilidad. La revisión manual pendiente está delimitada en [ACEPTACION.md](ACEPTACION.md).

API no habilitada en las funciones; no se concedió para ensayar otra ruta. Se comprobaron URLs estándar de lectura/edición y el servicio expuesto en la sesión, no una batería externa de API autenticada. No se ejecutaron jerarquía con un superior, instalación limpia ni informe operativo. La habilitación y los recorridos de negocio están ejecutados; la accesibilidad mantiene cobertura parcial y V1 permanece abierta.

[Evidencia sanitizada de fase 3B](evidencias/FASE-3B.json). Se conservan las evidencias previas, los fallos relevantes y la distinción entre preparación, compilación remota, despliegue y uso funcional.

## Antecedente: fase 3A, cuadrícula LWC y pruebas del componente completadas

Base revisada: 3551770c424bd26a06864db3398e7ced04877e55, main, remoto del repositorio registro-dedicacion-salesforce y árbol inicialmente limpio. Identidad del destino contrastada con el registro privado: Developer Edition compartida con P06, alias p06-renovaciones-dev, API 65.0. Se conserva el backend instalado; el manifiesto de esta fase contiene un único LightningComponentBundle.

### Comportamiento implementado

p07DedicacionSemanal incorpora selección de semana, siete días, selector de proyectos activos, filas persistidas e histórico inactivo, totales por fila/día/semana, borrador separado, guardado conjunto y errores contextualizados. La revisión se mantiene como texto, incluso por encima del entero seguro de JavaScript. Las cantidades con coma se normalizan solo si son válidas; no se redondea ni se presentan totales exactos con valores inválidos.

Una respuesta resuelta con ok=false conserva los cambios. Conflictos y resultados desconocidos exigen consultar el estado actual y decidir explícitamente qué descartar o reaplicar. La comparación no selecciona cambios por defecto, respeta la editabilidad actual y no guarda automáticamente. Las respuestas antiguas no sustituyen una selección más reciente. La coincidencia de valores tras una pérdida de respuesta no se presenta como confirmación causal de aquella petición.

Los controles se bloquean durante el guardado y no se fragmenta una petición que supere los límites. Cambiar de semana, actualizar o descartar con pendientes requiere confirmación. El componente expone tabla semántica, etiquetas por celda, región desplazable y focos de error/recuperación. Contrato, decisiones y límites en [ARQUITECTURA.md](ARQUITECTURA.md).

### Herramientas y pruebas locales

Dependencia directa de desarrollo fijada: @salesforce/sfdx-lwc-jest 7.1.2, etiqueta winter26 consultada; Jest 29.7.0 y compilador LWC 8.20.4. package-lock.json conserva el árbol. npm install y la reconstrucción posterior con npm ci terminaron correctamente con Node 24.13.0 y npm 11.6.2, sin cambios globales. Se conservaron avisos de obsolescencia transitivos; no se atribuye una auditoría de dependencias a esas operaciones.

Comandos reproducibles: npm ci, npm run test:unit y npm run test:unit:coverage. La ejecución final con cobertura supera 48/48 pruebas en dos suites, sin snapshots. Apex se simula como promesas de texto JSON; también se simulan zona horaria, LightningConfirm y componentes base Lightning.

| Cobertura Jest | Líneas | Ramas |
|---|---:|---:|
| modelo.js | 80/80; 100 % | 95/96; 98,95 % |
| p07DedicacionSemanal.js | 146/150; 97,33 % | 150/170; 88,23 % |
| Total JavaScript | 226/230; 98,26 % | 245/266; 92,10 % |

La cobertura no incluye el comportamiento real de componentes base ni equivale a cobertura funcional completa. La matriz [ACEPTACION.md](ACEPTACION.md) relaciona las pruebas con los criterios, conservando los pendientes de integración.

Se conservan los diagnósticos iniciales: mock de confirmación sin exportación ES module y archivo fixtures recogido como suite; después, un selector de prueba ambiguo entre celda y checkbox. Se corrigió la configuración y el selector, sin rebajar las aserciones. Las 44 pruebas siguientes pasaron; cuatro comprobaciones adicionales cubrieron corrección por fecha del servidor, confirmación inesperada, error de lectura fuera de orden y foco/etiquetas. Las 48 pasaron también tras npm ci.

### Validación y despliegue

| Operación | Identificador | Resultado final |
|---|---|---|
| Validación inicial del bundle | 0Afg700000L9TUDCA3 | Succeeded, success=true, checkOnly=true; 1 componente y 18 pruebas Apex |
| Primer despliegue | 0Afg700000L9GMQCA3 | Succeeded, success=true, checkOnly=false; 1 componente y 18 pruebas Apex |
| Recuperación previa a corrección | 09Sg700000bVksTEAS | Succeeded; cinco archivos coincidentes con el primer paquete |
| Validación de corrección | 0Afg700000L9eF4CAJ | Succeeded, success=true, checkOnly=true; 1 componente y 18 pruebas Apex |
| Despliegue final | 0Afg700000L94MtCAJ | Succeeded, success=true, checkOnly=false; 1 componente y 18 pruebas Apex |
| Recuperación final | 09Sg700000bVXdWEAW | Succeeded; cinco archivos coincidentes con las fuentes finales |

La revisión final detectó que el contador de pendientes ocultaba el aviso de contención y el mensaje de reaplicación. Se corrigió la prioridad visible, se adaptó la prueba al mensaje genérico real de Apex y se repitieron las 48 pruebas, la validación y el despliegue. La versión previa instalada se contrastó antes de sustituirla. Ambos paquetes y sus recibos se conservan; la segunda pareja de trabajos corresponde al resultado vigente.

RunSpecifiedTests seleccionó solo P07_DedicacionServiceTest: 18/18 pruebas remotas, sin fallos. Los recibos de este manifiesto LWC no aportan una medición nueva de cobertura Apex; la medición de fase 2A se conserva como antecedente. No se modificó Apex ni se ejecutó la batería P06.

La respuesta inicial Queued no se contabilizó como finalización. Las seis huellas del bundle y manifiesto coinciden con las fuentes finales comprobadas. Los cinco archivos recuperados solo omiten el salto de línea final. No se desplegaron tests, fixtures, dependencias, páginas, perfiles o permisos.

### Revisión editorial y local

Revisados los 21 archivos afectados: componente, modelo, pruebas, fixtures, manifiesto, configuración y lockfile, evidencia e instrucciones y documentación. Dos XML y tres JSON legibles, 42 enlaces locales existentes, UTF-8 y espaciado correctos; git diff --check sin incidencias. Sin atribuciones automáticas ni patrones de secretos detectados en ese alcance. Las fuentes de aplicación y pruebas conservan sus huellas comprobadas. No se presenta esta revisión como auditoría exhaustiva de dependencias o del equipo.

### Conservación y límites

El componente está disponible para páginas de aplicación Lightning; no se creó ni activó una página ni se sustituyó ninguna de P06. [INSTALACION.md](INSTALACION.md) indica cómo incorporarlo a una página P07 en la posterior demostración.

P07 mantiene cero proyectos, semanas y detalles persistentes; tres grupos vacíos y cuatro Permission Sets sin asignaciones. Licencias sin cambios: Salesforce 4/4 usadas y Salesforce Platform 0/6 usadas. No se crearon identidades funcionales ni se asignaron permisos al administrador.

P06 conserva 432 registros y cuatro comparticiones manuales de contrato, sin diferencias en el inventario acotado: campos devueltos por describe de cuatro objetos de negocio; Account Id/SystemModstamp; definiciones de objetos y permisos P06; grupos, pertenencias y asignaciones; perfiles, roles y estado activo de usuarios; inventario Apex P06. No es una auditoría general ni una repetición de sus demostraciones.

[Evidencia sanitizada de fase 3A](evidencias/FASE-3A.json): pruebas, cobertura, historial de correcciones, trabajos remotos, huellas, contraste y conservación. Recibos completos y diagnósticos permanecen en rutas privadas excluidas de Git. Las evidencias anteriores siguen intactas.

Fase 3A completada dentro del alcance de componente, pruebas locales, validación y despliegue. No se han realizado sesiones funcionales, comprobación real de controles base, teclado o lector de pantalla, pérdida de respuesta real ni concurrencia entre usuarios. No se cierra V1. El siguiente paso es la demostración integrada con identidades y datos ficticios P07, permisos mínimos y página específica; el informe corresponde a su fase posterior.

## Antecedente: fase 2A, servicio y protección de guardado completados

Base publicada: 816b8d13e83b08686e5ce747a17d17e5eff8fc51, rama main, remoto de registro-dedicacion-salesforce y árbol inicialmente limpio. Destino verificado mediante registro privado y consulta de Organization: Developer Edition compartida con P06, alias p06-renovaciones-dev, API 65.0. No se crearon organizaciones, autenticaciones ni identidades funcionales nuevas.

### Implementación

P07_DedicacionService consulta y guarda exclusivamente la semana propia. Valida el contrato estricto, identidad, permisos, fechas, precisión, proyectos activos, revisión y suma diaria del estado final; conserva las celdas omitidas y las cabeceras vacías. Los triggers de semana y detalle restringen las escrituras al contexto privado del servicio y protegen identidad, revisión, borrado, cascada, transferencia, reparentado y restauración. El resumen admite los cambios legítimos del guardado.

Se añaden P07_Consultar y P07_GuardarPropia y los Permission Sets P07_ServicioLectura y P07_GuardadoPropio, sin CRUD de escritura ni asignaciones. El modelo, grupos, reglas y permisos anteriores no forman parte del manifiesto nuevo. Contrato y transacciones en [ARQUITECTURA.md](ARQUITECTURA.md); seguridad en [ACCESO.md](ACCESO.md).

### Resultados remotos finales

| Operación | Identificador | Resultado |
|---|---|---|
| Validación inicial | 0Afg700000L9cm2CAB | Failed, checkOnly=true; errores de compilación, cero pruebas ejecutadas |
| Validación corregida | 0Afg700000L9SLzCAN | Succeeded, checkOnly=true; 8/8 componentes y 16/16 pruebas |
| Validación final con comprobaciones adicionales | 0Afg700000L9ei5CAB | Succeeded, checkOnly=true; 8/8 componentes y 18/18 pruebas |
| Despliegue | 0Afg700000L9H7ECAV | Succeeded, success=true, checkOnly=false; 8/8 componentes y 18/18 pruebas |
| Recuperación | 09Sg700000bUiO7EAK | Succeeded; 12 archivos contrastados |

Se corrigieron tres causas de compilación: la excepción interna debe terminar en Exception; System.JSON evita la colisión con un parámetro json; getDmlStatusCode devuelve texto y la clasificación recibe ese tipo. Los rechazos derivados de clases no compiladas en triggers y permisos desaparecieron con esas correcciones. Los recibos fallidos se conservan.

Las dos comprobaciones añadidas tras la primera validación satisfactoria cubren reparentado, acceso ajeno USER_MODE, altas directas masivas, límite de veinte proyectos y editabilidad de fechas futuras. Se volvió a validar el paquete completo. Las trece huellas de fuentes y manifiesto coinciden antes y después del despliegue; no se modificó el paquete validado.

RunSpecifiedTests ejecutó únicamente P07_DedicacionServiceTest. La respuesta inicial Queued no se contabilizó como resultado final. Cobertura real de validación final y despliegue:

| Componente | Líneas cubiertas / totales | Cobertura |
|---|---:|---:|
| P07_DedicacionService | 276 / 282 | 97,87 % |
| P07_SemanaGuard | 1 / 1 | 100 % |
| P07_DedicacionGuard | 1 / 1 | 100 % |

Sin fallos de pruebas ni avisos de cobertura. Las seis líneas no cubiertas corresponden al tratamiento de excepciones DML/query reales; la clasificación de sus códigos se comprueba separadamente y no acredita una colisión real. La cobertura de líneas no se presenta como cobertura completa de ramas o concurrencia.

### Atomicidad y acceso comprobados

La prueba de alta observa dos escrituras y un resumen de 60 minutos antes de provocar el fallo: después del rollback no quedan cabecera ni detalles. La prueba mixta observa cuatro etapas DML, 135 minutos y revisión 2; el rollback recupera las dos líneas originales, 90 minutos y revisión 1. Un guardado posterior con la revisión original funciona. El punto de fallo es privado, solo operativo en tests y no deshabilita las defensas.

Las pruebas contrastan CRUD y FLS explícitamente, permisos personalizados y acceso a registros con USER_MODE bajo identidades aisladas. El miembro puede guardar por el servicio sin CRUD de escritura ordinario; faltas de CRUD, FLS o permiso de operación se rechazan. Coordinación con compartición Read aislada no puede guardar. Los intentos directos se prueban además en SYSTEM_MODE para acreditar las defensas de los triggers.

### Contraste y conservación

Los doce archivos recuperados coinciden con las fuentes por contenido: Salesforce omite el salto de línea final de los cuatro archivos de código y añade isLicensed=false en los dos permisos personalizados. Estas normalizaciones se registran expresamente; no se cambiaron las fuentes tras validar.

P07 conserva cero proyectos, semanas y detalles persistentes. Los tres grupos siguen vacíos y con DoesIncludeBosses=false. Los cuatro Permission Sets P07 permanecen sin asignaciones. Siguen ocupadas las cuatro licencias Salesforce y libres las seis Salesforce Platform. Los seis usuarios de pruebas y sus asignaciones no persisten. No se modificó ni repitió el ajuste de jerarquía ya verificado en fase 1B.

P06 conserva los 432 registros inventariados: 11 Account, 198 contratos, 196 seguimientos, 20 ejecuciones y 7 incidencias, además de las cuatro comparticiones manuales de contrato. No hay diferencias en los campos contrastados de los cuatro objetos de negocio; Id/SystemModstamp de Account; definiciones de objetos y Permission Sets P06; grupos, pertenencias y asignaciones P06; perfiles, roles y estado activo de usuarios; inventario Apex P06. No se ejecutaron pruebas P06 ni sus demostraciones. Es una comprobación acotada, no una auditoría de toda la organización.

### Revisión local y editorial

Revisados los 24 archivos afectados: código, metadatos, manifiesto, evidencia JSON e instrucciones y documentación. XML y JSON legibles, enlaces locales existentes, UTF-8 correcto y git diff --check sin incidencias. Revisión de atribuciones, coautorías y patrones de secretos sin hallazgos en ese alcance; no es una auditoría exhaustiva del equipo. Las fuentes del paquete mantienen las huellas validadas y desplegadas.

### Evidencias y límites

[Evidencia sanitizada de fase 2A](evidencias/FASE-2A.json): trabajos finales, errores anteriores, pruebas, cobertura, huellas, recuperación y conservación. Recibos completos y datos identificativos permanecen en rutas privadas excluidas de Git. Las evidencias de fases anteriores se conservan.

Fase 2A completada dentro del alcance de servicio y pruebas aisladas. No se ha probado concurrencia real, carrera de creación, espera de bloqueo, sesiones ordinarias, retirada de grupos ni cambios de zona horaria o medianoche. La restauración real de detalle se rechaza; la restauración de cabecera está denegada en código pero no se fabricó una cabecera borrada eludiendo su defensa.

La [matriz de aceptación](ACEPTACION.md) distingue esta evidencia de las comprobaciones pendientes. V1 no está cerrada. El siguiente paso es la cuadrícula LWC y sus pruebas de borrador, conversión local, errores, conflicto y resultado desconocido, manteniendo el contrato implementado. Informe y sesiones por función requieren su fase correspondiente.

## Antecedente: fase 1B, instalación técnica completada

Destino verificado: Developer Edition compartida con P06, alias operativo p06-renovaciones-dev y API 65.0. Se reutilizó la autenticación técnica existente, sin cambiar el destino predeterminado ni crear usuarios. Los identificadores de organización y cuenta permanecen en el registro privado. Las escrituras se limitaron al paquete P07 y a la jerarquía de sus objetos de proyecto y semana.

Referencia publicada: 50354b06ffd6c9d11fb8ec1afebb10b49df47214, rama main y remoto de registro-dedicacion-salesforce. Se conservaron los cambios documentales existentes. La aceptación del paquete corresponde a esa base más la corrección local de los literales de la regla del catálogo; no se atribuye al commit sin corregir. Las huellas de las fuentes se conservaron antes de validar y se comprobaron antes y después del despliegue.

| Operación | Identificador | Resultado final |
|---|---|---|
| Validación inicial | 0Afg700000L9NyzCAF | Failed, checkOnly=true; un error en P07_CatalogoParticipantes |
| Segunda validación | 0Afg700000L9OlNCAV | Failed, checkOnly=true; mismo rechazo con True/False |
| Validación corregida | 0Afg700000L9P7xCAF | Succeeded, success=true, checkOnly=true; 33 componentes, cero errores |
| Despliegue | 0Afg700000L9Hf4CAF | Succeeded, success=true, checkOnly=false; 33 componentes, cero errores |
| Recuperación de definiciones | 09Sg700000bVBwMEAW | Succeeded; 31 XML recuperados en una ruta temporal separada |

Las respuestas iniciales Queued no se contabilizan como resultados finales. Las tres validaciones se ejecutaron con dry-run. Antes de desplegar se comprobó que no habían persistido componentes P07 y que las fuentes coincidían con las de la validación satisfactoria. NoTestRun: cero pruebas Apex; el paquete no contiene clases ni LWC.

### Corrección concreta

Salesforce rechazó los valores true/false de SharingCriteriaRule con el mensaje «Utilice "Verdadero" o "Falso"». El cambio a True/False también fue rechazado. Los literales Verdadero/Falso fueron aceptados con la cuenta técnica del destino. Solo se modificaron esos dos valores en ProyectoDedicacion__c.sharingRules-meta.xml; se mantuvieron Activo__c, equals, el filtro 1 OR 2, el grupo y el acceso Read. La regla incluye activos e inactivos y no amplía su alcance funcional.

### Contraste instalado

Se contrastaron tres objetos, doce campos, nueve validaciones activas, el resumen semanal, tres grupos, dos Permission Sets y dos reglas de compartición. Los 31 XML fuente conservan sus definiciones en la recuperación. Salesforce omite fullName dentro del XML recuperado de los tres grupos; el nombre de archivo y DeveloperName consultado por API coinciden. No hay diferencias inesperadas.

Proyecto y semana mantienen Private interno y externo; detalle mantiene ControlledByParent. Grant Access Using Hierarchies se desactivó para proyecto y semana y se verificó reabriendo el formulario. De 375 controles comparados solo cambiaron esas dos casillas. Los tres grupos mantienen doesIncludeBosses=false y cero miembros; los dos permisos mantienen lectura, sin escritura ni privilegios amplios, y cero asignaciones. Los tres objetos P07 contienen cero registros.

REST describe muestra al operador nueve campos personalizados. Su perfil no tiene concesiones FLS sobre los tres campos opcionales nuevos; no se ampliaron permisos para corregir el inventario. Los doce campos se verificaron mediante Metadata API y las seis concesiones FLS de los dos Permission Sets se comprobaron por API. Esta diferencia no se presenta como un defecto del paquete ni como prueba de acceso funcional.

### Capacidad y conservación del destino compartido

La cuenta técnica conserva permisos efectivos de API, modificación de metadatos, personalización y gestión de compartición. Las cuatro licencias Salesforce están ocupadas; hay seis Salesforce Platform libres y un perfil Platform disponible con API e informes. Existe capacidad de licencias prevista para tres identidades funcionales diferenciadas, pendientes de creación, configuración y pruebas. No se liberaron licencias ni se reutilizaron identidades funcionales de P06.

La referencia previa y el contraste final conservan 432 registros: 11 Account, 198 contratos, 196 seguimientos, 20 ejecuciones y 7 incidencias. Permanecen las cuatro comparticiones manuales de contratos inventariadas al comenzar. No hay diferencias en los campos contrastados de los cuatro objetos de negocio, los identificadores y SystemModstamp de Account, las definiciones de los cuatro objetos personalizados, los Permission Sets P06, grupos, pertenencias, asignaciones, las asignaciones de perfil y rol y el estado activo de los usuarios ni el inventario Apex. Este alcance no constituye una auditoría de toda la configuración de la organización.

### Evidencias y siguientes fases

[Evidencia sanitizada de fase 1B](evidencias/FASE-1B.json): resultados finales, errores, huellas, contraste, jerarquía, capacidad y conservación. Los recibos completos, inventarios identificativos y diagnósticos del navegador permanecen en rutas privadas excluidas de Git. [INSTALACION.md](INSTALACION.md) describe el procedimiento reproducible y sus límites.

La fase 1B técnica está completada. Todos los criterios funcionales AC-01 a AC-25 siguen pendientes: no se han probado guardado, atomicidad, concurrencia, agregación por DML ni seguridad efectiva con sesiones ordinarias. El siguiente desarrollo previsto es el servicio Apex y la protección de escrituras; la cuadrícula LWC corresponde a una fase posterior.

## Antecedente: fase 1A, modelo declarativo y acceso de lectura

Metadatos locales preparados: tres objetos, doce campos personalizados, nueve validaciones, tres grupos públicos, dos Permission Sets de lectura y dos reglas de compartición. El manifiesto [fase-1a.xml](../manifest/fase-1a.xml) selecciona diez miembros de nivel superior; incluye los campos y validaciones de los objetos.

El modelo incorpora el total semanal mediante resumen de todas las líneas. Conserva claves únicas, fechas de lunes a domingo, límites por línea, coherencia parcial de identidad, restricción de eliminación de proyectos y ausencia de reparentado. El [modelo exacto](MODELO_DATOS.md) distingue estas defensas de las invariantes pendientes de servidor.

Los permisos no habilitan escritura ordinaria. La [solución de acceso](ACCESO.md) concreta un ámbito por propietarios y grupos, catálogo de lectura para participantes y un requisito de instalación pendiente: desactivar y verificar la jerarquía de los objetos antes de habilitar participantes. No se han asignado usuarios ni permisos.

## Continuidad de la base publicada

Al comenzar esta fase, HEAD y la referencia local origin/main coincidían en fdd1f9e10d20b88c20598c5e367c34b1a3d72936, en rama main y con remoto del proyecto registro-dedicacion-salesforce. No se forzó ninguna referencia ni se consultó el remoto para actualizarla.

Existía una modificación local en .forceignore que añadía exclusiones para jsconfig.json y .eslintrc.json. Se conservó íntegra. El estado histórico sin commits corresponde únicamente a la creación inicial de la base; no describe el punto de partida de esta fase.

## Comprobaciones locales de fase 1A

| Comprobación | Resultado y límite |
|---|---|
| XML y JSON | 32 XML fuente/manifiesto bien formados, con namespace Metadata API; configuración DX legible y API 65.0 coherente con el manifiesto |
| Inventario y referencias | Tres objetos, doce campos, nueve validaciones; relaciones, resumen, campos de fórmulas y de error, grupos y diez miembros del manifiesto resueltos |
| Acceso estático | Dos permisos de solo lectura; sin FLS sobre campos universalmente obligatorios; dos reglas Read y tres grupos sin propagación jerárquica de grupo |
| Fórmulas | Referencias y paréntesis revisados; funciones contrastadas con documentación oficial. No se ejecutó el motor de fórmulas de Salesforce |
| Conversión final | CLI: status 0, sin avisos; once archivos Metadata API completos en tmp/fase-1a-mdapi-20261124, excluidos de Git |
| Integridad del paquete | XML convertido legible; inventario completo y contenido de los doce campos y nueve validaciones conservado respecto a las fuentes |
| Formato y documentación | Enlaces locales, UTF-8, acentos, finales de línea y diferencias revisados; el formato previo de .forceignore se conservó |
| Revisión editorial | Archivos propios actuales, metadatos e instrucciones revisados; sin atribuciones automáticas ni patrones de credenciales detectados en el alcance revisado |

Se revisaron 47 archivos propios actuales, incluidos los 32 XML nuevos. La búsqueda de patrones de secretos es acotada y no constituye una auditoría exhaustiva.

### Incidencia de conversión resuelta

Dos intentos en .local/fase-1a-mdapi-20261124 y .tmp/fase-1a-mdapi-20261124 devolvieron status 0, pero solo escribieron package.xml. La comprobación de inventario los rechazó como paquetes incompletos. No se contabilizan como conversiones satisfactorias.

La inspección del convertidor instalado mostró que StandardWriter aplica ForceIgnore al destino y que el filtro predeterminado **/.* omite carpetas ocultas. La conversión final utilizó tmp/, ya excluido por .gitignore y sin prefijo de carpeta oculta. Los dos resultados incompletos y el paquete final permanecen separados en directorios temporales excluidos; no se incorporan al repositorio.

Durante la preparación se corrigió también la pérdida de acentos causada por la codificación de una tubería de terminal. La revisión posterior confirma textos UTF-8 correctos; el paquete final se generó después de esa corrección.

## Comprobaciones no ejecutadas en fase 1A

No hubo autenticación, consulta a organizaciones, compilación de Salesforce, despliegue, carga de registros ni sesiones funcionales. No hay Apex o LWC que justifique pruebas Apex o Jest en esta entrega. No se instalaron dependencias ni se modificaron herramientas globales.

La conversión comprueba ensamblado de formato y conservación de contenido; no valida restricciones de plataforma, expresiones de fórmula ni seguridad efectiva. La API, las relaciones, las fórmulas, el resumen y los permisos necesitan aceptación y pruebas en un destino P07 identificado.

## Siguiente paso al terminar fase 1A

Identificar el destino exclusivo P07 y preparar una fase de compilación y verificación del modelo y acceso. Antes de asignar funciones, comprobar edición, API, licencias, identidades, ajuste de jerarquía y pertenencias. No cargar dedicaciones mediante rutas provisionales que suplanten el protocolo pendiente.

Después se implementarán el servicio de lectura y guardado, las protecciones de escritura y sus pruebas; posteriormente, la cuadrícula LWC y el informe. El [contrato de arquitectura](ARQUITECTURA.md) y los [criterios AC-01 a AC-25](ACEPTACION.md) recogen rollback posterior a escritura, repetición de peticiones, resultado desconocido y lectura coherente como escenarios previstos, no ejecutados.

## Antecedentes conservados

La inspección inicial constató la ausencia de carpeta P07 y revisó las herramientas sin modificar organizaciones. Después se creó la base independiente con quince archivos: configuración DX, exclusiones, convenciones y documentación. En aquel momento el repositorio estaba recién inicializado, sin commits ni remoto; la base publicada posterior queda identificada arriba.

Las comprobaciones de aquella base cubrieron JSON, estructura, enlaces, formato y exclusiones. Los inventarios de herramientas de [ENVIRONMENT.md](ENVIRONMENT.md) corresponden a esa inspección y no se presentan como una revisión general repetida en fase 1A.
