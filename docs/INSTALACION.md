# Validación e instalación

## Estado del procedimiento

Fase 1B técnica completada el 24/11/2026 en la Developer Edition compartida con P06, utilizando API 65.0 y destino explícito p06-renovaciones-dev. Se partió de 50354b06ffd6c9d11fb8ec1afebb10b49df47214 y se corrigieron localmente dos literales de la regla de catálogo. [STATUS.md](STATUS.md) y la [evidencia de fase 1B](evidencias/FASE-1B.json) registran los trabajos terminados, los rechazos previos y las huellas exactas del paquete aceptado.

El paquete seleccionado por [fase-1a.xml](../manifest/fase-1a.xml) contiene tres objetos con doce campos y nueve validaciones, tres grupos, dos permisos de lectura y dos reglas de compartición. No contiene Apex, LWC, datos, asignaciones ni componentes destructivos. El despliegue y el ajuste de jerarquía ya están realizados; estos comandos documentan el procedimiento y no implican que deba repetirse.

## Destino y autenticación

El destino de esta instalación es compartido con P06. La autorización se limita al paquete P07 y a la jerarquía de proyecto y semana; se conservan los componentes, datos, usuarios y asignaciones anteriores. El alias operativo conserva su nombre p06-renovaciones-dev: no representa una organización independiente ni implica cambiar de repositorio.

Se comprobó que la autenticación técnica existente respondía y coincidía con la organización y la sesión de navegador previstas. No fue necesario iniciar otra autorización. Si falta autenticación en otro equipo, completar el acceso exclusivamente en el navegador y contrastar después la identidad con el registro privado del destino:

~~~powershell
sf org login web --alias p06-renovaciones-dev --instance-url https://login.salesforce.com --browser chrome
~~~

