# Modelo de datos propuesto

Este documento define el diseño inicial. No acredita metadatos creados ni desplegados.

## Entidades

| Entidad propuesta | Campos principales | Restricciones |
|---|---|---|
| `ProyectoDedicacion__c` | `Name`, `Codigo__c`, `Activo__c` | Código obligatorio y único; catálogo compartido de lectura |
| `SemanaDedicacion__c` | `Usuario__c`, `Inicio__c`, `Clave__c`, `Revision__c`, `OwnerId` | Inicio en lunes; usuario y propietario coherentes; clave canónica única; revisión entera controlada por servidor |
| `DedicacionDiaria__c` | `Semana__c`, `Proyecto__c`, `Fecha__c`, `Minutos__c`, `Clave__c` | Semana master-detail; proyecto lookup; fecha dentro de la semana; minutos positivos en múltiplos de 15; identidad única |

El tipo, longitud, precisión, obligatoriedad y restricciones de eliminación definitivos se fijarán al implementar los metadatos y deberán superar la compilación de Salesforce.

## Identidad

- Semana: Id de usuario de 18 caracteres y lunes ISO, separados por `|`.
- Línea: Id de cabecera de 18 caracteres, Id de proyecto de 18 caracteres y fecha ISO, separados por `|`.
- Las claves se generan en servidor, sin depender de la configuración regional.
- Usuario, inicio, propietario y referencias de identidad no se cambian mediante edición ordinaria.

Un campo único evita duplicados exactos. También debe protegerse la formación canónica para impedir claves distintas que representen la misma identidad.

## Duración y fechas

Cada incremento de 0,25 horas equivale exactamente a 15 minutos. Se rechazan negativos, fracciones no permitidas, valores no finitos y conversiones ambiguas. No se redondea para aceptar entradas inválidas.

El máximo de 1.440 minutos se evalúa por persona y fecha sobre el estado final del conjunto, incluidos los registros no editados y el histórico inactivo. No basta con validar cada línea por separado.

El servidor comprueba que la fecha pertenece a los siete días de la cabecera y no es posterior al día actual del usuario. La fecha Date no se transforma a UTC para decidir el día de dedicación.

## Relaciones y conservación

Las líneas heredan acceso de la cabecera. No se conceden permisos ordinarios para borrar cabeceras, transferirlas ni modificar su usuario. La eliminación en cascada debe considerarse expresamente en las comprobaciones de seguridad.

La desactivación de un proyecto conserva sus líneas. No se permitirá eliminar proyectos referenciados por histórico. La política exacta de restricciones lookup se validará con la plataforma.

Las semanas vacías se conservan con su revisión. La eliminación de una línea forma parte del guardado transaccional y no constituye un cierre semanal.
