# Acceso e identidades

## Solución de fase 1A

Se define un único ámbito explícito de coordinación para V1 mediante grupos públicos y una regla de propietario. La pertenencia al grupo de titulares determina el ámbito; no se infiere a partir del proyecto ni se crea un objeto de equipos.

| Componente | Configuración instalada |
|---|---|
| ProyectoDedicacion__c | Private interno y externo |
| SemanaDedicacion__c | Private interno y externo |
| DedicacionDiaria__c | ControlledByParent interno y externo |
| P07_Participantes | Destinatarios autorizados de lectura del catálogo |
| P07_MiembrosAmbito | Propietarios cuyas semanas integran el ámbito |
| P07_CoordinacionAmbito | Destinatarios de lectura del ámbito |
| Semana: P07_LecturaAmbito | Read desde propietarios de P07_MiembrosAmbito hacia P07_CoordinacionAmbito |
| Proyecto: P07_CatalogoParticipantes | Read hacia P07_Participantes para Activo=true OR Activo=false |

Los tres grupos tienen doesIncludeBosses=false. No contienen usuarios, roles ni grupos anidados. Las pertenencias no se trasladan al desplegar el tipo Group: deberán configurarse y comprobarse en el destino P07.

La regla del catálogo incluye activos e inactivos de cualquier propietario para conservar su lectura histórica. La regla semanal no comparte entre miembros: solo con coordinación. Un miembro fuera del ámbito podrá pertenecer a P07_Participantes para consultar el catálogo sin que sus semanas entren en el ámbito.

## Matriz de acceso

| Recurso o acción | Miembro | Coordinación |
|---|---|---|
| Catálogo activo e inactivo | Lectura, con pertenencia a participantes | Lectura, con pertenencia a participantes |
| Semana y líneas propias | Lectura por propiedad | Lectura de las propias si existen |
| Semanas y líneas del ámbito | Sin concesión adicional | Lectura por la regla del ámbito |
| Dedicación ajena fuera del ámbito | Sin concesión | Sin concesión |
| DML directo sobre los tres objetos | No concedido | No concedido |
| Guardar semana propia por el servicio | Con P07_GuardadoPropio y lectura efectiva | No concedido con P07_ServicioLectura |
| Transferir cabeceras o restaurar registros | No habilitado | No habilitado |
| Administrar catálogo | No concedido | No concedido |

Están instalados P07_MiembroLectura y P07_CoordinacionLectura, sin asignaciones. Ambos conceden únicamente Read sobre los tres objetos, sin Create, Edit, Delete, View All Records, Modify All Records ni View All Fields. No añaden permisos de sistema, acceso Apex, perfiles, usuarios o asignaciones. Sus concesiones actuales son iguales; la diferencia funcional la aportan propiedad y grupos, y la separación permite evolucionar la escritura del miembro sin concederla a coordinación.

