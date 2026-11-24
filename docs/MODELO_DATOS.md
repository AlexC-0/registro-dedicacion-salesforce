# Modelo declarativo

Fase 1A: tres objetos, doce campos personalizados y nueve reglas de validación definidos localmente en API 65.0. Pendientes de compilación y comprobación en Salesforce. No se han creado registros.

## Objetos y nombres

| Objeto | Etiqueta | Name | Acceso interno y externo |
|---|---|---|---|
| ProyectoDedicacion__c | Proyecto de dedicación | Texto estándar, hasta 80 caracteres | Private |
| SemanaDedicacion__c | Semana de dedicación | Autonumérico SEM-{000000} | Private |
| DedicacionDiaria__c | Dedicación diaria | Autonumérico DED-{000000} | ControlledByParent |

Los tres objetos permiten informes y no habilitan actividades ni historial de campos. El acceso por jerarquía requiere además la configuración indicada en [ACCESO.md](ACCESO.md).

## Diccionario de campos personalizados

| Objeto | Campo | Tipo y tamaño | Obligatoriedad y comportamiento |
|---|---|---|---|
| Proyecto | Codigo__c | Text(40) | Obligatorio y único sin distinguir mayúsculas; no admite solo espacios |
| Proyecto | Activo__c | Checkbox | Predeterminado true; el control de escrituras sobre inactivos queda pendiente |
| Semana | Usuario__c | Lookup(User) | Obligatorio mediante UsuarioObligatorio; sin restricción de eliminación declarada sobre User |
| Semana | Inicio__c | Date | Obligatorio; debe ser lunes |
| Semana | Clave__c | Text(29) | Obligatoria, única y sensible a mayúsculas; sin fórmula ni valor predeterminado |
| Semana | Revision__c | Number(18,0) | Obligatoria, predeterminado 0 y valor no negativo |
| Semana | TotalMinutos__c | Summary: SUM | Calculado por Salesforce sobre Minutos__c de todas las líneas |
| Dedicación | Semana__c | MasterDetail(SemanaDedicacion__c) | Obligatoria por relación; sin reparentado; escribir en el detalle requiere acceso de escritura a la cabecera |
| Dedicación | Proyecto__c | Lookup(ProyectoDedicacion__c) | Obligatorio; deleteConstraint=Restrict conserva proyectos referenciados |
| Dedicación | Fecha__c | Date | Obligatoria; dentro del lunes y los seis días siguientes |
| Dedicación | Minutos__c | Number(4,0) | Obligatorio, positivo, múltiplo de 15 y como máximo 1.440 por línea |
| Dedicación | Clave__c | Text(48) | Obligatoria, única y sensible a mayúsculas; sin fórmula ni valor predeterminado |

Cada campo incluye etiqueta, descripción y ayuda. OwnerId es estándar en proyecto y semana; el detalle hereda propiedad de la semana. No se crean campos adicionales de propietario o usuario en las líneas.

Usuario__c se mantiene como lookup no obligatorio en su definición y se exige mediante regla en cada guardado. Así se evita imponer al lookup a User una política de eliminación propia de un objeto de negocio. Su FLS sí se declara en los permisos. La combinación definitiva necesita compilación remota.

El resumen no declara precisión ni escala independientes: su tipo y operación se apoyan en el campo numérico resumido. No se añade un campo de horas persistidas; su presentación futura será minutos / 60, sin alterar la unidad almacenada.

## Reglas declarativas

| Objeto | Regla | Rechazo definido |
|---|---|---|
| Proyecto | CodigoNoVacio | Código vacío o compuesto solo por espacios |
| Semana | UsuarioObligatorio | Usuario sin informar |
| Semana | InicioEnLunes | WEEKDAY(Inicio__c) distinto de 2 |
| Semana | RevisionNoNegativa | Revisión menor que cero |
| Semana | PropietarioCoherente | Propietario distinto del usuario, comparando IDs mediante CASESAFEID |
| Semana | IdentidadInmutable | Cambio de usuario, lunes, clave o propietario después del alta |
| Dedicación | FechaEnSemana | Fecha anterior al lunes o posterior al domingo |
| Dedicación | MinutosValidos | Minutos no positivos, mayores de 1.440 o no múltiplos de 15 |
| Dedicación | IdentidadInmutable | Cambio de proyecto, fecha o clave después del alta |

La relación master-detail añade la prohibición de reparentado. Los campos únicos rechazan valores duplicados exactos. Estas reglas se han escrito en metadatos; su aceptación por Salesforce y sus resultados funcionales siguen pendientes.

## Claves y límites del esquema

- Semana: Id de usuario de 18 caracteres + separador vertical + lunes ISO de diez caracteres: 29 caracteres.
- Dedicación: Id de semana de 18 caracteres + separador + Id de proyecto de 18 caracteres + separador + fecha ISO: 48 caracteres.

No hay generador canónico ni validación integral de correspondencia entre clave e identidad. Una cadena arbitraria puede satisfacer longitud y unicidad sin representar correctamente la identidad. No se introduce una carga manual o ruta provisional para suplir el generador.

La igualdad propietario/usuario y la inmutabilidad son defensas parciales. No verifican que el solicitante esté autorizado a actuar para esa persona. La revisión no negativa tampoco acredita incremento correcto, revisión esperada ni concurrencia.

Number con escala cero define almacenamiento, no valida el dato original: una fracción podría llegar redondeada a una regla. El futuro servidor deberá rechazar la entrada inválida antes del DML. Tampoco basta el límite por línea: dos líneas de 900 minutos superarían el máximo diario aunque cada una fuese válida individualmente.

## Total semanal

TotalMinutos__c suma DedicacionDiaria__c.Minutos__c a través de DedicacionDiaria__c.Semana__c, sin filtros de fecha adicionales ni de proyecto activo. Incluye el histórico inactivo y debe recalcularse al crear, cambiar o eliminar líneas.

El total semanal no aplica el máximo diario agregado ni controla la revisión. El futuro informe podrá utilizarlo al nivel de cabecera; si combina varias líneas por semana, no deberá sumar el mismo total repetido en cada fila. Los totales por día y proyecto se obtendrán de las líneas.

## Pendiente del servidor

Límite diario agregado; validación de la entrada original; generación y correspondencia canónica; autorización por identidad; incremento y comparación de revisión; guardado atómico; concurrencia; protección de proyectos inactivos; fecha actual del solicitante y rechazo de dedicación futura; borrado, restauración y demás rutas de escritura.

No se usa TODAY() como sustituto de la referencia temporal que deberá capturar y comprobar el servicio. Las semanas vacías se conservarán para no reiniciar su revisión. La eliminación en cascada sigue siendo una capacidad de plataforma que debe restringirse y probarse; los permisos ordinarios de esta fase no conceden eliminación.

## Referencias técnicas

[CustomField](https://developer.salesforce.com/docs/platform/api-metadata/references/meta-types/metadata-customfield.html), [WEEKDAY](https://help.salesforce.com/s/articleView?id=customize_functions_weekday.htm&language=en_US&type=5), [MOD](https://help.salesforce.com/s/articleView?id=sf.customize_functions_mod.htm&language=en_US&type=5) y [funciones de fórmula](https://help.salesforce.com/s/articleView?id=sf.customize_functions.htm&language=en_US&type=5). La documentación de tipos y funciones no sustituye la compilación de estas fórmulas.
