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

Ese era el estado inicial, anterior al LWC. Fase 3A incorpora package.json, package-lock.json y Jest local, con las versiones y comprobaciones descritas al final de este documento.

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

## Comprobación de fase 2A

El 24/11/2026 se volvió a contrastar la identidad del destino compartido y OrganizationType=Developer Edition antes de validar y desplegar, con API 65.0 explícita. Se utilizó la autenticación técnica existente y la CLI instalada, sin cambios globales ni dependencias nuevas. El paquete Apex de ocho miembros fue aceptado con RunSpecifiedTests y 18 pruebas P07 satisfactorias.

El contraste final mantiene Salesforce 4/4 usadas y Salesforce Platform 0/6 usadas; cuatro Permission Sets P07 sin asignaciones y tres grupos sin miembros. Los seis usuarios Platform, permisos y datos creados por las pruebas son aislados y no persisten. No se habilitaron identidades funcionales ni sesiones nuevas. La comprobación técnica no sustituye el futuro recorrido por función. Véanse [STATUS.md](STATUS.md) y la [evidencia de fase 2A](evidencias/FASE-2A.json).

## Herramientas locales de fase 3A

Node 24.13.0 y npm 11.6.2 comprobados sin actualización global. @salesforce/sfdx-lwc-jest 7.1.2 se fija como dependencia directa de desarrollo; la etiqueta winter26 se contrastó en el registro npm y se seleccionó para la base API 65.0. El paquete incorpora Jest 29.7.0 y @lwc/compiler 8.20.4. El ejecutor no publica engines propio; Jest declara ^14.15.0 || ^16.10.0 || >=18.0.0. La instalación y las pruebas con Node 24.13.0 acreditan la combinación utilizada.

npm install generó el lockfile y npm ci reconstruyó correctamente el árbol local. Los 419 paquetes instalados incluyen dependencias transitivas; no son dependencias de ejecución de la interfaz. Se conservaron avisos de obsolescencia del árbol, sin actualizaciones globales ni modificaciones transitivas improvisadas. Comandos reproducibles en [INSTALACION.md](INSTALACION.md).

Jest simula Apex como promesas de texto JSON, @salesforce/i18n/timeZone, LightningConfirm y los componentes base mediante los stubs del paquete. La compilación remota del bundle se registra separadamente; no se presupone que los stubs reproduzcan todo el comportamiento del navegador de Salesforce.

## Entorno final de fase 3B

Mismo destino compartido, cuenta técnica y API 65.0, nuevamente contrastados. No se actualizaron herramientas globales. El navegador se utilizó sobre la sesión existente y se identificó cada sesión funcional. La conexión temporal se detuvo al terminar; sus detalles y diagnósticos no forman parte de los requisitos de la aplicación.

| Licencia | Total | Usadas al terminar | Libres |
|---|---:|---:|---:|
| Salesforce | 4 | 4 | 0 |
| Salesforce Platform | 6 | 3 | 3 |

Las tres identidades nuevas utilizan un perfil propio sin privilegios administrativos, roles ni licencia Content. La primera creación atómica fue revertida por el límite de Content; la creación corregida desactiva expresamente esa licencia adicional. No hubo notificaciones o cambios de contraseña.

Aplicación, página, pestañas, layouts y vistas P07 instalados. Tres proyectos, tres cabeceras y cuatro líneas activas; tres líneas de ensayo eliminadas permanecen en la papelera. Grupos y permisos funcionales configurados según [ACCESO.md](ACCESO.md).

Login As terminó desactivado; el resto de SecuritySettings coincide con la referencia inicial. La cuenta técnica recuperó su sesión y no conserva la concesión temporal de catálogo. Esta preparación no proporciona credenciales para acceso autónomo a los usuarios ficticios.

La compilación y el despliegue de los trece metadatos finalizaron con NoTestRun y cero pruebas Apex nuevas. No se modificó código; los resultados automatizados anteriores conservan su fecha y alcance. Las sesiones reales y sus límites se documentan separadamente en [STATUS.md](STATUS.md).

## Entorno de fase 4

Comprobación del 25/11/2026: mismo destino Developer Edition compartido, alias explícito p06-renovaciones-dev, API 65.0 y cuenta técnica contrastada con el registro privado. Salesforce CLI 2.158.7, Node 24.13.0, npm 11.6.2 y Git 2.56.1.windows.1. No se actualizaron herramientas globales.

La conexión se restableció sobre Chrome preparado, con identidad técnica verificada. La continuación comprobó sesiones delegadas reales de A, B y coordinación; la sesión técnica quedó recuperada. Los detalles y diagnósticos de la conexión permanecen en notas privadas y no son requisitos de instalación de la aplicación.

Se mantienen Salesforce 4/4 y Salesforce Platform 3/6. No se crearon usuarios ni se cambiaron perfiles o autenticación. P07_InformesLectura se asignó inicialmente y se retiró de las tres identidades tras demostrar acceso a un informe público ajeno. Se conservan seis asignaciones explícitas y RunReports=false. Login As se utilizó temporalmente y se restauró; SecuritySettings coincide con la referencia previa.

El estado de datos y las limitaciones de comprobación funcional se recogen en [STATUS.md](STATUS.md) e [INFORME.md](INFORME.md).

Se corrigió la pérdida del cero inicial al escribir un decimal en una celda vacía: el LWC conserva el texto en edición separado del borrador significativo. La regresión nueva falló antes de corregir; después, 49/49 pruebas Jest en dos suites satisfactorias. Validación 0Afg700000LIaTyCAL y despliegue 0Afg700000LIPVKCA5: Succeeded, un bundle, NoTestRun. Recuperación 09Sg700000bjuwnEAA: cinco archivos coincidentes. Sin cambios de Apex o modelo ni pruebas Apex nuevas.

## Revisión de actualización fallida

El 25/11/2026 se verificó nuevamente el destino compartido y se desplegó únicamente el bundle existente, sin cambios de herramientas, autenticación ni políticas. Login As=false y RunReports=false; seis asignaciones explícitas, informe y carpeta conservados. 57 pruebas Jest locales satisfactorias; validación y despliegue con NoTestRun, cero Apex. Cinco archivos recuperados coinciden tras normalizar finales de línea. No se abrió una sesión funcional nueva para provocar fallos reales de lectura; [STATUS.md](STATUS.md) distingue esos límites.

## Estado de fase 4B

El 25/11/2026 se verificaron de nuevo organización Developer Edition, cuenta técnica y API 65.0 con el registro privado. No se crearon organizaciones, usuarios o autenticaciones. Salesforce 4/4 y Platform 3/6 utilizadas. Se instalaron siete componentes acotados y tres asignaciones P07_ConsultaInforme, conservando las seis previas. RunReports y Login As permanecen desactivados.

Jest local: 92/92; validación y despliegue: 26/26 pruebas Apex P07 en cada operación. Trece archivos recuperados y contrastados. No se instalaron dependencias ni herramientas globales. El navegador solo ofrecía la sesión técnica; no hay nueva evidencia de sesiones ordinarias. Los requisitos funcionales pendientes son acceso legítimo a las identidades P07 y recorrido de la consulta con sus permisos existentes. Véase [FASE-4B.md](FASE-4B.md).