FLS explícita de lectura y sin edición: Proyecto.Activo__c, Semana.Usuario__c y Semana.TotalMinutos__c. No se serializan permisos de campos universalmente obligatorios ni de la relación master-detail; Salesforce no admite desplegar FLS de campos obligatorios desde API 30.0. Los campos estándar de nombre e identidad siguen las capacidades del objeto. [Referencia PermissionSet](https://developer.salesforce.com/docs/platform/api-metadata/references/meta-types/metadata-permissionset.html).

Los Permission Sets son aditivos: los valores false no revocan permisos que procedan de un perfil u otra asignación. Antes de asignarlos se comprobará el acceso efectivo de identidades con perfil mínimo y sin otras concesiones amplias.

## Jerarquía: ajuste instalado y verificado

Private no desactiva por sí solo el acceso ascendente de los propietarios. doesIncludeBosses=false limita la propagación de la compartición de cada grupo, pero no sustituye el ajuste del objeto.

En fase 1B se desactivó Grant Access Using Hierarchies para SemanaDedicacion__c y ProyectoDedicacion__c desde Sharing Settings. Se guardó y reabrió el formulario: ambas casillas permanecen desmarcadas. La comparación de 375 controles confirma que solo cambiaron las dos casillas previstas. Los accesos internos y externos de ambos objetos siguen en Private; el detalle conserva ControlledByParent.

Este ajuste se aplica en Setup y no está representado por un atributo inventado en los XML. El procedimiento reproducible figura en [INSTALACION.md](INSTALACION.md). Continúan pendientes las pruebas de acceso efectivo, incluida una identidad superior en jerarquía sin pertenencia al ámbito y la retirada de miembros de grupos. [Configuración oficial](https://help.salesforce.com/s/articleView?id=sf.admin_sharing.htm&language=en_US&type=5).

## Servicio y escritura de fase 2A

Los permisos anteriores permanecen intactos y sin asignaciones. Se añaden dos Permission Sets, también sin asignaciones:

| Permission Set | Clase y permisos personalizados | Combinación prevista |
|---|---|---|
| P07_GuardadoPropio | P07_DedicacionService; P07_Consultar y P07_GuardarPropia | P07_MiembroLectura y acceso al catálogo |
| P07_ServicioLectura | P07_DedicacionService y P07_Consultar | P07_CoordinacionLectura y compartición pertinente |

Ninguno añade CRUD, FLS de edición, permisos de sistema o acceso general a registros. La clase exige los permisos personalizados, Read de los tres objetos y lectura de todos los campos utilizados. Las consultas son USER_MODE y la clase with sharing. El servicio solo acepta la semana del solicitante; coordinación consultará el ámbito mediante las superficies de lectura previstas, todavía pendientes de implementación funcional.

El DML interno SYSTEM_MODE es una capacidad acotada del servicio para materializar cambios propios calculados y autorizados. No se exige Create/Edit/Delete ordinario porque habilitaría rutas que no forman parte del contrato; tampoco se presenta ese DML como ejecución en modo usuario. Los triggers comprueban contexto privado, operación, identidad y valores previstos, incluidos los cambios legítimos del resumen. No existe bypass público. El protocolo se detalla en [ARQUITECTURA.md](ARQUITECTURA.md).

Se deniegan el borrado de cabeceras y su cascada, transferencias, reparentado, restauraciones y escritura directa. Eliminar una celda requiere el guardado protegido. La coordinación de solo lectura no obtiene permiso de guardado por tener acceso a la clase.

## Evidencia aislada de seguridad en fase 2A

P07_DedicacionServiceTest crea seis usuarios de prueba con perfil Salesforce Platform, permisos y proyectos aislados; todo se revierte automáticamente al terminar cada prueba. No crea identidades funcionales persistentes ni modifica asignaciones existentes.

Se comprueban por separado permisos efectivos de esquema, permiso de operación y acceso a registros. El miembro tiene Read pero carece de Create/Edit/Delete ordinarios y consigue guardar por el servicio. Otra identidad tiene P07_Consultar pero carece de CRUD; otra tiene Read de objetos sin FLS de Activo__c; una tercera tiene lectura sin permiso de operación. Las tres reciben ACCESO_DENEGADO. No se usa runAs por sí solo como prueba de CRUD/FLS.

Dos miembros conservan semanas propias distintas y no pueden consultar la semana o detalles ajenos mediante USER_MODE. Un proyecto privado ajeno no puede usarse al guardar. Coordinación recibe en el test una compartición Manual Read de una semana, puede consultarla en USER_MODE y sigue sin poder guardar por el servicio. Esta compartición aislada no demuestra la regla de grupos en sesiones ordinarias.

Se prueban intentos de DML directo en SYSTEM_MODE para confirmar que los triggers mantienen las defensas incluso sin la barrera de CRUD. Incluyen altas masivas, cambios de identidad, minutos o revisión, transferencia, reparentado, eliminación y restauración de un detalle. La restauración de cabecera está denegada en código, pero no se ha preparado una cabecera borrada eludiendo el bloqueo para ejecutar esa rama.

Estas pruebas no acreditan sesiones comerciales, pertenencias reales, acceso por API autenticada como cada función, jerarquía ni retirada de grupos. Esos recorridos permanecen pendientes en [ACEPTACION.md](ACEPTACION.md).

## Verificación futura

El destino compartido, la edición, API y licencias se comprobaron en fase 1B. Hay seis licencias Platform libres; se prevén identidades diferenciadas para miembro, coordinación y persona fuera del ámbito. Su creación, permisos mínimos y sesiones siguen pendientes. No se liberan licencias ni se reutilizan identidades funcionales de P06.

En el destino se contrastarán perfil, Permission Sets, pertenencias, jerarquía, comparticiones y sesiones ordinarias. Una cuenta administrativa o una consulta técnica de acceso no sustituye las pruebas por función. No se han creado identidades funcionales persistentes ni asignado permisos fuera de los tests aislados.

## Estado de fase 1B

Instalación y contraste técnicos completados. Los tres grupos existen con cero miembros y doesIncludeBosses=false. Los dos Permission Sets conceden Read sobre los tres objetos y tres permisos FLS de lectura cada uno, sin escritura ni privilegios amplios; no tienen asignaciones. No hay registros P07.

El perfil técnico existente no tiene concesiones FLS sobre Activo__c, Usuario__c y TotalMinutos__c. Su REST describe muestra nueve campos personalizados; Metadata API confirma los doce. No se asignaron permisos P07 al operador para alterar ese resultado. La presencia de las definiciones y concesiones no sustituye una sesión funcional.

La regla de catálogo conserva Activo verdadero O falso y acceso Read. En este destino, los criterios de casilla exigieron los literales Verdadero/Falso; true/false y True/False fueron rechazados. No cambió el alcance de la regla. Los resultados, conservación de P06 y límites constan en [STATUS.md](STATUS.md).

## Configuración y comprobación de fase 3B

Estado vigente: tres identidades ficticias exclusivas P07 activas. La configuración vacía descrita en las fases anteriores es histórica.

| Función | Perfil | Permisos explícitos | Grupos |
|---|---|---|---|
| A | P07_AccesoMinimo | P07_MiembroLectura, P07_GuardadoPropio | P07_Participantes, P07_MiembrosAmbito |
| B | P07_AccesoMinimo | P07_MiembroLectura, P07_GuardadoPropio | P07_Participantes |
| Coordinación | P07_AccesoMinimo | P07_CoordinacionLectura, P07_ServicioLectura | P07_Participantes, P07_CoordinacionAmbito |

El perfil propio se creó mediante la API de Profile para partir sin permisos de objetos; no se clonó un perfil amplio. La inspección efectiva confirma cero ObjectPermissions en el perfil y ausencia de API Enabled, View All Data, Modify All Data, Author Apex, Manage Users y View Setup. Los únicos permisos de sistema activos observados son ChatterInternalUser, ActivitiesAccess, FlowUFLRequired, ViewHelpLink y LightningExperienceUser. Los dos primeros son exigidos por la licencia; FlowUFLRequired exige la licencia funcional correspondiente para Flow. No se añadieron permisos de Flow al perfil.

Solo P07_Dedicacion es visible en este perfil y es su aplicación predeterminada. Sus cuatro pestañas, tres layouts y tres vistas P07_Accesibles permiten consultar sin añadir escritura ordinaria. Las vistas se comparten con P07_Participantes; filterScope=Everything significa todos los registros que el solicitante ya puede leer, no acceso global. No hay página predeterminada para toda la organización.

La identidad de sesión determina la propiedad que utiliza el servicio. Los permisos autorizan lectura u operación; la compartición determina qué registros ajenos pueden leerse. El guardado propio controlado no concede Edit al objeto. Por eso A y B guardan por el servicio, pero no editan por la ruta estándar ni leen registros del otro. Coordinación lee A por el grupo receptor, no puede editarlo y no accede a B.

Se comprobaron sesiones reales Login As, identificador efectivo, URLs directas de semana y detalle y denegación explícita de edición. El servicio devuelve ACCESO_DENEGADO a coordinación. UserRecordAccess complementa estas sesiones: cinco registros legibles para A y coordinación, dos para B, cero editables en el inventario de siete registros. No sustituye la evidencia funcional.

La retirada temporal de A produjo pérdida de lectura tras el recálculo, comprobada también por URL en coordinación. La pertenencia se restauró y se volvió a comprobar lectura sin edición. Estado final: cinco pertenencias y seis asignaciones explícitas, además de las asignaciones internas del perfil.

El mecanismo Login As requirió una habilitación temporal de la política. Finalizó desactivada y SecuritySettings coincide con el estado previo. Para una demostración posterior hace falta acceso legítimo a las identidades; la cuenta técnica abierta no constituye una sesión de miembro y no autoriza reactivar esa política automáticamente. No se generaron contraseñas ni se enviaron correos.

La preparación y desactivación del catálogo requirieron FLS temporal sobre Activo__c para la cuenta técnica. Se utilizó P07_CatalogoTemporal, con acceso limitado al catálogo, y se retiraron asignación y componente después de cada operación. No forma parte del paquete de aplicación ni de los permisos funcionales.

Las claves obligatorias y algunos campos pueden aparecer como Required en el layout recuperado por normalización de Salesforce; ese atributo no otorga Create o Edit. Los accesos efectivos siguen siendo de lectura y el botón de aprobación está excluido. Resultados y límites en [STATUS.md](STATUS.md).

## Estado de acceso de fase 4

Inicialmente, el 25/11/2026 se añadió P07_InformesLectura a A, B y coordinación: tres asignaciones nuevas y nueve explícitas en ese momento. La retirada final se detalla al terminar esta sección. El perfil y los seis permisos asignados previamente no se modificaron. Este conjunto solo habilita RunReports y la pestaña Informes; no concede permisos de objetos, campos, clases, API, exportación, suscripciones o administración de informes.

P07_Dedicacion comparte su carpeta de informes con P07_Participantes mediante View. La aplicación añade la quinta pestaña, Informes. No hay filtros fijos por identidad: el informe utiliza todos los registros accesibles y las reglas anteriores siguen determinando el ámbito. Conceder acceso a la carpeta no amplía la visibilidad de registros.

Se inspeccionaron las asignaciones efectivas, incluyendo el conjunto interno del perfil. Antes de la retirada, entre los privilegios revisados solo RunReports estaba habilitado; no hay CreateCustomizeReports, ManageReportsInPubFolders, ViewReportsInPublicFolders, CreateReportFolders, API, ViewAllData o ModifyAllData. Las concesiones de objetos siguen limitadas a Read en los tres objetos P07, sin escritura ni View All/Modify All. UserRecordAccess conserva cinco registros legibles para A y coordinación, dos para B y cero editables en los siete registros inventariados.

Las pertenencias efectivas calculadas son exclusivamente P07: participantes para los tres, miembros del ámbito para A y coordinación del ámbito para coordinación. La carpeta de informes P06 conserva View para sus tres grupos anteriores, sin incorporación de las identidades P07.

RunReports es general. A, B y coordinación abrieron «Sample Report: Orchestration Runs», sin filas; el informe P06 conocido fue denegado a las tres identidades. No se cumple exclusividad de informes P07.

Las tres asignaciones de P07_InformesLectura se retiraron tras comprobar acceso a un informe público ajeno. Permanecen las seis asignaciones explícitas anteriores y RunReports=false en los conjuntos efectivos, incluido el perfil, de A, B y coordinación. El informe, la carpeta y la pestaña permanecen instalados; su ejecución funcional queda deshabilitada. No se modificaron carpetas de otros proyectos.

Login As se utilizó temporalmente para las tres identidades y se restauró a false, sin otras diferencias en SecuritySettings; sesión técnica recuperada. Los informes se probaron antes de la retirada. La ausencia final de RunReports se comprueba en asignaciones efectivas, no mediante una nueva sesión posterior. Véanse [INFORME.md](INFORME.md) y [FASE-4.json](evidencias/FASE-4.json).
