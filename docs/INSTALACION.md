# Preparación e instalación del esquema

## Estado del procedimiento

Preparación de fase 1B sobre 8b408a3978e83cc7d48c5df5ae62bbcec9e95dce, API 65.0. Los comandos remotos de este documento no se han ejecutado: falta identificar y autenticar una organización exclusiva de P07. Los resultados reales se registran en [STATUS.md](STATUS.md).

El paquete seleccionado por [fase-1a.xml](../manifest/fase-1a.xml) contiene tres objetos con doce campos y nueve validaciones, tres grupos, dos permisos de lectura y dos reglas de compartición. No contiene Apex, LWC, datos, asignaciones ni componentes destructivos.

## Alta y autenticación

La opción prevista es una Developer Edition nueva y exclusiva. El [alta oficial](https://developer.salesforce.com/signup) requiere datos personales, aceptación de condiciones y activación de la cuenta. Estos pasos deben completarse directamente en Salesforce; no se almacenan contraseñas, tokens o enlaces de activación en el proyecto. [Guía oficial de Developer Edition](https://developer.salesforce.com/docs/platform/api-rest/guide/quickstart-dev-org.html).

Después del alta, comprobar en el navegador que la sesión corresponde a la organización nueva de P07. No basta con que la sesión de Salesforce ya esté abierta. Para autorizar la CLI sin establecer destino predeterminado:

~~~powershell
sf org login web --alias p07-dedicacion-dev --instance-url https://login.salesforce.com --browser chrome
~~~

El alias es una propuesta local y todavía no está creado. Se omiten --set-default y --set-default-dev-hub. Introducir credenciales y completar las verificaciones de cuenta exclusivamente en el navegador. No utilizar una sesión de otro proyecto ni publicar la salida de autenticación. [Referencia de autenticación](https://developer.salesforce.com/docs/platform/salesforce-cli-reference/guide/cli_reference_org_login_web.html).

## Verificación previa del destino

Antes de validar o desplegar:

1. Contrastar el identificador de organización y la identidad técnica autenticada con la cuenta dedicada identificada para P07. Conservar el vínculo en .private/, excluido de Git. Un alias nuevo no convierte una organización anterior en un destino nuevo.
2. Comprobar OrganizationType y edición de desarrollo. IsSandbox=false por sí solo no identifica producción ni demuestra exclusividad.
3. Confirmar respuesta de API 65.0 y permisos efectivos de la cuenta técnica para API, metadatos y compartición. No ampliar permisos de funciones ordinarias para instalar.
4. Consultar licencias totales y usadas y comprobar que permiten objetos personalizados, Apex, LWC e informes. Evaluar por separado la viabilidad de miembro, coordinación y una identidad fuera del ámbito; no crear usuarios ni asignarlos durante esta fase.
5. Inspeccionar la existencia de los diez miembros del manifiesto. Si ya hay componentes P07, recuperar sus definiciones en una ruta temporal separada y comparar antes de escribir. No sobrescribir diferencias remotas sin comprenderlas.
6. Capturar HEAD, cambios locales y huellas SHA-256 de las fuentes y del manifiesto. Una corrección no publicada requiere huellas nuevas y una nueva validación; no se atribuye el resultado al commit inicial.

Los detalles identificativos y recibos completos permanecen en .private/ o tmp/, ambos excluidos. Las evidencias públicas se limitan a resultados sanitizados. No se consultan organizaciones anteriores para comprobar si pueden reutilizarse.

## Validación remota sin persistencia

La ayuda de la CLI instalada confirma --dry-run para validar sin guardar el despliegue y NoTestRun para entornos de desarrollo. Se utiliza project deploy start, con destino y API explícitos:

~~~powershell
sf project deploy start --manifest manifest/fase-1a.xml --target-org p07-dedicacion-dev --api-version 65.0 --test-level NoTestRun --dry-run --async --json
~~~

Este comando es una validación remota, no una conversión local. NoTestRun significa que no se ejecutan pruebas Apex; no acredita cobertura. La ausencia de clases en el paquete no permite inventar pruebas ejecutadas.

La respuesta inicial asíncrona no demuestra éxito. Consultar el trabajo identificado hasta que termine; sustituir ID_VALIDACION por el identificador devuelto y conservar el mismo destino:

~~~powershell
sf project deploy report --job-id ID_VALIDACION --target-org p07-dedicacion-dev --json
~~~

La ayuda instalada de project deploy report no admite --api-version; no se añade ese flag al seguimiento. La operación inicial sí fija API 65.0 y el informe se solicita para su identificador exacto, con destino explícito.

Exigir estado final Succeeded, success=true, checkOnly=true y ausencia de errores de componentes. No utilizar --ignore-errors, --ignore-warnings o --ignore-conflicts. Ante un rechazo, conservar el error, corregir únicamente el componente afectado y repetir las comprobaciones y la validación necesarias. [Referencia de despliegue y dry-run](https://developer.salesforce.com/docs/platform/salesforce-cli-reference/guide/cli_reference_project_deploy_start.html).

## Despliegue inicial

Solo después de identidad confirmada, conflictos resueltos y validación satisfactoria. Volver a contrastar la identidad y las huellas del paquete validado. Si cambian las fuentes o el destino, repetir la validación.

~~~powershell
sf project deploy start --manifest manifest/fase-1a.xml --target-org p07-dedicacion-dev --api-version 65.0 --test-level NoTestRun --async --json
~~~

Esta operación sí persiste los metadatos. Registrar el recibo separado del de validación y consultar su identificador con project deploy report, especificando otra vez el destino explícito. Exigir estado final Succeeded, success=true, checkOnly=false y ausencia de errores; una respuesta inicial o un estado parcial no completan la instalación.

## Contraste de componentes instalados

Recuperar los componentes del manifiesto en un directorio temporal nuevo bajo tmp/, fuera de force-app. Comparar definiciones por significado, considerando valores predeterminados y normalización de Salesforce. No reemplazar las fuentes con la recuperación.

Verificar como mínimo:

- Tres objetos y doce campos, etiquetas, tipos, longitudes, precisión y obligatoriedad.
- Nueve validaciones activas con sus fórmulas y mensajes; ninguna retirada para facilitar el despliegue.
- Claves únicas, referencia User, lookup obligatorio al proyecto con Restrict y master-detail sin reparentado.
- Resumen semanal con suma de Minutos__c por Semana__c, sin excluir proyectos inactivos.
- OWD Private en proyecto y semana, ControlledByParent en detalle; acceso interno y externo coherentes.
- Dos Permission Sets sin escritura ordinaria ni privilegios amplios; FLS conforme a las fuentes.
- Tres grupos con doesIncludeBosses=false y cero miembros; dos reglas de compartición Read con los grupos y criterios previstos.
- Ausencia de asignaciones de los permisos P07 y de registros de proyecto, semana o dedicación creados por este procedimiento.

No crear semanas ni dedicaciones para ensayar el esquema con claves manuales. La inspección de definiciones aceptadas no demuestra agregación funcional, atomicidad, concurrencia, permisos efectivos ni comportamiento de la futura aplicación.

## Ajuste de jerarquía en Setup

Después de instalar, en la organización P07 confirmada:

1. Abrir Setup, buscar Sharing Settings y entrar en la configuración de compartición.
2. En Organization-Wide Defaults, pulsar Edit.
3. Localizar Proyecto de dedicación y Semana de dedicación. Mantener sus accesos internos y externos en Private.
4. Desmarcar Grant Access Using Hierarchies para ambos objetos. No modificar las filas de otros objetos. El detalle permanece Controlled by Parent.
5. Guardar y esperar a que termine cualquier recálculo. Volver a abrir la configuración y comprobar que ambas opciones continúan desmarcadas.

Conservar evidencia sanitizada de la lectura posterior. Si no se dispone del acceso necesario a Setup, registrar el ajuste y su verificación como pendientes. doesIncludeBosses=false en los grupos no sustituye esta configuración. [Procedimiento oficial](https://help.salesforce.com/s/articleView?id=sf.admin_sharing.htm&language=en_US&type=5).

Los grupos permanecen vacíos y los permisos sin asignaciones. El ajuste de jerarquía tampoco sustituye las futuras pruebas con identidades funcionales.

## Continuidad

Al terminar, documentar por separado validación, despliegue, contraste, jerarquía y capacidad de identidades. Mantener pendientes los criterios funcionales hasta disponer de sus pruebas. El siguiente desarrollo previsto es el servicio Apex de lectura y guardado con protección de todas las rutas de escritura.
