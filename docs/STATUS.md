# Estado del proyecto

Fecha: 24/11/2026.

## Fase 1B: instalación técnica completada

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
