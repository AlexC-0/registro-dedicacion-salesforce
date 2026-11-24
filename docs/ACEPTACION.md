# Criterios de aceptación V1

Todos los criterios funcionales siguen pendientes. Fase 1A aporta el esquema; fase 1B acredita validación, despliegue, contraste de definiciones y ajuste de jerarquía en el destino compartido con P06. No se crearon registros ni identidades funcionales y no se realizaron sesiones ordinarias. La aceptación de metadatos y el ajuste de configuración no acreditan comportamiento funcional.

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

Estos escenarios están previstos y no se han ejecutado en las fases 1A y 1B.

## Evidencia requerida

Registrar fecha, versión de fuentes, entorno, identidad funcional, procedimiento, resultado y limitaciones. Conservar resultados fallidos relevantes y evitar secretos o datos reales.

Separar inspección estática, compilación, pruebas Apex, pruebas Jest y sesiones funcionales. Una repetición secuencial no demuestra concurrencia y una sesión administrativa no demuestra los permisos de miembro o coordinación.
