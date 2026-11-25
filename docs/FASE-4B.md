# Fase 4B — Consulta operativa propia

Fecha: 25/11/2026. Base revisada: 14dc47a8b68a4b1d062ed11a8ac3bc13b07d4edf, rama main, árbol inicialmente limpio. La consulta LWC y Apex está implementada, validada, desplegada y habilitada mediante tres asignaciones específicas. Su demostración con las tres identidades ordinarias sigue pendiente. Fase 4 y V1 abiertas.

## Comportamiento y contrato

P07 Dedicación incorpora «Consulta de dedicación» en lugar de la entrada estándar Informes. El informe y su carpeta se conservan instalados, sin asignaciones de P07_InformesLectura y con RunReports=false. El cambio de pestaña facilita la navegación; no sustituye la autorización.

La vista permite seleccionar una semana o un intervalo inclusivo de lunes y pulsar Consultar. Muestra semanas, miembros, proyectos, detalle diario y subtotales en minutos enteros. Los proyectos inactivos mantienen su histórico. Una semana sin líneas devuelve un resultado vacío y no altera su cabecera. No ofrece edición, exportación, creación de informes ni administración.

P07_InformeService.consultar recibe un único texto JSON con desde y hasta. Ambos deben ser lunes reales ISO y desde no puede ser posterior a hasta; para una semana, los dos coinciden. Rechaza claves adicionales. La respuesta contiene ok, resultado y errores. El contrato completo está en [ARQUITECTURA.md](ARQUITECTURA.md#contrato-de-consulta-operativa-de-fase-4b).

Se admiten hasta 1.000 líneas visibles, sin limitar silenciosamente el número de semanas. Se consultan como máximo 1.001; el exceso produce LIMITE_VOLUMEN, sin detalle ni sumas parciales. Detalle y todos los totales proceden de las mismas líneas. No existe paginación ni promesa de volumen ilimitado. Una semana individual que supere la capacidad también requiere un error explícito.

El cliente retira resultados al cambiar filtros o iniciar otra consulta. Ignora respuestas antiguas y no conserva cifras anteriores tras fallos. Contrasta fechas aplicadas, integridad, duplicados, cantidad de líneas y sumas antes de presentar éxito. Etiquetas, tablas semánticas, avisos y foco de resumen/error están comprobados en DOM simulado.

## Autorización

API 65.0, with sharing, P07_Consultar y comprobaciones de lectura de objetos y campos. Las dos consultas de negocio utilizan USER_MODE explícito. Los miembros con P07_GuardarPropia se limitan a su propia identidad y propiedad; coordinación utiliza la compartición existente. Las etiquetas de miembro proceden de la relación accesible de usuario; no se ampliaron permisos de User.

Los proyectos relacionados se recuperan por sus identificadores en USER_MODE. Si falta acceso a alguno, la consulta completa devuelve ACCESO_DENEGADO. La falta de permiso, CRUD o FLS no se presenta como una semana vacía. El servicio no ejecuta DML, Analytics API ni una consulta mediante identidad administrativa.

P07_ConsultaInforme concede solo acceso a P07_InformeService y visibilidad de P07_InformeOperativo. Requiere los permisos P07 previos; no añade permisos de operación, CRUD, FLS, API o RunReports. Se comprobaron identidad, perfil y estado activo antes de crear las tres asignaciones. Permanecen las seis anteriores: nueve explícitas en total. SetupEntityAccess y metadatos acreditan el acceso a clase configurado; no equivalen a una llamada real desde Lightning como miembro.

## Pruebas y despliegue

| Comprobación | Resultado |
|---|---|
| Jest | 92/92, cuatro suites; 57 regresiones existentes y 35 pruebas nuevas |
| Apex aislado | 8 pruebas nuevas de P07_InformeServiceTest y 18 de P07_DedicacionServiceTest |
| Validación 0Afg700000LJDjpCAH | Succeeded, done=true, checkOnly=true; 7/7 componentes, 26/26 pruebas |
| Despliegue 0Afg700000LJEUbCAP | Succeeded, done=true, checkOnly=false; 7/7 componentes, 26/26 pruebas |
| Recuperación 09Sg700000bktiXEAQ | Succeeded; 13 archivos contrastados |
| Servicio nuevo | 100/104 líneas cubiertas en cada ejecución Apex |

Apex usa SeeAllData=false, usuarios y datos aislados. Comprueba ámbito propio y coordinación, compartición ajena que no amplía la consulta propia, ausencia de permiso/CRUD/FLS, fechas inválidas, relación inaccesible, histórico, semana vacía, papelera conservada, sumas y ausencia de DML durante la consulta.

La frontera de volumen se prueba con cuatro líneas y un límite reducible solo durante tests: cuatro se aceptan y el exceso de tres se rechaza sin resultado parcial. No constituye una carga de 1.001 registros ni una prueba de rendimiento. El límite productivo permanece fijado en 1.000. Un test demuestra expresamente que una llamada Apex directa de runAs no prueba la puerta de acceso a clase de Lightning.

Jest simula Apex y componentes base. Comprueba peticiones, fechas, carga, duplicados de envío, vacío, fallos y recuperación, cambios de filtro, respuestas fuera de orden, contratos incoherentes, etiquetas y foco. No acredita comportamiento real de los controles base ni accesibilidad completa.

Las catorce huellas de fuentes y manifiesto se mantuvieron entre validación y despliegue. Se contrastaron los trece archivos recuperados normalizando CRLF/LF, salto final y formato XML. Salesforce añadió únicamente los valores predeterminados isNavTabPersistenceDisabled=false e isOmniPinnedViewEnabled=false de CustomApplication. No se modificaron el modelo, el servicio de guardado, sus triggers ni la cuadrícula.

Una comprobación local de asignaciones se detuvo antes de escribir porque esperaba un objeto en classAccesses y Metadata API devolvió una lista. Se corrigió el comprobador y se verificaron las tres asignaciones; no se alteró el permiso para superar la comprobación. No hubo rechazos de compilación ni pruebas fallidas en la validación o el despliegue.

## Conservación y referencia actual

P07 conserva tres proyectos, tres cabeceras, cuatro líneas activas y tres eliminadas. Coinciden los campos inventariados y SystemModstamp, informes y carpetas P07/P06, permiso estándar retirado, grupos, pertenencias y seis asignaciones anteriores. SecuritySettings coincide y Login As=false.

P06 conserva 432 registros, cuatro comparticiones manuales, grupos, pertenencias, asignaciones, usuarios preexistentes, metadatos de objetos/permisos e inventario Apex comprobados. No se ejecutaron sus pruebas. Licencias sin cambios: Salesforce 4/4 utilizadas y Platform 3/6.

La consulta técnica actual de líneas y propietarios confirma:

| Referencia | Líneas | Minutos | Revisión de cabecera |
|---|---:|---:|---:|
| A, 23/11/2026 | 3 | 105 | 5 |
| B, 23/11/2026 | 1 | 60 | 2 |
| A, 16/11/2026 | 0 | 0 | 2 |

El proyecto histórico conserva dos líneas que suman 45 minutos. UserRecordAccess sobre diez registros actuales ofrece ocho legibles para A, cinco para B y ocho para coordinación; ninguno editable. Coordinación tiene el conjunto legible de A y no la semana ni la línea de B.

Los totales se recalcularon desde las líneas. La cuenta técnica no dispone de los campos opcionales Activo__c, Usuario__c y TotalMinutos__c en esta lectura; no se ampliaron permisos para obtenerlos. El estado inactivo sigue respaldado por la evidencia histórica y la conservación de SystemModstamp, no por una nueva lectura de ese campo.

## Comprobación funcional pendiente

Solo se encontró la sesión técnica, contrastada con la cuenta de instalación. La apertura directa de la pestaña nueva mostró «La página no existe» en esa sesión, que no tiene la nueva asignación; se restauró su página inicial. Este resultado no demuestra un defecto de navegación de A/B/coordinación ni una denegación del servicio Apex. Tampoco acredita la carga del nuevo componente.

No se abrieron sesiones ordinarias ni se activó Login As. Faltan el recorrido de la nueva consulta y teclado como A, B y coordinación, la comprobación de acceso a clase a través de Lightning y la denegación real de ejecución de informes estándar ajenos con RunReports=false. Las asignaciones, las pruebas aisladas y UserRecordAccess no sustituyen esas observaciones.

El siguiente paso es disponer de sesiones legítimas de las tres identidades existentes y ejecutar esos recorridos sin modificar datos. No se concedieron permisos temporales ni se modificaron contraseñas o políticas. Se mantienen los pendientes de concurrencia real, resultado desconocido, lectura concurrente coherente, superior jerárquico sin pertenencia y accesibilidad completa. [ACEPTACION.md](ACEPTACION.md) conserva los criterios.

Evidencia sanitizada: [FASE-4B.json](evidencias/FASE-4B.json). Se conservan resultados y errores anteriores. La revisión editorial cubre los archivos propios actuales y entregables nuevos; no modifica el historial.
