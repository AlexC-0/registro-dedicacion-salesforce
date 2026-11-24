# Entorno

Inspección local del 24/11/2026. Las versiones describen el entorno observado; no son una validación integral de compatibilidad.

## Herramientas

| Herramienta | Versión observada | Resultado |
|---|---|---|
| Git | 2.56.1.windows.1 | Disponible |
| Node.js | 24.13.0 | Cumple el requisito Node >=22 del manifiesto de la CLI instalada |
| npm | 11.6.2 | Disponible |
| Salesforce CLI | 2.158.7 | Responde; avisos auxiliares de permisos al consultar procesos |
| Plugin Apex | 4.4.7 | Instalado |
| Plugin deploy-retrieve | 4.3.2 | Instalado |
| Plugin org | 7.0.13 | Instalado |
| VS Code | 1.147.0 | Responde; avisos de permisos y escritura de logs |
| Extensiones Salesforce, Apex y LWC | 68.12.0 | Instaladas; activación no comprobada |
| Java en PATH | 1.8.0_503 | No acredita un JDK compatible con el servicio Apex actual |
| Jest y sfdx-lwc-jest | No localizados | Ausentes en PATH y rutas globales comprobadas; no se examinó todo el equipo |

No hay JAVA_HOME ni JDK_HOME en la terminal inspeccionada, ni ajuste java.home de Apex en la configuración principal del editor. No se descartan otras instalaciones o perfiles. La [guía oficial de Java](https://developer.salesforce.com/docs/platform/sfvscode-extensions/guide/java-setup.html) recomienda JDK 21. No se han instalado herramientas ni modificado configuraciones globales.

## Proyecto DX

Un paquete fuente `force-app`, namespace vacío y API 65.0 provisional. No se configura usuario, alias, Dev Hub ni organización predeterminada.

API 65.0 es una versión publicada de Winter '26, documentada por [Salesforce](https://developer.salesforce.com/blogs/2025/09/take-a-deep-dive-into-metadata-api-deployments). Se utiliza como base explícita de configuración, sin necesidad identificada de APIs posteriores para los metadatos declarativos de fase 1A. Antes de desplegar se comprobará la versión admitida por el destino; no se atribuye compatibilidad remota a esta selección.

No hay package.json, dependencias ni lockfile porque todavía no hay código JavaScript ni herramientas de pruebas incorporadas al proyecto. Al añadirlas se fijarán conjuntamente versiones compatibles con el runtime y el lockfile correspondiente.

## Salesforce

No se ha identificado ni autenticado una organización P07. La inspección de nombres de alias locales solo encontró destinos de proyectos anteriores, excluidos para este proyecto. No se contactó con esas organizaciones ni se reutilizaron sus datos o configuraciones.

Se recomienda una Developer Edition dedicada, condicionada a verificar licencias y capacidades. No hay Dev Hub autorizado acreditado para scratch orgs; ese mecanismo requiere [un Dev Hub](https://developer.salesforce.com/docs/platform/sfdx-dev/guide/sfdx-setup-enable-devhub.html). No se crea una definición scratch que presuponga su disponibilidad.

Pendientes: identidad y exclusividad del destino, edición, API, licencias, usuarios, permisos efectivos y configuración de jerarquía. El mecanismo de ámbito ya está definido mediante grupos y reglas en [ACCESO.md](ACCESO.md); sus pertenencias y verificación permanecen pendientes. La verificación debe realizarse en el destino P07 identificado, sin exponer credenciales ni reutilizar identidades de otros trabajos.

## Conversión local de fase 1A

Se utilizó la CLI ya instalada mediante su entrada Node, sin instalar paquetes. Comando equivalente: `sf project convert source --manifest manifest/fase-1a.xml --output-dir tmp/fase-1a-mdapi-20261124 --json`. La salida quedó excluida de Git y se comprobó su inventario, no solo el código de salida.

El convertidor aplica sus filtros también al destino. Las carpetas ocultas dieron paquetes incompletos; se usa tmp/ sin punto inicial. Los resultados y límites constan en [STATUS.md](STATUS.md). No hubo conexión a Salesforce ni cambios de configuración global.

## Preparación de fase 1B

El 24/11/2026 se revisó la información local del destino: no aparece una organización P07 identificada ni autenticada. Se consultaron únicamente nombres de alias y configuración pertinente, sin contactar destinos de proyectos anteriores. La Developer Edition nueva y exclusiva sigue siendo la opción recomendada; el alta y activación de cuenta no se han realizado desde este procedimiento.

La ayuda de la CLI instalada confirma org login web con alias sin --set-default y project deploy start con --dry-run, --test-level NoTestRun, --target-org y --api-version. Los comandos de ayuda emitieron avisos auxiliares de acceso denegado al consultar procesos, pero devolvieron su contenido. No se modificó la instalación para eliminarlos. La ayuda de project deploy report no incluye --api-version; el procedimiento conserva ese parámetro en la operación inicial y consulta el identificador exacto con destino explícito.

API 65.0, permisos técnicos, edición, licencias y capacidad de las tres identidades funcionales siguen sin comprobación remota. La guía [INSTALACION.md](INSTALACION.md) concreta las verificaciones y el procedimiento; prepararlo no equivale a ejecutarlo.

El destino mostrado en el navegador se contrastó únicamente con los registros locales y coincidió con una organización anterior, por lo que quedó excluido. No se publican sus identificadores ni direcciones. La conexión Playwright configurada con MCP 0.0.69 agotó el tiempo de espera. La extensión ya estaba instalada en el perfil habitual de Chrome, versión 0.6.0. Se inició un puente temporal exclusivo de la sesión P07 con MCP 0.0.86, disponible en la caché local, enlazado únicamente a loopback. No se actualizaron paquetes ni se cambió la configuración global.

El puente temporal respondió correctamente: creación de una pestaña propia, evaluación sobre la página vacía y navegación al alta oficial. Los auxiliares, la sesión de conexión y los registros están en .private/, excluidos de Git. El alta y la autenticación Salesforce siguen pendientes; la conectividad del navegador no las sustituye.
