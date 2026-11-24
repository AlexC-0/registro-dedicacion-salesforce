# Definición del proyecto

## Objetivo

Registrar y consultar dedicación ficticia por persona, proyecto y día mediante una vista semanal. La interfaz mantiene un borrador y confirma el conjunto en una transacción de servidor.

## Reglas funcionales

- Semana de lunes a domingo con fechas Date; una cabecera por usuario y lunes.
- Una línea por semana, proyecto y fecha.
- Entrada en horas decimales con incrementos de 0,25. Persistencia en minutos enteros y sin redondeo silencioso.
- Suma máxima de 1.440 minutos por día, incluyendo todos los proyectos de la persona.
- Cero o vacío retira la dedicación existente al confirmar el conjunto; una celda sin cambios conserva su valor.
- La fecha actual se determina en Salesforce según la zona horaria del usuario. No se admite dedicación futura.
- El histórico de proyectos inactivos se muestra y no se edita. Tampoco se elimina mediante cero o vacío: la prohibición de edición prevalece.
- El miembro escribe únicamente su dedicación. Coordinación consulta solo dentro de su ámbito y no edita registros ajenos.
- No existen estados, cierres semanales ni aprobaciones.
- Una revisión desactualizada rechaza todo el guardado y conserva el borrador en pantalla.
- Todas las rutas de escritura expuestas deben respetar las invariantes del servidor.

## Límites V1

Quedan fuera nóminas, facturación, validez laboral, horas extraordinarias, aprobaciones, cierres, planificación de capacidad, cronómetros, fichajes, integraciones, comunicaciones externas, programación, funcionamiento sin conexión, producción y datos reales.

No se presupone disponibilidad de licencias, usuarios ni una organización. No se incorporan servicios de pago ni permisos administrativos a funciones ordinarias.

## Decisiones iniciales

La revisión pertenece a la cabecera semanal. Las líneas dependen de ella para propiedad y acceso. Los nombres técnicos, tipos y tamaños de los doce campos están definidos en los metadatos de fase 1A y descritos en [MODELO_DATOS.md](MODELO_DATOS.md). Su aceptación e instalación remotas están comprobadas en fase 1B. Fase 2A aporta el servicio y pruebas Apex aisladas de guardado y protección; fase 3A aporta la cuadrícula y pruebas locales del cliente. Siguen pendientes la demostración integrada, el informe, las sesiones ordinarias y la concurrencia real.

El borrado de una celda significa eliminar su línea, no eliminar la cabecera. Mantener la cabecera evita reiniciar la revisión cuando una semana queda vacía. El catálogo de proyectos no se administra desde la cuadrícula.
