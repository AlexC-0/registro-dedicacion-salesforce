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

Un paquete fuente `force-app`, namespace vacío y API 65.0, comprobada en el destino compartido. No se configura usuario, alias, Dev Hub ni organización predeterminada.

API 65.0 es una versión publicada de Winter '26, documentada por [Salesforce](https://developer.salesforce.com/blogs/2025/09/take-a-deep-dive-into-metadata-api-deployments). Se utiliza como base explícita de configuración, sin necesidad identificada de APIs posteriores para los metadatos declarativos de fase 1A. La fase 1B comprobó respuesta de API 65.0, validación remota e instalación del paquete. Esa aceptación no equivale a una prueba funcional.

No hay package.json, dependencias ni lockfile porque todavía no hay código JavaScript ni herramientas de pruebas incorporadas al proyecto. Al añadirlas se fijarán conjuntamente versiones compatibles con el runtime y el lockfile correspondiente.

## Salesforce: destino compartido verificado

Developer Edition compartida con P06, identificada mediante el alias p06-renovaciones-dev, contraste con el registro local de autenticación y consulta remota de Organization. La cuenta técnica y el identificador de organización se conservan en privado. La sesión de navegador corresponde al mismo dominio verificado. No se creó otra organización ni se modificó el destino predeterminado.

API 65.0 responde y acepta el paquete P07 corregido. La cuenta técnica tiene API Enabled, Modify Metadata, Customize Application, Manage Sharing, View Setup, Author Apex y Run Reports; sus privilegios administrativos ya existían. No se concedieron permisos de instalación a identidades funcionales.

| Licencia relevante | Total | Usadas | Libres |
|---|---:|---:|---:|
| Salesforce | 4 | 4 | 0 |
| Salesforce Platform | 6 | 0 | 6 |

La licencia Platform admite aplicaciones y objetos personalizados e informes según la [documentación oficial](https://help.salesforce.com/s/articleView?id=platform.users_license_types_available.htm&language=en_US&type=5). Se localizó un perfil Platform con API e informes habilitados. La disponibilidad permite prever tres identidades diferenciadas; su configuración mínima, acceso a las futuras clases/LWC y comportamiento efectivo deben comprobarse en la fase correspondiente. No se crearon usuarios ni asignaciones y no se alteraron las identidades de P06.

La consulta de límites indicó DataStorageMB: máximo 5 y restante 5; FileStorageMB: máximo 20 y restante 20; API diaria: máximo 15.000 y restante 14.929 en ese instante. Son cuotas reportadas por Salesforce, con su granularidad de medida, y no una prueba de rendimiento ni almacenamiento vacío.

Los tres objetos P07 no contienen registros. Los grupos están vacíos y los permisos sin asignar. El requisito de jerarquía está aplicado y verificado para proyecto y semana; véase [ACCESO.md](ACCESO.md). Se contrastó la conservación del estado P06 antes y después dentro del alcance de [STATUS.md](STATUS.md).

## Conversión local de fase 1A

Se utilizó la CLI ya instalada mediante su entrada Node, sin instalar paquetes. Comando equivalente: `sf project convert source --manifest manifest/fase-1a.xml --output-dir tmp/fase-1a-mdapi-20261124 --json`. La salida quedó excluida de Git y se comprobó su inventario, no solo el código de salida.

El convertidor aplica sus filtros también al destino. Las carpetas ocultas dieron paquetes incompletos; se usa tmp/ sin punto inicial. Los resultados y límites constan en [STATUS.md](STATUS.md). No hubo conexión a Salesforce ni cambios de configuración global.

## Antecedente de preparación y operación

La preparación inicial se realizó sin destino P07 identificado y contemplaba una Developer Edition exclusiva. El alcance vigente utiliza la organización de desarrollo compartida con P06, con escrituras limitadas a P07 y conservación contrastada de los componentes y registros anteriores. La autenticación existente fue suficiente; no se repitió el inicio de sesión ni se cambió su alias.

La ayuda instalada confirmó dry-run, NoTestRun, destino y API explícitos. project deploy report no admite --api-version: se fijó 65.0 al iniciar cada trabajo y se consultó su identificador exacto con --target-org. Las respuestas finales y los intentos fallidos se conservan separados.

Los detalles operativos, auxiliares y diagnósticos de la conexión temporal del navegador permanecen en notas privadas excluidas de Git. No son dependencias de la aplicación ni requisitos de instalación. No se instalaron herramientas ni se cambió su configuración global.
