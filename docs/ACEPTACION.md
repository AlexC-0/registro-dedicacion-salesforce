# Criterios de aceptación V1

Fase 1A aporta el esquema y fase 1B acredita su instalación y el ajuste de jerarquía. La fase 2A añade evidencia Apex aislada del servicio y sus defensas. Los criterios completos de V1 siguen sujetos a los recorridos de interfaz, sesiones ordinarias y concurrencia que correspondan; no se equipara una prueba de servidor con aceptación funcional completa.

| ID | Escenario | Resultado exigido |
|---|---|---|
| AC-01 | Semana y fechas | Lunes a domingo, incluyendo cruces de mes y año, sin desplazamientos por UTC |
| AC-02 | Conversión | 0,25 horas equivale a 15 minutos; rechazo de valores inválidos sin redondeo |
| AC-03 | Límite diario | 1.440 minutos aceptados; exceso rechazado al sumar todos los proyectos |
| AC-04 | Futuro | Rechazo según fecha actual del usuario en Salesforce |
| AC-05 | Cero y vacío | Eliminación de una celda editable al guardar; celda omitida conservada |
| AC-06 | Proyecto inactivo | Histórico visible y no editable, incluida la eliminación |
| AC-07 | Cabecera única | Una semana por usuario y lunes, también ante creación simultánea |
| AC-08 | Línea única | Una línea por semana, proyecto y fecha, con clave canónica protegida |
| AC-09 | Atomicidad | Provocar un fallo después de al menos una escritura dentro del guardado; comprobar rollback de altas, cambios, bajas, resumen y revisión, sin cambios parciales |
| AC-10 | Revisión | Una pantalla antigua no sobrescribe cambios posteriores |
| AC-11 | Borrador | Errores y conflictos conservan cambios locales y no muestran éxito |
| AC-12 | Propiedad | Un miembro no modifica dedicación ajena ni suplanta usuario |
| AC-13 | Coordinación | Lectura en su ámbito y denegación de edición ajena |
| AC-14 | Fuera del ámbito | Sin acceso a dedicación ajena por interfaz, Apex, API o informe habilitados |
| AC-15 | Rutas alternativas | Restricciones respetadas o rutas denegadas, incluida eliminación y restauración |
| AC-16 | Informe operativo | Datos y totales correctos, con visibilidad ajustada al solicitante |
| AC-17 | Semana vacía | Borrar la última línea conserva cabecera y continuidad de revisión |
| AC-18 | Seguridad del esquema | Claves, revisión, usuario, fechas de identidad y propiedad protegidos |
| AC-19 | Cambio de semana | No se pierde el borrador sin una decisión explícita |
| AC-20 | Accesibilidad | Cuadrícula operable con teclado, etiquetas y errores comprensibles |
| AC-21 | Repetición de petición | Reenviar una petición ya confirmada no duplica registros ni reaplica cambios; conflicto o resultado reconciliado sin incremento adicional de revisión |
| AC-22 | Resultado desconocido | Simular pérdida de respuesta tras confirmar en servidor; conservar borrador, mostrar incertidumbre y reconciliar sin sobrescritura ni reenvío ciego |
| AC-23 | Lectura coherente | Con un guardado concurrente, revisión, líneas y total devueltos corresponden al mismo estado confirmado |
| AC-24 | Jerarquía y ámbito | Una identidad superior en jerarquía sin pertenencia no obtiene acceso; comprobar también retirada del grupo y ausencia de permisos amplios |
| AC-25 | Total semanal | Crear, modificar y eliminar líneas recalcula el resumen, incluyendo histórico inactivo; no confundir el total semanal con el máximo diario |

Estos escenarios no se ejecutaron en las fases 1A y 1B. La evidencia nueva de fase 2A se delimita a continuación.

## Evidencia requerida

Registrar fecha, versión de fuentes, entorno, identidad funcional, procedimiento, resultado y limitaciones. Conservar resultados fallidos relevantes y evitar secretos o datos reales.

Separar inspección estática, compilación, pruebas Apex, pruebas Jest y sesiones funcionales. Una repetición secuencial no demuestra concurrencia y una sesión administrativa no demuestra los permisos de miembro o coordinación.

## Cobertura de fase 2A

Los resultados finales, cobertura de código y huellas se conservan en [STATUS.md](STATUS.md) y [FASE-2A.json](evidencias/FASE-2A.json). Pruebas SeeAllData=false de P07_DedicacionServiceTest; datos y usuarios aislados, sin sesiones funcionales ni transacciones paralelas.

