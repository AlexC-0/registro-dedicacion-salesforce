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
