# Criterios de aceptación V1

Todos los criterios están pendientes. La base local no acredita funcionamiento de la aplicación.

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
| AC-09 | Atomicidad | Un error rechaza el conjunto sin cambios parciales |
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

## Evidencia requerida

Registrar fecha, versión de fuentes, entorno, identidad funcional, procedimiento, resultado y limitaciones. Conservar resultados fallidos relevantes y evitar secretos o datos reales.

Separar inspección estática, compilación, pruebas Apex, pruebas Jest y sesiones funcionales. Una repetición secuencial no demuestra concurrencia y una sesión administrativa no demuestra los permisos de miembro o coordinación.