| Criterios | Evidencia de servidor | Pendiente o límite |
|---|---|---|
| AC-01, AC-04 | fechasYDuplicados y limiteProyectosYLecturaFutura: lunes, fuera de semana, cruce de año, futuro y editabilidad | Presentación local, interfaz, medianoche y otras zonas horarias |
| AC-02 | rechazoPrecisionAntesDml y cicloCanonicoYNoop: 0.25, precisión, formato y conversión sin redondeo | Conversión de entrada localizada en LWC |
| AC-03, AC-06 | limiteAgregadoYOmitidas e historicoInactivo: 1.440, exceso con celdas omitidas, histórico visible y no modificable | Interfaz y desactivación simultánea real |
| AC-05, AC-17 | cicloCanonicoYNoop: cero/vacío/null, omisión, cabecera vacía y continuidad | Presentación y borrador |
| AC-07, AC-08 | cicloCanonicoYNoop, fechasYDuplicados, aislamientoPorIdentidad: claves canónicas y duplicados de petición | Carrera real de creación; clasificación de errores de colisión simulada |
| AC-09 | rollbackAltaTrasDml y rollbackMixtoIncluyeRevision: escrituras observadas antes del fallo y restauración exacta | Sin concurrencia real ni pérdida de comunicación |
| AC-10, AC-21 | revisionYRepeticion: revisión antigua y repetición rechazadas sin cambios adicionales | Conflicto entre pantallas reales |
| AC-12, AC-14 | aislamientoPorIdentidad, reparentadoYAccesoAjeno, contratoEstricto: propiedad derivada, sin acceso ajeno USER_MODE ni suplantación | API con cada sesión, LWC e informe |
| AC-13 | coordinacionSoloLectura: compartición aislada Read, consulta y denegación de guardado | Regla real de ámbito, grupos y sesiones |
| AC-15, AC-18 | defensaCabeceraDirecta, defensaDetalleDirectoYRestauracion, reparentadoYAccesoAjeno y seguridadCrudFlsPermiso | Restauración de cabecera solo revisada en código; no se elude su bloqueo de borrado para fabricar un fixture |
| AC-23 | Lectura bajo bloqueo implementada; cicloCanonicoYNoop contrasta revisión, líneas y total secuenciales | Lectura y escritura realmente concurrentes |
| AC-25 | cicloCanonicoYNoop, limiteAgregadoYOmitidas, historicoInactivo y rollbackMixtoIncluyeRevision | Informe e interfaz; el máximo es diario, no semanal |
| AC-11, AC-16, AC-19, AC-20, AC-22 | Sin ejecución en fase 2A | Borrador, informe, cambio de semana, accesibilidad y resultado desconocido |
| AC-24 | Se conserva el ajuste instalado de fase 1B, sin volver a modificarlo | Jerarquía, retirada de miembros y sesiones ordinarias |

Las aserciones de CRUD, FLS y permisos personalizados son explícitas y se complementan con USER_MODE; runAs no se presenta como comprobación suficiente por sí solo. Ningún criterio de concurrencia real se cierra con llamadas consecutivas. Los límites de lectura y el protocolo quedan documentados para la fase LWC.

## Cobertura de fase 3A

Las pruebas Jest de p07DedicacionSemanal y modelo.js usan respuestas Apex simuladas como texto JSON y stubs explícitos de componentes base y diálogo. Su ejecución comprueba comportamiento del cliente, no permisos, persistencia ni concurrencia en Salesforce. Resultados y huellas en [STATUS.md](STATUS.md) y [FASE-3A.json](evidencias/FASE-3A.json).

| Criterios | Comprobación local de frontend | Límite pendiente |
|---|---|---|
| AC-01, AC-04 | Siete días, cruce de año, calendario, zona Salesforce simulada, corrección por hoy del servidor y días futuros bloqueados | Zona y reloj reales de cada sesión |
| AC-02, AC-03 | Coma/punto, cuartos exactos, rechazo sin redondear, suma diaria con omitidas e inactivas | Recorrido integrado con Apex y controles base reales |
| AC-05, AC-06, AC-17 | Vacío explícito, vuelta al original, histórico inactivo visible y solo lectura | Persistencia y resumen reales ya tienen evidencia Apex; falta sesión funcional |
| AC-10, AC-11, AC-21 | Error resuelto con ok=false conserva borrador; conflictos, selección y reaplicación explícita; doble envío impedido | Conflicto entre sesiones reales |
| AC-19 | Cambio de semana, actualización y descarte requieren decisión; cancelar conserva | Interacción real del diálogo y navegación fuera del componente |
| AC-20 | Tabla semántica, etiquetas por celda, región desplazable y foco de error comprobados en DOM | Teclado, lector de pantalla, contraste y controles reales |
| AC-22 | Transporte perdido, coincidencia posterior sin atribuir causalidad y reconciliación fallida | Pérdida de respuesta real después de confirmar en servidor |
| AC-23 | Respuestas y errores de lectura fuera de orden no reemplazan la selección vigente | Lectura/escritura concurrentes del backend |
| AC-25 | Totales por fila, día y semana del estado propuesto; totales indeterminados si hay texto inválido | Comparación integrada con resumen e informe reales |
| Límites del contrato | 140 celdas, veinte proyectos, 60.000 caracteres y revisión superior al entero seguro; sin fragmentar peticiones | Uso ordinario con catálogo y datos ficticios |

