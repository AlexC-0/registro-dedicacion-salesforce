# Estado del proyecto

Fecha: 24/11/2026.

## Fase 3A: cuadrícula LWC y pruebas del componente completadas

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