Este comando de autenticación no se ejecutó en la fase 1B completada. Se omiten --set-default y --set-default-dev-hub. No publicar credenciales, tokens, recibos de autenticación ni enlaces reutilizables. [Referencia oficial](https://developer.salesforce.com/docs/platform/salesforce-cli-reference/guide/cli_reference_org_login_web.html).

## Verificación previa del destino

Antes de validar o desplegar:

1. Contrastar el identificador de organización y la cuenta técnica con el registro privado del destino compartido. Un alias por sí solo no acredita identidad.
2. Comprobar OrganizationType=Developer Edition. IsSandbox=false no basta para identificar el tipo de entorno.
3. Confirmar respuesta de API 65.0 y permisos efectivos para API, metadatos y compartición. Utilizar los privilegios técnicos existentes; no ampliar permisos de funciones ordinarias.
4. Consultar licencias totales y usadas. La fase 1B observó cuatro licencias Salesforce ocupadas y seis Platform libres. Las tres identidades funcionales previstas requieren configuración y comprobación posteriores; no crearlas ni asignarlas durante esta instalación.
5. Inspeccionar los diez miembros del manifiesto. Antes del despliegue inicial no existían componentes P07. En operaciones posteriores, recuperar y comparar primero cualquier componente existente; no sobrescribir diferencias remotas no comprendidas.
6. Capturar referencia de fuentes, cambios pendientes y huellas SHA-256. Una corrección requiere nuevas huellas y otra validación. Conservar una referencia de los componentes, registros y asignaciones P06 que permita contrastar su conservación al terminar.

Los recibos completos e inventarios identificativos permanecen en .private/ o tmp/, ambos excluidos de Git. Las evidencias públicas contienen resultados sanitizados. No se modifica la configuración global de herramientas ni se consulta otro destino por defecto.

## Validación remota sin persistencia

Se utilizó project deploy start con --dry-run para validar sin persistir, NoTestRun y destino/API explícitos:

~~~powershell
sf project deploy start --manifest manifest/fase-1a.xml --target-org p06-renovaciones-dev --api-version 65.0 --test-level NoTestRun --dry-run --async --json
~~~

Este comando es una validación remota, no una conversión local. NoTestRun significa que no se ejecutan pruebas Apex; no acredita cobertura. La ausencia de clases en el paquete no permite inventar pruebas ejecutadas.

La respuesta inicial asíncrona no demuestra éxito. Consultar el trabajo identificado hasta que termine; sustituir ID_VALIDACION por el identificador devuelto y conservar el mismo destino:

~~~powershell
sf project deploy report --job-id ID_VALIDACION --target-org p06-renovaciones-dev --json
~~~

La ayuda instalada de project deploy report no admite --api-version; no se añade ese flag al seguimiento. La operación inicial sí fija API 65.0 y el informe se solicita para su identificador exacto, con destino explícito.

Exigir estado final Succeeded, success=true, checkOnly=true y ausencia de errores de componentes. No utilizar --ignore-errors, --ignore-warnings o --ignore-conflicts. Ante un rechazo, conservar el error, corregir únicamente el componente afectado y repetir las comprobaciones y la validación necesarias. [Referencia de despliegue y dry-run](https://developer.salesforce.com/docs/platform/salesforce-cli-reference/guide/cli_reference_project_deploy_start.html).

### Literales de criterios de casilla

La regla P07_CatalogoParticipantes compara Activo__c con Verdadero y Falso, usando 1 OR 2. En el destino y con la cuenta técnica verificados, Salesforce rechazó true/false y True/False y exigió esos literales localizados. Se corrigieron únicamente los dos valores y se repitió la validación completa; no se modificó el idioma del usuario ni la lógica de acceso. En otro contexto de idioma deberá comprobarse la aceptación mediante validación remota antes de desplegar.

## Despliegue inicial

Solo después de identidad confirmada, conflictos resueltos y validación satisfactoria. Volver a contrastar la identidad y las huellas del paquete validado. Si cambian las fuentes o el destino, repetir la validación.

~~~powershell
sf project deploy start --manifest manifest/fase-1a.xml --target-org p06-renovaciones-dev --api-version 65.0 --test-level NoTestRun --async --json
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

El ajuste quedó aplicado y verificado en fase 1B. Para una instalación que aún lo requiera, comprobar primero la identidad del destino compartido y limitar los cambios a las dos filas P07:

1. Abrir Setup, buscar Sharing Settings y entrar en la configuración de compartición.
2. En Organization-Wide Defaults, pulsar Edit.
3. Localizar Proyecto de dedicación y Semana de dedicación. Mantener sus accesos internos y externos en Private.
4. Desmarcar Grant Access Using Hierarchies para ambos objetos. No modificar las filas de otros objetos. El detalle permanece Controlled by Parent.
5. Guardar y esperar a que termine cualquier recálculo. Volver a abrir la configuración y comprobar que ambas opciones continúan desmarcadas.

Comparar el formulario antes y después para descartar cambios en otras filas. La ejecución de fase 1B contrastó 375 controles y confirmó únicamente las dos casillas previstas, con lectura posterior tras reabrir la edición. Conservar evidencia sanitizada de esa lectura. Si no se dispone del acceso necesario a Setup, registrar el ajuste y su verificación como pendientes. doesIncludeBosses=false en los grupos no sustituye esta configuración. [Procedimiento oficial](https://help.salesforce.com/s/articleView?id=sf.admin_sharing.htm&language=en_US&type=5).

Los grupos permanecen vacíos y los permisos sin asignaciones. El ajuste de jerarquía tampoco sustituye las futuras pruebas con identidades funcionales.

## Continuidad

Al terminar, documentar por separado validación, despliegue, contraste, jerarquía y capacidad de identidades. Mantener pendientes los criterios funcionales hasta disponer de sus pruebas. El servicio y las protecciones se incorporaron posteriormente mediante el procedimiento de fase 2A siguiente.

## Actualización de fase 2A ejecutada

La base 816b8d13e83b08686e5ce747a17d17e5eff8fc51 ya tenía instalado el esquema. El manifiesto [fase-2a.xml](../manifest/fase-2a.xml) selecciona ocho miembros: servicio, clase de pruebas, dos triggers, dos permisos personalizados y dos Permission Sets de acceso a las operaciones. No reinstala el esquema, cambia jerarquía o asigna permisos.

Se verificó la identidad contra el registro privado y se comprobó que ninguno de los ocho nombres nuevos existía en el destino. Ante componentes existentes en una instalación posterior, recuperar y comprender sus diferencias antes de sobrescribirlos. Los grupos y permisos de lectura de fase 1B son prerrequisitos; las pruebas aisladas requieren un perfil Salesforce Platform mínimo, sin acceso previo a los objetos personalizados. No se amplían privilegios para hacer pasar las pruebas.

Validación ejecutada con pruebas específicas:

~~~powershell
sf project deploy start --manifest manifest/fase-2a.xml --target-org p06-renovaciones-dev --api-version 65.0 --test-level RunSpecifiedTests --tests P07_DedicacionServiceTest --dry-run --async --json
sf project deploy report --job-id ID_VALIDACION --target-org p06-renovaciones-dev --json
~~~

Exigir Succeeded, success=true, checkOnly=true, cero errores y resultados de pruebas y cobertura aceptados. Conservar recibos fallidos; cualquier corrección de fuentes exige repetir la validación. Después de contrastar otra vez identidad y huellas del paquete:

~~~powershell
sf project deploy start --manifest manifest/fase-2a.xml --target-org p06-renovaciones-dev --api-version 65.0 --test-level RunSpecifiedTests --tests P07_DedicacionServiceTest --async --json
sf project deploy report --job-id ID_DESPLIEGUE --target-org p06-renovaciones-dev --json
~~~

El resultado final debe tener checkOnly=false y pruebas satisfactorias. No se utiliza NoTestRun ni se ejecuta la batería P06. La respuesta inicial Queued no completa ninguna operación. La validación final 0Afg700000L9ei5CAB y el despliegue 0Afg700000L9H7ECAV finalizaron correctamente con 18 pruebas; el servicio cubre 276/282 líneas y ambos triggers 1/1.

La recuperación se realizó en una carpeta temporal separada:

~~~powershell
sf project retrieve start --manifest manifest/fase-2a.xml --target-org p06-renovaciones-dev --api-version 65.0 --output-dir tmp/fase-2a-retrieve-20261124 --wait 1 --json
~~~

En una ejecución posterior utilizar otra carpeta nueva. Comparar código y XML sin reemplazar las fuentes. Se contrastaron doce archivos: Salesforce omite el salto de línea final del código y explicita isLicensed=false en CustomPermission. No aparecieron diferencias funcionales. Las trece huellas del manifiesto y fuentes coinciden con la validación final.

El contraste posterior confirmó cero registros P07, grupos sin miembros, cuatro Permission Sets sin asignaciones y licencias sin cambios. Los usuarios y datos de SeeAllData=false no persistieron. El inventario acotado P06 no presenta diferencias. Detalles, fallos y límites en [STATUS.md](STATUS.md) y [FASE-2A.json](evidencias/FASE-2A.json).

Esta actualización acredita servicio y pruebas aisladas, no habilitación de funciones ordinarias. La asignación de usuarios, catálogo funcional, sesiones, LWC e informe corresponde a fases posteriores; no cargar dedicaciones mediante claves manuales.