AC-07, AC-08, AC-09, AC-12 a AC-16, AC-18 y AC-24 no reciben nuevas pruebas de seguridad, transacción o informe por ejecutar Jest. Se mantiene la evidencia Apex anterior y sus límites. Ningún criterio completo de V1 se cierra únicamente con esta entrega de frontend.

## Evidencia funcional de fase 3B

Sesiones reales de A, B y coordinación mediante Login As, contrastadas con sus identidades privadas. No se empleó la cuenta administrativa para simular permisos funcionales.

| Criterios | Evidencia nueva | Límite conservado |
|---|---|---|
| AC-01, AC-02, AC-04 | Semana real del 23 al 29; coma decimal, minutos exactos, rechazo de 0,3 y días futuros deshabilitados | Otros husos, cambio de día y cruces temporales no ensayados aquí |
| AC-03, AC-11, AC-19 | Exceso diario rechazado con borrador; cancelación de los tres diálogos y descarte explícito | No se atribuye nueva prueba de carga ni pérdida de transporte |
| AC-05, AC-17 | Cero/vacío eliminan; omitidas conservadas; semana vacía con cabecera y revisión 2 | Sin purga ni restauración manual de registros |
| AC-06, AC-25 | Histórico desactivado después de dos guardados válidos, visible y bloqueado; total 105 contrastado con líneas y resumen | No se demuestra desactivación simultánea con un guardado |
| AC-08, AC-10, AC-21 | Sin claves activas duplicadas; pantalla antigua rechazada; selección inicial vacía, reaplicación explícita y una petición al doble envío | No acredita AC-07 de carrera de creación ni colisión simultánea |
| AC-09 | Petición con una celda válida y otra inválida rechazada sin cambios, antes de DML | El rollback después de escrituras sigue acreditado solo por Apex histórico |
| AC-12, AC-13, AC-14 | A y B guardan lo propio y no abren registros conocidos del otro; coordinación lee A y no B | No equivale a cobertura de todas las superficies de la plataforma |
| AC-15, AC-18 | Edición estándar denegada incluso sobre semana propia; coordinación también denegada por servicio | API externa no habilitada ni ensayada; no se ampliaron permisos |
| AC-24 | Retirada del grupo, recálculo, pérdida de acceso real y restauración comprobados | Superior jerárquico sin pertenencia no ensayado |
| AC-20 | Etiquetas, controles y diálogos reales; foco visible y paso con Tab; desbordamiento y desplazamiento programático | Navegación integral, flechas/rueda y lector de pantalla no acreditados |
| AC-16, AC-22, AC-23 | Sin evidencia nueva de informe, pérdida de respuesta tras commit o lectura/escritura simultáneas | Se mantienen pendientes |

El escenario de dos pantallas corresponde al mismo usuario y a guardados sucesivos con revisión antigua. La consulta de coordinación y las denegaciones se contrastaron también por URL directa, además de la lista con las dos semanas de A. Los resultados técnicos y funcionales se complementan; no se intercambian.

Para completar la revisión manual de accesibilidad: abrir una sesión funcional legítima, recorrer fecha, selector, celdas, errores y diálogos usando solo teclado; reducir la anchura, enfocar la región de cuadrícula y verificar acceso a columnas finales y totales mediante desplazamiento horizontal. Comprobar cancelación, retorno de foco y lectura de etiquetas y errores con lector de pantalla. Registrar resultados observados, sin dar por superadas las interacciones que la automatización no acreditó.

La fase no cierra V1. El informe operativo corresponde a la entrega posterior; los límites anteriores no se consideran aceptados por omisión. Véanse [STATUS.md](STATUS.md) y [FASE-3B.json](evidencias/FASE-3B.json).

## Evidencia y límites de fase 4

Se corrigió la pérdida del cero inicial al escribir un decimal en una celda vacía: el LWC conserva el texto en edición separado del borrador significativo. La regresión nueva falló antes de corregir; después, 49/49 pruebas Jest en dos suites satisfactorias. Validación 0Afg700000LIaTyCAL y despliegue 0Afg700000LIPVKCA5: Succeeded, un bundle, NoTestRun. Recuperación 09Sg700000bjuwnEAA: cinco archivos coincidentes. Sin cambios de Apex o modelo ni pruebas Apex nuevas.

