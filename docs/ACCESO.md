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

## Matriz provisional

| Recurso o acción | Miembro | Coordinación |
|---|---|---|
| Catálogo activo e inactivo | Lectura, con pertenencia a participantes | Lectura, con pertenencia a participantes |
| Semana y líneas propias | Lectura por propiedad | Lectura de las propias si existen |
| Semanas y líneas del ámbito | Sin concesión adicional | Lectura por la regla del ámbito |
| Dedicación ajena fuera del ámbito | Sin concesión | Sin concesión |
| Crear, editar o eliminar en los tres objetos | No concedido | No concedido |
| Transferir cabeceras o restaurar registros | No habilitado | No habilitado |
| Administrar catálogo | No concedido | No concedido |

Están instalados P07_MiembroLectura y P07_CoordinacionLectura, sin asignaciones. Ambos conceden únicamente Read sobre los tres objetos, sin Create, Edit, Delete, View All Records, Modify All Records ni View All Fields. No añaden permisos de sistema, acceso Apex, perfiles, usuarios o asignaciones. Sus concesiones actuales son iguales; la diferencia funcional la aportan propiedad y grupos, y la separación permite evolucionar la escritura del miembro sin concederla a coordinación.

FLS explícita de lectura y sin edición: Proyecto.Activo__c, Semana.Usuario__c y Semana.TotalMinutos__c. No se serializan permisos de campos universalmente obligatorios ni de la relación master-detail; Salesforce no admite desplegar FLS de campos obligatorios desde API 30.0. Los campos estándar de nombre e identidad siguen las capacidades del objeto. [Referencia PermissionSet](https://developer.salesforce.com/docs/platform/api-metadata/references/meta-types/metadata-permissionset.html).

Los Permission Sets son aditivos: los valores false no revocan permisos que procedan de un perfil u otra asignación. Antes de asignarlos se comprobará el acceso efectivo de identidades con perfil mínimo y sin otras concesiones amplias.

## Jerarquía: ajuste instalado y verificado

Private no desactiva por sí solo el acceso ascendente de los propietarios. doesIncludeBosses=false limita la propagación de la compartición de cada grupo, pero no sustituye el ajuste del objeto.

En fase 1B se desactivó Grant Access Using Hierarchies para SemanaDedicacion__c y ProyectoDedicacion__c desde Sharing Settings. Se guardó y reabrió el formulario: ambas casillas permanecen desmarcadas. La comparación de 375 controles confirma que solo cambiaron las dos casillas previstas. Los accesos internos y externos de ambos objetos siguen en Private; el detalle conserva ControlledByParent.

Este ajuste se aplica en Setup y no está representado por un atributo inventado en los XML. El procedimiento reproducible figura en [INSTALACION.md](INSTALACION.md). Continúan pendientes las pruebas de acceso efectivo, incluida una identidad superior en jerarquía sin pertenencia al ámbito y la retirada de miembros de grupos. [Configuración oficial](https://help.salesforce.com/s/articleView?id=sf.admin_sharing.htm&language=en_US&type=5).

## Evolución de la escritura

Estos permisos no son los finales de V1. El futuro servicio comprobará solicitante, objetos, campos y registros, y aplicará el protocolo de revisión. Solo se ampliarán las concesiones necesarias cuando las rutas habilitadas cuenten con protección de invariantes y pruebas negativas. Coordinación conservará lectura de dedicación ajena; no se añadirán privilegios administrativos ni acceso general de edición.

Se mantendrán denegados el borrado de cabeceras, transferencias y restauraciones ordinarias. La operación de eliminar una celda deberá pasar por el guardado protegido y no habilitar una ruta directa que eluda revisión o atomicidad.

## Verificación futura

El destino compartido, la edición, API y licencias se comprobaron en fase 1B. Hay seis licencias Platform libres; se prevén identidades diferenciadas para miembro, coordinación y persona fuera del ámbito. Su creación, permisos mínimos y sesiones siguen pendientes. No se liberan licencias ni se reutilizan identidades funcionales de P06.

En el destino se contrastarán perfil, Permission Sets, pertenencias, jerarquía, comparticiones y sesiones ordinarias. Una cuenta administrativa o una consulta técnica de acceso no sustituye las pruebas por función. No se han creado ni asignado usuarios en esta fase.

## Estado de fase 1B

Instalación y contraste técnicos completados. Los tres grupos existen con cero miembros y doesIncludeBosses=false. Los dos Permission Sets conceden Read sobre los tres objetos y tres permisos FLS de lectura cada uno, sin escritura ni privilegios amplios; no tienen asignaciones. No hay registros P07.

El perfil técnico existente no tiene concesiones FLS sobre Activo__c, Usuario__c y TotalMinutos__c. Su REST describe muestra nueve campos personalizados; Metadata API confirma los doce. No se asignaron permisos P07 al operador para alterar ese resultado. La presencia de las definiciones y concesiones no sustituye una sesión funcional.

La regla de catálogo conserva Activo verdadero O falso y acceso Read. En este destino, los criterios de casilla exigieron los literales Verdadero/Falso; true/false y True/False fueron rechazados. No cambió el alcance de la regla. Los resultados, conservación de P06 y límites constan en [STATUS.md](STATUS.md).
