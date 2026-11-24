# P07 — Registro semanal de dedicación a proyectos en Salesforce

Aplicación de demostración para registrar dedicación propia por proyecto y día en una cuadrícula semanal de lunes a domingo. Utiliza exclusivamente proyectos y registros ficticios.

## Estado

Base local creada el 24/11/2026: proyecto Salesforce DX, estructura de fuentes y documentación técnica inicial. La aplicación todavía no está implementada y no hay organización Salesforce vinculada. No se han realizado compilaciones, despliegues ni pruebas funcionales.

## Alcance V1

- Cuadrícula LWC con borrador local y guardado conjunto mediante Apex.
- Horas decimales en incrementos exactos de 0,25; persistencia en minutos enteros.
- Validación en servidor, unicidad y protección frente a pantallas desactualizadas.
- Consulta de coordinación limitada a su ámbito e informe operativo.
- Permisos proporcionados y comprobaciones automatizadas y funcionales.

No incluye nóminas, facturación, control horario con validez laboral, aprobaciones, cierres, capacidad prevista, cronómetros, fichajes, integraciones, procesos programados, funcionamiento sin conexión, producción ni datos reales.

## Estructura

| Ruta | Contenido |
|---|---|
| `force-app/main/default` | Directorio de fuentes, todavía sin componentes |
| `sfdx-project.json` | Proyecto DX; API 65.0 provisional |
| `docs/PROJECT_BRIEF.md` | Objetivos, reglas y límites |
| `docs/MODELO_DATOS.md` | Diseño inicial de entidades e invariantes |
| `docs/ARQUITECTURA.md` | Guardado, concurrencia y decisiones de implementación |
| `docs/ACCESO.md` | Matriz de acceso e identidades de prueba |
| `docs/ACEPTACION.md` | Criterios y evidencia pendiente |
| `docs/ENVIRONMENT.md` | Herramientas observadas y destino pendiente |
| `docs/STATUS.md` | Estado y siguientes entregas |

## Preparación

El repositorio es independiente de los proyectos anteriores. No contiene credenciales, alias de destino, usuarios ni datos importados de otras organizaciones.

La base no necesita paquetes npm. Las dependencias de pruebas LWC se seleccionarán y fijarán junto con su lockfile al implementar la interfaz. La versión API se contrastará con el destino P07 antes del primer despliegue; su presencia en la configuración no acredita compatibilidad remota.
