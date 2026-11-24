# Estado del proyecto

Fecha: 24/11/2026.

## Fase 1B: preparación y destino pendiente

Inspección del 24/11/2026 sobre 8b408a3978e83cc7d48c5df5ae62bbcec9e95dce. HEAD y la referencia local origin/main coinciden; rama main, remoto de P07 y árbol limpio al comenzar. No se cambió de referencia ni se repitió la inspección general de herramientas.

No se localizó un destino P07 expresamente identificado en documentación, configuración o alias locales. No se consultaron organizaciones anteriores. El bloqueo es el alta o identificación de una Developer Edition exclusiva y la intervención de cuenta necesaria para autenticarla; no es una carencia del modelo local.

La sesión de navegador propuesta posteriormente coincide con un destino de un proyecto anterior según el registro local de autenticación; se descartó sin consultarlo remotamente. La primera conexión Playwright agotó el tiempo de espera. Se resolvió para esta sesión con un puente temporal P07 en loopback, usando Playwright MCP 0.0.86 ya disponible localmente y la extensión existente de Chrome. Se comprobaron creación y control de una pestaña vacía y navegación al formulario oficial de alta. No se modificó la configuración global ni se instalaron herramientas. No se rellenó ni envió el formulario ni se aceptaron condiciones; abrir la página no acredita la creación de una organización.

| Área | Resultado actual |
|---|---|
| Destino e identidad | Pendientes; no se ha iniciado autenticación |
| API y permisos técnicos | API 65.0 configurada; compatibilidad remota no comprobada |
| Licencias e identidades funcionales | No consultadas; disponibilidad no acreditada |
| Validación remota | No ejecutada; sin recibo ni errores de Salesforce observados |
| Despliegue | No ejecutado; condicionado a destino confirmado y validación satisfactoria |
| Jerarquía y acceso instalado | No aplicados ni inspeccionados remotamente |
| Preparación local | 32 XML legibles, JSON y manifiesto revisados; exclusión de rutas privadas comprobada |
| CLI | Ayuda instalada de autenticación y despliegue consultada; dry-run y NoTestRun disponibles para el procedimiento previsto |
| Navegador | Puente temporal P07 operativo; pestaña independiente y formulario oficial abiertos mediante Playwright, sin consultar la organización anterior |

Se preparó [INSTALACION.md](INSTALACION.md) con autenticación sin destino predeterminado, verificación de identidad y capacidad, validación sin persistencia, despliegue condicionado, contraste de componentes y ajuste de jerarquía. Los comandos remotos de esa guía son procedimientos pendientes, no operaciones realizadas.

No hay cambios de metadatos respecto de la referencia revisada. Las modificaciones de esta preparación son documentales. No se han creado usuarios, datos, asignaciones, grupos remotos ni organizaciones; no se han instalado herramientas.

El siguiente paso imprescindible es disponer de la cuenta de la organización exclusiva y completar su autenticación local. Después se podrá verificar identidad, edición, API, permisos, licencias y ausencia de conflictos antes de validar y desplegar. La matriz funcional mantiene todos sus criterios pendientes.

## Antecedente: fase 1A, modelo declarativo y acceso de lectura

Metadatos locales preparados: tres objetos, doce campos personalizados, nueve validaciones, tres grupos públicos, dos Permission Sets de lectura y dos reglas de compartición. El manifiesto [fase-1a.xml](../manifest/fase-1a.xml) selecciona diez miembros de nivel superior; incluye los campos y validaciones de los objetos.

El modelo incorpora el total semanal mediante resumen de todas las líneas. Conserva claves únicas, fechas de lunes a domingo, límites por línea, coherencia parcial de identidad, restricción de eliminación de proyectos y ausencia de reparentado. El [modelo exacto](MODELO_DATOS.md) distingue estas defensas de las invariantes pendientes de servidor.

Los permisos no habilitan escritura ordinaria. La [solución de acceso](ACCESO.md) concreta un ámbito por propietarios y grupos, catálogo de lectura para participantes y un requisito de instalación pendiente: desactivar y verificar la jerarquía de los objetos antes de habilitar participantes. No se han asignado usuarios ni permisos.

## Continuidad de la base publicada

Al comenzar esta fase, HEAD y la referencia local origin/main coincidían en fdd1f9e10d20b88c20598c5e367c34b1a3d72936, en rama main y con remoto del proyecto registro-dedicacion-salesforce. No se forzó ninguna referencia ni se consultó el remoto para actualizarla.

Existía una modificación local en .forceignore que añadía exclusiones para jsconfig.json y .eslintrc.json. Se conservó íntegra. El estado histórico sin commits corresponde únicamente a la creación inicial de la base; no describe el punto de partida de esta fase.

## Comprobaciones locales

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

## Comprobaciones no ejecutadas

No hubo autenticación, consulta a organizaciones, compilación de Salesforce, despliegue, carga de registros ni sesiones funcionales. No hay Apex o LWC que justifique pruebas Apex o Jest en esta entrega. No se instalaron dependencias ni se modificaron herramientas globales.

La conversión comprueba ensamblado de formato y conservación de contenido; no valida restricciones de plataforma, expresiones de fórmula ni seguridad efectiva. La API, las relaciones, las fórmulas, el resumen y los permisos necesitan aceptación y pruebas en un destino P07 identificado.

## Siguiente paso al terminar fase 1A

Identificar el destino exclusivo P07 y preparar una fase de compilación y verificación del modelo y acceso. Antes de asignar funciones, comprobar edición, API, licencias, identidades, ajuste de jerarquía y pertenencias. No cargar dedicaciones mediante rutas provisionales que suplanten el protocolo pendiente.

Después se implementarán el servicio de lectura y guardado, las protecciones de escritura y sus pruebas; posteriormente, la cuadrícula LWC y el informe. El [contrato de arquitectura](ARQUITECTURA.md) y los [criterios AC-01 a AC-25](ACEPTACION.md) recogen rollback posterior a escritura, repetición de peticiones, resultado desconocido y lectura coherente como escenarios previstos, no ejecutados.

## Antecedentes conservados

La inspección inicial constató la ausencia de carpeta P07 y revisó las herramientas sin modificar organizaciones. Después se creó la base independiente con quince archivos: configuración DX, exclusiones, convenciones y documentación. En aquel momento el repositorio estaba recién inicializado, sin commits ni remoto; la base publicada posterior queda identificada arriba.

Las comprobaciones de aquella base cubrieron JSON, estructura, enlaces, formato y exclusiones. Los inventarios de herramientas de [ENVIRONMENT.md](ENVIRONMENT.md) corresponden a esa inspección y no se presentan como una revisión general repetida en fase 1A.