| Criterio | Evidencia obtenida | Estado o límite |
|---|---|---|
| AC-16 | A=105, B=60 y coordinación=105 de A; tres, una y tres filas | Permiso retirado al terminar; habilitación pendiente |
| AC-06, AC-17 | Dos líneas históricas y 45 minutos; semana vacía sin detalle y cabecera conservada | Sin ensayo de desactivación concurrente |
| AC-14 | Informe P07 respeta ámbito; informe P06 denegado a las tres identidades | Informe público ajeno accesible; retiradas las tres asignaciones de informes |
| AC-20 | Teclado real: selectores, celdas, errores, acciones, diálogos, foco y desplazamiento horizontal | Cobertura básica realizada; lector de pantalla y auditoría completa pendientes |
| AC-25 | A: 1,75 h, cabecera e informe 105; B: 1 h, cabecera e informe 60; coordinación: cabecera de A e informe 105 | Cuadrícula propia de coordinación con 0 h, no representa A |

Las tres asignaciones de P07_InformesLectura se retiraron tras comprobar acceso a un informe público ajeno. Permanecen las seis asignaciones explícitas anteriores y RunReports=false en los conjuntos efectivos, incluido el perfil, de A, B y coordinación. El informe, la carpeta y la pestaña permanecen instalados; su ejecución funcional queda deshabilitada. No se modificaron carpetas de otros proyectos.

Las pruebas del informe se realizaron antes de retirar el permiso. La fase y V1 permanecen abiertas: resolver la habilitación compatible con el aislamiento. El borrador de teclado se descartó expresamente, con cero peticiones de guardado y datos/revisiones conservados. Login As restaurado a false y SecuritySettings sin diferencias.

No se rebajan criterios de concurrencia real, resultado desconocido, lectura/escritura simultánea ni jerarquía. [FASE-4.json](evidencias/FASE-4.json) distingue instalación, corrección, pruebas locales, sesiones reales y capacidad final.

## Regresión de descarte antes de lectura fallida

AC-11, AC-19 y AC-25 incorporan evidencia local adicional: con 60 minutos confirmados y texto «2», aceptar el descarte y fallar la lectura deja celda «1», total «1 h», sin cambios pendientes y Guardar deshabilitado. Cuatro regresiones reproducen el defecto antes de corregir, cubriendo actualización y cambio de semana con rechazo de promesa y ok=false. Tres casos de cancelación conservan texto y borrador; otro contrasta cancelar y aceptar la adopción del estado actual.

La batería final supera 57 pruebas, incluida escritura decimal carácter a carácter. Son simulaciones Jest; no una nueva demostración funcional en Salesforce ni cierre de accesibilidad. El bundle se validó, desplegó y recuperó por separado. Fase 4 y V1 siguen abiertas. Véase [FASE-4-ACTUALIZACION-FALLIDA.json](evidencias/FASE-4-ACTUALIZACION-FALLIDA.json).

## Cobertura de la consulta propia de fase 4B

AC-16 conserva su resultado exigido y utiliza ahora P07_InformeService y p07InformeDedicacion como mecanismo operativo. El informe estándar continúa instalado sin habilitación. No se reduce el requisito de aislamiento ni se acepta por omisión.

| Criterios | Evidencia nueva | Límite pendiente |
|---|---|---|
| AC-13, AC-14, AC-18 | Apex aislado: ámbito, operación, CRUD/FLS y relaciones; tres asignaciones de clase/pestaña sin RunReports | Sesiones ordinarias, puerta de clase de Lightning y denegación real de informes ajenos |
| AC-06, AC-16, AC-17, AC-25 | Histórico, vacío, papelera y totales probados; consulta completa o error de volumen | No es prueba de rendimiento ni demostración integrada de las tres identidades |
| AC-20 | Jest: etiquetas, controles, foco y tablas; filtros y datos coherentes | Teclado real de la nueva vista, controles base y lector de pantalla |
| AC-11, AC-19 | Las 57 regresiones existentes vuelven a pasar junto a 35 pruebas nuevas | No se repitieron guardados reales ni se modificó la cuadrícula |

Validación y despliegue finalizados con 26/26 pruebas Apex; no equivalen a aceptación funcional. Continúan pendientes concurrencia real, resultado desconocido, lectura simultánea coherente y superior jerárquico sin pertenencia, además de los límites anteriores. Fase 4 y V1 abiertas. Resultados y preservación en [FASE-4B.md](FASE-4B.md) y [FASE-4B.json](evidencias/FASE-4B.json).
